Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:36192 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933Ab0IAIxM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Sep 2010 04:53:12 -0400
From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Randy Dunlap <randy.dunlap@oracle.com>, Neil Brown <neilb@suse.de>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: [REGRESSION PATCH v2] NFS: let NFS_V4 and NFSD_V4 enforce CRYPTO
Date: Wed,  1 Sep 2010 10:52:50 +0200
Message-Id: <1283331170-11440-1-git-send-email-u.kleine-koenig@pengutronix.de>
In-Reply-To: <20100830121022.GA14459@pengutronix.de>
References: <20100830121022.GA14459@pengutronix.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

here comes a v2 of the patch that improves the commit log with a more
detailed analysis of the breakage introduced by df486a2
(= v2.6.36-rc2~34^2~1 BTW) and additionally undoes the "default y" for
RPCSEC_GSS_KRB5.

So compared to the state before df486a2 the changes are:

        NFS_V4 selects CRYPTO
        NFSD_V4 selects CRYPTO
	RPCSEC_GSS_KRB5 doesn't depend on EXPERIMENTAL anymore
	RPCSEC_GSS_KRB5 now depends on CRYPTO instead of selecting it

Best regards
Uwe

----------------------------->8----------------------------

This is a follow up to

	df486a2 (NFS: Fix the selection of security flavours in Kconfig)

Before df486a2 NFS_V4 selected RPCSEC_GSS_KRB5 but didn't enforce the
latter's dependency EXPERIMENTAL.  df486a2 removed RPCSEC_GSS_KRB5's
dependency on EXPERIMENTAL but additionally let it depend on CRYPTO
(instead of select CRYPTO before).  So it was still possible to have a
config that has NFS_V4 but not RPCSEC_GSS_KRB5.  Moreover df486a2
changed the dependency of NFS_V4 and NFSD_V4 on RPCSEC_GSS_KRB5 from

	config NFS_V4
		...
		select RPCSEC_GSS_KRB5

to

	config RPCSEC_GSS_KRB5
		...
		prompt "..." if !(NFS_V4 || NFSD_V4)
		default y

This works but is ugly as it hides the dependencies of NFSD?_V4 in a
different Kconfig file.  So this is undone here, too.

The following ARM defconfigs were affected by this problem:
	mx1 pxa3xx qil-a9260 usb-a9260 usb-a9263

These builds ended in:

	  LD      init/built-in.o
	  LD      .tmp_vmlinux1
	fs/built-in.o: In function `nfs_callback_authenticate':
	compr_zlib.c:(.text+0x7c040): undefined reference to `svc_gss_principal'
	make[2]: *** [.tmp_vmlinux1] Error 1
	make[1]: *** [sub-make] Error 2
	make: *** [all] Error 2

Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
---
 fs/nfs/Kconfig     |    2 ++
 fs/nfsd/Kconfig    |    2 ++
 net/sunrpc/Kconfig |    6 ++----
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 6c2aad4..5b9f870 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -63,6 +63,8 @@ config NFS_V3_ACL
 config NFS_V4
 	bool "NFS client support for NFS version 4"
 	depends on NFS_FS
+	select CRYPTO # recursive select: RPCSEC_GSS_KRB5 depends on CRYPTO
+	select RPCSEC_GSS_KRB5
 	help
 	  This option enables support for version 4 of the NFS protocol
 	  (RFC 3530) in the kernel's NFS client.
diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 95932f5..3678a16 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -69,6 +69,8 @@ config NFSD_V4
 	depends on NFSD && PROC_FS && EXPERIMENTAL
 	select NFSD_V3
 	select FS_POSIX_ACL
+	select CRYPTO # recursive select: RPCSEC_GSS_KRB5 depends on CRYPTO
+	select RPCSEC_GSS_KRB5
 	help
 	  This option enables support in your system's NFS server for
 	  version 4 of the NFS protocol (RFC 3530).
diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 3376d76..523be24 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -18,10 +18,8 @@ config SUNRPC_XPRT_RDMA
 	  If unsure, say N.
 
 config RPCSEC_GSS_KRB5
-	tristate
+	tristate "Secure RPC: Kerberos V mechanism"
 	depends on SUNRPC && CRYPTO
-	prompt "Secure RPC: Kerberos V mechanism" if !(NFS_V4 || NFSD_V4)
-	default y
 	select SUNRPC_GSS
 	select CRYPTO_MD5
 	select CRYPTO_DES
@@ -35,7 +33,7 @@ config RPCSEC_GSS_KRB5
 	  available from http://linux-nfs.org/.  In addition, user-space
 	  Kerberos support should be installed.
 
-	  If unsure, say Y.
+	  If unsure, say N.
 
 config RPCSEC_GSS_SPKM3
 	tristate "Secure RPC: SPKM3 mechanism (EXPERIMENTAL)"
-- 
1.7.1

