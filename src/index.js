'use strict';

import 'native-promise-only';
import _ from 'lodash';
import axios from 'axios';
import c3 from 'c3';
import moment from 'moment';
const endpoint = config.endpoint;
const apiKey = (config.hasOwnProperty('apiKey')) ? config.apiKey: null;
import riot from 'riot';
import './tags/projects.tag';
import './tags/errors.tag';
import './tags/overview.tag';

const req = axios.create({
    baseURL: endpoint,
    timeout: 120000,
    headers: {'x-api-key': apiKey}
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
                return -1 * parseInt(error.count, 10);
            });
            riot.mount('app', 'errors', {
                project: project,
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

riot.route('/projects/*/*', (project, message) => {
    const start = moment().startOf('month').format();
    const end = moment().endOf('month').format();

    req.get('/projects/' + project + '/errors/' + message, {
        params: {
            start: start,
            end: end
        }
    })
        .then((res) => {
            const omitted = _.omit(res.data.meta, [
                'project',
                'message',
                'type',
                'backtrace',
                'timestamp',
                'event',
                'notifications'
            ]);
            riot.mount('app', 'overview', {
                project: res.data.meta.project,
                message: res.data.meta.message,
                type: res.data.meta.type,
                meta: omitted,
                backtrace: res.data.meta.backtrace,
                timestamp: res.data.meta.timestamp,
                items: res.data.timeline.errors,
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

riot.route(() => {
    location.href = 'index.html#/projects';
});

riot.route.start(true);
