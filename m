From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 03/15] rpc: minor gss_alloc_msg cleanup
Date: Fri, 12 Dec 2008 13:20:23 -0500
Message-ID: <1229106035-16102-4-git-send-email-bfields@citi.umich.edu>
References: <1229106035-16102-1-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-2-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-3-git-send-email-bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33979 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758444AbYLLSUi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2008 13:20:38 -0500
In-Reply-To: <1229106035-16102-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I want to add a little more code here, so it'll be convenient to have
this flatter.

Also, I'll want to add another error condition, so it'll be more
convenient to return -ENOMEM than NULL in the error case.  The only
caller is already converting NULL to -ENOMEM anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 1cb4bcc..7baa432 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -329,16 +329,16 @@ gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid)
 	struct gss_upcall_msg *gss_msg;
 
 	gss_msg = kzalloc(sizeof(*gss_msg), GFP_NOFS);
-	if (gss_msg != NULL) {
-		INIT_LIST_HEAD(&gss_msg->list);
-		rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
-		init_waitqueue_head(&gss_msg->waitqueue);
-		atomic_set(&gss_msg->count, 1);
-		gss_msg->msg.data = &gss_msg->uid;
-		gss_msg->msg.len = sizeof(gss_msg->uid);
-		gss_msg->uid = uid;
-		gss_msg->auth = gss_auth;
-	}
+	if (gss_msg == NULL)
+		return ERR_PTR(-ENOMEM);
+	INIT_LIST_HEAD(&gss_msg->list);
+	rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
+	init_waitqueue_head(&gss_msg->waitqueue);
+	atomic_set(&gss_msg->count, 1);
+	gss_msg->msg.data = &gss_msg->uid;
+	gss_msg->msg.len = sizeof(gss_msg->uid);
+	gss_msg->uid = uid;
+	gss_msg->auth = gss_auth;
 	return gss_msg;
 }
 
@@ -355,8 +355,8 @@ gss_setup_upcall(struct rpc_clnt *clnt, struct gss_auth *gss_auth, struct rpc_cr
 		uid = 0;
 
 	gss_new = gss_alloc_msg(gss_auth, uid);
-	if (gss_new == NULL)
-		return ERR_PTR(-ENOMEM);
+	if (IS_ERR(gss_new))
+		return gss_new;
 	gss_msg = gss_add_msg(gss_auth, gss_new);
 	if (gss_msg == gss_new) {
 		int res = rpc_queue_upcall(gss_auth->dentry->d_inode, &gss_new->msg);
-- 
1.5.5.rc1

