Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54923 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753426Ab0IVC6R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 22:58:17 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 22 Sep 2010 12:55:07 +1000
Subject: [PATCH 7/7] nfsd: allow deprecated interface to be compiled out.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20100922025507.31745.35688.stgit@localhost.localdomain>
In-Reply-To: <20100922025009.31745.98237.stgit@localhost.localdomain>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Add CONFIG_NFSD_DEPRECATED, default to y.
Only include deprecated interface if this is defined.
This allows distros to remove this interface before the official
removal, and allows developers to test without it.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/Makefile      |    5 +----
 fs/compat.c      |    2 +-
 fs/nfsd/Kconfig  |   12 ++++++++++++
 fs/nfsd/export.c |   22 +++++++++++++++++++---
 fs/nfsd/nfsctl.c |   10 ++++++++++
 5 files changed, 43 insertions(+), 8 deletions(-)

diff --git a/fs/Makefile b/fs/Makefile
index e6ec1d3..26956fc 100644
--- a/fs/Makefile
+++ b/fs/Makefile
@@ -29,10 +29,7 @@ obj-$(CONFIG_EVENTFD)		+= eventfd.o
 obj-$(CONFIG_AIO)               += aio.o
 obj-$(CONFIG_FILE_LOCKING)      += locks.o
 obj-$(CONFIG_COMPAT)		+= compat.o compat_ioctl.o
-
-nfsd-$(CONFIG_NFSD)		:= nfsctl.o
-obj-y				+= $(nfsd-y) $(nfsd-m)
-
+obj-$(CONFIG_NFSD_DEPRECATED)	+= nfsctl.o
 obj-$(CONFIG_BINFMT_AOUT)	+= binfmt_aout.o
 obj-$(CONFIG_BINFMT_EM86)	+= binfmt_em86.o
 obj-$(CONFIG_BINFMT_MISC)	+= binfmt_misc.o
diff --git a/fs/compat.c b/fs/compat.c
index 718c706..df5e671 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -1963,7 +1963,7 @@ asmlinkage long compat_sys_ppoll(struct pollfd __user *ufds,
 }
 #endif /* HAVE_SET_RESTORE_SIGMASK */
 
