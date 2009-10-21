From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 3/5] nfsd: Fix independence of linux/nfsd/ headers
Date: Wed, 21 Oct 2009 10:14:51 +0200
Message-ID: <1256112891-739-1-git-send-email-bharrosh@panasas.com>
References: <4ADEC1EF.8040107@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.M
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:23755 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752028AbZJUIOv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Oct 2009 04:14:51 -0400
In-Reply-To: <4ADEC1EF.8040107@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An header should be compilation independent, .i.e pull in
any header who's declarations are directly used by this header.
And not let users re-include all it's dependencies all over
again.

[At the end of the day what's the use of a header if it does
 not have more then one user?]

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 include/linux/nfsd/cache.h         |    1 +
 include/linux/nfsd/nfs4layoutxdr.h |    2 ++
 include/linux/nfsd/nfsfh.h         |    1 +
 include/linux/nfsd/xdr.h           |    1 +
 include/linux/nfsd/xdr4.h          |    1 +
 5 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfsd/cache.h b/include/linux/nfsd/cache.h
index 3a3f589..3890284 100644
--- a/include/linux/nfsd/cache.h
+++ b/include/linux/nfsd/cache.h
@@ -12,6 +12,7 @@
 
 #include <linux/in.h>
 #include <linux/uio.h>
+#include <linux/sunrpc/svc.h>
 
 /*
  * Representation of a reply cache entry.
diff --git a/include/linux/nfsd/nfs4layoutxdr.h b/include/linux/nfsd/nfs4layoutxdr.h
index ad7f4cb..d4d05d7 100644
--- a/include/linux/nfsd/nfs4layoutxdr.h
+++ b/include/linux/nfsd/nfs4layoutxdr.h
@@ -38,6 +38,8 @@
 
 #if defined(CONFIG_PNFSD)
 
+#include <linux/nfsd/nfsd4_pnfs.h>
+
 /* the nfsd4_pnfs_devlist dev_addr for the file layout type */
 struct pnfs_filelayout_devaddr {
 	struct xdr_netobj	r_netid;
diff --git a/include/linux/nfsd/nfsfh.h b/include/linux/nfsd/nfsfh.h
index b91760c..b4e024c 100644
--- a/include/linux/nfsd/nfsfh.h
+++ b/include/linux/nfsd/nfsfh.h
@@ -18,6 +18,7 @@
 #ifdef __KERNEL__
 # include <linux/string.h>
 # include <linux/fs.h>
+# include <linux/sunrpc/svc.h>
 #endif
 #include <linux/nfsd/const.h>
 
diff --git a/include/linux/nfsd/xdr.h b/include/linux/nfsd/xdr.h
index a0132ef..84dc0f0 100644
--- a/include/linux/nfsd/xdr.h
+++ b/include/linux/nfsd/xdr.h
@@ -10,6 +10,7 @@
 #include <linux/fs.h>
 #include <linux/vfs.h>
 #include <linux/nfs.h>
+#include <linux/nfsd/nfsd.h>
 
 struct nfsd_fhandle {
 	struct svc_fh		fh;
diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
index bdd4beb..9243d1b 100644
--- a/include/linux/nfsd/xdr4.h
+++ b/include/linux/nfsd/xdr4.h
@@ -40,6 +40,7 @@
 #define _LINUX_NFSD_XDR4_H
 
 #include <linux/nfs4.h>
+#include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/nfsd4_pnfs.h>
 
 #define NFSD4_MAX_TAGLEN	128
-- 
1.6.2.1

