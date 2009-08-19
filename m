From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 08/32] SUNRPC: Allow rpc_pipefs_ops to have null values for
 upcall and downcall
Date: Wed, 19 Aug 2009 19:38:31 -0400
Message-ID: <1250725135-14632-9-git-send-email-Trond.Myklebust@netapp.com>
References: <1250725135-14632-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
Mime-Version: 1.0
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39738 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754022AbZHSXkx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Aug 2009 19:40:53 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n7JNePR9001724
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2009 16:40:41 -0700 (PDT)
In-Reply-To: <1250725135-14632-8-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also ensure that we use the umode_t type when appropriate...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/rpc_pipe.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index f6f60f6..8fa7182 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -417,7 +417,7 @@ enum {
 struct rpc_filelist {
 	char *name;
 	const struct file_operations *i_fop;
-	int mode;
+	umode_t mode;
 };
 
 static struct rpc_filelist files[] = {
@@ -516,7 +516,7 @@ rpc_release_path(struct nameidata *nd)
 }
 
 static struct inode *
-rpc_get_inode(struct super_block *sb, int mode)
+rpc_get_inode(struct super_block *sb, umode_t mode)
 {
 	struct inode *inode = new_inode(sb);
 	if (!inode)
@@ -589,7 +589,8 @@ rpc_populate(struct dentry *parent,
 	struct inode *inode, *dir = parent->d_inode;
 	void *private = RPC_I(dir)->private;
 	struct dentry *dentry;
-	int mode, i;
+	umode_t mode;
+	int i;
 
 	mutex_lock(&dir->i_mutex);
 	for (i = start; i < eof; i++) {
@@ -783,6 +784,12 @@ struct dentry *rpc_mkpipe(struct dentry *parent, const char *name,
 	struct dentry *dentry;
 	struct inode *dir, *inode;
 	struct rpc_inode *rpci;
+	umode_t umode = S_IFIFO | S_IRUSR | S_IWUSR;
+
+	if (ops->upcall == NULL)
+		umode &= ~S_IRUGO;
+	if (ops->downcall == NULL)
+		umode &= ~S_IWUGO;
 
 	dentry = rpc_lookup_create(parent, name, strlen(name), 0);
 	if (IS_ERR(dentry))
@@ -799,7 +806,7 @@ struct dentry *rpc_mkpipe(struct dentry *parent, const char *name,
 		rpci->nkern_readwriters++;
 		goto out;
 	}
-	inode = rpc_get_inode(dir->i_sb, S_IFIFO | S_IRUSR | S_IWUSR);
+	inode = rpc_get_inode(dir->i_sb, umode);
 	if (!inode)
 		goto err_dput;
 	inode->i_ino = iunique(dir->i_sb, 100);
-- 
1.6.0.4
