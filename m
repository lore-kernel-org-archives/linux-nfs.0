Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45195 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932138AbcCSRXi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Mar 2016 13:23:38 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 5A727C00B8CE
	for <linux-nfs@vger.kernel.org>; Sat, 19 Mar 2016 17:23:37 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (vpn-59-151.rdu2.redhat.com [10.10.59.151])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u2JHNaLh002914
	for <linux-nfs@vger.kernel.org>; Sat, 19 Mar 2016 13:23:37 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] gssd: ignore pipe directories that do not exist
Date: Sat, 19 Mar 2016 13:23:35 -0400
Message-Id: <1458408215-25696-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Back when commit aba5ea5c and commit 55197c98
happen that replaced dnotify with inotify the
ignoring of non-existent upcall directories
got dropped. The patch adds it back and stops
following error log

ERROR: inotify_add_watch failed for nfs/clntXX:
No such file or directory

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index e7cb07f..7ba27b1 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -400,8 +400,9 @@ gssd_get_clnt(struct topdir *tdi, const char *name)
 
 	clp->wd = inotify_add_watch(inotify_fd, clp->relpath, IN_CREATE | IN_DELETE);
 	if (clp->wd < 0) {
-		printerr(0, "ERROR: inotify_add_watch failed for %s: %s\n",
-			 clp->relpath, strerror(errno));
+		if (errno != ENOENT)
+			printerr(0, "ERROR: inotify_add_watch failed for %s: %s\n",
+			 	clp->relpath, strerror(errno));
 		goto out;
 	}
 
-- 
2.5.0

