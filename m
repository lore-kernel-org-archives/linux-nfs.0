From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/10] NFSD: Remove redundant "select" clauses in fs/Kconfig
Date: Tue, 05 Feb 2008 13:09:41 -0500
Message-ID: <20080205180941.32229.27133.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:56510 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbYBESJm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2008 13:09:42 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m15I9feS016431
	for <linux-nfs@vger.kernel.org>; Tue, 5 Feb 2008 10:09:41 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m15I9fhc032308
	for <linux-nfs@vger.kernel.org>; Tue, 5 Feb 2008 13:09:41 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As far as I can tell, selecting the CRYPTO and CRYPTO_MD5 entries under
CONFIG_NFSD is redundant, since CONFIG_NFSD_V4 already selects
RPCSEC_GSS_KRB5, which selects these entries.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 165308d..17f0ccf 100644
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

