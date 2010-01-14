From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/24] statd: Update rmtcall.c
Date: Thu, 14 Jan 2010 12:29:15 -0500
Message-ID: <20100114172915.26079.41958.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:35989 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757380Ab0ANRbJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:09 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the open code to construct NLM downcalls and PMAP_GETPORT RPC
requests with calls to our new library routines.

This clean up removes redundant code in rmtcall.c, and enables the
possibility of making NLM downcalls via IPv6 transports.  We won't
support that for a long while, however.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/notlist.h |    4 +
 utils/statd/rmtcall.c |  181 ++++++++++++-------------------------------------
 2 files changed, 47 insertions(+), 138 deletions(-)

diff --git a/utils/statd/notlist.h b/utils/statd/notlist.h
index 664c9d8..f915ae1 100644
--- a/utils/statd/notlist.h
+++ b/utils/statd/notlist.h
@@ -13,14 +13,14 @@
 struct notify_list {
   mon			mon;	/* Big honkin' NSM structure. */
   struct in_addr	addr;	/* IP address for callback. */
-  unsigned short	port;	/* port number for callback */
+  in_port_t		port;	/* port number for callback */
   short int		times;	/* Counter used for various things. */
   int			state;	/* For storing notified state for callbacks. */
   char			*dns_name; /* used for matching incoming
 				    * NOTIFY requests */
   struct notify_list	*next;	/* Linked list forward pointer. */
   struct notify_list	*prev;	/* Linked list backward pointer. */
-  u_int32_t		xid;	/* XID of MS_NOTIFY RPC call */
+  uint32_t		xid;	/* XID of MS_NOTIFY RPC call */
   time_t		when;	/* notify: timeout for re-xmit */
 };
 
diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
index 5700fc7..1a97684 100644
--- a/utils/statd/rmtcall.c
+++ b/utils/statd/rmtcall.c
@@ -37,21 +37,19 @@
 #include <netdb.h>
 #include <string.h>
 #include <unistd.h>
-#ifdef HAVE_IFADDRS_H
-#include <ifaddrs.h>
-#endif /* HAVE_IFADDRS_H */
+
 #include "sm_inter.h"
 #include "statd.h"
 #include "notlist.h"
 #include "ha-callout.h"
 
+#include "nsm.h"
+#include "nfsrpc.h"
+
 #if SIZEOF_SOCKLEN_T - 0 == 0
 #define socklen_t int
 #endif
 
-#define MAXMSGSIZE	(2048 / sizeof(unsigned int))
-
-static unsigned long	xid = 0;	/* RPC XID counter */
 static int		sockfd = -1;	/* notify socket */
 
 /*
@@ -103,144 +101,53 @@ statd_get_socket(void)
 	return sockfd;
 }
 
-static unsigned long
-xmit_call(struct sockaddr_in *sin,
-	  u_int32_t prog, u_int32_t vers, u_int32_t proc,
-	  xdrproc_t func, void *obj)
-/* 		__u32 prog, __u32 vers, __u32 proc, xdrproc_t func, void *obj) */
-{
-	unsigned int		msgbuf[MAXMSGSIZE], msglen;
-	struct rpc_msg		mesg;
-	struct pmap		pmap;
-	XDR			xdr, *xdrs = &xdr;
-	int			err;
-
-	if (!xid)
-		xid = getpid() + time(NULL);
-
-	mesg.rm_xid = ++xid;
-	mesg.rm_direction = CALL;
-	mesg.rm_call.cb_rpcvers = 2;
-	if (sin->sin_port == 0) {
-		sin->sin_port = htons(PMAPPORT);
-		mesg.rm_call.cb_prog = PMAPPROG;
-		mesg.rm_call.cb_vers = PMAPVERS;
-		mesg.rm_call.cb_proc = PMAPPROC_GETPORT;
-		pmap.pm_prog = prog;
-		pmap.pm_vers = vers;
-		pmap.pm_prot = IPPROTO_UDP;
-		pmap.pm_port = 0;
-		func = (xdrproc_t) xdr_pmap;
-		obj  = &pmap;
-	} else {
-		mesg.rm_call.cb_prog = prog;
-		mesg.rm_call.cb_vers = vers;
-		mesg.rm_call.cb_proc = proc;
-	}
-	mesg.rm_call.cb_cred.oa_flavor = AUTH_NULL;
-	mesg.rm_call.cb_cred.oa_base = (caddr_t) NULL;
-	mesg.rm_call.cb_cred.oa_length = 0;
-	mesg.rm_call.cb_verf.oa_flavor = AUTH_NULL;
-	mesg.rm_call.cb_verf.oa_base = (caddr_t) NULL;
-	mesg.rm_call.cb_verf.oa_length = 0;
-
-	/* Create XDR memory object for encoding */
-	xdrmem_create(xdrs, (caddr_t) msgbuf, sizeof(msgbuf), XDR_ENCODE);
-
-	/* Encode the RPC header part and payload */
-	if (!xdr_callmsg(xdrs, &mesg) || !func(xdrs, obj)) {
-		xlog(D_GENERAL, "%s: can't encode RPC message!", __func__);
-		xdr_destroy(xdrs);
-		return 0;
-	}
-
-	/* Get overall length of datagram */
-	msglen = xdr_getpos(xdrs);
-
-	if ((err = sendto(sockfd, msgbuf, msglen, 0,
-			(struct sockaddr *) sin, sizeof(*sin))) < 0) {
-		xlog_warn("%s: sendto failed: %m", __func__);
-	} else if (err != msglen) {
-		xlog_warn("%s: short write: %m", __func__);
-	}
-
-	xdr_destroy(xdrs);
-
-	return err == msglen? xid : 0;
-}
-
 static notify_list *
