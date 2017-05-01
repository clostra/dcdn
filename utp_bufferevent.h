#ifndef __UTP_BUFFEREVENT_H__
#define __UTP_BUFFEREVENT_H__

#include "network.h"


uint64 utp_on_read(utp_callback_arguments *a);
uint64 utp_on_state_change(utp_callback_arguments *a);

void utp_connect_tcp(event_base *base, utp_socket *s, const struct sockaddr *address, socklen_t address_len);
void tcp_connect_utp(event_base *base, utp_context* utpctx, int fd, const struct sockaddr *address, socklen_t address_len);

#endif // __UTP_BUFFEREVENT_H__
