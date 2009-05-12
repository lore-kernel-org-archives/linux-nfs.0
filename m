From: akpm@linux-foundation.org
Subject: [patch for 2.6.30? 1/1] lockd: fix FILE_LOCKING=n build error
Date: Tue, 12 May 2009 13:28:09 -0700
Message-ID: <200905122047.n4CKlP24029339@imap1.linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	randy.dunlap@oracle.com, bfields@fieldses.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57297 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751075AbZELUu1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 May 2009 16:50:27 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

lockd/svclock.c is missing a header file <linux/fs.h>.

<linux/fs.h> is missing a definition of locks_release_private()
for the config case of FILE_LOCKING=n, causing a build error:

fs/lockd/svclock.c:330: error: implicit declaration of function 'locks_release_private'

lockd without FILE_LOCKING doesn't make sense, so make LOCKD and LOCKD_V4
depend on FILE_LOCKING, and make NFS depend on FILE_LOCKING.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Bruce Fields <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/Kconfig     |    2 ++
 fs/nfs/Kconfig |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff -puN fs/Kconfig~lockd-fix-file_locking=n-build-error fs/Kconfig
--- a/fs/Kconfig~lockd-fix-file_locking=n-build-error
+++ a/fs/Kconfig
@@ -236,10 +236,12 @@ source "fs/nfsd/Kconfig"
 
 config LOCKD
 	tristate
+	depends on FILE_LOCKING
 
 config LOCKD_V4
 	bool
 	depends on NFSD_V3 || NFS_V3
+	depends on FILE_LOCKING
 	default y
 
 config EXPORTFS
diff -puN fs/nfs/Kconfig~lockd-fix-file_locking=n-build-error fs/nfs/Kconfig
--- a/fs/nfs/Kconfig~lockd-fix-file_locking=n-build-error
+++ a/fs/nfs/Kconfig
@@ -1,6 +1,6 @@
 config NFS_FS
 	tristate "NFS client support"
-	depends on INET
+	depends on INET && FILE_LOCKING
 	select LOCKD
 	select SUNRPC
 	select NFS_ACL_SUPPORT if NFS_V3_ACL
_
