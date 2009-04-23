From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/19] NFSD: Refactor portlist socket closing into a helper
Date: Thu, 23 Apr 2009 19:31:48 -0400
Message-ID: <20090423233147.17283.90298.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:45448 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755109AbZDWXc3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:32:29 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Refactor the socket closing logic out of __write_ports() to
make it easier to understand and maintain.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   36 ++++++++++++++++++++++++------------
 1 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 748532b..fa268d1 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -911,6 +911,27 @@ static ssize_t write_versions(struct file *file, char *buf, size_t size)
 }
 
 /*
+ * A '-' followed by the 'name' of a socket means we close the socket.
+ */
+static ssize_t __write_ports_delfd(char *buf)
+{
+	char *toclose;
+	int len = 0;
+
+	toclose = kstrdup(buf + 1, GFP_KERNEL);
+	if (toclose == NULL)
+		return -ENOMEM;
+
+	if (nfsd_serv != NULL)
+		len = svc_sock_names(buf, nfsd_serv, toclose);
+	if (len >= 0)
+		lockd_down();
+
+	kfree(toclose);
+	return len;
+}
+
+/*
  * A transport listener is added by writing it's transport name and
  * a port number.
  */
@@ -1004,18 +1025,9 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size)
 		}
 		return err < 0 ? err : 0;
 	}
-	if (buf[0] == '-' && isdigit(buf[1])) {
-		char *toclose = kstrdup(buf+1, GFP_KERNEL);
-		int len = 0;
-		if (!toclose)
-			return -ENOMEM;
-		if (nfsd_serv)
-			len = svc_sock_names(buf, nfsd_serv, toclose);
-		if (len >= 0)
-			lockd_down();
-		kfree(toclose);
-		return len;
-	}
+
+	if (buf[0] == '-' && isdigit(buf[1]))
+		return __write_ports_delfd(buf);
 
 	if (isalpha(buf[0]))
 		return __write_ports_addxprt(buf);

