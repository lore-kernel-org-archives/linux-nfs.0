From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/11] NFSD: Remove NFSD_TCP kernel build option
Date: Fri, 08 Feb 2008 12:51:39 -0500
Message-ID: <20080208175139.16261.57023.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:7834 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759205AbYBHRvm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2008 12:51:42 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Likewise, distros usually leave CONFIG_NFSD_TCP enabled.

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
index 4965fd8..9c2c24b 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1646,7 +1646,6 @@ config NFSD
 	select EXPORTFS
 	select NFSD_V2_ACL if NFSD_V3_ACL
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
-	select NFSD_TCP if NFSD_V4
 	select CRYPTO_MD5 if NFSD_V4
 	select CRYPTO if NFSD_V4
 	select FS_POSIX_ACL if NFSD_V4
@@ -1705,15 +1704,6 @@ config NFSD_V4
 	  should only be used if you are interested in helping to test NFSv4.
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
 config ROOT_NFS
 	bool "Root file system on NFS"
 	depends on NFS_FS=y && IP_PNP
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
 

