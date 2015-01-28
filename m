Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49284 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753506AbbA1UyV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Jan 2015 15:54:21 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t0SE7S6o005343
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2015 09:07:28 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-58-65.rdu2.redhat.com [10.10.58.65])
	by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t0SE7Oxo020173
	for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2015 09:07:27 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/4] configure.ac: More clean up
Date: Wed, 28 Jan 2015 09:07:22 -0500
Message-Id: <1422454042-12840-5-git-send-email-steved@redhat.com>
In-Reply-To: <1422454042-12840-1-git-send-email-steved@redhat.com>
References: <1422454042-12840-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added a couple default values to the flag descriptions

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index f27b46e..f667abe 100644
--- a/configure.ac
+++ b/configure.ac
@@ -147,7 +147,8 @@ AC_ARG_WITH(rpcgen,
 	AC_SUBST(RPCGEN_PATH)
 	AM_CONDITIONAL(CONFIG_RPCGEN, [test "$RPCGEN_PATH" = ""])
 AC_ARG_ENABLE(uuid,
-	[AC_HELP_STRING([--disable-uuid], [Exclude uuid support to avoid buggy libblkid])],
+	[AC_HELP_STRING([--disable-uuid], 
+		[Exclude uuid support to avoid buggy libblkid. @<:@default=no@:>@])],
 	if test "$enableval" = "yes" ; then choose_blkid=yes; else choose_blkid=no; fi,
 	choose_blkid=default)
 AC_ARG_ENABLE(mount,
@@ -160,7 +161,7 @@ AC_ARG_ENABLE(mount,
 if test "$enable_mount" = yes; then
 	AC_ARG_ENABLE(libmount-mount,
 		[AC_HELP_STRING([--enable-libmount-mount],
-				[Link mount.nfs with libmount (EXPERIMENTAL)])],
+				[Link mount.nfs with libmount @<:@default=no@:>@])],
 		enable_libmount=$enableval,
 		enable_libmount=no)
 fi
-- 
2.1.0

