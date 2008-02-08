From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/11] NFSD: Remove redundant "select" clauses in fs/Kconfig
Date: Fri, 08 Feb 2008 12:52:37 -0500
Message-ID: <20080208175237.16261.51118.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:9488 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932459AbYBHRwj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2008 12:52:39 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As far as I can tell, selecting the CRYPTO and CRYPTO_MD5 entries under
CONFIG_NFSD is redundant, since CONFIG_NFSD_V4 already selects
RPCSEC_GSS_KRB5, which selects these entries.

Testing with "make menuconfig" shows that the entries under CRYPTO still
properly reflect "Y" or "M" based on the setting of CONFIG_NFSD after this
change is applied.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 21362e9..f799964 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1658,8 +1658,6 @@ config NFSD
 	select SUNRPC
 	select EXPORTFS
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
-	select CRYPTO_MD5 if NFSD_V4
-	select CRYPTO if NFSD_V4
 	help
 	  Choose Y here if you want to allow other computers to access
 	  files residing on this system using Sun's Network File System

