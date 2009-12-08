From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] statd: squelch compiler warning in sm-notify.c
Date: Tue, 08 Dec 2009 13:08:51 -0500
Message-ID: <20091208180851.3982.85467.stgit@localhost.localdomain>
References: <20091208180547.3982.31814.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:29469 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965711AbZLHSJO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:09:14 -0500
In-Reply-To: <20091208180547.3982.31814.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Get rid of a false positive compiler warning, seen with
-Wextra.

sm-notify.c: In function =E2=80=98record_pid=E2=80=99:
sm-notify.c:690: warning: comparison between signed and unsigned intege=
r
expressions

Document some ignored return codes while we're here.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 1d4403a..15d0a92 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -765,17 +765,21 @@ nsm_get_state(int update)
 static int record_pid(void)
 {
 	char pid[20];
+	ssize_t len;
 	int fd;
=20
-	snprintf(pid, 20, "%d\n", getpid());
+	(void)snprintf(pid, sizeof(pid), "%d\n", (int)getpid());
 	fd =3D open("/var/run/sm-notify.pid", O_CREAT|O_EXCL|O_WRONLY, 0600);
 	if (fd < 0)
 		return 0;
-	if (write(fd, pid, strlen(pid)) !=3D strlen(pid))  {
+
+	len =3D write(fd, pid, strlen(pid));
+	if ((len < 0) || ((size_t)len !=3D strlen(pid))) {
 		xlog_warn("Writing to pid file failed: errno %d (%m)",
 				errno);
 	}
-	close(fd);
+
+	(void)close(fd);
 	return 1;
 }
=20

