Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35967 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752121AbbKIPkj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Nov 2015 10:40:39 -0500
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id 16E248FAA5
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2015 15:40:39 +0000 (UTC)
Received: from smallhat.boston.devel.redhat.com (vpn-54-90.rdu2.redhat.com [10.10.54.90])
	by int-mx13.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id tA9FecFW013823
	for <linux-nfs@vger.kernel.org>; Mon, 9 Nov 2015 10:40:38 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] rcpbind.sock removed when daemon is killed
Date: Mon,  9 Nov 2015 10:40:36 -0500
Message-Id: <1447083636-17178-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpcbind.sock and rpcbind.lock are created as root
when rpcbind starts. Some distro allow rpcbind
to run as root, others do not.

For distro that change the uid/gid of the running
rpcbind, the uid/gid of those files most also be
changed so they can be removed at termination

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpcbind.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/src/rpcbind.c b/src/rpcbind.c
index 045daa1..c6129a9 100644
--- a/src/rpcbind.c
+++ b/src/rpcbind.c
@@ -262,10 +262,18 @@ main(int argc, char *argv[])
 			syslog(LOG_ERR, "cannot get uid of '%s': %m", id);
 			exit(1);
 		}
-                if (setgid(p->pw_gid) == -1) {
-                        syslog(LOG_ERR, "setgid to '%s' (%d) failed: %m", id, p->pw_gid);
-                        exit(1);
-                }
+		if (chown(RPCBINDDLOCK, p->pw_uid, p->pw_gid) < 0){
+			syslog(LOG_WARNING, "chown of '%s' to %d/%d failed: %m", 
+				RPCBINDDLOCK, p->pw_uid, p->pw_gid);
+		}
+		if (chown(_PATH_RPCBINDSOCK, p->pw_uid, p->pw_gid) < 0){
+			syslog(LOG_WARNING, "chown of '%s' to %d/%d failed: %m", 
+				_PATH_RPCBINDSOCK, p->pw_uid, p->pw_gid);
+		}
+		if (setgid(p->pw_gid) == -1) {
+			syslog(LOG_ERR, "setgid to '%s' (%d) failed: %m", id, p->pw_gid);
+			exit(1);
+		}
 		if (setgroups(0, NULL) == -1) {
 			syslog(LOG_ERR, "dropping supplemental groups failed: %m");
 			exit(1);
-- 
2.4.3

