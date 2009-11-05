From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 2/5] nfsd: Fix independence of a few nfsd related
	headers
Date: Thu, 5 Nov 2009 11:41:45 -0500
Message-ID: <20091105164145.GC29981@fieldses.org>
References: <4ADEC1EF.8040107@panasas.com> <1256112873-32495-1-git-send-email-bharrosh@panasas.com> <1256171298.6809.1.camel@heimdal.trondhjem.org> <4AE01569.9000002@panasas.com> <1256220146.6402.23.camel@heimdal.trondhjem.org> <4AE08165.2040100@panasas.com> <20091104220927.GS11637@fieldses.org> <4AF2914F.60803@panasas.com> <20091105163333.GB29981@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37959 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756073AbZKEQlg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2009 11:41:36 -0500
In-Reply-To: <20091105163333.GB29981@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

By the way, along the lines of your .h moves, while looking at steved's
export stuff I was reminded again of how much in include/linux/nfsd is
really internal to nfsd, so I'm thinking of committing this.

--b.

>From 0142013a3f49ca296f8880829c67f2afd85b4bfe Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@citi.umich.edu>
Date: Wed, 4 Nov 2009 18:12:35 -0500
Subject: [PATCH] nfsd: make nfsd/vfs.h for common includes

None of this stuff is used outside nfsd, so move it out of the common
linux include directory.

Actually, probably none of the stuff in include/linux/nfsd/nfsd.h really
belongs there, so later we may remove that file entirely.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/lockd.c           |    1 +
 fs/nfsd/nfs2acl.c         |    1 +
 fs/nfsd/nfs3acl.c         |    1 +
 fs/nfsd/nfs3proc.c        |    1 +
 fs/nfsd/nfs4proc.c        |    1 +
 fs/nfsd/nfs4recover.c     |    1 +
 fs/nfsd/nfs4state.c       |    1 +
 fs/nfsd/nfs4xdr.c         |    1 +
 fs/nfsd/nfsfh.c           |    1 +
 fs/nfsd/nfsproc.c         |    1 +
 fs/nfsd/nfssvc.c          |    1 +
 fs/nfsd/vfs.c             |    1 +
 fs/nfsd/vfs.h             |   98 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfsd/nfsd.h |   87 +---------------------------------------
 14 files changed, 111 insertions(+), 86 deletions(-)
 create mode 100644 fs/nfsd/vfs.h

diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index b2786a5..812bc64 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -16,6 +16,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
 #include <linux/lockd/bind.h>
+#include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_LOCKD
 
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 4e3219e..5e8ef72 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -14,6 +14,7 @@
 #include <linux/nfsd/xdr3.h>
 #include <linux/posix_acl.h>
 #include <linux/nfsacl.h>
+#include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 #define RETURN_STATUS(st)	{ resp->status = (st); return (st); }
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 9981dbb..354bf0f 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -13,6 +13,7 @@
 #include <linux/nfsd/xdr3.h>
 #include <linux/posix_acl.h>
 #include <linux/nfsacl.h>
+#include "vfs.h"
 
 #define RETURN_STATUS(st)	{ resp->status = (st); return (st); }
 
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index a713c41..1a259d3 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -25,6 +25,7 @@
 #include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr3.h>
 #include <linux/nfs3.h>
+#include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bebc0c2..60a93cd 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -48,6 +48,7 @@
 #include <linux/nfsd/xdr4.h>
 #include <linux/nfs4_acl.h>
 #include <linux/sunrpc/gss_api.h>
+#include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index b534840..c7a6b24 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -47,6 +47,7 @@
 #include <linux/crypto.h>
 #include <linux/sched.h>
 #include <linux/mount.h>
+#include "vfs.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fcb9817..d3fad54 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -56,6 +56,7 @@
 #include <linux/module.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/clnt.h>
+#include "vfs.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 0fbd50c..db0fc55 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -57,6 +57,7 @@
 #include <linux/nfs4_acl.h>
 #include <linux/sunrpc/gss_api.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 01965b2..d0d8a21 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -22,6 +22,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/nfsd/nfsd.h>
+#include "vfs.h"
 #include "auth.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_FH
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index c5393d1..6c967e1 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -24,6 +24,7 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
+#include "vfs.h"
 
 typedef struct svc_rqst	svc_rqst;
 typedef struct svc_buf	svc_buf;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 67ea83e..2944b31 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -35,6 +35,7 @@
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
 #include <linux/seq_file.h>
+#include "vfs.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 6385739..a7038ed 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -56,6 +56,7 @@
 #endif /* CONFIG_NFSD_V4 */
 #include <linux/jhash.h>
 #include <linux/ima.h>
