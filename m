From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 5/9] rpc: call release_pipe only on last close
Date: Sun,  9 Nov 2008 16:04:39 -0500
Message-ID: <1226264683-28650-6-git-send-email-bfields@citi.umich.edu>
References: <20081109204621.GD27376@fieldses.org>
 <1226264683-28650-1-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-2-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-3-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-4-git-send-email-bfields@citi.umich.edu>
 <1226264683-28650-5-git-send-email-bfields@citi.umich.edu>
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34903 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756012AbYKIVEq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2008 16:04:46 -0500
In-Reply-To: <1226264683-28650-5-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I can't see any reason we particularly need to call this until the last
gssd closes the pipe.

Also, this allows to guarantee that open_pipe and release_pipe are
called strictly in pairs; open_pipe on the first open, release_pipe on
the last close.  That'll make it very easy for the gss code to keep
track of which pipes gssd is using.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/rpc_pipe.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 4171ab7..712e1ec 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -126,13 +126,14 @@ rpc_close_pipes(struct inode *inode)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
 	struct rpc_pipe_ops *ops;
+	int last_close;
 
 	mutex_lock(&inode->i_mutex);
 	ops = rpci->ops;
 	if (ops != NULL) {
 		LIST_HEAD(free_list);
-
 		spin_lock(&inode->i_lock);
+		last_close = rpci->nreaders != 0 || rpci->nwriters != 0;
 		rpci->nreaders = 0;
 		list_splice_init(&rpci->in_upcall, &free_list);
 		list_splice_init(&rpci->pipe, &free_list);
@@ -141,7 +142,7 @@ rpc_close_pipes(struct inode *inode)
 		spin_unlock(&inode->i_lock);
 		rpc_purge_list(rpci, &free_list, ops->destroy_msg, -EPIPE);
 		rpci->nwriters = 0;
-		if (ops->release_pipe)
+		if (last_close && ops->release_pipe)
 			ops->release_pipe(inode);
 		cancel_delayed_work_sync(&rpci->queue_timeout);
 	}
@@ -195,6 +196,7 @@ rpc_pipe_release(struct inode *inode, struct file *filp)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
 	struct rpc_pipe_msg *msg;
+	int last_close;
 
 	mutex_lock(&inode->i_mutex);
 	if (rpci->ops == NULL)
@@ -221,7 +223,8 @@ rpc_pipe_release(struct inode *inode, struct file *filp)
 					rpci->ops->destroy_msg, -EAGAIN);
 		}
 	}
-	if (rpci->ops->release_pipe)
+	last_close = rpci->nwriters == 0 && rpci->nreaders == 0;
+	if (last_close && rpci->ops->release_pipe)
 		rpci->ops->release_pipe(inode);
 out:
 	mutex_unlock(&inode->i_mutex);
-- 
1.5.5.rc1