-recv_rply(struct sockaddr_in *sin, u_long *portp)
+recv_rply(u_long *portp)
 {
-	unsigned int		msgbuf[MAXMSGSIZE], msglen;
-	struct rpc_msg		mesg;
+	char			msgbuf[NSM_MAXMSGSIZE];
+	ssize_t			msglen;
 	notify_list		*lp = NULL;
-	XDR			xdr, *xdrs = &xdr;
-	socklen_t		alen = sizeof(*sin);
+	XDR			xdr;
+	struct sockaddr_in	sin;
+	socklen_t		alen = (socklen_t)sizeof(sin);
+	uint32_t		xid;
 
-	/* Receive message */
-	if ((msglen = recvfrom(sockfd, msgbuf, sizeof(msgbuf), 0,
-			(struct sockaddr *) sin, &alen)) < 0) {
+	memset(msgbuf, 0, sizeof(msgbuf));
+	msglen = recvfrom(sockfd, msgbuf, sizeof(msgbuf), 0,
+				(struct sockaddr *)(char *)&sin, &alen);
+	if (msglen == (ssize_t)-1) {
 		xlog_warn("%s: recvfrom failed: %m", __func__);
 		return NULL;
 	}
 
-	/* Create XDR object for decoding buffer */
-	xdrmem_create(xdrs, (caddr_t) msgbuf, msglen, XDR_DECODE);
-
-	memset(&mesg, 0, sizeof(mesg));
-	mesg.rm_reply.rp_acpt.ar_results.where = NULL;
-	mesg.rm_reply.rp_acpt.ar_results.proc = (xdrproc_t) xdr_void;
-
-	if (!xdr_replymsg(xdrs, &mesg)) {
-		xlog_warn("%s: can't decode RPC message!", __func__);
-		goto done;
-	}
-
-	if (mesg.rm_reply.rp_stat != 0) {
-		xlog_warn("%s: [%s] RPC status %d", 
-				__func__,
-				inet_ntoa(sin->sin_addr),
-				mesg.rm_reply.rp_stat);
-		goto done;
-	}
-	if (mesg.rm_reply.rp_acpt.ar_stat != 0) {
-		xlog_warn("%s: [%s] RPC status %d",
-				__func__,
-				inet_ntoa(sin->sin_addr),
-				mesg.rm_reply.rp_acpt.ar_stat);
+	memset(&xdr, 0, sizeof(xdr));
+	xdrmem_create(&xdr, msgbuf, (unsigned int)msglen, XDR_DECODE);
+	xid = nsm_parse_reply(&xdr);
+	if (xid == 0)
 		goto done;
-	}
 
 	for (lp = notify; lp != NULL; lp = lp->next) {
 		/* LH - this was a bug... it should have been checking
 		 * the xid from the response message from the client,
 		 * not the static, internal xid */
-		if (lp->xid != mesg.rm_xid)
+		if (lp->xid != xid)
 			continue;
-		if (lp->addr.s_addr != sin->sin_addr.s_addr) {
+		if (lp->addr.s_addr != sin.sin_addr.s_addr) {
 			char addr [18];
 			strncpy (addr, inet_ntoa(lp->addr),
 				 sizeof (addr) - 1);
 			addr [sizeof (addr) - 1] = '\0';
 			xlog_warn("%s: address mismatch: "
 				"expected %s, got %s", __func__,
-				addr, inet_ntoa(sin->sin_addr));
-		}
-		if (lp->port == 0) {
-			if (!xdr_u_long(xdrs, portp)) {
-				xlog_warn("%s: [%s] can't decode reply body!",
-					__func__,
-					inet_ntoa(sin->sin_addr));
-				lp = NULL;
-				goto done;
-			}
+				addr, inet_ntoa(sin.sin_addr));
 		}
+		if (lp->port == 0)
+			*portp = nsm_recv_getport(&xdr);
 		break;
 	}
 
 done:
-	xdr_destroy(xdrs);
+	xdr_destroy(&xdr);
 	return lp;
 }
 
@@ -251,11 +158,6 @@ static int
 process_entry(notify_list *lp)
 {
 	struct sockaddr_in	sin;
-	struct status		new_status;
-	xdrproc_t		func;
-	void			*objp;
-	u_int32_t		proc, vers, prog;
-/* 	__u32			proc, vers, prog; */
 
 	if (NL_TIMES(lp) == 0) {
 		xlog(D_GENERAL, "%s: Cannot notify %s, giving up",
@@ -268,22 +170,30 @@ process_entry(notify_list *lp)
 	sin.sin_port   = lp->port;
 	/* LH - moved address into switch */
 
-	prog = NL_MY_PROG(lp);
-	vers = NL_MY_VERS(lp);
-	proc = NL_MY_PROC(lp);
-
 	/* __FORCE__ loopback for callbacks to lockd ... */
 	/* Just in case we somehow ignored it thus far */
 	sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
 
-	func = (xdrproc_t) xdr_status;
-	objp = &new_status;
-	new_status.mon_name = NL_MON_NAME(lp);
-	new_status.state    = NL_STATE(lp);
-	memcpy(new_status.priv, NL_PRIV(lp), SM_PRIV_SIZE);
+	if (sin.sin_port == 0)
+		lp->xid = nsm_xmit_getport(sockfd, &sin,
+					(rpcprog_t)NL_MY_PROG(lp),
+					(rpcvers_t)NL_MY_VERS(lp));
+	else {
+		struct mon m;
+
+		memcpy(m.priv, NL_PRIV(lp), SM_PRIV_SIZE);
 
-	lp->xid = xmit_call(&sin, prog, vers, proc, func, objp);
-	if (!lp->xid) {
+		m.mon_id.mon_name = NL_MON_NAME(lp);
+		m.mon_id.my_id.my_name = NULL;
+		m.mon_id.my_id.my_prog = NL_MY_PROG(lp);
+		m.mon_id.my_id.my_vers = NL_MY_VERS(lp);
+		m.mon_id.my_id.my_proc = NL_MY_PROC(lp);
+
+		lp->xid = nsm_xmit_nlmcall(sockfd,
+				(struct sockaddr *)(char *)&sin,
+				(socklen_t)sizeof(sin), &m, NL_STATE(lp));
+	}
+	if (lp->xid == 0) {
 		xlog_warn("%s: failed to notify port %d",
 				__func__, ntohs(lp->port));
 	}
@@ -298,14 +208,13 @@ process_entry(notify_list *lp)
 int
 process_reply(FD_SET_TYPE *rfds)
 {
-	struct sockaddr_in	sin;
 	notify_list		*lp;
 	u_long			port;
 
 	if (sockfd == -1 || !FD_ISSET(sockfd, rfds))
 		return 0;
 
-	if (!(lp = recv_rply(&sin, &port)))
+	if (!(lp = recv_rply(&port)))
 		return 1;
 
 	if (lp->port == 0) {

