From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 57/69] rpc: minor gss_alloc_msg cleanup
Date: Tue, 23 Dec 2008 18:02:23 -0500
Message-ID: <20081223230223.13743.82513.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63750 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752894AbYLWXYo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:44 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOcm3006401
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: \"J. Bruce Fields\" <bfields@citi.umich.edu>

I want to add a little more code here, so it'll be convenient to have
this flatter.

Also, I'll want to add another error condition, so it'll be more
convenient to return -ENOMEM than NULL in the error case.  The only
caller is already converting NULL to -ENOMEM anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)


diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 0fe3566..bc512ff 100644
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

