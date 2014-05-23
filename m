Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:47307 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbaEWL7c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 07:59:32 -0400
Received: by mail-qg0-f51.google.com with SMTP id q107so7817475qgd.38
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 04:59:31 -0700 (PDT)
Message-ID: <537F380A.5010302@gmail.com>
Date: Fri, 23 May 2014 19:59:06 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 2/4] NFSD: Helper function for parsing uuid
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 9a41d3d..8771f41 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -480,6 +480,23 @@ static inline int
 secinfo_parse(char **mesg, char *buf, struct svc_export *exp) { return 0; }
 #endif
 
+static inline int
+uuid_parse(char **mesg, char *buf, unsigned char **puuid)
+{
+	int len;
+
+	/* expect a 16 byte uuid encoded as \xXXXX... */
+	len = qword_get(mesg, buf, PAGE_SIZE);
+	if (len != 16)
+		return -EINVAL;
+
+	*puuid = kmemdup(buf, 16, GFP_KERNEL);
+	if (*puuid == NULL)
+		return -ENOMEM;
+
+	return 0;
+}
+
 static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 {
 	/* client path expiry [flags anonuid anongid fsid] */
@@ -558,18 +575,9 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 		while ((len = qword_get(&mesg, buf, PAGE_SIZE)) > 0) {
 			if (strcmp(buf, "fsloc") == 0)
 				err = fsloc_parse(&mesg, buf, &exp.ex_fslocs);
-			else if (strcmp(buf, "uuid") == 0) {
-				/* expect a 16 byte uuid encoded as \xXXXX... */
-				len = qword_get(&mesg, buf, PAGE_SIZE);
-				if (len != 16)
-					err  = -EINVAL;
-				else {
-					exp.ex_uuid =
-						kmemdup(buf, 16, GFP_KERNEL);
-					if (exp.ex_uuid == NULL)
-						err = -ENOMEM;
-				}
-			} else if (strcmp(buf, "secinfo") == 0)
+			else if (strcmp(buf, "uuid") == 0)
+				err = uuid_parse(&mesg, buf, &exp.ex_uuid);
+			else if (strcmp(buf, "secinfo") == 0)
 				err = secinfo_parse(&mesg, buf, &exp);
 			else
 				/* quietly ignore unknown words and anything
-- 
1.9.0

