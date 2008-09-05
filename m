From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/19] rpc.statd: Use __func__ in dprintf
Date: Fri, 05 Sep 2008 17:08:38 -0400
Message-ID: <20080905210838.10001.80910.stgit@manray.1015granger.net>
References: <20080905210054.10001.8518.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41650 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326AbYIEVJG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 17:09:06 -0400
In-Reply-To: <20080905210054.10001.8518.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The named function in many of the debugging messages in
utils/statd/rmtcall.c is out of date.  To prevent this from happening
in the future, replace these with __func__.

Also, note() and dprintf() do not require a terminating '\n' in their
format string.  So make all invocations consistent.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/rmtcall.c |   50 ++++++++++++++++++++++++++-----------------------
 1 files changed, 27 insertions(+), 23 deletions(-)

diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
index eb1919a..8240529 100644
--- a/utils/statd/rmtcall.c
+++ b/utils/statd/rmtcall.c
@@ -73,7 +73,7 @@ statd_get_socket(void)
 		if (sockfd >= 0) close(sockfd);
 
 		if ((sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
-			note(N_CRIT, "Can't create socket: %m");
+			note(N_CRIT, "%s: Can't create socket: %m", __func__);
 			return -1;
 		}
 
@@ -83,8 +83,8 @@ statd_get_socket(void)
 		sin.sin_addr.s_addr = INADDR_ANY;
 
 		if (bindresvport(sockfd, &sin) < 0) {
-			dprintf(N_WARNING,
-				"process_hosts: can't bind to reserved port\n");
+			dprintf(N_WARNING, "%s: can't bind to reserved port",
+					__func__);
 			break;
 		}
 		se = getservbyport(sin.sin_port, "udp");
@@ -142,7 +142,7 @@ xmit_call(int sockfd, struct sockaddr_in *sin,
 
 	/* Encode the RPC header part and payload */
 	if (!xdr_callmsg(xdrs, &mesg) || !func(xdrs, obj)) {
-		dprintf(N_WARNING, "xmit_mesg: can't encode RPC message!\n");
+		dprintf(N_WARNING, "%s: can't encode RPC message!", __func__);
 		xdr_destroy(xdrs);
 		return 0;
 	}
@@ -152,9 +152,9 @@ xmit_call(int sockfd, struct sockaddr_in *sin,
 
 	if ((err = sendto(sockfd, msgbuf, msglen, 0,
 			(struct sockaddr *) sin, sizeof(*sin))) < 0) {
-		dprintf(N_WARNING, "xmit_mesg: sendto failed: %m");
+		dprintf(N_WARNING, "%s: sendto failed: %m", __func__);
 	} else if (err != msglen) {
-		dprintf(N_WARNING, "xmit_mesg: short write: %m\n");
+		dprintf(N_WARNING, "%s: short write: %m", __func__);
 	}
 
 	xdr_destroy(xdrs);
@@ -174,7 +174,7 @@ recv_rply(int sockfd, struct sockaddr_in *sin, u_long *portp)
 	/* Receive message */
 	if ((msglen = recvfrom(sockfd, msgbuf, sizeof(msgbuf), 0,
 			(struct sockaddr *) sin, &alen)) < 0) {
-		dprintf(N_WARNING, "recv_rply: recvfrom failed: %m");
+		dprintf(N_WARNING, "%s: recvfrom failed: %m", __func__);
 		return NULL;
 	}
 
@@ -186,18 +186,20 @@ recv_rply(int sockfd, struct sockaddr_in *sin, u_long *portp)
 	mesg.rm_reply.rp_acpt.ar_results.proc = (xdrproc_t) xdr_void;
 
 	if (!xdr_replymsg(xdrs, &mesg)) {
-		note(N_WARNING, "recv_rply: can't decode RPC message!\n");
+		note(N_WARNING, "%s: can't decode RPC message!", __func__);
 		goto done;
 	}
 
 	if (mesg.rm_reply.rp_stat != 0) {
-		note(N_WARNING, "recv_rply: [%s] RPC status %d\n", 
+		note(N_WARNING, "%s: [%s] RPC status %d", 
+				__func__,
 				inet_ntoa(sin->sin_addr),
 				mesg.rm_reply.rp_stat);
 		goto done;
 	}
 	if (mesg.rm_reply.rp_acpt.ar_stat != 0) {
-		note(N_WARNING, "recv_rply: [%s] RPC status %d\n",
+		note(N_WARNING, "%s: [%s] RPC status %d",
+				__func__,
 				inet_ntoa(sin->sin_addr),
 				mesg.rm_reply.rp_acpt.ar_stat);
 		goto done;
@@ -214,14 +216,15 @@ recv_rply(int sockfd, struct sockaddr_in *sin, u_long *portp)
 			strncpy (addr, inet_ntoa(lp->addr),
 				 sizeof (addr) - 1);
 			addr [sizeof (addr) - 1] = '\0';
-			dprintf(N_WARNING, "address mismatch: "
-				"expected %s, got %s\n",
+			dprintf(N_WARNING, "%s: address mismatch: "
+				"expected %s, got %s", __func__,
 				addr, inet_ntoa(sin->sin_addr));
 		}
 		if (lp->port == 0) {
 			if (!xdr_u_long(xdrs, portp)) {
-				note(N_WARNING, "recv_rply: [%s] "
-					"can't decode reply body!\n",
+				note(N_WARNING,
+					"%s: [%s] can't decode reply body!",
+					__func__,
 					inet_ntoa(sin->sin_addr));
 				lp = NULL;
 				goto done;
@@ -249,8 +252,8 @@ process_entry(int sockfd, notify_list *lp)
 /* 	__u32			proc, vers, prog; */
 
 	if (NL_TIMES(lp) == 0) {
-		note(N_DEBUG, "Cannot notify %s, giving up.\n",
-					inet_ntoa(NL_ADDR(lp)));
+		note(N_DEBUG, "%s: Cannot notify %s, giving up.",
+				__func__, inet_ntoa(NL_ADDR(lp)));
 		return 0;
 	}
 
@@ -275,8 +278,8 @@ process_entry(int sockfd, notify_list *lp)
 
 	lp->xid = xmit_call(sockfd, &sin, prog, vers, proc, func, objp);
 	if (!lp->xid) {
-		note(N_WARNING, "notify_host: failed to notify port %d\n",
-				ntohs(lp->port));
+		note(N_WARNING, "%s: failed to notify port %d",
+				__func__, ntohs(lp->port));
 	}
 	NL_TIMES(lp) -= 1;
 
@@ -308,11 +311,11 @@ process_reply(FD_SET_TYPE *rfds)
 			nlist_insert_timer(&notify, lp);
 			return 1;
 		}
-		note(N_WARNING, "recv_rply: [%s] service %d not registered",
-			inet_ntoa(lp->addr), NL_MY_PROG(lp));
+		note(N_WARNING, "%s: [%s] service %d not registered",
+			__func__, inet_ntoa(lp->addr), NL_MY_PROG(lp));
 	} else {
-		dprintf(N_DEBUG, "Callback to %s (for %d) succeeded.",
-			NL_MY_NAME(lp), NL_MON_NAME(lp));
+		dprintf(N_DEBUG, "%s: Callback to %s (for %d) succeeded.",
+			__func__, NL_MY_NAME(lp), NL_MON_NAME(lp));
 	}
 	nlist_free(&notify, lp);
 	return 1;
@@ -340,7 +343,8 @@ process_notify_list(void)
 			nlist_insert_timer(&notify, entry);
 		} else {
 			note(N_ERROR,
-				"Can't callback %s (%d,%d), giving up.",
+				"%s: Can't callback %s (%d,%d), giving up.",
+					__func__,
 					NL_MY_NAME(entry),
 					NL_MY_PROG(entry),
 					NL_MY_VERS(entry));

