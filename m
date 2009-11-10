From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/29] statd: squelch compiler warning in sm-notify.c
Date: Tue, 10 Nov 2009 16:59:01 -0500
Message-ID: <20091110215900.23822.27196.stgit@matisse.1015granger.net>
References: <20091110215447.23822.15275.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, Chris.Mason@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:50497 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbZKJV7S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Nov 2009 16:59:18 -0500
In-Reply-To: <20091110215447.23822.15275.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up:  Get rid of a false positive compiler warning.

sm-notify.c: In function =E2=80=98record_pid=E2=80=99:
sm-notify.c:690: warning: comparison between signed and unsigned intege=
r
expressions

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 4fda046..9a46ec4 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -703,16 +703,20 @@ find_host(uint32_t xid)
 static int record_pid(void)
 {
 	char pid[20];
+	ssize_t len;
 	int fd;
=20
 	snprintf(pid, 20, "%d\n", getpid());
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

