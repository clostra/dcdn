#include <stdlib.h>
#include <assert.h>

#include "timer.h"


void timer_free(timer *t)
{
    assert(!evtimer_pending(&t->event, NULL));
    Block_release(t->cb);
    free(t);
}

void evtimer_callback(evutil_socket_t fd, short events, void *arg)
{
    timer *t = (timer*)arg;
    t->cb();
    if (!(event_get_events(&t->event) & EV_PERSIST)) {
        timer_free(t);
    }
}

void timer_cancel(timer *t)
{
    evtimer_del(&t->event);
    timer_free(t);
}

timer* timer_create(network *n, uint64_t timeout_ms, short events, callback cb)
{
    struct timeval timeout;
    timeout.tv_sec = timeout_ms / 1000;
    timeout.tv_usec = (timeout_ms % 1000) * 1000;
    timer *t = alloc(timer);
    t->cb = Block_copy(cb);
    if (!event_assign(&t->event, n->evbase, -1, events, evtimer_callback, t)) {
        evtimer_add(&t->event, &timeout);
        return t;
    }
    timer_free(t);
    return NULL;
}

timer* timer_start(network *n, uint64_t timeout_ms, callback cb)
{
    return timer_create(n, timeout_ms, 0, cb);
}

timer* timer_repeating(network *n, uint64_t timeout_ms, callback cb)
{
    return timer_create(n, timeout_ms, EV_PERSIST, cb);
}