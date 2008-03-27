From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] NFSD: Use "depends on" for PROC_FS dependency
Date: Thu, 27 Mar 2008 16:34:40 -0400
Message-ID: <20080327203440.5036.34031.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:29653 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761328AbYC0Uer (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Mar 2008 16:34:47 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently, commit 440bcc59 added a reverse dependency to fs/Kconfig to
ensure that PROC_FS was enabled if NFSD_V4 was enabled.

There is a guideline in Documentation/kbuild/kconfig-language.txt that
states "In general use select only for non-visible symbols (no prompts
anywhere) and for symbols with no dependencies."

A quick grep around other Kconfig files reveals that no entry currently
uses "select PROC_FS" -- every one uses "depends on".  Thus CONFIG_NFSD_V4
should use "depends on PROC_FS" as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 1dd59df..db67512 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1668,7 +1668,6 @@ config NFSD
 	select SUNRPC
 	select EXPORTFS
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
-	select PROC_FS if NFSD_V4
 	select PROC_FS if SUNRPC_GSS
 	help
 	  Choose Y here if you want to allow other computers to access
@@ -1730,8 +1729,7 @@ config NFSD_V3_ACL
 
 config NFSD_V4
 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
-	depends on NFSD && NFSD_V3 && EXPERIMENTAL
-	select FS_POSIX_ACL
+	depends on NFSD && NFSD_V3 && PROC_FS && EXPERIMENTAL
 	select RPCSEC_GSS_KRB5
 	help
 	  This option enables support in your system's NFS server for

