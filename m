From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/5] rpc: add an rpc_pipe_open method
Date: Fri, 13 Jun 2008 18:50:41 -0400
Message-ID: <1213397442-15611-5-git-send-email-bfields@citi.umich.edu>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
 <1213397442-15611-2-git-send-email-bfields@citi.umich.edu>
 <1213397442-15611-3-git-send-email-bfields@citi.umich.edu>
 <1213397442-15611-4-git-send-email-bfields@citi.umich.edu>
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43961 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755902AbYFMWuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 18:50:44 -0400
In-Reply-To: <1213397442-15611-4-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We want to transition to a new gssd upcall which is text-based and more
easily extensible.

To simplify upgrades, as well as testing and debugging, it will help if
we can upgrade gssd (to a version which understands the new upcall)
without having to choose at boot (or module-load) time whether we want
the new or the old upcall.

That means that when gssd opens an rpc upcall pipe, we'd like to just
start using whichever version it chose immediately--ideally without
having to wait the 30 seconds that it would normally take for upcalls
already queued on the wrong upcall pipe to time out.

So we add an rpc_pipe open method, which we will use to let the gssd
code know that a new gssd may have started up.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/rpc_pipe_fs.h |    1 +
 net/sunrpc/rpc_pipe.c              |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 867bea8..439bef3 100644
--- a/include/linux/sunrpc/rpc_pipe_fs.h
+++ b/include/linux/sunrpc/rpc_pipe_fs.h
@@ -15,6 +15,7 @@ struct rpc_pipe_ops {
 	ssize_t (*upcall)(struct file *, struct rpc_pipe_msg *, char __user *, size_t);
 	ssize_t (*downcall)(struct file *, const char __user *, size_t);
 	void (*release_pipe)(struct inode *);
+	int (*open_pipe)(struct inode *);
 	void (*destroy_msg)(struct rpc_pipe_msg *);
 };
 
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 41d968f..f7781fc 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -169,9 +169,15 @@ static int
 rpc_pipe_open(struct inode *inode, struct file *filp)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
-	int res = -ENXIO;
+	int res;
 
 	mutex_lock(&inode->i_mutex);
+	if (rpci->ops->open_pipe) {
+		res = rpci->ops->open_pipe(inode);
+		if (res)
+			goto out;
+	}
+	res = -ENXIO;
 	if (rpci->ops != NULL) {
 		if (filp->f_mode & FMODE_READ)
 			rpci->nreaders ++;
@@ -179,6 +185,7 @@ rpc_pipe_open(struct inode *inode, struct file *filp)
 			rpci->nwriters ++;
 		res = 0;
 	}
+out:
 	mutex_unlock(&inode->i_mutex);
 	return res;
 }
-- 
1.5.5.rc1

