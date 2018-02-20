Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43406 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751832AbeBTSug (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Feb 2018 13:50:36 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 1F7717C6A0
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:36 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 05BA810A9DE7
        for <linux-nfs@vger.kernel.org>; Tue, 20 Feb 2018 18:50:35 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/7] Removed format=2 warnings
Date: Tue, 20 Feb 2018 13:50:31 -0500
Message-Id: <20180220185034.26301-5-steved@redhat.com>
In-Reply-To: <20180220185034.26301-1-steved@redhat.com>
References: <20180220185034.26301-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added the -Werror=format=2 warning flag
and added couple pragma statments to ignore
the warning where it could not be avoided.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac            | 1 +
 utils/mount/stropts.c   | 2 ++
 utils/nfsstat/nfsstat.c | 2 ++
 3 files changed, 5 insertions(+)

diff --git a/configure.ac b/configure.ac
index 4f9d8c4..11b994b 100644
--- a/configure.ac
+++ b/configure.ac
@@ -551,6 +551,7 @@ my_am_cflags="\
  -Werror=missing-prototypes \
  -Werror=missing-declarations \
  -Werror=format-overflow=2 \
+ -Werror=format=2 \
 "
 
 AC_SUBST([AM_CFLAGS], ["$my_am_cflags"])
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 1217823..777de39 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -761,9 +761,11 @@ static int nfs_do_mount_v4(struct nfsmount_info *mi,
 			fmt = "vers=%lu.%lu";
 			break;
 		}
+#pragma GCC diagnostic ignored "-Wformat-nonliteral"
 		snprintf(version_opt, sizeof(version_opt) - 1,
 			fmt, mi->version.major,
 			mi->version.minor);
+#pragma GCC diagnostic warning "-Wformat-nonliteral"
 
 		if (po_append(options, version_opt) == PO_FAILED) {
 			errno = EINVAL;
diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 43fe0a8..c779053 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -980,8 +980,10 @@ more_stats:
 			}
 			bufp = buf;
 			for (; curindex < numvals; curindex++) {
+#pragma GCC diagnostic ignored "-Wformat-nonliteral"
 				n = sscanf(bufp, fmt, &ip->valptr[curindex],
 						&numconsumed);
+#pragma GCC diagnostic warning "-Wformat-nonliteral"
 				if (n != 1)
 					break;
 				if (is_proc) {
-- 
2.14.3

