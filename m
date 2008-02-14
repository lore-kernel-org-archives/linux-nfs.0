From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 8/8] NFS: NFS_V4 and NFSD_V4 should depend on SUNRPC_GSS
Date: Thu, 14 Feb 2008 15:58:54 -0500
Message-ID: <20080214205854.11765.6551.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:17863 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933458AbYBNU64 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2008 15:58:56 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1EKwtvm011851
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 12:58:55 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1EKwsM0011835
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 15:58:54 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a guideline in Documentation/kbuild/kconfig-language.txt that
states "In general use select only for non-visible symbols (no prompts
anywhere) and for symbols with no dependencies." Both CONFIG_NFS_V4 and
CONFIG_NFSD_V4 select RPCSEC_GSS_KRB5, which is visible, and has
dependencies.

For the sake of addressing the kconfig-language recommendation, 
"select RPCSEC_GSS_KRB5" to "select SUNRPC_GSS".

The server side requires it to build properly, and the client side has it
to provide support for loading GSS capabilities, which RFC 3530 makes
mandatory for NFS version 4.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index c7ad5b7..048c561 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1629,7 +1629,7 @@ config NFS_V3_ACL
 config NFS_V4
 	bool "NFS client support for NFS version 4 (EXPERIMENTAL)"
 	depends on NFS_FS && EXPERIMENTAL
-	select RPCSEC_GSS_KRB5
+	select SUNRPC_GSS
 	help
 	  This option enables support for version 4 of the NFS protocol 
 	  (RFC 3530) in the kernel's NFS client.
@@ -1720,7 +1720,7 @@ config NFSD_V4
 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
 	depends on NFSD && PROC_FS && EXPERIMENTAL
 	select NFSD_V3
-	select RPCSEC_GSS_KRB5
+	select SUNRPC_GSS
 	help
 	  This option enables support in your system's NFS server for
 	  version 4 of the NFS protocol (RFC 3530).

