From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/19] NFSD: Finish refactoring __write_ports()
Date: Thu, 23 Apr 2009 19:32:10 -0400
Message-ID: <20090423233210.17283.16437.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:59205 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408AbZDWXcZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:32:25 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Refactor transport name listing out of __write_ports() to
make it easier to understand and maintain.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d491fa9..caf4fdc 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -911,6 +911,17 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
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
@@ -1019,13 +1030,8 @@ static ssize_t __write_ports_delxprt(char *buf)
 
 static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 {
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

