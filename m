Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:53992 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932129Ab1IAPQd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Sep 2011 11:16:33 -0400
Received: from localhost.localdomain (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 562F01B402C
	for <linux-nfs@vger.kernel.org>; Thu,  1 Sep 2011 15:16:33 +0000 (UTC)
From: Mike Frysinger <vapier@gentoo.org>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] exportfs: do not warn if /etc/exports.d/ does not exist
Date: Thu,  1 Sep 2011 11:16:32 -0400
Message-Id: <1314890192-11075-2-git-send-email-vapier@gentoo.org>
In-Reply-To: <1314890192-11075-1-git-send-email-vapier@gentoo.org>
References: <1314890192-11075-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

It isn't uncommon for /etc/exports.d/ to not exist, and imo, it's not
that big of a deal as often times, a simple /etc/exports is sufficient.
So silently skip the case where the dir is missing.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 utils/exportfs/exportfs.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 986a272..7432a65 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -529,9 +529,12 @@ export_d_read(const char *dname)
 
 
 	n = scandir(dname, &namelist, NULL, versionsort);
-	if (n < 0)
+	if (n < 0) {
+		if (errno == ENOENT)
+			/* Silently return */
+			return;
 		xlog(L_NOTICE, "scandir %s: %s", dname, strerror(errno));
-	else if (n == 0)
+	} else if (n == 0)
 		return;
 
 	for (i = 0; i < n; i++) {
-- 
1.7.6

