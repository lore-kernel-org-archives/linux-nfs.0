From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/8] SUNRPC: Remove PROC_FS dependency
Date: Thu, 14 Feb 2008 15:58:40 -0500
Message-ID: <20080214205840.11765.24177.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:18226 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933541AbYBNU7D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2008 15:59:03 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1EKx1ug012135
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 12:59:01 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1EKwexO011823
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 15:58:40 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently, commit 440bcc59 added a reverse dependency to fs/Kconfig to
ensure that PROC_FS was enabled if SUNRPC_GSS was enabled.

Apparently this isn't necessary because the auth_gss components under
net/sunrpc will build correctly even if PROC_FS is disabled, though
RPCSEC_GSS will not work without /proc.

It also violates the guideline in Documentation/kbuild/kconfig-language.txt
that states "In general use select only for non-visible symbols (no prompts
anywhere) and for symbols with no dependencies."

To address these issues, remove the dependency.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index be25ff3..fcd8d10 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1658,7 +1658,6 @@ config NFSD
 	select SUNRPC
 	select EXPORTFS
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
-	select PROC_FS if SUNRPC_GSS
 	help
 	  Choose Y here if you want to allow other computers to access
 	  files residing on this system using Sun's Network File System

