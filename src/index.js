'use strict';

import 'native-promise-only';
import _ from 'lodash';
import axios from 'axios';
import c3 from 'c3';
import moment from 'moment';
import woothee from 'woothee';
const endpoint = config.endpoint;
const masterApiKey = (config.hasOwnProperty('masterApiKey')) ? config.masterApiKey: null;
import riot from 'riot';
import './tags/projects.tag';
import './tags/errors.tag';
import './tags/overview.tag';
import './tags/occurrence.tag';

const req = axios.create({
    baseURL: endpoint,
    timeout: 120000,
    headers: {'x-api-key': masterApiKey}
});

riot.route('/projects', () => {
    req.get('/projects')
        .then((res) => {
            riot.mount('app', 'projects', {
                projects: res.data.projects,
                req: req
            });
        })
        .catch((err) => {
            throw new Error(err);
        });
});

riot.route('/projects/*', (project) => {
    const q = riot.route.query();
    let params = {};
    if (q.hasOwnProperty('status')) {
        params.status = q.status.replace(/#.+$/,'');
    }
    req.get('/projects/' + project + '/errors', {
        params: params
    })
        .then((res) => {
            const sorted = _.sortBy(res.data.errors, (error) => {
                return -1 * moment(error.lastUpdated).valueOf();
            });
            riot.mount('app', 'errors', {
                project: decodeURIComponent(project),
                errors: sorted,
                moment: moment,
                req: req,
                config: config
            });
        })
        .catch((err) => {
            throw new Error(err);
        });
});

riot.route('/projects/*/errors/*', (project, message) => {
    const q = riot.route.query();
    let start = moment().startOf('month').format();
    let end = moment().endOf('month').format();

    if (q.hasOwnProperty('start') && q.start && q.hasOwnProperty('end') && q.end) {
        start = moment(q.start.replace(/#.+$/,''), 'YYYY-MM-DDTHH:mm:ss').format();
        end = moment(q.end.replace(/#.+$/,''), 'YYYY-MM-DDTHH:mm:ss').format();
    }

    Promise.all([
        req.get('/projects/' + project + '/errors/' + message, {
            params: {
                start: start,
                end: end
            }
        }),
        req.get('/projects/' + project + '/errors/' + message + '/occurrences', {
            params: {
                after: null,
                limit: 10
            }
        })
    ])
        .then((res) => {
            const error = res[0];
            const occurrences = res[1].data.occurrences;
            const omitted = _.omit(error.data.meta, [
                'project',
                'message',
                'type',
                'backtrace',
                'timestamp',
                'event',
                'notifications',
                'reversedUnixtime'
            ]);

            riot.mount('app', 'overview', {
                req: req,
                project: error.data.meta.project,
                message: error.data.meta.message,
                truncatedMessage: message,
                type: error.data.meta.type,
                meta: omitted,
                backtrace: error.data.meta.backtrace,
                timestamp: error.data.meta.timestamp,
                occurrences: occurrences,
                woothee: woothee,
                items: error.data.timeline.errors,
                c3: c3,
                _: _,
                moment: moment,
                start: start,
                end: end
            });
        })
        .catch((err) => {
            throw new Error(err);
        });
});

riot.route('/projects/*/errors/*/occurrences/*', (project, message, reversedUnixtime) => {
    req.get('/projects/' + project + '/errors/' + message + '/occurrences/' + reversedUnixtime, {
    })
        .then((res) => {
            const error = res;
            const omitted = _.omit(error.data.meta, [
                'project',
                'message',
                'type',
                'backtrace',
                'timestamp',
                'event',
                'notifications',
                'reversedUnixtime'
            ]);

            riot.mount('app', 'occurrence', {
                project: error.data.meta.project,
                message: error.data.meta.message,
                truncatedMessage: message,
                type: error.data.meta.type,
                meta: omitted,
                backtrace: error.data.meta.backtrace,
                _: _,
                moment: moment
            });
        })
        .catch((err) => {
            throw new Error(err);
        });
});


riot.route(() => {
    location.href = 'index.html#/projects';
});

riot.route.start(true);
