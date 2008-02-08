From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/11] NFSD: Use "depends on" for PROC_FS dependency
Date: Fri, 08 Feb 2008 12:52:15 -0500
Message-ID: <20080208175215.16261.39243.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:8943 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759400AbYBHRwS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2008 12:52:18 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently a reverse dependency was added to fs/Kconfig to ensure that
PROC_FS was enabled if NFSD_V4 was enabled.

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
index 4c16789..5f00ee7 100644
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
-	depends on NFSD && EXPERIMENTAL
+	depends on NFSD && PROC_FS && EXPERIMENTAL
 	select NFSD_V3
 	select RPCSEC_GSS_KRB5
 	help
@@ -1796,7 +1794,7 @@ config SUNRPC_BIND34
 
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism (EXPERIMENTAL)"
-	depends on SUNRPC && EXPERIMENTAL
+	depends on SUNRPC && PROC_FS && EXPERIMENTAL
 	select SUNRPC_GSS
 	select CRYPTO
 	select CRYPTO_MD5
@@ -1815,7 +1813,7 @@ config RPCSEC_GSS_KRB5
 
 config RPCSEC_GSS_SPKM3
 	tristate "Secure RPC: SPKM3 mechanism (EXPERIMENTAL)"
-	depends on SUNRPC && EXPERIMENTAL
+	depends on SUNRPC && PROC_FS && EXPERIMENTAL
 	select SUNRPC_GSS
 	select CRYPTO
 	select CRYPTO_MD5

