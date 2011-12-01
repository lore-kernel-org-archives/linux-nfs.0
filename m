Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64494 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755445Ab1LAQs2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Dec 2011 11:48:28 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [RFC v2 3/4] NFS: Add functions for adding new NFS versions
Date: Thu,  1 Dec 2011 11:48:21 -0500
Message-Id: <1322758102-29260-4-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1322758102-29260-1-git-send-email-bjschuma@netapp.com>
References: <1322758102-29260-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

These functions and structures allow us to add modular NFS versions at
runtime, rather than requiring them to be compiled directly into the NFS
kernel module.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c         |   65 +++++++++++++++++++++++++++++++++++++++++++---
 fs/nfs/file.c           |    2 +
 fs/nfs/internal.h       |   15 +++++++++++
 fs/nfs/mount_clnt.c     |    1 +
 fs/nfs/nfs3/nfs3proc.c  |    2 +-
 fs/nfs/nfs4proc.c       |    2 +-
 fs/nfs/proc.c           |    2 +-
 fs/nfs/super.c          |    1 +
 include/linux/nfs_xdr.h |    6 ++--
 9 files changed, 85 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c32a21f..9e77056 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -87,6 +87,21 @@ retry:
 static int nfs4_disable_idmapping = 0;
 
 /*
+ * NFS versions
+ */
+static struct nfs_version_ops *nfs_version_ops[5] = {
+	[2] = NULL,
+	[3] = NULL,
+	[4] = NULL,
+};
+
+static struct nfs_rpc_ops *nfs_ops[5] = {
+	[2]	= &nfs_v2_clientops,
+	[3]	= &nfs_v3_clientops,
+	[4]	= &nfs_v4_clientops,
+};
+
+/*
  * RPC cruft for NFS
  */
 static struct rpc_version *nfs_version[5] = {
@@ -137,6 +152,45 @@ struct nfs_client_initdata {
 	u32 minorversion;
 };
 
+void nfs_register_version(unsigned int version, struct nfs_version_ops *ops)
+{
+	nfs_version_ops[version] = ops;
+	nfs_version[version] = ops->nfs_rpc;
+	nfs_ops[version] = ops->nfs_ops;
+#ifdef CONFIG_NFS_V3_ACL
+	nfsacl_version[version] = ops->nfs_acl;
+#endif
+}
+EXPORT_SYMBOL_GPL(nfs_register_version);
+
+void nfs_unregister_version(unsigned int version)
+{
+	struct nfs_version_ops *ops = nfs_version_ops[version];
+	if (ops != NULL) {
+		nfs_version_ops[version] = NULL;
+		nfs_version[version] = NULL;
+		nfs_ops[version] = NULL;
+#ifdef CONFIG_NFS_V3_ACL
+		nfsacl_version[version] = NULL;
+#endif
+	}
+}
+EXPORT_SYMBOL_GPL(nfs_unregister_version);
+
+void nfs_version_ref(unsigned int version)
+{
+	struct nfs_version_ops *nfs = nfs_version_ops[version];
+	if (nfs != NULL)
+		nfs->version_ref();
+}
+
+void nfs_version_unref(unsigned int version)
+{
+	struct nfs_version_ops *nfs = nfs_version_ops[version];
+	if (nfs != NULL)
+		nfs->version_unref();
+}
+
 /*
  * Allocate a shared client record
  *
@@ -825,7 +879,7 @@ static int nfs_init_server(struct nfs_server *server,
 		.hostname = data->nfs_server.hostname,
 		.addr = (const struct sockaddr *)&data->nfs_server.address,
 		.addrlen = data->nfs_server.addrlen,
-		.rpc_ops = &nfs_v2_clientops,
+		.rpc_ops = nfs_ops[data->version],
 		.proto = data->nfs_server.protocol,
 	};
 	struct rpc_timeout timeparms;
@@ -834,10 +888,10 @@ static int nfs_init_server(struct nfs_server *server,
 
 	dprintk("--> nfs_init_server()\n");
 
-#ifdef CONFIG_NFS_V3
-	if (data->version == 3)
-		cl_init.rpc_ops = &nfs_v3_clientops;
-#endif
+	if (cl_init.rpc_ops == NULL) {
+		error = -EPROTONOSUPPORT;
+		goto out;
+	}
 
 	nfs_init_timeout_values(&timeparms, data->nfs_server.protocol,
 			data->timeo, data->retrans);
@@ -899,6 +953,7 @@ static int nfs_init_server(struct nfs_server *server,
 error:
 	server->nfs_client = NULL;
 	nfs_put_client(clp);
+out:
 	dprintk("<-- nfs_init_server() = xerror %d\n", error);
 	return error;
 }
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index eca56d4..90389ca 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -19,6 +19,7 @@
 #include <linux/time.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
+#include <linux/export.h>
 #include <linux/fcntl.h>
 #include <linux/stat.h>
 #include <linux/nfs_fs.h>
@@ -865,6 +866,7 @@ const struct file_operations nfs_file_operations = {
 	.check_flags	= nfs_check_flags,
 	.setlease	= nfs_setlease,
 };
+EXPORT_SYMBOL_GPL(nfs_file_operations);
 
 #ifdef CONFIG_NFS_V4
 static int
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 3f4d957..93a0ba2 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -68,6 +68,21 @@ struct nfs_clone_mount {
 	rpc_authflavor_t authflavor;
 };
 
+struct nfs_version_ops {
+	struct rpc_version *nfs_rpc;
+	struct nfs_rpc_ops *nfs_ops;
+#ifdef CONFIG_NFS_V3_ACL
+	struct rpc_version *nfs_acl;
+#endif
+	void (*version_ref)(void);
+	void (*version_unref)(void);
+};
+
+void nfs_register_version(unsigned int, struct nfs_version_ops *);
+void nfs_unregister_version(unsigned int);
+void nfs_version_ref(unsigned int);
+void nfs_version_unref(unsigned int);
+
 /*
  * Note: RFC 1813 doesn't limit the number of auth flavors that
  * a server can return, so make something up.
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index d4c2d6b..323a105 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -190,6 +190,7 @@ int nfs_mount(struct nfs_mount_request *info)
 		goto out_mnt_err;
 
 	dprintk("NFS: MNT request succeeded\n");
+	nfs_version_ref(info->version);
 	status = 0;
 
 out:
diff --git a/fs/nfs/nfs3/nfs3proc.c b/fs/nfs/nfs3/nfs3proc.c
index f37ddb9..593a44c 100644
--- a/fs/nfs/nfs3/nfs3proc.c
+++ b/fs/nfs/nfs3/nfs3proc.c
@@ -848,7 +848,7 @@ nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
 }
 
-const struct nfs_rpc_ops nfs_v3_clientops = {
+struct nfs_rpc_ops nfs_v3_clientops = {
 	.version	= 3,			/* protocol version */
 	.dentry_ops	= &nfs_dentry_operations,
 	.dir_inode_ops	= &nfs3_dir_inode_operations,
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index be2bbac..58bb8d2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6247,7 +6247,7 @@ static const struct inode_operations nfs4_file_inode_operations = {
 	.removexattr	= generic_removexattr,
 };
 
-const struct nfs_rpc_ops nfs_v4_clientops = {
+struct nfs_rpc_ops nfs_v4_clientops = {
 	.version	= 4,			/* protocol version */
 	.dentry_ops	= &nfs4_dentry_operations,
 	.dir_inode_ops	= &nfs4_dir_inode_operations,
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index f48125d..d3eb291 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -705,7 +705,7 @@ out_einval:
 	return -EINVAL;
 }
 
-const struct nfs_rpc_ops nfs_v2_clientops = {
+struct nfs_rpc_ops nfs_v2_clientops = {
 	.version	= 2,		       /* protocol version */
 	.dentry_ops	= &nfs_dentry_operations,
 	.dir_inode_ops	= &nfs_dir_inode_operations,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 1347774..96967ff 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2334,6 +2334,7 @@ static void nfs_kill_super(struct super_block *s)
 
 	kill_anon_super(s);
 	nfs_fscache_release_super_cookie(s);
+	nfs_version_unref(server->nfs_client->rpc_ops->version);
 	nfs_free_server(server);
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2a7c533..6004f5c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1260,9 +1260,9 @@ struct nfs_rpc_ops {
 /*
  * Function vectors etc. for the NFS client
  */
-extern const struct nfs_rpc_ops	nfs_v2_clientops;
-extern const struct nfs_rpc_ops	nfs_v3_clientops;
-extern const struct nfs_rpc_ops	nfs_v4_clientops;
+extern struct nfs_rpc_ops	nfs_v2_clientops;
+extern struct nfs_rpc_ops	nfs_v3_clientops;
+extern struct nfs_rpc_ops	nfs_v4_clientops;
 extern struct rpc_version	nfs_version2;
 extern struct rpc_version	nfs_version3;
 extern struct rpc_version	nfs_version4;
-- 
1.7.7.4

