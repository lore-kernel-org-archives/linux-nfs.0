Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36209 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933767AbdBVXg1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Feb 2017 18:36:27 -0500
Received: by mail-it0-f66.google.com with SMTP id w185so2811689ita.3
        for <linux-nfs@vger.kernel.org>; Wed, 22 Feb 2017 15:35:40 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org, neilb@suse.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] nfsd: Fix display of the version string
Date: Wed, 22 Feb 2017 18:35:33 -0500
Message-Id: <20170222233533.23845-3-trond.myklebust@primarydata.com>
In-Reply-To: <20170222233533.23845-2-trond.myklebust@primarydata.com>
References: <20170222233533.23845-1-trond.myklebust@primarydata.com>
 <20170222233533.23845-2-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The current display code assumes that v4 minor version 0 is tracked by
the call to nfsd_vers(). Now it is tracked by nfsd_minorversion(), and
so we need to adjust the display code.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfsctl.c | 56 ++++++++++++++++++++++++++------------------------------
 1 file changed, 26 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 4bbba88416dc..73e75ac90525 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -536,6 +536,19 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	return rv;
 }
 
+static ssize_t
+nfsd_print_version_support(char *buf, int remaining, const char *sep,
+		unsigned vers, unsigned minor)
+{
+	const char *format = (minor == 0) ? "%s%c%u" : "%s%c%u.%u";
+	bool supported = !!nfsd_vers(vers, NFSD_TEST);
+
+	if (vers == 4 && !nfsd_minorversion(minor, NFSD_TEST))
+		supported = false;
+	return snprintf(buf, remaining, format, sep,
+			supported ? '+' : '-', vers, minor);
+}
+
 static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
@@ -598,40 +611,23 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 	len = 0;
 	sep = "";
 	remaining = SIMPLE_TRANSACTION_LIMIT;
-	for (num=2 ; num <= 4 ; num++)
-		if (nfsd_vers(num, NFSD_AVAIL)) {
-			len = snprintf(buf, remaining, "%s%c%d", sep,
-				       nfsd_vers(num, NFSD_TEST)?'+':'-',
-				       num);
-			sep = " ";
-
-			if (len >= remaining)
-				break;
-			remaining -= len;
-			buf += len;
-			tlen += len;
-		}
-	if (nfsd_vers(4, NFSD_AVAIL))
-		for (minor = 0; minor <= NFSD_SUPPORTED_MINOR_VERSION;
-		     minor++) {
-			if (minor == 0 && nfsd_minorversion(minor, NFSD_TEST))
-				/* for backward compatibility, don't report
-				 * +4.0
-				 */
-				continue;
-			len = snprintf(buf, remaining, " %c4.%u",
-					(nfsd_vers(4, NFSD_TEST) &&
-					 nfsd_minorversion(minor, NFSD_TEST)) ?
-						'+' : '-',
-					minor);
-
+	for (num=2 ; num <= 4 ; num++) {
+		if (!nfsd_vers(num, NFSD_AVAIL))
+			continue;
+		minor = 0;
+		do {
+			len = nfsd_print_version_support(buf, remaining,
+					sep, num, minor);
 			if (len >= remaining)
-				break;
+				goto out;
 			remaining -= len;
 			buf += len;
 			tlen += len;
-		}
-
+			minor++;
+			sep = " ";
+		} while (num == 4 && minor <= NFSD_SUPPORTED_MINOR_VERSION);
+	}
+out:
 	len = snprintf(buf, remaining, "\n");
 	if (len >= remaining)
 		return -EINVAL;
-- 
2.9.3