+#include "vfs.h"
 
 #include <asm/uaccess.h>
 
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
new file mode 100644
index 0000000..b8011fd
--- /dev/null
+++ b/fs/nfsd/vfs.h
@@ -0,0 +1,98 @@
+/*
+ * Copyright (C) 1995-1997 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
+ */
+
+#ifndef LINUX_NFSD_VFS_H
+#define LINUX_NFSD_VFS_H
+
+/*
+ * Flags for nfsd_permission
+ */
+#define NFSD_MAY_NOP		0
+#define NFSD_MAY_EXEC		1 /* == MAY_EXEC */
+#define NFSD_MAY_WRITE		2 /* == MAY_WRITE */
+#define NFSD_MAY_READ		4 /* == MAY_READ */
+#define NFSD_MAY_SATTR		8
+#define NFSD_MAY_TRUNC		16
+#define NFSD_MAY_LOCK		32
+#define NFSD_MAY_OWNER_OVERRIDE	64
+#define NFSD_MAY_LOCAL_ACCESS	128 /* IRIX doing local access check on device special file*/
+#define NFSD_MAY_BYPASS_GSS_ON_ROOT 256
+
+#define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
+#define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
+
+/*
+ * Callback function for readdir
+ */
+typedef int (*nfsd_dirop_t)(struct inode *, struct dentry *, int, int);
+
+/* nfsd/vfs.c */
+int		fh_lock_parent(struct svc_fh *, struct dentry *);
+int		nfsd_racache_init(int);
+void		nfsd_racache_shutdown(void);
+int		nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
+		                struct svc_export **expp);
+__be32		nfsd_lookup(struct svc_rqst *, struct svc_fh *,
+				const char *, unsigned int, struct svc_fh *);
+__be32		 nfsd_lookup_dentry(struct svc_rqst *, struct svc_fh *,
+				const char *, unsigned int,
+				struct svc_export **, struct dentry **);
+__be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
+				struct iattr *, int, time_t);
+#ifdef CONFIG_NFSD_V4
+__be32          nfsd4_set_nfs4_acl(struct svc_rqst *, struct svc_fh *,
+                    struct nfs4_acl *);
+int             nfsd4_get_nfs4_acl(struct svc_rqst *, struct dentry *, struct nfs4_acl **);
+#endif /* CONFIG_NFSD_V4 */
+__be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
+				char *name, int len, struct iattr *attrs,
+				int type, dev_t rdev, struct svc_fh *res);
+#ifdef CONFIG_NFSD_V3
+__be32		nfsd_access(struct svc_rqst *, struct svc_fh *, u32 *, u32 *);
+__be32		nfsd_create_v3(struct svc_rqst *, struct svc_fh *,
+				char *name, int len, struct iattr *attrs,
+				struct svc_fh *res, int createmode,
+				u32 *verifier, int *truncp, int *created);
+__be32		nfsd_commit(struct svc_rqst *, struct svc_fh *,
+				loff_t, unsigned long);
+#endif /* CONFIG_NFSD_V3 */
+__be32		nfsd_open(struct svc_rqst *, struct svc_fh *, int,
+				int, struct file **);
+void		nfsd_close(struct file *);
+__be32 		nfsd_read(struct svc_rqst *, struct svc_fh *, struct file *,
+				loff_t, struct kvec *, int, unsigned long *);
+__be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
+				loff_t, struct kvec *,int, unsigned long *, int *);
+__be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
+				char *, int *);
+__be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
+				char *name, int len, char *path, int plen,
+				struct svc_fh *res, struct iattr *);
+__be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
+				char *, int, struct svc_fh *);
+__be32		nfsd_rename(struct svc_rqst *,
+				struct svc_fh *, char *, int,
+				struct svc_fh *, char *, int);
+__be32		nfsd_remove(struct svc_rqst *,
+				struct svc_fh *, char *, int);
+__be32		nfsd_unlink(struct svc_rqst *, struct svc_fh *, int type,
+				char *name, int len);
+int		nfsd_truncate(struct svc_rqst *, struct svc_fh *,
+				unsigned long size);
+__be32		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
+			     loff_t *, struct readdir_cd *, filldir_t);
+__be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
+				struct kstatfs *, int access);
+
+int		nfsd_notify_change(struct inode *, struct iattr *);
+__be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
+				struct dentry *, int);
+int		nfsd_sync_dir(struct dentry *dp);
+
+#if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+struct posix_acl *nfsd_get_posix_acl(struct svc_fh *, int);
+int nfsd_set_posix_acl(struct svc_fh *, int, struct posix_acl *);
+#endif
+
+#endif /* LINUX_NFSD_VFS_H */
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 510ffdd..e4518d0 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -25,30 +25,10 @@
  */
 #define NFSD_SUPPORTED_MINOR_VERSION	1
 
