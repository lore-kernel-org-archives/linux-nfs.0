Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48854 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754284Ab2G3UFe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jul 2012 16:05:34 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 07/10] NFS: Keep module parameters in the generic NFS client
Date: Mon, 30 Jul 2012 16:05:22 -0400
Message-Id: <1343678725-8659-8-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
References: <1343678725-8659-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

Otherwise we break backwards compatibility when v4 becomes a modules.
---
 fs/nfs/callback.c   | 24 ------------------------
 fs/nfs/idmap.c      |  3 ---
 fs/nfs/nfs4_fs.h    |  4 +++-
 fs/nfs/nfs4client.c |  9 ---------
 fs/nfs/nfs4proc.c   |  6 ------
 fs/nfs/nfs4xdr.c    |  6 ------
 fs/nfs/super.c      | 45 +++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 48 insertions(+), 49 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 23ff18f..ca3ac99 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -37,31 +37,7 @@ static struct nfs_callback_data nfs_callback_info[NFS4_MAX_MINOR_VERSION + 1];
 static DEFINE_MUTEX(nfs_callback_mutex);
 static struct svc_program nfs4_callback_program;
 
-unsigned int nfs_callback_set_tcpport;
-unsigned short nfs_callback_tcpport;
 unsigned short nfs_callback_tcpport6;
-#define NFS_CALLBACK_MAXPORTNR (65535U)
-
-static int param_set_portnr(const char *val, const struct kernel_param *kp)
-{
-	unsigned long num;
-	int ret;
-
-	if (!val)
-		return -EINVAL;
-	ret = strict_strtoul(val, 0, &num);
-	if (ret == -EINVAL || num > NFS_CALLBACK_MAXPORTNR)
-		return -EINVAL;
-	*((unsigned int *)kp->arg) = num;
-	return 0;
-}
-static struct kernel_param_ops param_ops_portnr = {
-	.set = param_set_portnr,
-	.get = param_get_uint,
-};
-#define param_check_portnr(name, p) __param_check(name, p, unsigned int);
-
-module_param_named(callback_tcpport, nfs_callback_set_tcpport, portnr, 0644);
 
 /*
  * This is the NFSv4 callback kernel thread.
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 864c51e..407a9b2 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -52,8 +52,6 @@
 
 #define NFS_UINT_MAXLEN 11
 
-/* Default cache timeout is 10 minutes */
-unsigned int nfs_idmap_cache_timeout = 600;
 static const struct cred *id_resolver_cache;
 static struct key_type key_type_id_resolver_legacy;
 
@@ -359,7 +357,6 @@ static int nfs_idmap_lookup_id(const char *name, size_t namelen, const char *typ
 }
 
 /* idmap classic begins here */
-module_param(nfs_idmap_cache_timeout, int, 0644);
 
 enum {
 	Opt_find_uid, Opt_find_gid, Opt_find_user, Opt_find_group, Opt_find_err
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index af8712d..dfaa26bc 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -367,7 +367,9 @@ extern struct nfs_subversion nfs_v4;
 struct dentry *nfs4_try_mount(int, const char *, struct nfs_mount_info *, struct nfs_subversion *);
 int init_nfs_v4(void);
 void exit_nfs_v4(void);
-
+extern bool nfs4_disable_idmapping;
+extern unsigned short max_session_slots;
+extern unsigned short send_implementation_id;
 /* nfs4sysctl.c */
 #ifdef CONFIG_SYSCTL
 int nfs4_register_sysctl(void);
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index b2d409d..cbcdfaf 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -18,11 +18,6 @@
 #define NFSDBG_FACILITY		NFSDBG_CLIENT
 
 /*
- * Turn off NFSv4 uid/gid mapping when using AUTH_SYS
- */
-static bool nfs4_disable_idmapping = true;
-
-/*
  * Get a unique NFSv4.0 callback identifier which will be used
  * by the V4.0 callback service to lookup the nfs_client struct
  */
@@ -659,7 +654,3 @@ error:
 	dprintk("<-- nfs4_create_referral_server() = error %d\n", error);
 	return ERR_PTR(error);
 }
