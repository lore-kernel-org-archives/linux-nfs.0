From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/23] NFSD: Refactor transport addition out of __write_ports()
Date: Thu, 05 Mar 2009 16:32:01 -0500
Message-ID: <20090305213200.21342.93422.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:24235 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714AbZCEVcy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:32:54 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Refactor transport addition out of __write_ports() to make
it easier to understand and maintain.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   49 ++++++++++++++++++++++++++++---------------------
 1 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index c56f50f..72af950 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -880,6 +880,30 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
 }
 
 /*
+ * A transport listener is added by writing it's transport name and
+ * a port number
+ */
+static ssize_t __write_ports_addxprt(const char *transport,
+				     const unsigned short port)
+{
+	int err;
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
  * name, and it's port number
  */
@@ -954,27 +978,10 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
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
+		if (sscanf(buf, "%15s %4u", transport, &port) == 2)
+			return __write_ports_addxprt(transport, port);
 
 	if (buf[0] == '-' && isalpha(buf[1]))
 		if (sscanf(&buf[1], "%15s %4u", transport, &port) == 2)

