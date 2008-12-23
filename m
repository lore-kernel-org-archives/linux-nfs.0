From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 60/69] rpc: track number of users of the gss upcall pipe
Date: Tue, 23 Dec 2008 18:02:24 -0500
Message-ID: <20081223230223.13743.39649.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1640 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762AbYLWXYp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:45 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOcm5006401
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: \"J. Bruce Fields\" <bfields@citi.umich.edu>

Keep a count of the number of pipes open plus the number of messages on
a pipe.  This count isn't used yet.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/auth_gss/auth_gss.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)


diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index bc512ff..51aa27d 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -75,6 +75,8 @@ struct gss_auth {
 	struct dentry *dentry;
 };
 
+static atomic_t pipe_users = ATOMIC_INIT(0);
+
 static void gss_free_ctx(struct gss_cl_ctx *);
 static struct rpc_pipe_ops gss_upcall_ops;
 
@@ -237,6 +239,7 @@ gss_release_msg(struct gss_upcall_msg *gss_msg)
 {
 	if (!atomic_dec_and_test(&gss_msg->count))
 		return;
+	atomic_dec(&pipe_users);
 	BUG_ON(!list_empty(&gss_msg->list));
 	if (gss_msg->ctx != NULL)
 		gss_put_ctx(gss_msg->ctx);
@@ -331,6 +334,7 @@ gss_alloc_msg(struct gss_auth *gss_auth, uid_t uid)
 	gss_msg = kzalloc(sizeof(*gss_msg), GFP_NOFS);
 	if (gss_msg == NULL)
 		return ERR_PTR(-ENOMEM);
+	atomic_inc(&pipe_users);
 	INIT_LIST_HEAD(&gss_msg->list);
 	rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
 	init_waitqueue_head(&gss_msg->waitqueue);
@@ -555,6 +559,13 @@ out:
 	return err;
 }
 
+static int
+gss_pipe_open(struct inode *inode)
+{
+	atomic_inc(&pipe_users);
+	return 0;
+}
+
 static void
 gss_pipe_release(struct inode *inode)
 {
@@ -574,6 +585,8 @@ gss_pipe_release(struct inode *inode)
 		spin_lock(&inode->i_lock);
 	}
 	spin_unlock(&inode->i_lock);
+
+	atomic_dec(&pipe_users);
 }
 
 static void
@@ -1349,6 +1362,7 @@ static struct rpc_pipe_ops gss_upcall_ops = {
 	.upcall		= gss_pipe_upcall,
 	.downcall	= gss_pipe_downcall,
 	.destroy_msg	= gss_pipe_destroy_msg,
+	.open_pipe	= gss_pipe_open,
 	.release_pipe	= gss_pipe_release,
 };
 

