Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:7579 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755503Ab2CUPVZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 11:21:25 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 21/23] NFS: Give modules a custom set / unset layoutdriver functions
Date: Wed, 21 Mar 2012 11:20:51 -0400
Message-Id: <1332343253-24970-22-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
References: <1332343253-24970-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Used to set or clear the pnfs layoutdriver when pnfs is in use.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c    |    6 ++++--
 fs/nfs/nfs.h       |    2 ++
 fs/nfs/nfs2super.c |   12 ++++++++++++
 fs/nfs/nfs3super.c |   12 ++++++++++++
 fs/nfs/nfs4super.c |    2 ++
 5 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 32a9a54..96de872 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -877,6 +877,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 				  struct nfs_fsinfo *fsinfo)
 {
 	unsigned long max_rpc_payload;
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
 
 	/* Work out a lot of parameters */
 	if (server->rsize == 0)
@@ -905,7 +906,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	server->pnfs_blksize = fsinfo->blksize;
-	set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
+	nfs_mod->set_layoutdriver(server, mntfh, fsinfo->layouttype);
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
@@ -1065,10 +1066,11 @@ struct nfs_server *nfs_alloc_server(void)
  */
 void nfs_free_server(struct nfs_server *server)
 {
+	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
 	dprintk("--> nfs_free_server()\n");
 
 	nfs_server_remove_lists(server);
-	unset_pnfs_layoutdriver(server);
+	nfs_mod->unset_layoutdriver(server);
 
 	if (server->destroy != NULL)
 		server->destroy(server);
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 21bc52b..fe8152f 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -43,6 +43,8 @@ struct nfs_subversion {
 	int (*return_delegation)(struct inode *);
 	void (*init_read)(struct nfs_pageio_descriptor *, struct inode *);
 	void (*init_write)(struct nfs_pageio_descriptor *, struct inode *, int);
+	void (*set_layoutdriver)(struct nfs_server *, const struct nfs_fh *, u32);
+	void (*unset_layoutdriver)(struct nfs_server *);
 };
 
 struct nfs_sb_mountdata {
diff --git a/fs/nfs/nfs2super.c b/fs/nfs/nfs2super.c
index a9a1a0b..88d772d 100644
--- a/fs/nfs/nfs2super.c
+++ b/fs/nfs/nfs2super.c
@@ -47,6 +47,16 @@ static struct vfsmount *nfs2_do_submount(struct dentry *dentry,
 	return _nfs_do_submount(&nfs_xdev_fs_type, dentry, fh, fattr, authflavor);
 }
 
+static void nfs2_set_layoutdriver(struct nfs_server *server,
+				  const struct nfs_fh *mntfh,
+				  u32 id)
+{
+}
+
+static void nfs2_unset_layoutdriver(struct nfs_server *server)
+{
+}
+
 static struct nfs_subversion nfs_v2 = {
 	.version  = 2,
 	.rpc_vers = &nfs_version2,
@@ -61,6 +71,8 @@ static struct nfs_subversion nfs_v2 = {
 	.submount = nfs2_do_submount,
 	.init_read = nfs_pageio_init_read_mds,
 	.init_write = nfs_pageio_init_write_mds,
+	.set_layoutdriver = nfs2_set_layoutdriver,
+	.unset_layoutdriver = nfs2_unset_layoutdriver,
 };
 
 static int __init init_nfs_v2(void)
diff --git a/fs/nfs/nfs3super.c b/fs/nfs/nfs3super.c
index c84ffe3..28f56e7 100644
--- a/fs/nfs/nfs3super.c
+++ b/fs/nfs/nfs3super.c
@@ -49,6 +49,16 @@ static struct vfsmount *nfs3_do_submount(struct dentry *dentry,
 	return _nfs_do_submount(&nfs_xdev_fs_type, dentry, fh, fattr, authflavor);
 }
 
+static void nfs3_set_layoutdriver(struct nfs_server *server,
+				  const struct nfs_fh *mntfh,
+				  u32 id)
+{
+}
+
+static void nfs3_unset_layoutdriver(struct nfs_server *server)
+{
+}
+
 const struct inode_operations nfs3_file_inode_operations = {
 	.permission	= nfs_permission,
 	.getattr	= nfs_getattr,
@@ -92,6 +102,8 @@ static struct nfs_subversion nfs_v3 = {
 	.submount = nfs3_do_submount,
 	.init_read = nfs_pageio_init_read_mds,
 	.init_write = nfs_pageio_init_write_mds,
+	.set_layoutdriver = nfs3_set_layoutdriver,
+	.unset_layoutdriver = nfs3_unset_layoutdriver,
 };
 
 static int __init init_nfs_v3(void)
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 6bf44e3..7b8e79b 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -658,6 +658,8 @@ static struct nfs_subversion nfs_v4 = {
 	.submount = nfs4_do_submount,
 	.init_read = pnfs_pageio_init_read,
 	.init_write = pnfs_pageio_init_write,
+	.set_layoutdriver = set_pnfs_layoutdriver,
+	.unset_layoutdriver = unset_pnfs_layoutdriver,
 };
 
 int __init init_nfs_v4(void)
-- 
1.7.9.4

