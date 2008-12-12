From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 06/15] rpc: track number of users of the gss upcall pipe
Date: Fri, 12 Dec 2008 13:20:26 -0500
Message-ID: <1229106035-16102-7-git-send-email-bfields@citi.umich.edu>
References: <1229106035-16102-1-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-2-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-3-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-4-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-5-git-send-email-bfields@citi.umich.edu>
 <1229106035-16102-6-git-send-email-bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33988 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758470AbYLLSUj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Dec 2008 13:20:39 -0500
In-Reply-To: <1229106035-16102-6-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Keep a count of the number of pipes open plus the number of messages on
a pipe.  This count isn't used yet.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/auth_gss.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 7baa432..45e6728 100644
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
@@ -1342,6 +1355,7 @@ static struct rpc_pipe_ops gss_upcall_ops = {
 	.upcall		= gss_pipe_upcall,
 	.downcall	= gss_pipe_downcall,
 	.destroy_msg	= gss_pipe_destroy_msg,
+	.open_pipe	= gss_pipe_open,
 	.release_pipe	= gss_pipe_release,
 };
 
-- 
1.5.5.rc1

