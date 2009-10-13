From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/26] statd: Update rmtcall.c
Date: Tue, 13 Oct 2009 10:56:06 -0400
Message-ID: <20091013145605.2424.21866.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:43123 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758063AbZJMO5H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:57:07 -0400
Received: from rgminet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEuPAE030466
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:56:26 GMT
Received: from acsmt353.oracle.com (acsmt353.oracle.com [141.146.40.153])
	by rgminet13.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DCEido005800
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:56:59 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the open code to construct NLM downcalls and PMAP_GETPORT RPC
requests with calls to our new library routines.

This clean up removes redundant code in rmtcall.c, and enables the
possibility of making NLM downcalls via IPv6 transports.  We won't
support that for a long while, however.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/rmtcall.c |  143 +++++++++----------------------------------------
 1 files changed, 26 insertions(+), 117 deletions(-)

diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
index 5700fc7..139b1de 100644
--- a/utils/statd/rmtcall.c
+++ b/utils/statd/rmtcall.c
@@ -45,13 +45,15 @@
 #include "notlist.h"
 #include "ha-callout.h"
 
+#include "nsm.h"
+#include "nfsrpc.h"
+
 #if SIZEOF_SOCKLEN_T - 0 == 0
 #define socklen_t int
 #endif
 
 #define MAXMSGSIZE	(2048 / sizeof(unsigned int))
 
-static unsigned long	xid = 0;	/* RPC XID counter */
 static int		sockfd = -1;	/* notify socket */
 
 /*
@@ -103,80 +105,15 @@ statd_get_socket(void)
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
 recv_rply(struct sockaddr_in *sin, u_long *portp)
 {
-	unsigned int		msgbuf[MAXMSGSIZE], msglen;
-	struct rpc_msg		mesg;
+	unsigned int		msgbuf[NSM_MAXMSGSIZE];
+	ssize_t			msglen;
 	notify_list		*lp = NULL;
 	XDR			xdr, *xdrs = &xdr;
 	socklen_t		alen = sizeof(*sin);
+	uint32_t		xid;
 
 	/* Receive message */
 	if ((msglen = recvfrom(sockfd, msgbuf, sizeof(msgbuf), 0,
@@ -187,36 +124,15 @@ recv_rply(struct sockaddr_in *sin, u_long *portp)
 
 	/* Create XDR object for decoding buffer */
 	xdrmem_create(xdrs, (caddr_t) msgbuf, msglen, XDR_DECODE);
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
+	xid = nsm_parse_reply(xdrs);
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
 		if (lp->addr.s_addr != sin->sin_addr.s_addr) {
 			char addr [18];
@@ -227,15 +143,8 @@ recv_rply(struct sockaddr_in *sin, u_long *portp)
 				"expected %s, got %s", __func__,
 				addr, inet_ntoa(sin->sin_addr));
 		}
-		if (lp->port == 0) {
-			if (!xdr_u_long(xdrs, portp)) {
-				xlog_warn("%s: [%s] can't decode reply body!",
-					__func__,
-					inet_ntoa(sin->sin_addr));
-				lp = NULL;
-				goto done;
-			}
-		}
+		if (lp->port == 0)
+			*portp = nsm_recv_rpcbind(AF_INET, xdrs);
 		break;
 	}
 
@@ -251,11 +160,7 @@ static int
 process_entry(notify_list *lp)
 {
 	struct sockaddr_in	sin;
-	struct status		new_status;
-	xdrproc_t		func;
-	void			*objp;
-	u_int32_t		proc, vers, prog;
-/* 	__u32			proc, vers, prog; */
+	struct sockaddr		*sap = (struct sockaddr *)&sin;
 
 	if (NL_TIMES(lp) == 0) {
 		xlog(D_GENERAL, "%s: Cannot notify %s, giving up",
@@ -268,21 +173,25 @@ process_entry(notify_list *lp)
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
+	if (nfs_get_port(sap) == 0)
+		lp->xid = nsm_xmit_rpcbind(sockfd, sap,
+				NL_MY_PROG(lp), NL_MY_VERS(lp));
+	else {
+		struct mon mon;
+
+		memcpy(mon.priv, NL_PRIV(lp), SM_PRIV_SIZE);
+		mon.mon_id.mon_name = NL_MON_NAME(lp);
+		mon.mon_id.my_id.my_prog = NL_MY_PROG(lp);
+		mon.mon_id.my_id.my_vers = NL_MY_VERS(lp);
+		mon.mon_id.my_id.my_proc = NL_MY_PROC(lp);
 
-	lp->xid = xmit_call(&sin, prog, vers, proc, func, objp);
+		lp->xid = nsm_xmit_nlmcall(sockfd, sap, sizeof(sin),
+						&mon, NL_STATE(lp));
+	}
 	if (!lp->xid) {
 		xlog_warn("%s: failed to notify port %d",
 				__func__, ntohs(lp->port));

