From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 09/26] libnsm: Add RPC construction helper functions
Date: Thu, 15 Oct 2009 11:21:19 -0400
Message-ID: <E06D8131-9057-4E6B-98EF-B87A876D786C@oracle.com>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net> <20091013145546.2424.83816.stgit@matisse.1015granger.net> <20091014172154.GA21332@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, chris.mason@oracle.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:42558 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbZJOPWg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Oct 2009 11:22:36 -0400
In-Reply-To: <20091014172154.GA21332@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 14, 2009, at 1:21 PM, J. Bruce Fields wrote:

> On Tue, Oct 13, 2009 at 10:55:46AM -0400, Chuck Lever wrote:
>> To manage concurrency, both statd and sm-notify construct raw RPC
>> requests in socket buffers, and use a minimal request scheduler
>> to send these requests and manage replies.  Both statd and sm-notify
>> open code the RPC request construction.
>
> Possibly dumb question: so we have to do this just because none of the
> rpc libraries support asynchronous calls?

Not dumb at all:  yes, statd (and sm-notify) set up their own  
asynchronous RPC call schedulers because the client-side RPC APIs  
provide only synchronous services.  statd also wires its NLM downcall  
scheduler into its RPC server loop (my_svc_run).  It's kind of a giant  
kludge, but it is simple, and allows statd and sm-notify to avoid a  
lot of forking.

The schedulers as they stand prevent us from using connection-oriented  
transports to deliver SM_NOTIFY calls and NLM downcalls.  In the  
downcall case, this is why statd broke when lockd started only a TCP  
listener (fixed in recent kernels).

NLM downcalls could be implemented with a synchronous RPC call in the  
server's SM_NOTIFY request handler instead.  But if the kernel isn't  
responding, statd's NSM listener would be made unavailable until the  
downcall completed.  statd's listener queue would have to take up that  
slack, I think.  This, and the fact that this scheduler code used to  
be shared with SM_NOTIFY delivery, is why we still have the NLM  
downcall scheduler.

> Would it be possible to add an asynchronous interface to tirpc some  
> day?

I think Sun's solution was to embrace pthreads in TI-RPC (and continue  
to support only a synchronous client API).  That would be a choice for  
Linux as well.

For an application like statd that has to use the standard glibc RPC  
implementation if TI-RPC isn't available, pthreads would likely be a  
non-starter.

