Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37000 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752965Ab2GaVAx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 17:00:53 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/4] rpc.gssd: handle error to open toplevel directory
Date: Tue, 31 Jul 2012 17:00:48 -0400
Message-Id: <1343768449-32205-3-git-send-email-bfields@redhat.com>
In-Reply-To: <20120731205931.GA32161@fieldses.org>
References: <20120731205931.GA32161@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Reverse the sense of the test here, and also add debugging and cleanup
in the error case.

(Though the lack of cleanup isn't currently a problem in practice since
we'll eventually exit in this case.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/gssd/gssd_main_loop.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index 6914687..142c8c5 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -121,11 +121,13 @@ topdirs_add_entry(struct dirent *dent)
 	}
 	snprintf(tdi->dirname, PATH_MAX, "%s/%s", pipefs_dir, dent->d_name);
 	tdi->fd = open(tdi->dirname, O_RDONLY);
-	if (tdi->fd != -1) {
-		fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
-		fcntl(tdi->fd, F_NOTIFY,
-		      DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
+	if (tdi->fd == -1) {
+		printerr(0, "ERROR: failed to open %s\n", tdi->dirname);
+		free(tdi);
+		return -1;
 	}
+	fcntl(tdi->fd, F_SETSIG, DNOTIFY_SIGNAL);
+	fcntl(tdi->fd, F_NOTIFY, DN_CREATE|DN_DELETE|DN_MODIFY|DN_MULTISHOT);
 
 	TAILQ_INSERT_HEAD(&topdirs_list, tdi, list);
 	return 0;
-- 
1.7.9.5