-
-module_param(nfs4_disable_idmapping, bool, 0644);
-MODULE_PARM_DESC(nfs4_disable_idmapping,
-		"Turn off NFSv4 idmapping when using 'sec=sys'");
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2e87727..a02cb73 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -72,8 +72,6 @@
 
 #define NFS4_MAX_LOOP_ON_RECOVER (10)
 
-static unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;
-
 struct nfs4_opendata;
 static int _nfs4_proc_open(struct nfs4_opendata *data);
 static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
@@ -6932,10 +6930,6 @@ const struct xattr_handler *nfs4_xattr_handlers[] = {
 	NULL
 };
 
-module_param(max_session_slots, ushort, 0644);
-MODULE_PARM_DESC(max_session_slots, "Maximum number of outstanding NFSv4.1 "
-		"requests the client will negotiate");
-
 /*
  * Local variables:
  *  c-basic-offset: 8
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 610ebcc..45ecaee 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -852,12 +852,6 @@ const u32 nfs41_maxread_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
 				    XDR_UNIT);
 #endif /* CONFIG_NFS_V4_1 */
 
-static unsigned short send_implementation_id = 1;
-
-module_param(send_implementation_id, ushort, 0644);
-MODULE_PARM_DESC(send_implementation_id,
-		"Send implementation ID with NFSv4.1 exchange_id");
-
 static const umode_t nfs_type2fmt[] = {
 	[NF4BAD] = 0,
 	[NF4REG] = S_IFREG,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a275d19..8e0da5a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2574,4 +2574,49 @@ out_no_address:
 	return -EINVAL;
 }
 
+/*
+ * NFS v4 module parameters need to stay in the
+ * NFS client for backwards compatibility
+ */
+unsigned int nfs_callback_set_tcpport;
+unsigned short nfs_callback_tcpport;
+/* Default cache timeout is 10 minutes */
+unsigned int nfs_idmap_cache_timeout = 600;
+/* Turn off NFSv4 uid/gid mapping when using AUTH_SYS */
+bool nfs4_disable_idmapping = true;
+unsigned short max_session_slots = NFS4_DEF_SLOT_TABLE_SIZE;
+unsigned short send_implementation_id = 1;
+
+#define NFS_CALLBACK_MAXPORTNR (65535U)
+
+static int param_set_portnr(const char *val, const struct kernel_param *kp)
+{
+	unsigned long num;
+	int ret;
+
+	if (!val)
+		return -EINVAL;
+	ret = strict_strtoul(val, 0, &num);
+	if (ret == -EINVAL || num > NFS_CALLBACK_MAXPORTNR)
+		return -EINVAL;
+	*((unsigned int *)kp->arg) = num;
+	return 0;
+}
+static struct kernel_param_ops param_ops_portnr = {
+	.set = param_set_portnr,
+	.get = param_get_uint,
+};
+#define param_check_portnr(name, p) __param_check(name, p, unsigned int);
+
+module_param_named(callback_tcpport, nfs_callback_set_tcpport, portnr, 0644);
+module_param(nfs_idmap_cache_timeout, int, 0644);
+module_param(nfs4_disable_idmapping, bool, 0644);
+MODULE_PARM_DESC(nfs4_disable_idmapping,
+		"Turn off NFSv4 idmapping when using 'sec=sys'");
+module_param(max_session_slots, ushort, 0644);
+MODULE_PARM_DESC(max_session_slots, "Maximum number of outstanding NFSv4.1 "
+		"requests the client will negotiate");
+module_param(send_implementation_id, ushort, 0644);
+MODULE_PARM_DESC(send_implementation_id,
+		"Send implementation ID with NFSv4.1 exchange_id");
 #endif /* CONFIG_NFS_V4 */
-- 
1.7.11.3

