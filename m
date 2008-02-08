From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/11] NFSD: Move "select FS_POSIX_ACL if NFSD_V4"
Date: Fri, 08 Feb 2008 12:52:22 -0500
Message-ID: <20080208175222.16261.68653.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:9124 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759226AbYBHRwY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2008 12:52:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: since FS_POSIX_ACL is a non-visible boolean entry, it can be
selected safely under the NFSD_V4 entry (also a boolean).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 5f00ee7..32c84d9 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -411,7 +411,7 @@ config JFS_STATISTICS
 	  to be made available to the user in the /proc/fs/jfs/ directory.
 
 config FS_POSIX_ACL
-# Posix ACL utility routines (for now, only ext2/ext3/jfs/reiserfs)
+# Posix ACL utility routines (for now, only ext2/ext3/jfs/reiserfs/nfs)
 #
 # NOTE: you can implement Posix ACLs without these helpers (XFS does).
 # 	Never use this symbol for ifdefs.
@@ -1661,7 +1661,6 @@ config NFSD
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
 	select CRYPTO_MD5 if NFSD_V4
 	select CRYPTO if NFSD_V4
-	select FS_POSIX_ACL if NFSD_V4
 	help
 	  Choose Y here if you want to allow other computers to access
 	  files residing on this system using Sun's Network File System
@@ -1723,6 +1722,7 @@ config NFSD_V4
 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
 	depends on NFSD && PROC_FS && EXPERIMENTAL
 	select NFSD_V3
+	select FS_POSIX_ACL
 	select RPCSEC_GSS_KRB5
 	help
 	  This option enables support in your system's NFS server for

