From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 2/5] nfsd: Fix independence of a few nfsd related headers
Date: Wed, 21 Oct 2009 10:14:33 +0200
Message-ID: <1256112873-32495-1-git-send-email-bharrosh@panasas.com>
References: <4ADEC1EF.8040107@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.M
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:7633 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751918AbZJUIOc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Oct 2009 04:14:32 -0400
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
 include/linux/nfs_xdr.h   |    1 +
 include/linux/nfsacl.h    |    1 +
 include/linux/posix_acl.h |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 2848a26..c316ca8 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -2,6 +2,7 @@
 #define _LINUX_NFS_XDR_H
 
 #include <linux/nfsacl.h>
+#include <linux/nfs3.h>
 
 /*
  * To change the maximum rsize and wsize supported by the NFS client, adjust
diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
index 43011b6..f321b57 100644
--- a/include/linux/nfsacl.h
+++ b/include/linux/nfsacl.h
@@ -29,6 +29,7 @@
 #ifdef __KERNEL__
 
 #include <linux/posix_acl.h>
+#include <linux/sunrpc/xdr.h>
 
 /* Maximum number of ACL entries over NFS */
 #define NFS_ACL_MAX_ENTRIES	1024
diff --git a/include/linux/posix_acl.h b/include/linux/posix_acl.h
index 065a365..0dcf674 100644
--- a/include/linux/posix_acl.h
+++ b/include/linux/posix_acl.h
@@ -9,6 +9,7 @@
 #define __LINUX_POSIX_ACL_H
 
 #include <linux/slab.h>
+#include <linux/fs.h>
 
 #define ACL_UNDEFINED_ID	(-1)
 
-- 
1.6.2.1

