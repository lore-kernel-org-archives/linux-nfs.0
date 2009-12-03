From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 12/12] nfsd: Move private headers to source directory
Date: Thu,  3 Dec 2009 20:30:56 +0200
Message-ID: <1259865056-4969-1-git-send-email-bharrosh@panasas.com>
References: <4B1802D0.8060206@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47818 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756159AbZLCSaw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Dec 2009 13:30:52 -0500
In-Reply-To: <4B1802D0.8060206@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lots of include/linux/nfsd/* headers are only used by
nfsd module. Move them to the source directory

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfsd/auth.c                     |    2 +-
 {include/linux => fs}/nfsd/cache.h |    0
 fs/nfsd/export.c                   |    3 ++-
 fs/nfsd/lockd.c                    |    2 +-
 fs/nfsd/nfs2acl.c                  |    7 ++++---
 fs/nfsd/nfs3acl.c                  |    7 ++++---
 fs/nfsd/nfs3proc.c                 |    4 ++--
 fs/nfsd/nfs3xdr.c                  |    2 +-
 fs/nfsd/nfs4callback.c             |    4 ++--
 fs/nfsd/nfs4proc.c                 |    4 ++--
 fs/nfsd/nfs4recover.c              |    5 +++--
 fs/nfsd/nfs4state.c                |    2 +-
 fs/nfsd/nfs4xdr.c                  |    3 ++-
 fs/nfsd/nfscache.c                 |    4 ++--
 fs/nfsd/nfsctl.c                   |    5 +++--
 {include/linux => fs}/nfsd/nfsd.h  |    0
 fs/nfsd/nfsfh.c                    |    2 +-
 fs/nfsd/nfsproc.c                  |    4 ++--
 fs/nfsd/nfssvc.c                   |    4 ++--
 fs/nfsd/nfsxdr.c                   |    2 +-
 {include/linux => fs}/nfsd/state.h |    0
 fs/nfsd/stats.c                    |    4 ++--
 fs/nfsd/vfs.c                      |   18 ++++++++++--------
 {include/linux => fs}/nfsd/xdr.h   |    2 +-
 {include/linux => fs}/nfsd/xdr3.h  |    2 +-
 {include/linux => fs}/nfsd/xdr4.h  |    4 ++--
 26 files changed, 52 insertions(+), 44 deletions(-)
 rename {include/linux => fs}/nfsd/cache.h (100%)
 rename {include/linux => fs}/nfsd/nfsd.h (100%)
 rename {include/linux => fs}/nfsd/state.h (100%)
 rename {include/linux => fs}/nfsd/xdr.h (99%)
 rename {include/linux => fs}/nfsd/xdr3.h (99%)
 rename {include/linux => fs}/nfsd/xdr4.h (99%)

diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index ad354d2..71209d4 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -5,7 +5,7 @@
  */
 
 #include <linux/sched.h>
-#include <linux/nfsd/nfsd.h>
+#include "nfsd.h"
 #include "auth.h"
 
 int nfsexp_flags(struct svc_rqst *rqstp, struct svc_export *exp)
diff --git a/include/linux/nfsd/cache.h b/fs/nfsd/cache.h
similarity index 100%
rename from include/linux/nfsd/cache.h
rename to fs/nfsd/cache.h
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 68e63f4..cb3dae2 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -18,10 +18,11 @@
 #include <linux/module.h>
 #include <linux/exportfs.h>
 
-#include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/syscall.h>
 #include <net/ipv6.h>
 
+#include "nfsd.h"
+
 #define NFSDDBG_FACILITY	NFSDDBG_EXPORT
 
 typedef struct auth_domain	svc_client;
diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index 801ef71..6f12777 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -9,8 +9,8 @@
  */
 
 #include <linux/file.h>
-#include <linux/nfsd/nfsd.h>
 #include <linux/lockd/bind.h>
+#include "nfsd.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_LOCKD
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index a54628d..874e2a9 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -6,10 +6,11 @@
  * Copyright (C) 2002-2003 Andreas Gruenbacher <agruen@suse.de>
  */
 
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
-#include <linux/nfsd/xdr3.h>
+#include "nfsd.h"
+/* FIXME: nfsacl.h is a broken header */
 #include <linux/nfsacl.h>
