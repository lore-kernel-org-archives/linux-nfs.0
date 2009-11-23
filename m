From: Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH 3/6] nfsd: Fix independence of a few nfsd related headers
Date: Mon, 23 Nov 2009 17:59:16 +0200
Message-ID: <1258991956-25392-1-git-send-email-bharrosh@panasas.com>
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
Received: from daytona.panasas.com ([67.152.220.89]:41675 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753283AbZKWP7P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Nov 2009 10:59:15 -0500
In-Reply-To: <4B0AB039.6020608@panasas.com>
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
 include/linux/nfs_xdr.h |    1 +
 include/linux/nfsacl.h  |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 62f63fb..00a0c81 100644
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
-- 
1.6.5.2

