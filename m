From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/11] NFSD: Move "select NFSD_V2_ACL if NFSD_V3_ACL"
Date: Mon, 11 Feb 2008 17:12:31 -0500
Message-ID: <20080211221231.1047.73886.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:4205 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756223AbYBKWNb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2008 17:13:31 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: since NFSD_V2_ACL is a boolean, it can be selected safely
under the NFSD_V3_ACL entry (also a boolean).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index e94ca09..fcaf61e 100644
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

