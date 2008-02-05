From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/5] NFSD: Remove NFSD_TCP kernel build option
Date: Mon, 04 Feb 2008 19:04:42 -0500
Message-ID: <20080205000442.18602.29035.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:28624 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757259AbYBEAEp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2008 19:04:45 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

TCP support in the Linux NFS server is stable enough that we can leave it
on always.  CONFIG_NFSD_TCP adds about 10 lines of code, and defaults to
"Y" anyway.

A run-time switch might be more appropriate if people feel they would like
to disable NFSD's TCP support.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig       |   10 ----------
 fs/nfsd/nfssvc.c |    2 --
 2 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index e6d4034..5ccff9a 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1686,7 +1686,6 @@ config NFSD
 	select EXPORTFS
 	select NFSD_V2_ACL if NFSD_V3_ACL
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
-	select NFSD_TCP if NFSD_V4
 	select CRYPTO_MD5 if NFSD_V4
 	select CRYPTO if NFSD_V4
 	select FS_POSIX_ACL if NFSD_V4
@@ -1763,15 +1762,6 @@ config NFSD_V4
 
 	  If unsure, say N.
 
-config NFSD_TCP
-	bool "Provide NFS server over TCP support"
-	depends on NFSD
-	default y
-	help
-	  If you want your NFS server to support TCP connections, say Y here.
-	  TCP connections usually perform better than the default UDP when
-	  the network is lossy or congested.  If unsure, say Y.
-
 config LOCKD
 	tristate
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 9647b0f..941041f 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -244,7 +244,6 @@ static int nfsd_init_socks(int port)
 	if (error < 0)
 		return error;
 
-#ifdef CONFIG_NFSD_TCP
 	error = lockd_up(IPPROTO_TCP);
 	if (error >= 0) {
 		error = svc_create_xprt(nfsd_serv, "tcp", port,
@@ -254,7 +253,6 @@ static int nfsd_init_socks(int port)
 	}
 	if (error < 0)
 		return error;
-#endif
 	return 0;
 }
 

