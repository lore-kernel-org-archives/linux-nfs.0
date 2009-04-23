From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/19] NFSD: Refactor transport addition out of __write_ports()
Date: Thu, 23 Apr 2009 19:31:40 -0400
Message-ID: <20090423233140.17283.32607.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:64806 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbZDWXc0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:32:26 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Refactor transport addition out of __write_ports() to make
it easier to understand and maintain.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   56 ++++++++++++++++++++++++++++++++----------------------
 1 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 2c1dce8..748532b 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -911,6 +911,36 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
 }
 
 /*
+ * A transport listener is added by writing it's transport name and
+ * a port number.
+ */
+static ssize_t __write_ports_addxprt(char *buf)
+{
+	char transport[16];
+	int port, err;
+
+	if (sscanf(buf, "%15s %4u", transport, &port) != 2)
+		return -EINVAL;
+
+	if (port < 1 || port > USHORT_MAX)
+		return -EINVAL;
+
+	err = nfsd_create_serv();
+	if (err != 0)
+		return err;
+
+	err = svc_create_xprt(nfsd_serv, transport,
+				PF_INET, port, SVC_SOCK_ANONYMOUS);
+	if (err < 0) {
+		/* Give a reasonable perror msg for bad transport string */
+		if (err == -ENOENT)
+			err = -EPROTONOSUPPORT;
+		return err;
+	}
+	return 0;
+}
+
+/*
  * A transport listener is removed by writing a "-", it's transport
  * name, and it's port number.
  */
@@ -986,29 +1016,9 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 		kfree(toclose);
 		return len;
 	}
-	/*
-	 * Add a transport listener by writing it's transport name
-	 */
-	if (isalpha(buf[0])) {
-		int err;
-		char transport[16];
-		int port;
-		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
-			if (port < 1 || port > 65535)
-				return -EINVAL;
-			err = nfsd_create_serv();
-			if (!err) {
-				err = svc_create_xprt(nfsd_serv,
-						      transport, PF_INET, port,
-						      SVC_SOCK_ANONYMOUS);
-				if (err == -ENOENT)
-					/* Give a reasonable perror msg for
-					 * bad transport string */
-					err = -EPROTONOSUPPORT;
-			}
-			return err < 0 ? err : 0;
-		}
-	}
+
+	if (isalpha(buf[0]))
+		return __write_ports_addxprt(buf);
 
 	if (buf[0] == '-' && isalpha(buf[1]))
 		return __write_ports_delxprt(buf);