-#if defined(CONFIG_NFSD) || defined(CONFIG_NFSD_MODULE)
+#if (defined(CONFIG_NFSD) || defined(CONFIG_NFSD_MODULE)) && !defined(CONFIG_NFSD_DEPRECATED)
 /* Stuff for NFS server syscalls... */
 struct compat_nfsctl_svc {
 	u16			svc32_port;
diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 4264377..18b3e89 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -28,6 +28,18 @@ config NFSD
 
 	  If unsure, say N.
 
+config NFSD_DEPRECATED
+	bool "Include support for deprecated syscall interface to NFSD"
+	depends on NFSD
+	default y
+	help
+	  The syscall interface to nfsd was obsoleted in 2.6.0 by a new
+	  filesystem based interface.  The old interface is due for removal
+	  in 2.6.40.  If you wish to remove the interface before then
+	  say N.
+
+	  In unsure, say Y.
+
 config NFSD_V2_ACL
 	bool
 	depends on NFSD
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index e56827b..a3c7d0c 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -28,9 +28,6 @@
 typedef struct auth_domain	svc_client;
 typedef struct svc_export	svc_export;
 
-static void		exp_do_unexport(svc_export *unexp);
-static int		exp_verify_string(char *cp, int max);
-
 /*
  * We have two caches.
  * One maps client+vfsmnt+dentry to export options - the export map
@@ -802,6 +799,7 @@ exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv, struct cache_req *reqp)
 	return ek;
 }
 
+#ifdef CONFIG_NFSD_DEPRECATED
 static int exp_set_key(svc_client *clp, int fsid_type, u32 *fsidv,
 		       struct svc_export *exp)
 {
@@ -852,6 +850,7 @@ exp_get_fsid_key(svc_client *clp, int fsid)
 
 	return exp_find_key(clp, FSID_NUM, fsidv, NULL);
 }
+#endif
 
 static svc_export *exp_get_by_name(svc_client *clp, const struct path *path,
 				     struct cache_req *reqp)
@@ -893,6 +892,7 @@ static struct svc_export *exp_parent(svc_client *clp, struct path *path)
 	return exp;
 }
 
+#ifdef CONFIG_NFSD_DEPRECATED
 /*
  * Hashtable locking. Write locks are placed only by user processes
  * wanting to modify export information.
@@ -925,6 +925,19 @@ exp_writeunlock(void)
 {
 	up_write(&hash_sem);
 }
+#else
+
+/* hash_sem not needed once deprecated interface is removed */
+void exp_readlock(void) {}
+static inline void exp_writelock(void){}
+void exp_readunlock(void) {}
+static inline void exp_writeunlock(void){}
+
+#endif
+
+#ifdef CONFIG_NFSD_DEPRECATED
+static void		exp_do_unexport(svc_export *unexp);
+static int		exp_verify_string(char *cp, int max);
 
 static void exp_fsid_unhash(struct svc_export *exp)
 {
@@ -1147,6 +1160,7 @@ out_unlock:
 	exp_writeunlock();
 	return err;
 }
+#endif /* CONFIG_NFSD_DEPRECATED */
 
 /*
  * Obtain the root fh on behalf of a client.
@@ -1529,6 +1543,7 @@ const struct seq_operations nfs_exports_op = {
 	.show	= e_show,
 };
 
+#ifdef CONFIG_NFSD_DEPRECATED
 /*
  * Add or modify a client.
  * Change requests may involve the list of host addresses. The list of
@@ -1618,6 +1633,7 @@ exp_verify_string(char *cp, int max)
 	printk(KERN_NOTICE "nfsd: couldn't validate string %s\n", cp);
 	return 0;
 }
+#endif /* CONFIG_NFSD_DEPRECATED */
 
 /*
  * Initialize the exports module.
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 7f0fc88..b278e44 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -22,6 +22,7 @@
  */
 enum {
 	NFSD_Root = 1,
+#ifdef CONFIG_NFSD_DEPRECATED
 	NFSD_Svc,
 	NFSD_Add,
 	NFSD_Del,
@@ -29,6 +30,7 @@ enum {
 	NFSD_Unexport,
 	NFSD_Getfd,
 	NFSD_Getfs,
+#endif
 	NFSD_List,
 	NFSD_Export_features,
 	NFSD_Fh,
@@ -54,6 +56,7 @@ enum {
 /*
  * write() for these nodes.
  */
+#ifdef CONFIG_NFSD_DEPRECATED
 static ssize_t write_svc(struct file *file, char *buf, size_t size);
 static ssize_t write_add(struct file *file, char *buf, size_t size);
 static ssize_t write_del(struct file *file, char *buf, size_t size);
@@ -61,6 +64,7 @@ static ssize_t write_export(struct file *file, char *buf, size_t size);
 static ssize_t write_unexport(struct file *file, char *buf, size_t size);
 static ssize_t write_getfd(struct file *file, char *buf, size_t size);
 static ssize_t write_getfs(struct file *file, char *buf, size_t size);
+#endif
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
 static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size);
 static ssize_t write_unlock_fs(struct file *file, char *buf, size_t size);
@@ -76,6 +80,7 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
+#ifdef CONFIG_NFSD_DEPRECATED
 	[NFSD_Svc] = write_svc,
 	[NFSD_Add] = write_add,
 	[NFSD_Del] = write_del,
@@ -83,6 +88,7 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Unexport] = write_unexport,
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
+#endif
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_FO_UnlockIP] = write_unlock_ip,
 	[NFSD_FO_UnlockFS] = write_unlock_fs,
@@ -196,6 +202,7 @@ static const struct file_operations pool_stats_operations = {
  * payload - write methods
  */
 
+#ifdef CONFIG_NFSD_DEPRECATED
 /**
  * write_svc - Start kernel's NFSD server
  *
@@ -491,6 +498,7 @@ static ssize_t write_getfd(struct file *file, char *buf, size_t size)
  out:
 	return err;
 }
+#endif /* CONFIG_NFSD_DEPRECATED */
 
 /**
  * write_unlock_ip - Release all locks used by a client
@@ -1365,6 +1373,7 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
 static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 {
 	static struct tree_descr nfsd_files[] = {
+#ifdef CONFIG_NFSD_DEPRECATED
 		[NFSD_Svc] = {".svc", &transaction_ops, S_IWUSR},
 		[NFSD_Add] = {".add", &transaction_ops, S_IWUSR},
 		[NFSD_Del] = {".del", &transaction_ops, S_IWUSR},
@@ -1372,6 +1381,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Unexport] = {".unexport", &transaction_ops, S_IWUSR},
 		[NFSD_Getfd] = {".getfd", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
+#endif
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_Export_features] = {"export_features",
 					&export_features_operations, S_IRUGO},


