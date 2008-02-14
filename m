From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/8] NFSD: Use "depends on" for PROC_FS dependency
Date: Thu, 14 Feb 2008 15:58:33 -0500
Message-ID: <20080214205833.11765.59099.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:17846 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933421AbYBNU64 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2008 15:58:56 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1EKwsKb011802
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 12:58:55 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1EKwXdU011817
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 15:58:33 -0500
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
index 90a2caa..be25ff3 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1658,7 +1658,6 @@ config NFSD
 	select SUNRPC
 	select EXPORTFS
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
-	select PROC_FS if NFSD_V4
 	select PROC_FS if SUNRPC_GSS
 	help
 	  Choose Y here if you want to allow other computers to access
@@ -1720,8 +1719,7 @@ config NFSD_V3_ACL
 
 config NFSD_V4
 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
-	depends on NFSD && NFSD_V3 && EXPERIMENTAL
-	select FS_POSIX_ACL
+	depends on NFSD && NFSD_V3 && PROC_FS && EXPERIMENTAL
 	select RPCSEC_GSS_KRB5
 	help
 	  This option enables support in your system's NFS server for

