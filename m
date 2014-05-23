Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:53284 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbaEWMCJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 08:02:09 -0400
Received: by mail-qg0-f46.google.com with SMTP id q108so7634119qgd.5
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 05:02:08 -0700 (PDT)
Message-ID: <537F38AB.10102@gmail.com>
Date: Fri, 23 May 2014 20:01:47 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 4/4] NFSD: Ignore and warn once for more fslocs or more uuids
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If mountd writes more fslocs or more uuids, just ignore and warn once.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 90d37b6..1d56ae3 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -394,6 +394,12 @@ fsloc_parse(char **mesg, char *buf, struct nfsd4_fs_locations *fsloc)
 	int len;
 	int migrated, i, err;
 
+	/* utils writes more fslocs than one */
+	if (fsloc->locations) {
+		WARN_ON_ONCE(1);
+		return 0;
+	}
+
 	/* listsize */
 	err = get_uint(mesg, &fsloc->locations_count);
 	if (err)
@@ -485,6 +491,12 @@ uuid_parse(char **mesg, char *buf, unsigned char **puuid)
 {
 	int len;
 
+	/* utils writes more uuid than one */
+	if (*puuid) {
+		WARN_ON_ONCE(1);
+		return 0;
+	}
+
 	/* expect a 16 byte uuid encoded as \xXXXX... */
 	len = qword_get(mesg, buf, PAGE_SIZE);
 	if (len != EX_UUID_LEN)
-- 
1.9.0

