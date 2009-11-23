From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 4/6] nfsd: Headers Independence and include cleanups
Date: Mon, 23 Nov 2009 17:59:38 +0200
Message-ID: <1258991978-25419-1-git-send-email-bharrosh@panasas.com>
References: <4B0AB039.6020608@panasas.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Randy Dunlap <randy.dunlap@oracle.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Trond Myklebust <Trond.M
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17944 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754978AbZKWP7h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2009 10:59:37 -0500
In-Reply-To: <4B0AB039.6020608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Add includes that are directly used by headers
* Remove includes that are not needed

These are the changes made:

[xdr.h]
struct nfsd_readdirres has an embedded struct readdir_cd from nfsd.h
fixing that we can drop other includes

[xdr4.h]
embedded types defined both at state.h and nfsd.h

[syscall.h]
After export.h fix none of these stuff is needed.
fix extra space in # include <> statement

[stats.h]
does not need <linux/nfs4.h> but was export to user-mode
so I don't touch it

[state.h]
embedded types from nfsfh.h like struct knfsd_fh. bringing that
eliminates the need for all other includes

[nfsfh.h]
directly manipulating types from sunrpc/svc.h.
Removed Other unused headers.

[nfsd.h]
removed unused headers include

[export.h]
lots of sunrpc/svc.h types and a single prototype declaration
with pointer from nfsfh.h, but all users of export.h do need
nfsfh.h any way. remove now un-needed include.

[const.h]
Unfixed (not independent)

[cache.h]
could do with a forward declaration of "struct svc_rqst;"
from sunrpc/svc.h but all users absolutely will need
sunrpc/svc.h it is easier overall this way.

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/nfsd/cache.h   |    3 +--
 include/linux/nfsd/export.h  |    2 +-
 include/linux/nfsd/nfsd.h    |    4 ----
 include/linux/nfsd/nfsfh.h   |    3 +--
 include/linux/nfsd/state.h   |    4 +---
 include/linux/nfsd/syscall.h |    8 +-------
 include/linux/nfsd/xdr.h     |    3 +--
 include/linux/nfsd/xdr4.h    |    3 ++-
 8 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/include/linux/nfsd/cache.h b/include/linux/nfsd/cache.h
index 3a3f589..a165425 100644
--- a/include/linux/nfsd/cache.h
+++ b/include/linux/nfsd/cache.h
@@ -10,8 +10,7 @@
 #ifndef NFSCACHE_H
 #define NFSCACHE_H
 
-#include <linux/in.h>
-#include <linux/uio.h>
+#include <linux/sunrpc/svc.h>
 
 /*
  * Representation of a reply cache entry.
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index a6d9ef2..ef3d416 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -12,7 +12,7 @@
 
 # include <linux/types.h>
 #ifdef __KERNEL__
-# include <linux/in.h>
+# include <linux/nfsd/nfsfh.h>
 #endif
 
 /*
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 510ffdd..b6fdc76 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -11,13 +11,9 @@
 #define LINUX_NFSD_NFSD_H
 
 #include <linux/types.h>
-#include <linux/unistd.h>
-#include <linux/fs.h>
-#include <linux/posix_acl.h>
 #include <linux/mount.h>
 
 #include <linux/nfsd/debug.h>
-#include <linux/nfsd/nfsfh.h>
 #include <linux/nfsd/export.h>
 #include <linux/nfsd/stats.h>
 /*
diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
index 2973e11..49523ed 100644
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -16,8 +16,7 @@
 
 # include <linux/types.h>
 #ifdef __KERNEL__
-# include <linux/string.h>
-# include <linux/fs.h>
+# include <linux/sunrpc/svc.h>
 #endif
 #include <linux/nfsd/const.h>
 
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 5aadf8a..2af7568 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -37,9 +37,7 @@
 #ifndef _NFSD4_STATE_H
 #define _NFSD4_STATE_H
 
-#include <linux/list.h>
-#include <linux/kref.h>
-#include <linux/sunrpc/clnt.h>
+#include <linux/nfsd/nfsfh.h>
 
 typedef struct {
 	u32             cl_boot;
diff --git a/include/linux/nfsd/syscall.h b/include/linux/nfsd/syscall.h
index 7a3b565..812bc1e 100644
--- a/include/linux/nfsd/syscall.h
+++ b/include/linux/nfsd/syscall.h
@@ -9,14 +9,8 @@
 #ifndef NFSD_SYSCALL_H
 #define NFSD_SYSCALL_H
 
-# include <linux/types.h>
-#ifdef __KERNEL__
-# include <linux/in.h>
-#endif 
-#include <linux/posix_types.h>
-#include <linux/nfsd/const.h>
+#include <linux/types.h>
 #include <linux/nfsd/export.h>
-#include <linux/nfsd/nfsfh.h>
 
 /*
  * Version of the syscall interface
diff --git a/include/linux/nfsd/xdr.h b/include/linux/nfsd/xdr.h
index a0132ef..58f824d 100644
--- a/include/linux/nfsd/xdr.h
+++ b/include/linux/nfsd/xdr.h
@@ -7,9 +7,8 @@
 #ifndef LINUX_NFSD_H
 #define LINUX_NFSD_H
 
-#include <linux/fs.h>
 #include <linux/vfs.h>
-#include <linux/nfs.h>
+#include <linux/nfsd/nfsd.h>
 
 struct nfsd_fhandle {
 	struct svc_fh		fh;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index 73164c2..1bf2662 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -39,7 +39,8 @@
 #ifndef _LINUX_NFSD_XDR4_H
 #define _LINUX_NFSD_XDR4_H
 
-#include <linux/nfs4.h>
+#include <linux/nfsd/state.h>
+#include <linux/nfsd/nfsd.h>
 
 #define NFSD4_MAX_TAGLEN	128
 #define XDR_LEN(n)                     (((n) + 3) & ~3)
-- 
1.6.5.2

