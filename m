From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/23] NFSD: Refactor transport removal out of __write_ports()
Date: Thu, 05 Mar 2009 16:31:53 -0500
Message-ID: <20090305213153.21342.35722.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:25017 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028AbZCEVct (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:32:49 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Refactor transport removal out of __write_ports() to make it
easier to understand and maintain.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   53 +++++++++++++++++++++++++++++------------------------
 1 files changed, 29 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 817999e..c56f50f 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -879,8 +879,32 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
 	return rv;
 }
 
+/*
+ * A transport listener is removed by writing a "-", it's transport
+ * name, and it's port number
+ */
+static ssize_t __write_ports_delxprt(const char *transport,
+				     const unsigned short port)
+{
+	struct svc_xprt *xprt;
+
+	if (port == 0 || nfsd_serv == NULL)
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
+	char transport[16];
+	int port;
+
 	if (size == 0) {
 		int len = 0;
 
@@ -951,30 +975,11 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
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
-			if (port == 0)
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
+		if (sscanf(&buf[1], "%15s %4u", transport, &port) == 2)
+			return __write_ports_delxprt(transport, port);
+
 	return -EINVAL;
 }
 

