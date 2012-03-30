Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51498 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761268Ab2C3TCt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Mar 2012 15:02:49 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 05/10] NFS: Rename nfs4_proc_get_root()
Date: Fri, 30 Mar 2012 15:02:32 -0400
Message-Id: <1333134157-17141-6-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
References: <1333134157-17141-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This function is really getting the root filehandle and not the root
dentry of the filesystem.  I also removed the rpc_ops lookup from
nfs4_get_rootfh() under the assumption that if we reach this function
then we already know we are using NFS v4.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/getroot.c  |    2 +-
 fs/nfs/nfs4_fs.h  |    1 +
 fs/nfs/nfs4proc.c |    6 +++---
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
index 4ca6f5c..8a0f33e 100644
--- a/fs/nfs/getroot.c
+++ b/fs/nfs/getroot.c
@@ -150,7 +150,7 @@ int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
 		goto out;
 
 	/* Start by getting the root filehandle from the server */
-	ret = server->nfs_client->rpc_ops->getroot(server, mntfh, &fsinfo);
+	ret = nfs4_proc_get_rootfh(server, mntfh, &fsinfo);
 	if (ret < 0) {
 		dprintk("nfs4_get_rootfh: getroot error = %d\n", -ret);
 		goto out;
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 97ecc86..f2dc8d5 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -207,6 +207,7 @@ extern const struct inode_operations nfs4_dir_inode_operations;
 /* nfs4proc.c */
 extern int nfs4_proc_setclientid(struct nfs_client *, u32, unsigned short, struct rpc_cred *, struct nfs4_setclientid_res *);
 extern int nfs4_proc_setclientid_confirm(struct nfs_client *, struct nfs4_setclientid_res *arg, struct rpc_cred *);
+extern int nfs4_proc_get_rootfh(struct nfs_server *, struct nfs_fh *, struct nfs_fsinfo *);
 extern int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred);
 extern int nfs4_init_clientid(struct nfs_client *, struct rpc_cred *);
 extern int nfs41_init_clientid(struct nfs_client *, struct rpc_cred *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f82bde0..bd00e10 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2345,8 +2345,8 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 /*
  * get the file handle for the "/" directory on the server
  */
-static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
-			      struct nfs_fsinfo *info)
+int nfs4_proc_get_rootfh(struct nfs_server *server, struct nfs_fh *fhandle,
+			 struct nfs_fsinfo *info)
 {
 	int minor_version = server->nfs_client->cl_minorversion;
 	int status = nfs4_lookup_root(server, fhandle, info);
@@ -6465,7 +6465,7 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.dir_inode_ops	= &nfs4_dir_inode_operations,
 	.file_inode_ops	= &nfs4_file_inode_operations,
 	.file_ops	= &nfs4_file_operations,
-	.getroot	= nfs4_proc_get_root,
+	.getroot	= nfs4_proc_get_rootfh,
 	.getattr	= nfs4_proc_getattr,
 	.setattr	= nfs4_proc_setattr,
 	.lookup		= nfs4_proc_lookup,
-- 
1.7.9.5

