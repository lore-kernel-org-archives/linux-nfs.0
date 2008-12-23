From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 58/69] rpc: add an rpc_pipe_open method
Date: Tue, 23 Dec 2008 18:02:23 -0500
Message-ID: <20081223230223.13743.56399.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1640 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752914AbYLWXYq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:46 -0500
Received: from sacrsexc1-prd.hq.netapp.com ([10.99.115.27])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOc0h006400
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:42 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: \"J. Bruce Fields\" <bfields@citi.umich.edu>

We want to transition to a new gssd upcall which is text-based and more
easily extensible.

To simplify upgrades, as well as testing and debugging, it will help if
we can upgrade gssd (to a version which understands the new upcall)
without having to choose at boot (or module-load) time whether we want
the new or the old upcall.

We will do this by providing two different pipes: one named, as
currently, after the mechanism (normally "krb5"), and supporting the
old upcall.  One named "gssd" and supporting the new upcall version.

We allow gssd to indicate which version it supports by its choice of
which pipe to open.

As we have no interest in supporting *simultaneous* use of both
versions, we'll forbid opening both pipes at the same time.

So, add a new pipe_open callback to the rpc_pipefs api, which the gss
code can use to track which pipes have been open, and to refuse opens of
incompatible pipes.

We only need this to be called on the first open of a given pipe.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/rpc_pipe_fs.h |    1 +
 net/sunrpc/rpc_pipe.c              |   22 +++++++++++++++-------
 2 files changed, 16 insertions(+), 7 deletions(-)


diff --git a/include/linux/sunrpc/rpc_pipe_fs.h b/include/linux/sunrpc/rpc_pipe_fs.h
index 51b977a..cea764c 100644
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
index 55b2049..c9b57f4 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -169,16 +169,24 @@ static int
 rpc_pipe_open(struct inode *inode, struct file *filp)
 {
 	struct rpc_inode *rpci = RPC_I(inode);
+	int first_open;
 	int res = -ENXIO;
 
 	mutex_lock(&inode->i_mutex);
-	if (rpci->ops != NULL) {
-		if (filp->f_mode & FMODE_READ)
-			rpci->nreaders ++;
-		if (filp->f_mode & FMODE_WRITE)
-			rpci->nwriters ++;
-		res = 0;
+	if (rpci->ops == NULL)
+		goto out;
+	first_open = rpci->nreaders == 0 && rpci->nwriters == 0;
+	if (first_open && rpci->ops->open_pipe) {
+		res = rpci->ops->open_pipe(inode);
+		if (res)
+			goto out;
 	}
+	if (filp->f_mode & FMODE_READ)
+		rpci->nreaders++;
+	if (filp->f_mode & FMODE_WRITE)
+		rpci->nwriters++;
+	res = 0;
+out:
 	mutex_unlock(&inode->i_mutex);
 	return res;
 }
@@ -748,7 +756,7 @@ rpc_rmdir(struct dentry *dentry)
  * @name: name of pipe
  * @private: private data to associate with the pipe, for the caller's use
  * @ops: operations defining the behavior of the pipe: upcall, downcall,
- *	release_pipe, and destroy_msg.
+ *	release_pipe, open_pipe, and destroy_msg.
  * @flags: rpc_inode flags
  *
  * Data is made available for userspace to read by calls to

