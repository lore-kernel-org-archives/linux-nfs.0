Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5033 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753702Ab1IVTpD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 15:45:03 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8MJj2Dt027258
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 15:45:03 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8MJj087012846
	for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 15:45:02 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] configure.ac: Removed unused defines in config.h
Date: Thu, 22 Sep 2011 15:44:58 -0400
Message-Id: <1316720699-2611-3-git-send-email-steved@redhat.com>
In-Reply-To: <1316720699-2611-1-git-send-email-steved@redhat.com>
References: <1316720699-2611-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Cleaned out 3 unused defines from config.h

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/configure.ac b/configure.ac
index 7f4b88c..61b9c00 100644
--- a/configure.ac
+++ b/configure.ac
@@ -61,7 +61,6 @@ AC_ARG_ENABLE(nfsv4,
 	enable_nfsv4=$enableval,
 	enable_nfsv4=yes)
 	if test "$enable_nfsv4" = yes; then
-		AC_DEFINE(NFS4_SUPPORTED, 1, [Define this if you want NFSv4 support compiled in])
 		IDMAPD=idmapd
 	else
 		enable_nfsv4=
@@ -78,7 +77,6 @@ AC_ARG_ENABLE(nfsv41,
 	enable_nfsv41=yes)
 	if test "$enable_nfsv41" = yes; then
 		BLKMAPD=blkmapd
-		AC_DEFINE(NFS41_SUPPORTED, 1, [Define this if you want NFSv41 support compiled in])
 	else
 		enable_nfsv41=
 		BLKMAPD=
@@ -92,7 +90,6 @@ AC_ARG_ENABLE(gss,
 	enable_gss=$enableval,
 	enable_gss=yes)
 	if test "$enable_gss" = yes; then
-		AC_DEFINE(GSS_SUPPORTED, 1, [Define this if you want rpcsec_gss support compiled in])
 		GSSD=gssd
 		SVCGSSD=svcgssd
 	else
-- 
1.7.6.2

