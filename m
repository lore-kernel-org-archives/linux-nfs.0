From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/23] NFSD: Finish refactoring __write_ports()
Date: Thu, 05 Mar 2009 16:32:31 -0500
Message-ID: <20090305213230.21342.84979.stgit@ingres.1015granger.net>
References: <20090305212823.21342.38352.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:24976 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbZCEVcq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Mar 2009 16:32:46 -0500
In-Reply-To: <20090305212823.21342.38352.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Refactor transport name listing out of __write_ports() to
make it easier to understand and maintain.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 441fbfd..80f773b 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -880,6 +880,17 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
 }
 
 /*
+ * Zero-length write.  Return a list of NFSD's current listener
+ * transports.
+ */
+static ssize_t __write_ports_names(char *buf)
+{
+	if (nfsd_serv == NULL)
+		return 0;
+	return svc_xprt_names(nfsd_serv, buf, 0);
+}
+
+/*
  * A single 'fd' number was written, in which case it must be for
  * a socket of a supported family/protocol, and we use it as an
  * nfsd listener.
@@ -981,13 +992,8 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 	char transport[16];
 	int port;
 
-	if (size == 0) {
-		int len = 0;
-
-		if (nfsd_serv)
-			len = svc_xprt_names(nfsd_serv, buf, 0);
-		return len;
-	}
+	if (size == 0)
+		return __write_ports_names(buf);
 
 	if (isdigit(buf[0]))
 		return __write_ports_addfd(buf);

