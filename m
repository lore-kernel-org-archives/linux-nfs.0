Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45361 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754695AbbA1U4T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:56:19 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t0SE7RXx004727
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2015 09:07:28 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-58-65.rdu2.redhat.com [10.10.58.65])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t0SE7Oxn020173
	for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2015 09:07:27 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/4] configure.ac: clean up
Date: Wed, 28 Jan 2015 09:07:21 -0500
Message-Id: <1422454042-12840-4-git-send-email-steved@redhat.com>
In-Reply-To: <1422454042-12840-1-git-send-email-steved@redhat.com>
References: <1422454042-12840-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reworked the configuration flags. If the default
is on the used --disable to turn off. If the
default is off use --enable to turn on.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/configure.ac b/configure.ac
index 3feb0b3..f27b46e 100644
--- a/configure.ac
+++ b/configure.ac
@@ -66,8 +66,8 @@ AC_ARG_WITH(systemd,
 	AC_SUBST(unitdir)
 
 AC_ARG_ENABLE(nfsv4,
-	[AC_HELP_STRING([--enable-nfsv4],
-                        [enable support for NFSv4 @<:@default=yes@:>@])],
+	[AC_HELP_STRING([--disable-nfsv4],
+                        [disable support for NFSv4 @<:@default=no@:>@])],
 	enable_nfsv4=$enableval,
 	enable_nfsv4=yes)
 	if test "$enable_nfsv4" = yes; then
@@ -81,8 +81,8 @@ AC_ARG_ENABLE(nfsv4,
 	AM_CONDITIONAL(CONFIG_NFSV4, [test "$enable_nfsv4" = "yes"])
 
 AC_ARG_ENABLE(nfsv41,
-	[AC_HELP_STRING([--enable-nfsv41],
-                        [enable support for NFSv41 @<:@default=yes@:>@])],
+	[AC_HELP_STRING([--disable-nfsv41],
+                        [disable support for NFSv41 @<:@default=no@:>@])],
 	enable_nfsv41=$enableval,
 	enable_nfsv41=yes)
 	if test "$enable_nfsv41" = yes; then
@@ -99,8 +99,8 @@ AC_ARG_ENABLE(nfsv41,
 	AM_CONDITIONAL(CONFIG_NFSV41, [test "$enable_nfsv41" = "yes"])
 
 AC_ARG_ENABLE(gss,
-	[AC_HELP_STRING([--enable-gss],
-              [enable client support for rpcsec_gss @<:@default=yes@:>@])],
+	[AC_HELP_STRING([--disable-gss],
+              [disable client support for rpcsec_gss @<:@default=no@:>@])],
 	enable_gss=$enableval,
 	enable_gss=yes)
 	if test "$enable_gss" = yes; then
@@ -151,8 +151,8 @@ AC_ARG_ENABLE(uuid,
 	if test "$enableval" = "yes" ; then choose_blkid=yes; else choose_blkid=no; fi,
 	choose_blkid=default)
 AC_ARG_ENABLE(mount,
-	[AC_HELP_STRING([--enable-mount],
-			[Create mount.nfs and do not use the util-linux mount(8) functionality. @<:@default=yes@:>@])],
+	[AC_HELP_STRING([--disable-mount],
+		[Don't build mount.nfs and do use the util-linux mount(8) functionality. @<:@default=no@:>@])],
 	enable_mount=$enableval,
 	enable_mount=yes)
 	AM_CONDITIONAL(CONFIG_MOUNT, [test "$enable_mount" = "yes"])
@@ -166,10 +166,10 @@ if test "$enable_mount" = yes; then
 fi
 
 AC_ARG_ENABLE(tirpc,
-	[AC_HELP_STRING([--enable-tirpc],
-			[enable use of TI-RPC @<:@default=yes@:>@])],
+	[AC_HELP_STRING([--disable-tirpc],
+			[disable use of TI-RPC library @<:@default=no@:>@])],
 	enable_tirpc=$enableval,
-	enable_tirpc='')
+	enable_tirpc=yes)
 AC_ARG_ENABLE(ipv6,
 	[AC_HELP_STRING([--disable-ipv6],
                         [disable support for IPv6 @<:@default=no@:>@])],
@@ -211,8 +211,8 @@ else
 fi
 
 AC_ARG_ENABLE(nfsdcltrack,
-	[AC_HELP_STRING([--enable-nfsdcltrack],
-			[enable NFSv4 clientid tracking programs @<:@default=yes@:>@])],
+	[AC_HELP_STRING([--disable-nfsdcltrack],
+			[disable NFSv4 clientid tracking programs @<:@default=no@:>@])],
 	enable_nfsdctrack=$enableval,
 	enable_nfsdcltrack="yes")
 
-- 
2.1.0

