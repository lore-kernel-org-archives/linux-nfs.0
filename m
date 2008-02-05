From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/10] NFSD: Move "select NFSD_V2_ACL if NFSD_V3_ACL"
Date: Tue, 05 Feb 2008 13:09:33 -0500
Message-ID: <20080205180933.32229.82839.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:56377 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592AbYBESJf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2008 13:09:35 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m15I9Yfw016278
	for <linux-nfs@vger.kernel.org>; Tue, 5 Feb 2008 10:09:34 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m15I9XGh032302
	for <linux-nfs@vger.kernel.org>; Tue, 5 Feb 2008 13:09:34 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: since NFSD_V2_ACL is a boolean, it can be selected safely
under the NFSD_V3_ACL entry (also a boolean).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index faf5620..165308d 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1657,7 +1657,6 @@ config NFSD
 	select LOCKD
 	select SUNRPC
 	select EXPORTFS
-	select NFSD_V2_ACL if NFSD_V3_ACL
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
 	select CRYPTO_MD5 if NFSD_V4
 	select CRYPTO if NFSD_V4
@@ -1699,6 +1698,7 @@ config NFSD_V3
 config NFSD_V3_ACL
 	bool "NFS server support for the NFSv3 ACL protocol extension"
 	depends on NFSD_V3
+	select NFSD_V2_ACL
 	help
 	  Solaris NFS servers support an auxiliary NFSv3 ACL protocol that
 	  never became an official part of the NFS version 3 protocol.

