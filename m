From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/19] NFSD: Refactor transport removal out of __write_ports()
Date: Thu, 23 Apr 2009 19:31:32 -0400
Message-ID: <20090423233132.17283.22025.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:64779 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926AbZDWXcX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:32:23 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Refactor transport removal out of __write_ports() to make it
easier to understand and maintain.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   53 +++++++++++++++++++++++++++++------------------------
 1 files changed, 29 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index af16849..2c1dce8 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -910,6 +910,31 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
 	return rv;
 }
 
+/*
+ * A transport listener is removed by writing a "-", it's transport
+ * name, and it's port number.
+ */
+static ssize_t __write_ports_delxprt(char *buf)
+{
+	struct svc_xprt *xprt;
+	char transport[16];
+	int port;
+
+	if (sscanf(&buf[1], "%15s %4u", transport, &port) != 2)
+		return -EINVAL;
+
+	if (port < 1 || port > USHORT_MAX || nfsd_serv == NULL)
+		return -EINVAL;
+
+	xprt = svc_find_xprt(nfsd_serv, transport, AF_UNSPEC, port);
+	if (xprt == NULL)
+		return -ENOTCONN;
+
+	svc_close_xprt(xprt);
+	svc_xprt_put(xprt);
+	return 0;
+}
+
 static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 {
 	if (size == 0) {
@@ -984,30 +1009,10 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 			return err < 0 ? err : 0;
 		}
 	}
-	/*
-	 * Remove a transport by writing it's transport name and port number
-	 */
-	if (buf[0] == '-' && isalpha(buf[1])) {
-		struct svc_xprt *xprt;
-		int err = -EINVAL;
-		char transport[16];
-		int port;
-		if (sscanf(&buf[1], "%15s %4d", transport, &port) == 2) {
-			if (port < 1 || port > 65535)
-				return -EINVAL;
-			if (nfsd_serv) {
-				xprt = svc_find_xprt(nfsd_serv, transport,
-						     AF_UNSPEC, port);
-				if (xprt) {
-					svc_close_xprt(xprt);
-					svc_xprt_put(xprt);
-					err = 0;
-				} else
-					err = -ENOTCONN;
-			}
-			return err < 0 ? err : 0;
-		}
-	}
+
+	if (buf[0] == '-' && isalpha(buf[1]))
+		return __write_ports_delxprt(buf);
+
 	return -EINVAL;
 }
 

