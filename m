Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:60122 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751879AbeBTSug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Feb 2018 13:50:36 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id EFF8881AE893
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:35 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id D65A010A9DE7
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:35 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/7] Removed format-overflow=2 warnings
Date: Tue, 20 Feb 2018 13:50:30 -0500
Message-Id: <20180220185034.26301-4-steved@redhat.com>
In-Reply-To: <20180220185034.26301-1-steved@redhat.com>
References: <20180220185034.26301-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added the -Werror=format-overflow=2 warning flag
and then cleaned up the mess

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac          | 1 +
 support/nfs/cacheio.c | 2 +-
 utils/idmapd/idmapd.c | 2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index 31990c3..4f9d8c4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -550,6 +550,7 @@ my_am_cflags="\
  -Werror=strict-prototypes \
  -Werror=missing-prototypes \
  -Werror=missing-declarations \
+ -Werror=format-overflow=2 \
 "
 
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 9912afa..9dc4cf1 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -212,7 +212,7 @@ cache_flush(int force)
 {
 	struct stat stb;
 	int c;
-	char stime[20];
+	char stime[32];
 	char path[200];
 	time_t now;
 	/* Note: the order of these caches is important.
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index c7e75bd..67d115d 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -169,7 +169,7 @@ static int
 flush_nfsd_cache(char *path, time_t now)
 {
 	int fd;
-	char stime[20];
+	char stime[32];
 
 	sprintf(stime, "%ld\n", now);
 	fd = open(path, O_RDWR);
-- 
2.14.3

