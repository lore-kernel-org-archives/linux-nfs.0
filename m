From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] sunrpc: add sv_maxconn field to svc_serv
Date: Fri, 17 Oct 2008 14:26:09 -0400
Message-ID: <1224267970-15769-1-git-send-email-jlayton@redhat.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49884 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753077AbYJQS01 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 14:26:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svc_check_conn_limits() attempts to prevent denial of service attacks
by having the service close old connections once it reaches a
threshold. This threshold is based on the number of threads in the
service:

	(serv->sv_nrthreads + 3) * 20

Once we reach this, we drop the oldest connections and a printk pops
to warn the admin that they should increase the number of threads.

Increasing the number of threads isn't an option however for services
like lockd. We don't want to eliminate this check entirely for such
services but we need some way to increase this limit.

This patch adds a sv_maxconn field to the svc_serv struct. When it's
set to 0, we use the current method to calculate the max number of
connections. RPC services can then set this on an as-needed basis.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc_xprt.c      |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 3afe7fb..048da8a 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -61,6 +61,7 @@ struct svc_serv {
 	unsigned int		sv_max_payload;	/* datagram payload size */
 	unsigned int		sv_max_mesg;	/* max_payload + 1 page for overheads */
 	unsigned int		sv_xdrsize;	/* XDR buffer size */
+	unsigned int		sv_maxconn;	/* max connections allowed */
 
 	struct list_head	sv_permsocks;	/* all permanent sockets */
 	struct list_head	sv_tempsocks;	/* all temporary sockets */
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bf5b5cd..e57583a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -525,10 +525,17 @@ int svc_port_is_privileged(struct sockaddr *sin)
  * The only somewhat efficient mechanism would be if drop old
  * connections from the same IP first. But right now we don't even
  * record the client IP in svc_sock.
+ *
+ * single-threaded services that expect a lot of clients will probably
+ * need to set sv_maxconn to override the default value which is based
+ * on the number of threads
  */
 static void svc_check_conn_limits(struct svc_serv *serv)
 {
-	if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
+	unsigned int limit = serv->sv_maxconn ? serv->sv_maxconn :
+				(serv->sv_nrthreads+3) * 20;
+
+	if (serv->sv_tmpcnt > limit) {
 		struct svc_xprt *xprt = NULL;
 		spin_lock_bh(&serv->sv_lock);
 		if (!list_empty(&serv->sv_tempsocks)) {
-- 
1.5.5.1

