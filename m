From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] NLM: Always start both UDP and TCP listeners
Date: Fri, 03 Oct 2008 17:15:23 -0400
Message-ID: <20081003211523.9870.79228.stgit@ingres.1015granger.net>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:55253 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbYJCVPw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 17:15:52 -0400
In-Reply-To: <20081003211305.9870.6835.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 24e36663, which first appeared in 2.6.19, changed lockd so that
the client side starts a UDP listener only if there is a UDP NFSv2/v3
mount.  Its description notes:

    This... means that lockd will *not* listen on UDP if the only
    mounts are TCP mount (and nfsd hasn't started).

    The latter is the only one that concerns me at all - I don't know
    if this might be a problem with some servers.

Unfortunately it is a problem for Linux itself.  The rpc.statd daemon
on Linux uses UDP for contacting the local lockd, no matter which
protocol is used for NFS mounts.  Without a local lockd UDP listener,
NFSv2/v3 lock recovery from Linux NFS clients always fails.

Revert parts of commit 24e36663 so lockd_up() always starts both
listeners.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Neil Brown <neilb@suse.de>
---

 fs/lockd/svc.c |   37 +++++++++++++++++++------------------
 1 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 1553fec..583d30d 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -203,25 +203,28 @@ lockd(void *vrqstp)
 }
 
 /*
- * Make any sockets that are needed but not present.
- * If nlm_udpport or nlm_tcpport were set as module
- * options, make those sockets unconditionally
+ * Ensure there are active UDP and TCP listeners for lockd.
+ *
+ * Even if we have only TCP NFS mounts and/or TCP NFSDs, some
+ * local services (such as rpc.statd) still require UDP, and
+ * some NFS servers do not yet support NLM over TCP.
+ *
+ * Returns zero if all listeners are available; otherwise a
+ * negative errno value is returned.
  */
-static int make_socks(struct svc_serv *serv, int proto)
+static int make_socks(struct svc_serv *serv)
 {
 	static int warned;
 	struct svc_xprt *xprt;
 	int err = 0;
 
-	if (proto == IPPROTO_UDP || nlm_udpport) {
-		xprt = svc_find_xprt(serv, "udp", 0, 0);
-		if (!xprt)
-			err = svc_create_xprt(serv, "udp", nlm_udpport,
-					      SVC_SOCK_DEFAULTS);
-		else
-			svc_xprt_put(xprt);
-	}
-	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport)) {
+	xprt = svc_find_xprt(serv, "udp", 0, 0);
+	if (!xprt)
+		err = svc_create_xprt(serv, "udp", nlm_udpport,
+				      SVC_SOCK_DEFAULTS);
+	else
+		svc_xprt_put(xprt);
+	if (err >= 0) {
 		xprt = svc_find_xprt(serv, "tcp", 0, 0);
 		if (!xprt)
 			err = svc_create_xprt(serv, "tcp", nlm_tcpport,
@@ -251,11 +254,8 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 	/*
 	 * Check whether we're already up and running.
 	 */
-	if (nlmsvc_rqst) {
-		if (proto)
-			error = make_socks(nlmsvc_rqst->rq_server, proto);
+	if (nlmsvc_rqst)
 		goto out;
-	}
 
 	/*
 	 * Sanity check: if there's no pid,
@@ -272,7 +272,8 @@ lockd_up(int proto) /* Maybe add a 'family' option when IPv6 is supported ?? */
 		goto out;
 	}
 
-	if ((error = make_socks(serv, proto)) < 0)
+	error = make_socks(serv);
+	if (error < 0)
 		goto destroy_and_out;
 
 	/*

