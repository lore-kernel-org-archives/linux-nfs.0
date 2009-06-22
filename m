From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] mydaemon: remove closeall() calls from mydaemon()
Date: Mon, 22 Jun 2009 15:50:38 -0400
Message-ID: <1245700238-3755-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.121]:57304 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbZFVTui (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jun 2009 15:50:38 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

idmapd and svcgssd have a mydaemon() routine that uses closeall() to
close file descriptors. Unfortunately, they aren't using it correctly
and it ends up closing the pipe that the child process uses to talk to
its parent.

Fix this by not using closeall() in this routine and instead, just close
the file descriptors that we know need to be closed. If /dev/null can't
be opened for some reason, then just have the child exit with a non-zero
error.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/svcgssd.c  |   14 ++++++++++----
 utils/idmapd/idmapd.c |    9 ++++++---
 2 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 69d2a69..729b6a6 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -117,10 +117,16 @@ mydaemon(int nochdir, int noclose)
 
 	if (noclose == 0) {
 		tempfd = open("/dev/null", O_RDWR);
-		dup2(tempfd, 0);
-		dup2(tempfd, 1);
-		dup2(tempfd, 2);
-		closeall(3);
+		if (tempfd >= 0) {
+			dup2(tempfd, 0);
+			dup2(tempfd, 1);
+			dup2(tempfd, 2);
+			close(tempfd);
+		} else {
+			printerr(1, "mydaemon: can't open /dev/null: errno %d "
+				    "(%s)\n", errno, strerror(errno));
+			exit(1);
+		}
 	}
 
 	return;
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index b690e21..9cbe96c 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -978,9 +978,12 @@ mydaemon(int nochdir, int noclose)
 			dup2(tempfd, 0);
 			dup2(tempfd, 1);
 			dup2(tempfd, 2);
-			closeall(3);
-		} else
-			closeall(0);
+			close(tempfd);
+		} else {
+			err(1, "mydaemon: can't open /dev/null: errno %d",
+			       errno);
+			exit(1);
+		}
 	}
 
 	return;
-- 
1.6.0.6