-/*
- * Flags for nfsd_permission
- */
-#define NFSD_MAY_NOP		0
-#define NFSD_MAY_EXEC		1 /* == MAY_EXEC */
-#define NFSD_MAY_WRITE		2 /* == MAY_WRITE */
-#define NFSD_MAY_READ		4 /* == MAY_READ */
-#define NFSD_MAY_SATTR		8
-#define NFSD_MAY_TRUNC		16
-#define NFSD_MAY_LOCK		32
-#define NFSD_MAY_OWNER_OVERRIDE	64
-#define NFSD_MAY_LOCAL_ACCESS	128 /* IRIX doing local access check on device special file*/
-#define NFSD_MAY_BYPASS_GSS_ON_ROOT 256
-
-#define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
-#define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
-
-/*
- * Callback function for readdir
- */
 struct readdir_cd {
 	__be32			err;	/* 0, nfserr, or nfserr_eof */
 };
-typedef int (*nfsd_dirop_t)(struct inode *, struct dentry *, int, int);
+
 
 extern struct svc_program	nfsd_program;
 extern struct svc_version	nfsd_version2, nfsd_version3,
@@ -73,69 +53,6 @@ int		nfsd_nrpools(void);
 int		nfsd_get_nrthreads(int n, int *);
 int		nfsd_set_nrthreads(int n, int *);
 
-/* nfsd/vfs.c */
-int		fh_lock_parent(struct svc_fh *, struct dentry *);
-int		nfsd_racache_init(int);
-void		nfsd_racache_shutdown(void);
-int		nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
-		                struct svc_export **expp);
-__be32		nfsd_lookup(struct svc_rqst *, struct svc_fh *,
-				const char *, unsigned int, struct svc_fh *);
-__be32		 nfsd_lookup_dentry(struct svc_rqst *, struct svc_fh *,
-				const char *, unsigned int,
-				struct svc_export **, struct dentry **);
-__be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
-				struct iattr *, int, time_t);
-#ifdef CONFIG_NFSD_V4
-__be32          nfsd4_set_nfs4_acl(struct svc_rqst *, struct svc_fh *,
-                    struct nfs4_acl *);
-int             nfsd4_get_nfs4_acl(struct svc_rqst *, struct dentry *, struct nfs4_acl **);
-#endif /* CONFIG_NFSD_V4 */
-__be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
-				char *name, int len, struct iattr *attrs,
-				int type, dev_t rdev, struct svc_fh *res);
-#ifdef CONFIG_NFSD_V3
-__be32		nfsd_access(struct svc_rqst *, struct svc_fh *, u32 *, u32 *);
-__be32		nfsd_create_v3(struct svc_rqst *, struct svc_fh *,
-				char *name, int len, struct iattr *attrs,
-				struct svc_fh *res, int createmode,
-				u32 *verifier, int *truncp, int *created);
-__be32		nfsd_commit(struct svc_rqst *, struct svc_fh *,
-				loff_t, unsigned long);
-#endif /* CONFIG_NFSD_V3 */
-__be32		nfsd_open(struct svc_rqst *, struct svc_fh *, int,
-				int, struct file **);
-void		nfsd_close(struct file *);
-__be32 		nfsd_read(struct svc_rqst *, struct svc_fh *, struct file *,
-				loff_t, struct kvec *, int, unsigned long *);
-__be32 		nfsd_write(struct svc_rqst *, struct svc_fh *,struct file *,
-				loff_t, struct kvec *,int, unsigned long *, int *);
-__be32		nfsd_readlink(struct svc_rqst *, struct svc_fh *,
-				char *, int *);
-__be32		nfsd_symlink(struct svc_rqst *, struct svc_fh *,
-				char *name, int len, char *path, int plen,
-				struct svc_fh *res, struct iattr *);
-__be32		nfsd_link(struct svc_rqst *, struct svc_fh *,
-				char *, int, struct svc_fh *);
-__be32		nfsd_rename(struct svc_rqst *,
-				struct svc_fh *, char *, int,
-				struct svc_fh *, char *, int);
-__be32		nfsd_remove(struct svc_rqst *,
-				struct svc_fh *, char *, int);
-__be32		nfsd_unlink(struct svc_rqst *, struct svc_fh *, int type,
-				char *name, int len);
-int		nfsd_truncate(struct svc_rqst *, struct svc_fh *,
-				unsigned long size);
-__be32		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
-			     loff_t *, struct readdir_cd *, filldir_t);
-__be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
-				struct kstatfs *, int access);
-
-int		nfsd_notify_change(struct inode *, struct iattr *);
-__be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
-				struct dentry *, int);
-int		nfsd_sync_dir(struct dentry *dp);
-
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
 #ifdef CONFIG_NFSD_V2_ACL
 extern struct svc_version nfsd_acl_version2;
@@ -147,8 +64,6 @@ extern struct svc_version nfsd_acl_version3;
 #else
 #define nfsd_acl_version3 NULL
 #endif
-struct posix_acl *nfsd_get_posix_acl(struct svc_fh *, int);
-int nfsd_set_posix_acl(struct svc_fh *, int, struct posix_acl *);
 #endif
 
 enum vers_op {NFSD_SET, NFSD_CLEAR, NFSD_TEST, NFSD_AVAIL };
-- 
1.6.3.3

