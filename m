Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38013 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753692Ab1IVTpC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Sep 2011 15:45:02 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p8MJj2uj002390
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 15:45:02 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p8MJj086012846
	for <linux-nfs@vger.kernel.org>; Thu, 22 Sep 2011 15:45:01 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] configure.ac: Remove the NFS v3 enable flag
Date: Thu, 22 Sep 2011 15:44:57 -0400
Message-Id: <1316720699-2611-2-git-send-email-steved@redhat.com>
In-Reply-To: <1316720699-2611-1-git-send-email-steved@redhat.com>
References: <1316720699-2611-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Removed the unused macros that enable and disable V3.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/configure.ac b/configure.ac
index d85ab21..7f4b88c 100644
--- a/configure.ac
+++ b/configure.ac
@@ -55,17 +55,6 @@ AC_ARG_WITH(start-statd,
 	)
 	AC_SUBST(startstatd)
 	AC_DEFINE_UNQUOTED(START_STATD, "$startstatd", [Define this to a script which can start statd on mount])
-AC_ARG_ENABLE(nfsv3,
-	[AC_HELP_STRING([--enable-nfsv3],
-                        [enable support for NFSv3 @<:@default=yes@:>@])],
-	enable_nfsv3=$enableval,
-	enable_nfsv3=yes)
-	if test "$enable_nfsv3" = yes; then
-		AC_DEFINE(NFS3_SUPPORTED, 1, [Define this if you want NFSv3 support compiled in])
-	else
-		enable_nfsv3=
-	fi
-	AC_SUBST(enable_nfsv3)
 AC_ARG_ENABLE(nfsv4,
 	[AC_HELP_STRING([--enable-nfsv4],
                         [enable support for NFSv4 @<:@default=yes@:>@])],
-- 
1.7.6.2

