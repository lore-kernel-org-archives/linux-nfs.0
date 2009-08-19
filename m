From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 11/32] SUNRPC: Clean up rpc_unlink()
Date: Wed, 19 Aug 2009 19:38:34 -0400
Message-ID: <1250725135-14632-12-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-10-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:5817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754030AbZHSXkx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:53 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNePRB001724
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:41 -0700 (PDT)
In-Reply-To: <1250725135-14632-11-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/rpc_pipe.c |   35 +++++++++++++++++++++++++++--------
 1 files changed, 27 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index d8c7815..cf30bf5 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -601,6 +601,29 @@ static int __rpc_mkpipe(struct inode *dir, struct dentry *dentry,
 	return 0;
 }
 
+static int __rpc_unlink(struct inode *dir, struct dentry *dentry)
+{
+	int ret;
+
+	dget(dentry);
+	ret = simple_unlink(dir, dentry);
+	d_delete(dentry);
+	dput(dentry);
+	return ret;
+}
+
+static int __rpc_rmpipe(struct inode *dir, struct dentry *dentry)
+{
+	struct inode *inode = dentry->d_inode;
+	struct rpc_inode *rpci = RPC_I(inode);
+
+	rpci->nkern_readwriters--;
+	if (rpci->nkern_readwriters != 0)
+		return 0;
+	rpc_close_pipes(inode);
+	return __rpc_unlink(dir, dentry);
+}
+
 /*
  * FIXME: This probably has races.
  */
@@ -848,14 +871,15 @@ struct dentry *rpc_mkpipe(struct dentry *parent, const char *name,
 				rpci->ops != ops ||
 				rpci->flags != flags) {
 			dput (dentry);
-			dentry = ERR_PTR(-EBUSY);
+			err = -EBUSY;
+			goto out_err;
 		}
 		rpci->nkern_readwriters++;
 		goto out;
 	}
 
 	err = __rpc_mkpipe(dir, dentry, umode, &rpc_pipe_fops,
-			private, ops, flags);
+			   private, ops, flags);
 	if (err)
 		goto out_err;
 	dget(dentry);
@@ -889,12 +913,7 @@ rpc_unlink(struct dentry *dentry)
 	parent = dget_parent(dentry);
 	dir = parent->d_inode;
 	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
-	if (--RPC_I(dentry->d_inode)->nkern_readwriters == 0) {
-		rpc_close_pipes(dentry->d_inode);
-		error = simple_unlink(dir, dentry);
-		if (!error)
-			d_delete(dentry);
-	}
+	error = __rpc_rmpipe(dir, dentry);
 	dput(dentry);
 	mutex_unlock(&dir->i_mutex);
 	dput(parent);
-- 
1.6.0.4
