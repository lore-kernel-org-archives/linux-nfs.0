From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/22] NFSD: Prevent buffer overflow in write_threads()
Date: Fri, 12 Dec 2008 16:59:04 -0500
Message-ID: <20081212215904.24332.76206.stgit@ingres.1015granger.net>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:58803 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133AbYLLV7e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2008 16:59:34 -0500
In-Reply-To: <20081212215340.24332.88416.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up write_threads() to eliminate the small possibility of
overflowing its output buffer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index a8e3f6b..f8a2a7f 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -666,9 +666,9 @@ static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 static ssize_t write_threads(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
-	int rv;
+
 	if (size > 0) {
-		int newthreads;
+		int rv, newthreads;
 		rv = get_int(&mesg, &newthreads);
 		if (rv)
 			return rv;
@@ -678,8 +678,9 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 		if (rv)
 			return rv;
 	}
-	sprintf(buf, "%d\n", nfsd_nrthreads());
-	return strlen(buf);
+
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
+							nfsd_nrthreads());
 }
 
 /**

