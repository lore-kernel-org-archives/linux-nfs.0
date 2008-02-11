From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/11] NFSD: Use "depends on" for PROC_FS dependency
Date: Mon, 11 Feb 2008 17:12:16 -0500
Message-ID: <20080211221216.1047.31922.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:1519 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758049AbYBKWM1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2008 17:12:27 -0500
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

For SUNRPC_GSS, it's a little more complex.  Other entries can "select"
SUNRPC_GSS, as it is non-visible.  However, the guideline suggests an
entry can't "select" it if it has a dependency (such as PROC_FS).
So, we add forward dependencies on PROC_FS to RPCSEC_GSS_FOO instead.

XXX: Both CONFIG_NFSV4 and CONFIG_NFSD_V4 select RPCSEC_GSS_KRB5, which is
visible, which kconfig-language.txt also frowns upon.  The intent was to
enable at least one GSS mechanism if V4 was enabled.  Perhaps we should
make SUNRPC_GSS visible, and make the NFSv4 options visible only if
SUNRPC_GSS is enabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 0c8f85d..9ee288f 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1662,8 +1662,6 @@ config NFSD
 	select CRYPTO_MD5 if NFSD_V4
 	select CRYPTO if NFSD_V4
 	select FS_POSIX_ACL if NFSD_V4
-	select PROC_FS if NFSD_V4
-	select PROC_FS if SUNRPC_GSS
 	help
 	  Choose Y here if you want to allow other computers to access
 	  files residing on this system using Sun's Network File System
@@ -1723,7 +1721,7 @@ config NFSD_V3_ACL
 
 config NFSD_V4
 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
-	depends on NFSD && NFSD_V3 && EXPERIMENTAL
+	depends on NFSD && NFSD_V3 && PROC_FS && EXPERIMENTAL
 	select RPCSEC_GSS_KRB5
 	help
 	  This option enables support in your system's NFS server for
@@ -1798,7 +1796,7 @@ config SUNRPC_BIND34
 
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
-	depends on SUNRPC && EXPERIMENTAL
+	depends on SUNRPC && PROC_FS && EXPERIMENTAL
 	select SUNRPC_GSS
 	select CRYPTO
 	select CRYPTO_MD5
@@ -1817,7 +1815,7 @@ config RPCSEC_GSS_KRB5
 
 config RPCSEC_GSS_SPKM3
 	tristate "Secure RPC: SPKM3 mechanism (EXPERIMENTAL)"
-	depends on SUNRPC && EXPERIMENTAL
+	depends on SUNRPC && PROC_FS && EXPERIMENTAL
 	select SUNRPC_GSS
 	select CRYPTO
 	select CRYPTO_MD5

