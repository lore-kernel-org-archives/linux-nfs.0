From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/10] NFSD: Remove NFSv4 dependency on NFSv3
Date: Tue, 05 Feb 2008 13:09:12 -0500
Message-ID: <20080205180912.32229.84694.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:56023 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758918AbYBESJN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Feb 2008 13:09:13 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m15I9CxH015795
	for <linux-nfs@vger.kernel.org>; Tue, 5 Feb 2008 10:09:13 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m15I9Cue032284
	for <linux-nfs@vger.kernel.org>; Tue, 5 Feb 2008 13:09:12 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Because NFSD_V4 "depends on" NFSD_V3, it appears as a child of the NFSD_V3
menu entry, and is not visible if NFSD_V3 is unselected.

Replace the dependency on NFSD_V3 with a "select NFSD_V3".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 9ad62a9..4c16789 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1723,7 +1723,8 @@ config NFSD_V3_ACL
 
 config NFSD_V4
 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
-	depends on NFSD && NFSD_V3 && EXPERIMENTAL
+	depends on NFSD && EXPERIMENTAL
+	select NFSD_V3
 	select RPCSEC_GSS_KRB5
 	help
 	  This option enables support in your system's NFS server for

