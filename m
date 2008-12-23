From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 59/69] rpc: call release_pipe only on last close
Date: Tue, 23 Dec 2008 18:02:23 -0500
Message-ID: <20081223230223.13743.97120.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63750 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752742AbYLWXYm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:42 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOcSm021557
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:40 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: \"J. Bruce Fields\" <bfields@citi.umich.edu>

I can't see any reason we need to call this until either the kernel or
the last gssd closes the pipe.

Also, this allows to guarantee that open_pipe and release_pipe are
called strictly in pairs; open_pipe on gssd's first open, release_pipe
on gssd's last close (or on the close of the kernel side of the pipe, if
that comes first).

That will make it very easy for the gss code to keep track of which
pipes gssd is using.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/rpc_pipe.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)


diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index c9b57f4..3105efb 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -126,13 +126,14 @@ rpc_close_pipes(struct inode *inode)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
 	struct rpc_pipe_ops *ops;
+	int need_release;
 
 	mutex_lock(&inode->i_mutex);
 	ops = rpci->ops;
 	if (ops != NULL) {
 		LIST_HEAD(free_list);
-
 		spin_lock(&inode->i_lock);
+		need_release = rpci->nreaders != 0 || rpci->nwriters != 0;
 		rpci->nreaders = 0;
 		list_splice_init(&rpci->in_upcall, &free_list);
 		list_splice_init(&rpci->pipe, &free_list);
@@ -141,7 +142,7 @@ rpc_close_pipes(struct inode *inode)
 		spin_unlock(&inode->i_lock);
 		rpc_purge_list(rpci, &free_list, ops->destroy_msg, -EPIPE);
 		rpci->nwriters = 0;
-		if (ops->release_pipe)
+		if (need_release && ops->release_pipe)
 			ops->release_pipe(inode);
 		cancel_delayed_work_sync(&rpci->queue_timeout);
 	}
@@ -196,6 +197,7 @@ rpc_pipe_release(struct inode *inode, struct file *filp)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
 	struct rpc_pipe_msg *msg;
+	int last_close;
 
 	mutex_lock(&inode->i_mutex);
 	if (rpci->ops == NULL)
@@ -222,7 +224,8 @@ rpc_pipe_release(struct inode *inode, struct file *filp)
 					rpci->ops->destroy_msg, -EAGAIN);
 		}
 	}
-	if (rpci->ops->release_pipe)
+	last_close = rpci->nwriters == 0 && rpci->nreaders == 0;
+	if (last_close && rpci->ops->release_pipe)
 		rpci->ops->release_pipe(inode);
 out:
 	mutex_unlock(&inode->i_mutex);