+#include "cache.h"
+#include "xdr3.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 2f5c61b..c6011dd 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -6,10 +6,11 @@
  * Copyright (C) 2002-2003 Andreas Gruenbacher <agruen@suse.de>
  */
 
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
-#include <linux/nfsd/xdr3.h>
+#include "nfsd.h"
+/* FIXME: nfsacl.h is a broken header */
 #include <linux/nfsacl.h>
+#include "cache.h"
+#include "xdr3.h"
 #include "vfs.h"
 
 #define RETURN_STATUS(st)	{ resp->status = (st); return (st); }
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index b694b43..90b19ca 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -10,8 +10,8 @@
 #include <linux/ext2_fs.h>
 #include <linux/magic.h>
 
-#include <linux/nfsd/cache.h>
-#include <linux/nfsd/xdr3.h>
+#include "cache.h"
+#include "xdr3.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 623e13a..c523bb8 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -9,7 +9,7 @@
  */
 
 #include <linux/namei.h>
-#include <linux/nfsd/xdr3.h>
+#include "xdr3.h"
 #include "auth.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 4fe3960..f7a3158 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -34,8 +34,8 @@
  */
 
 #include <linux/sunrpc/clnt.h>
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/state.h>
+#include "nfsd.h"
+#include "state.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d0e04cb..f8a37c4 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -36,8 +36,8 @@
  */
 #include <linux/file.h>
 
-#include <linux/nfsd/cache.h>
-#include <linux/nfsd/xdr4.h>
+#include "cache.h"
+#include "xdr4.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 48742f2..6744e7f 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -33,12 +33,13 @@
 *
 */
 
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/state.h>
 #include <linux/file.h>
 #include <linux/namei.h>
 #include <linux/crypto.h>
 #include <linux/sched.h>
+
+#include "nfsd.h"
+#include "state.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1fe6e29..2923e6c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -36,11 +36,11 @@
 
 #include <linux/file.h>
 #include <linux/smp_lock.h>
-#include <linux/nfsd/xdr4.h>
 #include <linux/namei.h>
 #include <linux/swap.h>
 #include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/clnt.h>
+#include "xdr4.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2fa9682..cab9780 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -43,10 +43,11 @@
 #include <linux/namei.h>
 #include <linux/statfs.h>
 #include <linux/utsname.h>
-#include <linux/nfsd/xdr4.h>
 #include <linux/nfsd_idmap.h>
 #include <linux/nfs4_acl.h>
 #include <linux/sunrpc/svcauth_gss.h>
+
+#include "xdr4.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 96694b8..18aa972 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -10,8 +10,8 @@
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
+#include "nfsd.h"
+#include "cache.h"
 
 /* Size of reply cache. Common values are:
  * 4.3BSD:	128
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e4f49fd..0415680 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -11,12 +11,13 @@
 
 #include <linux/nfsd_idmap.h>
 #include <linux/sunrpc/svcsock.h>
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/lockd/lockd.h>
 #include <linux/sunrpc/clnt.h>
 
+#include "nfsd.h"
+#include "cache.h"
+
 /*
  *	We have a single directory with 9 nodes in it.
  */
diff --git a/include/linux/nfsd/nfsd.h b/fs/nfsd/nfsd.h
similarity index 100%
rename from include/linux/nfsd/nfsd.h
rename to fs/nfsd/nfsd.h
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 4ef4601..2bf9efb 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -12,7 +12,7 @@
 #include <linux/exportfs.h>
 
 #include <linux/sunrpc/svcauth_gss.h>
-#include <linux/nfsd/nfsd.h>
+#include "nfsd.h"
 #include "vfs.h"
 #include "auth.h"
 
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index b6bd9e0..21a5f79 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -9,8 +9,8 @@
 
 #include <linux/namei.h>
 
-#include <linux/nfsd/cache.h>
-#include <linux/nfsd/xdr.h>
+#include "cache.h"
+#include "xdr.h"
 #include "vfs.h"
 
 typedef struct svc_rqst	svc_rqst;
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index b2d7ffa..b520ce1 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -15,11 +15,11 @@
 
 #include <linux/sunrpc/stats.h>
 #include <linux/sunrpc/svcsock.h>
