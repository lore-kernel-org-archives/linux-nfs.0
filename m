Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:37680 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751786AbeBTSug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Feb 2018 13:50:36 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A2AFA402314E
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:35 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 8B83810A9DE7
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:35 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/7] configure.ac: clean up
Date: Tue, 20 Feb 2018 13:50:28 -0500
Message-Id: <20180220185034.26301-2-steved@redhat.com>
In-Reply-To: <20180220185034.26301-1-steved@redhat.com>
References: <20180220185034.26301-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove ARCHFLAGS since it has not been needed for years.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 20 ++++++--------------
 1 file changed, 6 insertions(+), 14 deletions(-)

diff --git a/configure.ac b/configure.ac
index 95991c1..b3f6b97 100644
--- a/configure.ac
+++ b/configure.ac
@@ -543,20 +543,12 @@ AC_SUBST(CXXFLAGS_FOR_BUILD)
 AC_SUBST(CPPFLAGS_FOR_BUILD)
 AC_SUBST(LDFLAGS_FOR_BUILD)
 
-dnl *************************************************************
-dnl Set up "global" CFLAGS
-dnl *************************************************************
-dnl Use architecture-specific compile flags
-dnl (We use $host and not $build in case we are cross-compiling)
-dnl *************************************************************
-dnl Note: we no longer have arch specific compile flags, but 
-dnl the stub is left here in case they are needed one day.
-case $host in
-  *)
-    ARCHFLAGS="" ;;
-esac
-
-my_am_cflags="-Wall -Wextra -Wstrict-prototypes $ARCHFLAGS -pipe"
+my_am_cflags="\
+ -pipe \
+ -Wall \
+ -Wextra \
+ -Wstrict-prototypes \
+"
 
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
 
-- 
2.14.3

