From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/19] NFSD: Stricter buffer size checking in write_versions()
Date: Thu, 23 Apr 2009 19:33:18 -0400
Message-ID: <20090423233317.17283.36743.stgit@ingres.1015granger.net>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26918 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756164AbZDWXeg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 19:34:36 -0400
In-Reply-To: <20090423231550.17283.24432.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While it's not likely today that there are enough NFS versions to
overflow the output buffer in write_versions(), we should be more
careful about detecting the end of the buffer.

The number of NFS versions will only increase as NFSv4 minor versions
are added.

Note that this API doesn't behave the same as portlist.  Here we
attempt to display as many versions as will fit in the buffer, and do
not provide any indication that an overflow would have occurred.  I
don't have any good rationale for that.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   32 +++++++++++++++++++++++++-------
 1 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index c484346..a152694 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -793,7 +793,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
 	char *vers, *minorp, sign;
-	int len, num;
+	int len, num, remaining;
 	unsigned minor;
 	ssize_t tlen = 0;
 	char *sep;
@@ -840,32 +840,50 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 			}
 		next:
 			vers += len + 1;
-			tlen += len;
 		} while ((len = qword_get(&mesg, vers, size)) > 0);
 		/* If all get turned off, turn them back on, as
 		 * having no versions is BAD
 		 */
 		nfsd_reset_versions();
 	}
+
 	/* Now write current state into reply buffer */
 	len = 0;
 	sep = "";
+	remaining = SIMPLE_TRANSACTION_LIMIT;
 	for (num=2 ; num <= 4 ; num++)
 		if (nfsd_vers(num, NFSD_AVAIL)) {
-			len += sprintf(buf+len, "%s%c%d", sep,
+			len = snprintf(buf, remaining, "%s%c%d", sep,
 				       nfsd_vers(num, NFSD_TEST)?'+':'-',
 				       num);
 			sep = " ";
+
+			if (len > remaining)
+				break;
+			remaining -= len;
+			buf += len;
+			tlen += len;
 		}
 	if (nfsd_vers(4, NFSD_AVAIL))
-		for (minor = 1; minor <= NFSD_SUPPORTED_MINOR_VERSION; minor++)
-			len += sprintf(buf+len, " %c4.%u",
+		for (minor = 1; minor <= NFSD_SUPPORTED_MINOR_VERSION;
+		     minor++) {
+			len = snprintf(buf, remaining, " %c4.%u",
 					(nfsd_vers(4, NFSD_TEST) &&
 					 nfsd_minorversion(minor, NFSD_TEST)) ?
 						'+' : '-',
 					minor);
-	len += sprintf(buf+len, "\n");
-	return len;
+
+			if (len > remaining)
+				break;
+			remaining -= len;
+			buf += len;
+			tlen += len;
+		}
+
+	len = snprintf(buf, remaining, "\n");
+	if (len > remaining)
+		return -EINVAL;
+	return tlen + len;
 }
 
 /**

