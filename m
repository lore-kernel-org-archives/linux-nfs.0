Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:37940 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755524Ab1IQPRI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2011 11:17:08 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1R4wc3-0005ZA-Ce
	for linux-nfs@vger.kernel.org; Sat, 17 Sep 2011 11:15:28 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] configure.ac: Added server 4.1 support configuration option
Date: Sat, 17 Sep 2011 11:17:01 -0400
Message-Id: <1316272622-4894-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Separate the v4.1 support in the client and server
by creating the --enable-nfsdv4 configuration option.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac              |   19 ++++++++++++++++---
 support/include/nfs/nfs.h |    2 +-
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/configure.ac b/configure.ac
index 1a28f8a..18a735d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -75,17 +75,30 @@ AC_ARG_ENABLE(nfsv4,
 
 AC_ARG_ENABLE(nfsv41,
 	[AC_HELP_STRING([--enable-nfsv41],
-                        [enable support for NFSv41 @<:@default=no@:>@])],
+                        [enable for NFS v4.1 client support @<:@default=yes@:>@])],
 	enable_nfsv41=$enableval,
-	enable_nfsv41=no)
+	enable_nfsv41=yes)
 	if test "$enable_nfsv41" = yes; then
-		AC_DEFINE(NFS41_SUPPORTED, 1, [Define this if you want NFSv41 support compiled in])
+		AC_DEFINE(NFS41_SUPPORTED, 1, [Define this if you want NFSv4.1 client support compiled in])
 	else
 		enable_nfsv41=
 	fi
 	AC_SUBST(enable_nfsv41)
 	AM_CONDITIONAL(CONFIG_NFSV41, [test "$enable_nfsv41" = "yes"])
 
+AC_ARG_ENABLE(nfsvd41,
+	[AC_HELP_STRING([--enable-nfsdv41],
+                        [enable for NFS v4.1 server support @<:@default=no@:>@])],
+	enable_nfsdv41=$enableval,
+	enable_nfsvd41=no)
+	if test "$enable_nfsdv41" = yes; then
+		AC_DEFINE(NFSD41_SUPPORTED, 1, [Define this if you want NFSv4.1 server support compiled in])
+	else
+		enable_nfsdv41=
+	fi
+	AC_SUBST(enable_nfsdv41)
+	AM_CONDITIONAL(CONFIG_NFSDV41, [test "$enable_nfsdv41" = "yes"])
+
 AC_ARG_ENABLE(gss,
 	[AC_HELP_STRING([--enable-gss],
                         [enable support for rpcsec_gss @<:@default=yes@:>@])],
diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index c939d78..d06ac1f 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -16,7 +16,7 @@
 #define NFSD_MAXVERS 4
 
 #define NFSD_MINMINORVERS4 1
-#ifdef  NFS41_SUPPORTED
+#ifdef  NFSD41_SUPPORTED
 #define NFSD_MAXMINORVERS4 1
 #else
 #define NFSD_MAXMINORVERS4 0
-- 
1.7.6

