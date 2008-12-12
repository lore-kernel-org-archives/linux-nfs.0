From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/22] NFSD: Prevent buffer overflow in write_versions()
Date: Fri, 12 Dec 2008 16:59:12 -0500
Message-ID: <20081212215911.24332.44272.stgit@ingres.1015granger.net>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aime.le-rouzic@bull.net, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:36699 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755355AbYLLV7s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2008 16:59:48 -0500
In-Reply-To: <20081212215340.24332.88416.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix up write_versions() to eliminate the possibility of overflowing
its output buffer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   26 ++++++++++++++++++--------
 1 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f8a2a7f..41e09c6 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -777,7 +777,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
 	char *vers, sign;
-	int len, num;
+	int len, num, remaining;
 	ssize_t tlen = 0;
 	char *sep;
 
@@ -818,18 +818,28 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 		 */
 		nfsd_reset_versions();
 	}
+
 	/* Now write current state into reply buffer */
-	len = 0;
+	tlen = 0;
 	sep = "";
-	for (num=2 ; num <= 4 ; num++)
+	remaining = SIMPLE_TRANSACTION_LIMIT;
+	for (num = 2 ; num <= 4 ; num++)
 		if (nfsd_vers(num, NFSD_AVAIL)) {
-			len += sprintf(buf+len, "%s%c%d", sep,
-				       nfsd_vers(num, NFSD_TEST)?'+':'-',
-				       num);
+			len = snprintf(buf, remaining, "%s%c%d", sep,
+					nfsd_vers(num, NFSD_TEST) ?  '+' : '-',
+					num);
 			sep = " ";
+
+			if (len >= remaining - 1)
+				break;
+
+			remaining -= len;
+			buf += len;
+			tlen += len;
 		}
-	len += sprintf(buf+len, "\n");
-	return len;
+	snprintf(buf, remaining, "\n");
+
+	return tlen;
 }
 
 /**

