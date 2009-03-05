From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/23] NFSD: Refactor socket creation out of __write_ports()
Date: Thu, 05 Mar 2009 16:32:16 -0500
Message-ID: <20090305213215.21342.77130.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:25101 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976AbZCEVcz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:32:55 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Refactor the socket creation logic out of __write_ports() to
make it easier to understand and maintain.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   64 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 34 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 5b99a99..0d3efa4 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -880,6 +880,37 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
 }
 
 /*
+ * A single 'fd' number was written, in which case it must be for
+ * a socket of a supported family/protocol, and we use it as an
+ * nfsd listener.
+ */
+static ssize_t __write_ports_addfd(char *buf)
+{
+	char *mesg = buf;
+	int fd, err;
+
+	err = get_int(&mesg, &fd);
+	if (err != 0 || fd < 0)
+		return -EINVAL;
+
+	err = nfsd_create_serv();
+	if (err != 0)
+		return err;
+
+	err = svc_addsock(nfsd_serv, fd, buf);
+	if (err >= 0) {
+		err = lockd_up();
+		if (err < 0)
+			svc_sock_names(buf + strlen(buf) + 1, nfsd_serv, buf);
+
+		/* Decrease the count, but don't shut down the service */
+		nfsd_serv->sv_nrthreads--;
+	}
+
+	return err < 0 ? err : 0;
+}
+
+/*
  * A '-' followed by the 'name' of a socket means we close the socket.
  */
 static ssize_t __write_ports_delfd(char *buf)
@@ -957,36 +988,9 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 			len = svc_xprt_names(nfsd_serv, buf, 0);
 		return len;
 	}
-	/* Either a single 'fd' number is written, in which
-	 * case it must be for a socket of a supported family/protocol,
-	 * and we use it as an nfsd socket, or
-	 * A '-' followed by the 'name' of a socket in which case
-	 * we close the socket.
-	 */
-	if (isdigit(buf[0])) {
-		char *mesg = buf;
-		int fd;
-		int err;
-		err = get_int(&mesg, &fd);
-		if (err)
-			return -EINVAL;
-		if (fd < 0)
-			return -EINVAL;
-		err = nfsd_create_serv();
-		if (!err) {
-			err = svc_addsock(nfsd_serv, fd, buf);
-			if (err >= 0) {
-				err = lockd_up();
-				if (err < 0)
-					svc_sock_names(buf+strlen(buf)+1, nfsd_serv, buf);
-			}
-			/* Decrease the count, but don't shutdown the
-			 * the service
-			 */
-			nfsd_serv->sv_nrthreads--;
-		}
-		return err < 0 ? err : 0;
-	}
+
+	if (isdigit(buf[0]))
+		return __write_ports_addfd(buf);
 
 	if (buf[0] == '-' && isdigit(buf[1]))
 		return __write_ports_delfd(buf);

