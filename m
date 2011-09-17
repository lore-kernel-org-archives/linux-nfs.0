Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:37941 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755531Ab1IQPRI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2011 11:17:08 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1R4wc4-0005ZA-7n
	for linux-nfs@vger.kernel.org; Sat, 17 Sep 2011 11:15:28 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] configure.ac: Remove unused NFS3_SUPPORTED define
Date: Sat, 17 Sep 2011 11:17:02 -0400
Message-Id: <1316272622-4894-2-git-send-email-steved@redhat.com>
In-Reply-To: <1316272622-4894-1-git-send-email-steved@redhat.com>
References: <1316272622-4894-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This configuration option is not used. So remove
it for now then possibly added it back when
V3 supported is disabled.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/configure.ac b/configure.ac
index 18a735d..07a25ad 100644
--- a/configure.ac
+++ b/configure.ac
@@ -46,17 +46,7 @@ AC_ARG_WITH(start-statd,
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
+
 AC_ARG_ENABLE(nfsv4,
 	[AC_HELP_STRING([--enable-nfsv4],
                         [enable support for NFSv4 @<:@default=yes@:>@])],
-- 
1.7.6

