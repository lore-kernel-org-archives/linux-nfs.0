From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 12/85] nfs41: set nfs_client rpc_ops based on minorversion
Date: Mon, 10 Nov 2008 22:19:55 +0200
Message-ID: <1226348395-7418-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:60732 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbYKJUUB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:20:01 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c         |    6 ++--
 fs/nfs/nfs4proc.c       |   49 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/nfs_xdr.h |    3 ++
 3 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c6e9b4e..7bc150b 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -359,7 +359,8 @@ static struct nfs_client *nfs_get_client(const struct nfs_client_initdata *cl_in
 	int error;
 
 	dprintk("--> nfs_get_client(%s,v%u)\n",
-		cl_init->hostname ?: "", cl_init->rpc_ops->version);
+		cl_init->hostname ?: "",
+		cl_init->rpc_ops ? cl_init->rpc_ops->version : 0);
 
 	/* see if the client already exists */
 	do {
@@ -976,7 +977,7 @@ static int nfs4_init_client(struct nfs_client *clp,
 	}
 
 	/* Check NFS protocol revision and initialize RPC op vector */
-	clp->rpc_ops = &nfs_v4_clientops;
+	clp->rpc_ops = nfsv4_minorversion_clientops[clp->cl_minorversion];
 
 	error = nfs_create_rpc_client(clp, timeparms, authflavour,
 					RPC_CLNT_CREATE_DISCRTRY);
@@ -1016,7 +1017,6 @@ static int nfs4_set_client(struct nfs_server *server,
 		.hostname = hostname,
 		.addr = addr,
 		.addrlen = addrlen,
-		.rpc_ops = &nfs_v4_clientops,
 		.proto = proto,
 	};
 	struct nfs_client *clp;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 83e700a..0256c97 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3682,7 +3682,7 @@ static const struct inode_operations nfs4_file_inode_operations = {
 	.listxattr	= nfs4_listxattr,
 };
 
-const struct nfs_rpc_ops nfs_v4_clientops = {
+const struct nfs_rpc_ops nfs_v40_clientops = {
 	.version	= 4,			/* protocol version */
 	.dentry_ops	= &nfs4_dentry_operations,
 	.dir_inode_ops	= &nfs4_dir_inode_operations,
@@ -3720,6 +3720,53 @@ const struct nfs_rpc_ops nfs_v4_clientops = {
 	.clear_acl_cache = nfs4_zap_acl_attr,
 };
 
+#if defined(CONFIG_NFS_V4_1)
+const struct nfs_rpc_ops nfs_v41_clientops = {
+	.version	= 4,			/* protocol version */
+	.dentry_ops	= &nfs4_dentry_operations,
+	.dir_inode_ops	= &nfs4_dir_inode_operations,
+	.file_inode_ops	= &nfs4_file_inode_operations,
+	.getroot	= nfs4_proc_get_root,
+	.getattr	= nfs4_proc_getattr,
+	.setattr	= nfs4_proc_setattr,
+	.lookupfh	= nfs4_proc_lookupfh,
+	.lookup		= nfs4_proc_lookup,
+	.access		= nfs4_proc_access,
+	.readlink	= nfs4_proc_readlink,
+	.create		= nfs4_proc_create,
+	.remove		= nfs4_proc_remove,
+	.unlink_setup	= nfs4_proc_unlink_setup,
+	.unlink_done	= nfs4_proc_unlink_done,
+	.rename		= nfs4_proc_rename,
+	.link		= nfs4_proc_link,
+	.symlink	= nfs4_proc_symlink,
+	.mkdir		= nfs4_proc_mkdir,
+	.rmdir		= nfs4_proc_remove,
+	.readdir	= nfs4_proc_readdir,
+	.mknod		= nfs4_proc_mknod,
+	.statfs		= nfs4_proc_statfs,
+	.fsinfo		= nfs4_proc_fsinfo,
+	.pathconf	= nfs4_proc_pathconf,
+	.set_capabilities = nfs4_server_capabilities,
+	.decode_dirent	= nfs4_decode_dirent,
+	.read_setup	= nfs4_proc_read_setup,
+	.read_done	= nfs4_read_done,
+	.write_setup	= nfs4_proc_write_setup,
+	.write_done	= nfs4_write_done,
+	.commit_setup	= nfs4_proc_commit_setup,
+	.commit_done	= nfs4_commit_done,
+	.lock		= nfs4_proc_lock,
+	.clear_acl_cache = nfs4_zap_acl_attr,
+};
+#endif /* CONFIG_NFS_V4_1 */
+
+const struct nfs_rpc_ops *nfsv4_minorversion_clientops[] = {
+	&nfs_v40_clientops,
+#if defined(CONFIG_NFS_V4_1)
+	&nfs_v41_clientops,
+#endif
+};
+
 /*
  * Local variables:
  *  c-basic-offset: 8
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a8a0953..1d6f09a 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -966,6 +966,9 @@ struct nfs_rpc_ops {
 extern const struct nfs_rpc_ops	nfs_v2_clientops;
 extern const struct nfs_rpc_ops	nfs_v3_clientops;
 extern const struct nfs_rpc_ops	nfs_v4_clientops;
+extern const struct nfs_rpc_ops	nfs_v40_clientops;
+extern const struct nfs_rpc_ops	nfs_v41_clientops;
+extern const struct nfs_rpc_ops	*nfsv4_minorversion_clientops[];
 extern struct rpc_version	nfs_version2;
 extern struct rpc_version	nfs_version3;
 extern struct rpc_version	nfs_version4;
-- 
1.6.0.2

