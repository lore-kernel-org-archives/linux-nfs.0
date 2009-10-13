From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/26] statd: squelch compiler warning in sm-notify.c
Date: Tue, 13 Oct 2009 10:57:06 -0400
Message-ID: <20091013145706.2424.34252.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:60480 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760112AbZJMO6M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:58:12 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEvCXK008673
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:57:14 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9D9Sx0c010554
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:57:32 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Get rid of a false positive compiler warning.

sm-notify.c: In function =E2=80=98record_pid=E2=80=99:
sm-notify.c:690: warning: comparison between signed and unsigned intege=
r
expressions

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 78b4174..f50ff2d 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -675,16 +675,20 @@ find_host(uint32_t xid)
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

