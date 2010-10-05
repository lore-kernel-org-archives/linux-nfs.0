Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:14785 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754325Ab0JETaZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 15:30:25 -0400
Message-ID: <4CAB7CCB.3070904@parallels.com>
Date: Tue, 05 Oct 2010 23:30:19 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] sunrpc: Turn list_for_each-s into the ..._entry-s
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Saves some lines of code and some branticks when reading one.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/svc_xprt.c |    6 ++----
 net/sunrpc/svcsock.c  |   12 +++---------
 net/sunrpc/xprt.c     |    6 ++----
 3 files changed, 7 insertions(+), 17 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 12025ee..bef1e88 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -100,16 +100,14 @@ EXPORT_SYMBOL_GPL(svc_unreg_xprt_class);
  */
 int svc_print_xprts(char *buf, int maxlen)
 {
-	struct list_head *le;
+	struct svc_xprt_class *xcl;
 	char tmpstr[80];
 	int len = 0;
 	buf[0] = '\0';
 
 	spin_lock(&svc_xprt_class_lock);
-	list_for_each(le, &svc_xprt_class_list) {
+	list_for_each_entry(xcl, &svc_xprt_class_list, xcl_list) {
 		int slen;
-		struct svc_xprt_class *xcl =
-			list_entry(le, struct svc_xprt_class, xcl_list);
 
 		sprintf(tmpstr, "%s %d\n", xcl->xcl_name, xcl->xcl_max_payload);
 		slen = strlen(tmpstr);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 88de3d0..1454739 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1261,19 +1261,13 @@ void svc_sock_update_bufs(struct svc_serv *serv)
 	 * The number of server threads has changed. Update
 	 * rcvbuf and sndbuf accordingly on all sockets
 	 */
-	struct list_head *le;
+	struct svc_sock *svsk;
 
 	spin_lock_bh(&serv->sv_lock);
-	list_for_each(le, &serv->sv_permsocks) {
-		struct svc_sock *svsk =
-			list_entry(le, struct svc_sock, sk_xprt.xpt_list);
+	list_for_each_entry(svsk, &serv->sv_permsocks, sk_xprt.xpt_list)
 		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
-	}
-	list_for_each(le, &serv->sv_tempsocks) {
-		struct svc_sock *svsk =
-			list_entry(le, struct svc_sock, sk_xprt.xpt_list);
+	list_for_each_entry(svsk, &serv->sv_tempsocks, sk_xprt.xpt_list)
 		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
-	}
 	spin_unlock_bh(&serv->sv_lock);
 }
 EXPORT_SYMBOL_GPL(svc_sock_update_bufs);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 64a4a94..4c8f18a 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -755,13 +755,11 @@ static void xprt_connect_status(struct rpc_task *task)
  */
 struct rpc_rqst *xprt_lookup_rqst(struct rpc_xprt *xprt, __be32 xid)
 {
-	struct list_head *pos;
+	struct rpc_rqst *entry;
 
-	list_for_each(pos, &xprt->recv) {
-		struct rpc_rqst *entry = list_entry(pos, struct rpc_rqst, rq_list);
+	list_for_each_entry(entry, &xprt->recv, rq_list)
 		if (entry->rq_xid == xid)
 			return entry;
-	}
 
 	dprintk("RPC:       xprt_lookup_rqst did not find xid %08x\n",
 			ntohl(xid));
-- 
1.5.5.6

