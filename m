Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:21401 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932757Ab2AMUL1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:27 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 27/44] NFS: Create a custom alloc_client() function
Date: Fri, 13 Jan 2012 15:10:36 -0500
Message-Id: <1326485453-1350-28-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This gives v4 a chance to initialize the client idr structure.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/client.c      |   42 +++++++++++++++++++++++-------------------
 fs/nfs/nfs.h         |   10 ++++++++++
 fs/nfs/nfs2/client.c |    6 ++++++
 fs/nfs/nfs2/module.c |    1 +
 fs/nfs/nfs2/nfs2.h   |    3 +++
 fs/nfs/nfs3/client.c |    4 ++++
 fs/nfs/nfs3/module.c |    1 +
 fs/nfs/nfs3/nfs3.h   |    3 +++
 fs/nfs/nfs4/nfs4.h   |    1 +
 9 files changed, 52 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dc10b2e..a4b7634 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -139,6 +139,7 @@ static struct nfs_subversion nfs_v4_mod = {
 	.unreference = nfs_module_null_function,
 	.validate_mount_data = nfs4_validate_text_mount_data,
 	.init_aclclient = nfs4_init_aclclient,
+	.alloc_client = nfs4_alloc_client,
 	.try_mount = nfs4_try_mount,
 	.shutdown_client = nfs4_shutdown_client,
 	.have_delegation = nfs4_have_delegation,
@@ -149,15 +150,6 @@ static struct nfs_subversion nfs_v4_mod = {
 };
 #endif /* CONFIG_NFS_V4 */
 
-struct nfs_client_initdata {
-	const char *hostname;
-	const struct sockaddr *addr;
-	size_t addrlen;
-	const struct nfs_rpc_ops *rpc_ops;
-	int proto;
-	u32 minorversion;
-};
-
 struct nfs_subversion *get_nfs_version(unsigned int version)
 {
 	struct nfs_subversion *nfs;
@@ -224,6 +216,25 @@ void __init nfs_register_versions(void)
 #endif
 }
 
+#ifdef CONFIG_NFS_V4
+int nfs4_alloc_client(struct nfs_client *clp, const struct nfs_client_initdata *cl_init)
+{
+	int err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
+	if (err)
+		return err;
+
+	spin_lock_init(&clp->cl_lock);
+	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
+	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
+	clp->cl_boot_time = CURRENT_TIME;
+	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
+	clp->cl_minorversion = cl_init->minorversion;
+	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
+
+	return 0;
+}
+#endif
+
 /*
  * Allocate a shared client record
  *
@@ -234,6 +245,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 {
 	struct nfs_client *clp;
 	struct rpc_cred *cred;
+	struct nfs_subversion *nfs_mod;
 	int err = -ENOMEM;
 
 	if ((clp = kzalloc(sizeof(*clp), GFP_KERNEL)) == NULL)
@@ -259,19 +271,11 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 
 	clp->cl_proto = cl_init->proto;
 
-#ifdef CONFIG_NFS_V4
-	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
+	nfs_mod = get_nfs_client_version(clp);
+	err = nfs_mod->alloc_client(clp, cl_init);
 	if (err)
 		goto error_cleanup;
 
-	spin_lock_init(&clp->cl_lock);
-	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
-	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
-	clp->cl_boot_time = CURRENT_TIME;
-	clp->cl_state = 1 << NFS4CLNT_LEASE_EXPIRED;
-	clp->cl_minorversion = cl_init->minorversion;
-	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
-#endif
 	cred = rpc_lookup_machine_cred("*");
 	if (!IS_ERR(cred))
 		clp->cl_machine_cred = cred;
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 3aa900d..b2a930d 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -14,6 +14,15 @@
 struct nfs_clone_mount;
 struct nfs_parsed_mount_data;
 
+struct nfs_client_initdata {
+	const char *hostname;
+	const struct sockaddr *addr;
+	size_t addrlen;
+	const struct nfs_rpc_ops *rpc_ops;
+	int proto;
+	u32 minorversion;
+};
+
 struct nfs_subversion {
 	unsigned int version;		/* Protocol number */
 	struct rpc_version *rpc_vers;	/* NFS version information */
@@ -27,6 +36,7 @@ struct nfs_subversion {
 				   struct nfs_fh *,
 				   const char *);
 	void (*init_aclclient)(struct nfs_server *);
+	int (*alloc_client)(struct nfs_client *, const struct nfs_client_initdata *);
 	struct dentry *(*try_mount)(struct file_system_type *, int,
 				    const char *, struct nfs_fh *,
 				    struct nfs_parsed_mount_data *);
diff --git a/fs/nfs/nfs2/client.c b/fs/nfs/nfs2/client.c
index 1150704..36d6499 100644
--- a/fs/nfs/nfs2/client.c
+++ b/fs/nfs/nfs2/client.c
@@ -4,9 +4,15 @@
 #include <linux/sunrpc/sched.h>
 #include <linux/nfs_fs_sb.h>
 #include <linux/nfs_mount.h>
+#include "nfs2.h"
 
 void nfs2_init_aclclient(struct nfs_server *server)
 {
 	server->flags &= ~NFS_MOUNT_NOACL;
 	server->caps &= ~NFS_CAP_ACLS;
 }
+
+int nfs2_alloc_client(struct nfs_client *clp, const struct nfs_client_initdata *cl_init)
+{
+	return 0;
+}
diff --git a/fs/nfs/nfs2/module.c b/fs/nfs/nfs2/module.c
index 5efe3d8..e527001 100644
--- a/fs/nfs/nfs2/module.c
+++ b/fs/nfs/nfs2/module.c
@@ -42,6 +42,7 @@ struct nfs_subversion nfs_v2 = {
 	.unreference = nfs2_unreference,
 	.validate_mount_data = nfs_validate_text_mount_data,
 	.init_aclclient = nfs2_init_aclclient,
+	.alloc_client = nfs2_alloc_client,
 	.try_mount = generic_nfs_fs_mount,
 	.shutdown_client = nfs2_shutdown_client,
 	.have_delegation = nfs2_no_delegation,
diff --git a/fs/nfs/nfs2/nfs2.h b/fs/nfs/nfs2/nfs2.h
index 76e62bf..2ce1245 100644
--- a/fs/nfs/nfs2/nfs2.h
+++ b/fs/nfs/nfs2/nfs2.h
@@ -4,10 +4,13 @@
 #include <linux/fs.h>
 #include <linux/sunrpc/clnt.h>
 
+#include "../nfs.h"
+
 extern struct rpc_version nfs_version2;
 extern const struct nfs_rpc_ops nfs_v2_clientops;
 
 void nfs2_init_aclclient(struct nfs_server *);
+int nfs2_alloc_client(struct nfs_client *, const struct nfs_client_initdata *);
 
 extern const struct inode_operations nfs_file_inode_operations;
 extern const struct file_operations nfs_file_operations;
diff --git a/fs/nfs/nfs3/client.c b/fs/nfs/nfs3/client.c
index 9f7e997..4aa2024 100644
--- a/fs/nfs/nfs3/client.c
+++ b/fs/nfs/nfs3/client.c
@@ -56,3 +56,7 @@ void nfs3_init_aclclient(struct nfs_server *server)
 }
 #endif
 
+int nfs3_alloc_client(struct nfs_client *clp, const struct nfs_client_initdata *cl_init)
+{
+	return 0;
+}
diff --git a/fs/nfs/nfs3/module.c b/fs/nfs/nfs3/module.c
index f9c979f..a63dbe7 100644
--- a/fs/nfs/nfs3/module.c
+++ b/fs/nfs/nfs3/module.c
@@ -42,6 +42,7 @@ struct nfs_subversion nfs_v3 = {
 	.unreference = nfs3_unreference,
 	.validate_mount_data = nfs_validate_text_mount_data,
 	.init_aclclient = nfs3_init_aclclient,
+	.alloc_client = nfs3_alloc_client,
 	.try_mount = generic_nfs_fs_mount,
 	.shutdown_client = nfs3_shutdown_client,
 	.have_delegation = nfs3_no_delegation,
diff --git a/fs/nfs/nfs3/nfs3.h b/fs/nfs/nfs3/nfs3.h
index 5ed7efa..d43df84 100644
--- a/fs/nfs/nfs3/nfs3.h
+++ b/fs/nfs/nfs3/nfs3.h
@@ -4,10 +4,13 @@
 #include <linux/fs.h>
 #include <linux/sunrpc/clnt.h>
 
+#include "../nfs.h"
+
 extern struct rpc_version nfs_version3;
 extern struct nfs_rpc_ops nfs_v3_clientops;
 
 void nfs3_init_aclclient(struct nfs_server *);
+int nfs3_alloc_client(struct nfs_client *, const struct nfs_client_initdata *);
 
 extern const struct inode_operations nfs3_file_inode_operations;
 extern const struct file_operations nfs3_file_operations;
diff --git a/fs/nfs/nfs4/nfs4.h b/fs/nfs/nfs4/nfs4.h
index 6ff094f..37f12d6 100644
--- a/fs/nfs/nfs4/nfs4.h
+++ b/fs/nfs/nfs4/nfs4.h
@@ -14,5 +14,6 @@ struct dentry *nfs4_try_mount(struct file_system_type *, int, const char *,
 			      struct nfs_fh *, struct nfs_parsed_mount_data *);
 int nfs4_validate_text_mount_data(void *, struct nfs_parsed_mount_data *,
 				  struct nfs_fh *, const char *);
+int nfs4_alloc_client(struct nfs_client *, const struct nfs_client_initdata *);
 
 #endif /* __LINUX_FS_NFS_NFS4_H */
-- 
1.7.8.3