> --b.
>
>>
>> Introduce helper functions that can construct and send raw
>> NSMPROC_NOTIFY, NLM downcalls, and portmapper calls over a datagram
>> socket, and receive and parse their replies.  Support for IPv6 and
>> RPCB_GETADDR is featured.  This code (and the IPv6 support it
>> introduces) can now be shared by statd and sm-notify, eliminating
>> code and bug duplication.
>>
>> This implementation is based on what's in utils/statd/rmtcall.c now,
>> but is wrapped up in a nice API and includes extra error checking.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> support/include/nsm.h   |   25 ++
>> support/nsm/Makefile.am |    2
>> support/nsm/rpc.c       |  505 +++++++++++++++++++++++++++++++++++++ 
>> ++++++++++
>> 3 files changed, 531 insertions(+), 1 deletions(-)
>> create mode 100644 support/nsm/rpc.c
>>
>> diff --git a/support/include/nsm.h b/support/include/nsm.h
>> index 594f0d9..96b23f2 100644
>> --- a/support/include/nsm.h
>> +++ b/support/include/nsm.h
>> @@ -59,4 +59,29 @@ extern int	nsm_insert_monitored_host(const char  
>> *hostname,
>> extern void	nsm_delete_monitored_host(const char *hostname);
>> extern void	nsm_delete_notified_host(const char *hostname);
>>
>> +/* rpc.c */
>> +
>> +#define NSM_MAXMSGSIZE	(2048 / sizeof(uint32_t))
>> +
>> +extern uint32_t nsm_xmit_getport(const int sock,
>> +			const struct sockaddr_in *sin,
>> +			const unsigned long program,
>> +			const unsigned long version);
>> +extern uint32_t nsm_xmit_getaddr(const int sock,
>> +			const struct sockaddr_in6 *sin6,
>> +			const rpcprog_t program, const rpcvers_t version);
>> +extern uint32_t nsm_xmit_rpcbind(const int sock, const struct  
>> sockaddr *sap,
>> +			const rpcprog_t program, const rpcvers_t version);
>> +extern uint32_t nsm_xmit_notify(const int sock, const struct  
>> sockaddr *sap,
>> +			const socklen_t salen, const rpcprog_t program,
>> +			const char *mon_name, const int state);
>> +extern uint32_t nsm_xmit_nlmcall(const int sock, const struct  
>> sockaddr *sap,
>> +			const socklen_t salen, const struct mon *mon,
>> +			const int state);
>> +extern uint32_t nsm_parse_reply(XDR *xdrs);
>> +extern unsigned long
>> +		nsm_recv_getport(XDR *xdrs);
>> +extern uint16_t nsm_recv_getaddr(XDR *xdrs);
>> +extern uint16_t nsm_recv_rpcbind(const int family, XDR *xdrs);
>> +
>> #endif	/* !_NFS_UTILS_SUPPORT_NSM_H */
>> diff --git a/support/nsm/Makefile.am b/support/nsm/Makefile.am
>> index e359a43..2038e68 100644
>> --- a/support/nsm/Makefile.am
>> +++ b/support/nsm/Makefile.am
>> @@ -10,7 +10,7 @@ GENFILES	= $(GENFILES_CLNT) $(GENFILES_SVC) $ 
>> (GENFILES_XDR) $(GENFILES_H)
>> EXTRA_DIST	= sm_inter.x
>>
>> noinst_LIBRARIES = libnsm.a
>> -libnsm_a_SOURCES = $(GENFILES) file.c
>> +libnsm_a_SOURCES = $(GENFILES) file.c rpc.c
>>
>> BUILT_SOURCES = $(GENFILES)
>>
>> diff --git a/support/nsm/rpc.c b/support/nsm/rpc.c
>> new file mode 100644
>> index 0000000..a9d3a62
>> --- /dev/null
>> +++ b/support/nsm/rpc.c
>> @@ -0,0 +1,505 @@
>> +/*
>> + * Copyright 2009 Oracle.  All rights reserved.
>> + *
>> + * This file is part of nfs-utils.
>> + *
>> + * nfs-utils is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License as  
>> published by
>> + * the Free Software Foundation; either version 2 of the License, or
>> + * (at your option) any later version.
>> + *
>> + * nfs-utils is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> + * GNU General Public License for more details.
>> + *
>> + * You should have received a copy of the GNU General Public License
>> + * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/ 
>> >.
>> + */
>> +
>> +/*
>> + * NSM for Linux.
>> + *
>> + * Instead of using ONC or TI RPC library calls, statd constructs
>> + * RPC calls directly in socket buffers.  This allows a single
>> + * socket to be concurrently shared among several different RPC
>> + * programs and versions using a simple RPC request dispatcher.
>> + *
>> + * This file contains the details of RPC header and call
>> + * construction and reply parsing, and a method for creating a
>> + * socket for use with these functions.
>> + */
>> +
>> +#ifdef HAVE_CONFIG_H
>> +#include <config.h>
>> +#endif	/* HAVE_CONFIG_H */
>> +
>> +#include <time.h>
>> +#include <netdb.h>
>> +#include <string.h>
>> +#include <unistd.h>
>> +#include <fcntl.h>
>> +
>> +#include <sys/types.h>
>> +#include <sys/socket.h>
>> +#include <sys/time.h>
>> +#include <netinet/in.h>
>> +#include <net/if.h>
>> +#include <arpa/inet.h>
>> +
>> +#include <rpc/rpc.h>
>> +#include <rpc/pmap_prot.h>
>> +#include <rpc/pmap_rmt.h>
>> +
>> +#ifdef HAVE_LIBTIRPC
>> +#include <netconfig.h>
>> +#include <rpc/rpcb_prot.h>
>> +#endif	/* HAVE_LIBTIRPC */
>> +
>> +#include "xlog.h"
>> +#include "nfsrpc.h"
>> +#include "nsm.h"
>> +#include "sm_inter.h"
>> +
>> +/*
>> + * Returns a fresh XID appropriate for RPC over UDP -- never zero.
>> + */
>> +static uint32_t
>> +nsm_next_xid(void)
>> +{
>> +	static uint32_t nsm_xid = 0;
>> +	struct timeval now;
>> +
>> +	if (nsm_xid == 0) {
>> +		(void)gettimeofday(&now, NULL);
>> +		nsm_xid = getpid() ^ now.tv_sec ^ now.tv_usec;
>> +	}
>> +
>> +	return nsm_xid++;
>> +}
>> +
>> +/*
>> + * Select a fresh XID and construct an RPC header in @mesg.
>> + * Always use AUTH_NULL credentials and verifiers.
>> + *
>> + * Returns the new XID.
>> + */
>> +static uint32_t
>> +nsm_init_rpc_header(const rpcprog_t program, const rpcvers_t  
>> version,
>> +			const rpcproc_t procedure, struct rpc_msg *mesg)
>> +{
>> +	struct call_body *cb = &mesg->rm_call;
>> +
>> +	mesg->rm_xid = nsm_next_xid();
>> +	mesg->rm_direction = CALL;
>> +
>> +	cb->cb_rpcvers = RPC_MSG_VERSION;
>> +	cb->cb_prog = program;
>> +	cb->cb_vers = version;
>> +	cb->cb_proc = procedure;
>> +
>> +	cb->cb_cred.oa_flavor = AUTH_NULL;
>> +	cb->cb_cred.oa_base = (caddr_t) NULL;
>> +	cb->cb_cred.oa_length = 0;
>> +	cb->cb_verf.oa_flavor = AUTH_NULL;
>> +	cb->cb_verf.oa_base = (caddr_t) NULL;
>> +	cb->cb_verf.oa_length = 0;
>> +
>> +	return mesg->rm_xid;
>> +}
>> +
>> +/*
>> + * Send a completed RPC call on a socket.
>> + *
>> + * Returns 1 if all the bytes were sent successfully; otherwise
>> + * zero if any error occurred.
>> + */
>> +static int
>> +nsm_rpc_sendto(const int sock, const struct sockaddr *sap,
>> +			const socklen_t salen, XDR *xdrs, void *buf)
>> +{
>> +	const unsigned int len = xdr_getpos(xdrs);
>> +	ssize_t err;
>> +
>> +	err = sendto(sock, buf, len, 0, sap, salen);
>> +	if ((err < 0) || ((size_t)err != len)) {
>> +		xlog(L_ERROR, "%s: sendto failed: %m", __func__);
>> +		return 0;
>> +	}
>> +	return 1;
>> +}
>> +
>> +/**
>> + * nsm_xmit_getport - post a PMAP_GETPORT call on a socket  
>> descriptor
>> + * @sock: datagram socket descriptor
>> + * @sin: pointer to AF_INET socket address of server
>> + * @program: RPC program number to query
>> + * @version: RPC version number to query
>> + *
>> + * Send a PMAP_GETPORT call to the portmap daemon at @sin using
>> + * socket descriptor @sock.  This request queries the RPC program
>> + * [program, version, IPPROTO_UDP].
>> + *
>> + * NB: PMAP_GETPORT works only for IPv4 hosts.  This implementation
>> + *     works only over UDP, and queries only UDP registrations.
>> + *
>> + * Returns the XID of the call, or zero if an error occurred.
>> + */
>> +uint32_t
>> +nsm_xmit_getport(const int sock, const struct sockaddr_in *sin,
>> +			const unsigned long program,
>> +			const unsigned long version)
>> +{
>> +	struct pmap parms = {
>> +		.pm_prog	= program,
>> +		.pm_vers	= version,
>> +		.pm_prot	= IPPROTO_UDP,
>> +		.pm_port	= 0,
>> +	};
>> +	unsigned int msgbuf[NSM_MAXMSGSIZE];
>> +	struct rpc_msg mesg;
>> +	uint32_t xid;
>> +	int err = 0;
>> +	XDR xdr;
>> +
>> +	xlog(D_CALL, "Sending PMAP_GETPORT for %u, %u, udp", program,  
>> version);
>> +
>> +	xid = nsm_init_rpc_header(PMAPPROG, PMAPVERS,
>> +					(rpcproc_t)PMAPPROC_GETPORT, &mesg);
>> +
>> +	xdrmem_create(&xdr, (caddr_t)msgbuf, sizeof(msgbuf), XDR_ENCODE);
>> +
>> +	if (xdr_callmsg(&xdr, &mesg) && xdr_pmap(&xdr, &parms)) {
>> +		struct sockaddr_in addr = *sin;
>> +
>> +		addr.sin_port = htons((uint16_t)PMAPPORT);
>> +		err = nsm_rpc_sendto(sock, (struct sockaddr *)&addr,
>> +					(socklen_t)sizeof(addr), &xdr, msgbuf);
>> +	} else
>> +		xlog(L_ERROR, "%s: can't encode PMAP_GETPORT call", __func__);
>> +
>> +	xdr_destroy(&xdr);
>> +
>> +	return err? xid : 0;
>> +}
>> +
>> +/**
>> + * nsm_xmit_getaddr - post an RPCB_GETADDR call on a socket  
>> descriptor
>> + * @sock: datagram socket descriptor
>> + * @sin: pointer to AF_INET6 socket address of server
>> + * @program: RPC program number to query
>> + * @version: RPC version number to query
>> + *
>> + * Send an RPCB_GETADDR call to the rpcbind daemon at @sap using
>> + * socket descriptor @sock.  This request queries the RPC program
>> + * [program, version, "udp6"].
>> + *
>> + * NB: RPCB_GETADDR works for both IPv4 and IPv6 hosts.  This
>> + *     implementation works only over UDP and AF_INET6, and queries
>> + *     only "udp6" registrations.
>> + *
>> + * Returns the XID of the call, or zero if an error occurred.
>> + */
>> +#ifdef HAVE_LIBTIRPC
>> +uint32_t
>> +nsm_xmit_getaddr(const int sock, const struct sockaddr_in6 *sin6,
>> +			const rpcprog_t program, const rpcvers_t version)
>> +{
>> +	struct rpcb parms = {
>> +		.r_prog		= program,
>> +		.r_vers		= version,
>> +		.r_netid	= "udp6",
>> +		.r_owner	= "",
>> +	};
>> +	unsigned int msgbuf[NSM_MAXMSGSIZE];
>> +	struct rpc_msg mesg;
>> +	uint32_t xid;
>> +	int err = 0;
>> +	XDR xdr;
>> +
>> +	xlog(D_CALL, "Sending RPCB_GETADDR for %u, %u, udp6", program,  
>> version);
>> +
>> +	xid = nsm_init_rpc_header(RPCBPROG, RPCBVERS,
>> +					(rpcproc_t)RPCBPROC_GETADDR, &mesg);
>> +
>> +	parms.r_addr = nfs_sockaddr2universal((struct sockaddr *)sin6);
>> +	if (parms.r_addr == NULL) {
>> +		xlog(L_ERROR, "%s: can't encode socket address", __func__);
>> +		return 0;
>> +	}
>> +
>> +	xdrmem_create(&xdr, (caddr_t)msgbuf, sizeof(msgbuf), XDR_ENCODE);
>> +
>> +	if (xdr_callmsg(&xdr, &mesg) && xdr_rpcb(&xdr, &parms)) {
>> +		struct sockaddr_in6 addr = *sin6;
>> +
>> +		addr.sin6_port = htons((uint16_t)PMAPPORT);
>> +		err = nsm_rpc_sendto(sock, (struct sockaddr *)&addr,
>> +					(socklen_t)sizeof(addr), &xdr, msgbuf);
>> +	} else
>> +		xlog(L_ERROR, "%s: can't encode RPCB_GETADDR call", __func__);
>> +
>> +	xdr_destroy(&xdr);
>> +	free(parms.r_addr);
>> +
>> +	return err? xid : 0;
>> +}
>> +#else	/* !HAVE_LIBTIRPC */
>> +uint32_t
>> +nsm_xmit_getaddr(const int sock __attribute__((unused)),
>> +			const struct sockaddr_in6 *sin6 __attribute__((unused)),
>> +			const rpcprog_t program __attribute__((unused)),
>> +			const rpcvers_t version __attribute__((unused)))
>> +{
>> +	return 0;
>> +}
>> +#endif	/* !HAVE_LIBTIRPC */
>> +
>> +/**
>> + * nsm_xmit_rpcbind - post an rpcbind request
>> + * @sock: datagram socket descriptor
>> + * @sap: pointer to socket address of server
>> + * @program: RPC program number to query
>> + * @version: RPC version number to query
>> + *
>> + * Send an rpcbind query to the rpcbind daemon at @sap using
>> + * socket descriptor @sock.
>> + *
>> + * NB: This implementation works only over UDP, but can query IPv4  
>> or IPv6
>> + *     hosts.  It queries only UDP registrations.
>> + *
>> + * Returns the XID of the call, or zero if an error occurred.
>> + */
>> +uint32_t
>> +nsm_xmit_rpcbind(const int sock, const struct sockaddr *sap,
>> +			const rpcprog_t program, const rpcvers_t version)
>> +{
>> +	switch (sap->sa_family) {
>> +	case AF_INET:
>> +		return nsm_xmit_getport(sock, (const struct sockaddr_in *)sap,
>> +						program, version);
>> +	case AF_INET6:
>> +		return nsm_xmit_getaddr(sock, (const struct sockaddr_in6 *)sap,
>> +						program, version);
>> +	}
>> +	return 0;
>> +}
>> +
>> +/**
>> + * nsm_xmit_notify - post an NSMPROC_NOTIFY call on a socket  
>> descriptor
>> + * @sock: datagram socket descriptor
>> + * @sap: pointer to socket address of peer to notify (port already  
>> filled in)
>> + * @salen: length of socket address
>> + * @program: RPC program number to use
>> + * @mon_name: mon_name of local peer (ie the rebooting system)
>> + * @state: state of local peer
>> + *
>> + * Send an NSMPROC_NOTIFY call to the peer at @sap using socket  
>> descriptor @sock.
>> + * This request notifies the peer that we have rebooted.
>> + *
>> + * NB: This implementation works only over UDP, but supports both  
>> AF_INET
>> + *     and AF_INET6.
>> + *
>> + * Returns the XID of the call, or zero if an error occurred.
>> + */
>> +uint32_t
>> +nsm_xmit_notify(const int sock, const struct sockaddr *sap,
>> +			const socklen_t salen, const rpcprog_t program,
>> +			const char *mon_name, const int state)
>> +{
>> +	struct stat_chge state_change = {
>> +		.mon_name	= strdup(mon_name),
>> +		.state		= state,
>> +	};
>> +	unsigned int msgbuf[NSM_MAXMSGSIZE];
>> +	struct rpc_msg mesg;
>> +	uint32_t xid;
>> +	int err = 0;
>> +	XDR xdr;
>> +
>> +	if (state_change.mon_name == NULL) {
>> +		xlog(L_ERROR, "%s: no memory", __func__);
>> +		return 0;
>> +	}
>> +
>> +	xlog(D_CALL, "Sending SM_NOTIFY for %s", mon_name);
>> +
>> +	xid = nsm_init_rpc_header(program, SM_VERS, SM_NOTIFY, &mesg);
>> +
>> +	xdrmem_create(&xdr, (caddr_t)msgbuf, sizeof(msgbuf), XDR_ENCODE);
>> +
>> +	if (xdr_callmsg(&xdr, &mesg) && xdr_stat_chge(&xdr,  
>> &state_change)) {
>> +		err = nsm_rpc_sendto(sock, sap, salen, &xdr, msgbuf);
>> +	} else
>> +		xlog(L_ERROR, "%s: can't encode NSMPROC_NOTIFY call",
>> +				__func__);
>> +
>> +	xdr_destroy(&xdr);
>> +	free(state_change.mon_name);
>> +
>> +	return err? xid : 0;
>> +}
>> +
>> +/**
>> + * nsm_xmit_nlmcall - post an unnamed call to local NLM on a  
>> socket descriptor
>> + * @sock: datagram socket descriptor
>> + * @sap: address/port of NLM service to contact
>> + * @salen: size of @sap
>> + * @mon: callback data defining RPC call to make
>> + * @state: state of rebooting host
>> + *
>> + * Send an unnamed call (previously requested via NSMPROC_MON) to  
>> the
>> + * specified local UDP-based RPC service using socket descriptor  
>> @sock.
>> + *
>> + * NB: This implementation works only over UDP, but supports both  
>> AF_INET
>> + *     and AF_INET6.
>> + *
>> + * Returns the XID of the call, or zero if an error occurred.
>> + */
>> +uint32_t
>> +nsm_xmit_nlmcall(const int sock, const struct sockaddr *sap,
>> +			const socklen_t salen, const struct mon *mon,
>> +			const int state)
>> +{
>> +	struct status new_status = {
>> +		.mon_name	= mon->mon_id.mon_name,
>> +		.state		= state,
>> +	};
>> +	const struct my_id *id = &mon->mon_id.my_id;
>> +	unsigned int msgbuf[NSM_MAXMSGSIZE];
>> +	struct rpc_msg mesg;
>> +	uint32_t xid;
>> +	int err = 0;
>> +	XDR xdr;
>> +
>> +	xlog(D_CALL, "Sending NLM downcall for %s", mon->mon_id.mon_name);
>> +
>> +	xid = nsm_init_rpc_header(id->my_prog, id->my_vers, id->my_proc,  
>> &mesg);
>> +
>> +	memcpy(&new_status.priv, &mon->priv, sizeof(new_status.priv));
>> +	xdrmem_create(&xdr, (caddr_t)msgbuf, sizeof(msgbuf), XDR_ENCODE);
>> +
>> +	if (xdr_callmsg(&xdr, &mesg) && xdr_status(&xdr, &new_status))
>> +		err = nsm_rpc_sendto(sock, sap, salen, &xdr, msgbuf);
>> +	else
>> +		xlog(L_ERROR, "%s: can't encode NLM downcall", __func__);
>> +
>> +	xdr_destroy(&xdr);
>> +
>> +	return err? xid : 0;
>> +}
>> +
>> +/**
>> + * nsm_parse_reply - parse and validate the header in an RPC reply
>> + * @xdrs: pointer to XDR
>> + *
>> + * Returns the XID of the reply, or zero if an error occurred.
>> + */
>> +uint32_t
>> +nsm_parse_reply(XDR *xdrs)
>> +{
>> +	struct rpc_msg mesg = {
>> +		.rm_reply.rp_acpt.ar_results.proc	= (xdrproc_t)xdr_void,
>> +	};
>> +
>> +	if (!xdr_replymsg(xdrs, &mesg)) {
>> +		xlog(L_ERROR, "%s: can't decode RPC reply", __func__);
>> +		return 0;
>> +	}
>> +
>> +	if (mesg.rm_reply.rp_stat != 0) {
>> +		xlog(L_ERROR, "%s: [0x%x] RPC status %d",
>> +			__func__, mesg.rm_xid, mesg.rm_reply.rp_stat);
>> +		return 0;
>> +	}
>> +
>> +	if (mesg.rm_reply.rp_acpt.ar_stat != 0) {
>> +		xlog(L_ERROR, "%s: [0x%x] RPC accept status %d",
>> +			__func__, mesg.rm_xid, mesg.rm_reply.rp_acpt.ar_stat);
>> +		return 0;
>> +	}
>> +
>> +	return mesg.rm_xid;
>> +}
>> +
>> +/**
>> + * nsm_recv_getport - parse PMAP_GETPORT reply
>> + * @xdrs: pointer to XDR
>> + *
>> + * Returns the port number from the RPC reply, or zero
>> + * if an error occurred.
>> + */
>> +unsigned long
>> +nsm_recv_getport(XDR *xdrs)
>> +{
>> +	unsigned long port = 0;
>> +
>> +	if (!xdr_u_long(xdrs, &port))
>> +		xlog(L_ERROR, "%s: can't decode pmap reply",
>> +			__func__);
>> +	if (port > UINT16_MAX) {
>> +		xlog(L_ERROR, "%s: bad port number",
>> +			__func__);
>> +		port = 0;
>> +	}
>> +
>> +	xlog(D_CALL, "Received PMAP_GETPORT result: %lu", port);
>> +	return port;
>> +}
>> +
>> +/**
>> + * nsm_recv_getaddr - parse RPCB_GETADDR reply
>> + * @xdrs: pointer to XDR
>> + *
>> + * Returns the port number from the RPC reply, or zero
>> + * if an error occurred.
>> + */
>> +uint16_t
>> +nsm_recv_getaddr(XDR *xdrs)
>> +{
>> +	int port;
>> +	char *uaddr = NULL;
>> +
>> +	if (!xdr_wrapstring(xdrs, &uaddr))
>> +		xlog(L_ERROR, "%s: can't decode rpcb reply",
>> +			__func__);
>> +
>> +	if ((uaddr == NULL) || (uaddr[0] == '\0')) {
>> +		xlog(D_CALL, "Received RPCB_GETADDR result: "
>> +				"program not registered");
>> +		return 0;
>> +	}
>> +
>> +	port = nfs_universal2port(uaddr);
>> +
>> +	xdr_free((xdrproc_t)xdr_wrapstring, (char *)&uaddr);
>> +
>> +	if (port < 0 || port > UINT16_MAX) {
>> +		xlog(L_ERROR, "%s: bad port number",
>> +			__func__);
>> +		return 0;
>> +	}
>> +
>> +	xlog(D_CALL, "Received RPCB_GETADDR result: %d", port);
>> +	return port;
>> +}
>> +
>> +/**
>> + * nsm_recv_rpcbind - parse rpcbind reply
>> + * @af: address family of reply
>> + * @xdrs: pointer to XDR
>> + *
>> + * Returns the port number from the RPC reply, or zero
>> + * if an error occurred.
>> + */
>> +uint16_t
>> +nsm_recv_rpcbind(const int family, XDR *xdrs)
>> +{
>> +	switch (family) {
>> +	case AF_INET:
>> +		return nsm_recv_getport(xdrs);
>> +	case AF_INET6:
>> +		return nsm_recv_getaddr(xdrs);
>> +	}
>> +	return 0;
>> +}
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