-#include <linux/nfsd/nfsd.h>
-#include <linux/nfsd/cache.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
 #include <linux/seq_file.h>
+#include "nfsd.h"
+#include "cache.h"
 #include "vfs.h"
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 5e0603d..3bec831 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -6,7 +6,7 @@
  * Copyright (C) 1995, 1996 Olaf Kirch <okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org>
  */
 
-#include <linux/nfsd/xdr.h>
+#include "xdr.h"
 #include "auth.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
diff --git a/include/linux/nfsd/state.h b/fs/nfsd/state.h
similarity index 100%
rename from include/linux/nfsd/state.h
rename to fs/nfsd/state.h
diff --git a/fs/nfsd/stats.c b/fs/nfsd/stats.c
index e3e411e..3fc69df 100644
--- a/fs/nfsd/stats.c
+++ b/fs/nfsd/stats.c
@@ -25,11 +25,11 @@
 
 #include <linux/seq_file.h>
 #include <linux/module.h>
-
 #include <linux/sunrpc/stats.h>
-#include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/stats.h>
 
+#include "nfsd.h"
+
 struct nfsd_stats	nfsdstats;
 struct svc_stat		nfsd_svcstats = {
 	.program	= &nfsd_program,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 81ce108..04bdba1 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -22,23 +22,25 @@
 #include <linux/fcntl.h>
 #include <linux/namei.h>
 #include <linux/delay.h>
-#include <linux/nfsd/nfsd.h>
-#ifdef CONFIG_NFSD_V3
-#include <linux/nfsd/xdr3.h>
-#endif /* CONFIG_NFSD_V3 */
 #include <linux/quotaops.h>
 #include <linux/fsnotify.h>
 #include <linux/posix_acl_xattr.h>
 #include <linux/xattr.h>
+#include <linux/jhash.h>
+#include <linux/ima.h>
+#include <asm/uaccess.h>
+
+#ifdef CONFIG_NFSD_V3
+#include "xdr3.h"
+#endif /* CONFIG_NFSD_V3 */
+
 #ifdef CONFIG_NFSD_V4
 #include <linux/nfs4_acl.h>
 #include <linux/nfsd_idmap.h>
 #endif /* CONFIG_NFSD_V4 */
-#include <linux/jhash.h>
-#include <linux/ima.h>
-#include "vfs.h"
 
-#include <asm/uaccess.h>
+#include "nfsd.h"
+#include "vfs.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_FILEOP
 
diff --git a/include/linux/nfsd/xdr.h b/fs/nfsd/xdr.h
similarity index 99%
rename from include/linux/nfsd/xdr.h
rename to fs/nfsd/xdr.h
index 58f824d..235ee5c 100644
--- a/include/linux/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -8,7 +8,7 @@
 #define LINUX_NFSD_H
 
 #include <linux/vfs.h>
-#include <linux/nfsd/nfsd.h>
+#include "nfsd.h"
 
 struct nfsd_fhandle {
 	struct svc_fh		fh;
diff --git a/include/linux/nfsd/xdr3.h b/fs/nfsd/xdr3.h
similarity index 99%
rename from include/linux/nfsd/xdr3.h
rename to fs/nfsd/xdr3.h
index 421eddd..b330756 100644
--- a/include/linux/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -9,7 +9,7 @@
 #ifndef _LINUX_NFSD_XDR3_H
 #define _LINUX_NFSD_XDR3_H
 
-#include <linux/nfsd/xdr.h>
+#include "xdr.h"
 
 struct nfsd3_sattrargs {
 	struct svc_fh		fh;
diff --git a/include/linux/nfsd/xdr4.h b/fs/nfsd/xdr4.h
similarity index 99%
rename from include/linux/nfsd/xdr4.h
rename to fs/nfsd/xdr4.h
index 1bf2662..83202a1 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -39,8 +39,8 @@
 #ifndef _LINUX_NFSD_XDR4_H
 #define _LINUX_NFSD_XDR4_H
 
-#include <linux/nfsd/state.h>
-#include <linux/nfsd/nfsd.h>
+#include "state.h"
+#include "nfsd.h"
 
 #define NFSD4_MAX_TAGLEN	128
 #define XDR_LEN(n)                     (((n) + 3) & ~3)
-- 
1.6.5.2

