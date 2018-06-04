Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:55218 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751498AbeFDWby (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 18:31:54 -0400
Received: by mail-it0-f66.google.com with SMTP id 76-v6so999557itx.4
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 15:31:54 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-49-162-121.hsd1.mi.comcast.net. [68.49.162.121])
        by smtp.gmail.com with ESMTPSA id s5-v6sm4309480ioj.13.2018.06.04.15.31.52
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Jun 2018 15:31:52 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 02/11] NFS: Pass the inode down to the getattr() callback
Date: Mon,  4 Jun 2018 18:31:20 -0400
Message-Id: <20180604223129.121477-2-trond.myklebust@hammerspace.com>
In-Reply-To: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
References: <20180604223129.121477-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Allow the getattr() callback to check things like whether or not we hold
a delegation so that it can adjust the attributes that it is asking for.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/client.c         |  3 ++-
 fs/nfs/dir.c            |  3 ++-
 fs/nfs/export.c         |  2 +-
 fs/nfs/inode.c          |  3 ++-
 fs/nfs/nfs3proc.c       |  3 ++-
 fs/nfs/nfs4proc.c       | 17 ++++++++++-------
 fs/nfs/proc.c           |  3 ++-
 include/linux/nfs_xdr.h |  3 ++-
 8 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b9129e2befea..02e97c29af0c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -969,7 +969,8 @@ struct nfs_server *nfs_create_server(struct nfs_mount_info *mount_info,
 	}
 
 	if (!(fattr->valid & NFS_ATTR_FATTR)) {
-		error = nfs_mod->rpc_ops->getattr(server, mount_info->mntfh, fattr, NULL);
+		error = nfs_mod->rpc_ops->getattr(server, mount_info->mntfh,
+				fattr, NULL, NULL);
 		if (error < 0) {
 			dprintk("nfs_create_server: getattr error = %d\n", -error);
 			goto error;
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 978a22ea962c..7a9c14426855 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1656,7 +1656,8 @@ int nfs_instantiate(struct dentry *dentry, struct nfs_fh *fhandle,
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	if (!(fattr->valid & NFS_ATTR_FATTR)) {
 		struct nfs_server *server = NFS_SB(dentry->d_sb);
-		error = server->nfs_client->rpc_ops->getattr(server, fhandle, fattr, NULL);
+		error = server->nfs_client->rpc_ops->getattr(server, fhandle,
+				fattr, NULL, NULL);
 		if (error < 0)
 			goto out_error;
 	}
diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index ab5de3246c5c..deecb67638aa 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -102,7 +102,7 @@ nfs_fh_to_dentry(struct super_block *sb, struct fid *fid,
 	}
 
 	rpc_ops = NFS_SB(sb)->nfs_client->rpc_ops;
-	ret = rpc_ops->getattr(NFS_SB(sb), server_fh, fattr, label);
+	ret = rpc_ops->getattr(NFS_SB(sb), server_fh, fattr, label, NULL);
 	if (ret) {
 		dprintk("%s: getattr failed %d\n", __func__, ret);
 		dentry = ERR_PTR(ret);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 5de724b1b90c..a720427e5aa3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1101,7 +1101,8 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 		goto out;
 	}
 
-	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), fattr, label);
+	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), fattr,
+			label, inode);
 	if (status != 0) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Lu) getattr failed, error=%d\n",
 			 inode->i_sb->s_id,
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 5645ef4c5259..ec8a9efa268f 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -101,7 +101,8 @@ nfs3_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
  */
 static int
 nfs3_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr, struct nfs4_label *label)
+		struct nfs_fattr *fattr, struct nfs4_label *label,
+		struct inode *inode)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs3_procedures[NFS3PROC_GETATTR],
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c44cfa6be8ff..cd60e8360ef2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -92,8 +92,8 @@ static void nfs4_layoutget_release(void *calldata);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
 static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
-static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label);
-static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label);
+static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct nfs_fattr *, struct nfs4_label *label, struct inode *inode);
+static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label, struct inode *inode);
 static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 			    struct nfs_fattr *fattr, struct iattr *sattr,
 			    struct nfs_open_context *ctx, struct nfs4_label *ilabel,
@@ -2494,7 +2494,8 @@ static int _nfs4_proc_open(struct nfs4_opendata *data,
 	}
 	if (!(o_res->f_attr->valid & NFS_ATTR_FATTR)) {
 		nfs4_sequence_free_slot(&o_res->seq_res);
-		nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr, o_res->f_label);
+		nfs4_proc_getattr(server, &o_res->fh, o_res->f_attr,
+				o_res->f_label, NULL);
 	}
 	return 0;
 }
@@ -3763,7 +3764,7 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *mntfh,
 	if (IS_ERR(label))
 		return PTR_ERR(label);
 
-	error = nfs4_proc_getattr(server, mntfh, fattr, label);
+	error = nfs4_proc_getattr(server, mntfh, fattr, label, NULL);
 	if (error < 0) {
 		dprintk("nfs4_get_root: getattr error = %d\n", -error);
 		goto err_free_label;
@@ -3828,7 +3829,8 @@ static int nfs4_get_referral(struct rpc_clnt *client, struct inode *dir,
 }
 
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
-				struct nfs_fattr *fattr, struct nfs4_label *label)
+				struct nfs_fattr *fattr, struct nfs4_label *label,
+				struct inode *inode)
 {
 	struct nfs4_getattr_arg args = {
 		.fh = fhandle,
@@ -3852,12 +3854,13 @@ static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 }
 
 static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
-				struct nfs_fattr *fattr, struct nfs4_label *label)
+				struct nfs_fattr *fattr, struct nfs4_label *label,
+				struct inode *inode)
 {
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = _nfs4_proc_getattr(server, fhandle, fattr, label);
+		err = _nfs4_proc_getattr(server, fhandle, fattr, label, inode);
 		trace_nfs4_getattr(server, fhandle, fattr, err);
 		err = nfs4_handle_exception(server, err,
 				&exception);
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 763f77e7f1f1..e0c257bd62b9 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -99,7 +99,8 @@ nfs_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
  */
 static int
 nfs_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
-		struct nfs_fattr *fattr, struct nfs4_label *label)
+		struct nfs_fattr *fattr, struct nfs4_label *label,
+		struct inode *inode)
 {
 	struct rpc_message msg = {
 		.rpc_proc	= &nfs_procedures[NFSPROC_GETATTR],
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 09dc14ac5804..9dee3c23895d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1581,7 +1581,8 @@ struct nfs_rpc_ops {
 	struct dentry *(*try_mount) (int, const char *, struct nfs_mount_info *,
 				     struct nfs_subversion *);
 	int	(*getattr) (struct nfs_server *, struct nfs_fh *,
-			    struct nfs_fattr *, struct nfs4_label *);
+			    struct nfs_fattr *, struct nfs4_label *,
+			    struct inode *);
 	int	(*setattr) (struct dentry *, struct nfs_fattr *,
 			    struct iattr *);
 	int	(*lookup)  (struct inode *, const struct qstr *,
-- 
2.17.1

