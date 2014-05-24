Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f42.google.com ([209.85.219.42]:43339 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaEXDUS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 23:20:18 -0400
Received: by mail-oa0-f42.google.com with SMTP id j17so6483914oag.29
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 20:20:17 -0700 (PDT)
Message-ID: <53800FDD.7030001@gmail.com>
Date: Sat, 24 May 2014 11:19:57 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH v2] NFSD: Error out when getting more than one fsloc/secinfo/uuid
References: <537F38AB.10102@gmail.com> <20140523135435.GK25423@fieldses.org> <537F5A1A.9000005@gmail.com> <20140523144128.GO25423@fieldses.org>
In-Reply-To: <20140523144128.GO25423@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
remove WARN_ON_ONCE(1) and return -EINVAL instead of ignoring it. 

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 7884051..13b85f9 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -389,6 +389,10 @@ fsloc_parse(char **mesg, char *buf, struct nfsd4_fs_locations *fsloc)
 	int len;
 	int migrated, i, err;
 
+	/* more than one fsloc */
+	if (fsloc->locations)
+		return -EINVAL;
+
 	/* listsize */
 	err = get_uint(mesg, &fsloc->locations_count);
 	if (err)
@@ -442,6 +446,10 @@ static int secinfo_parse(char **mesg, char *buf, struct svc_export *exp)
 	u32 listsize;
 	int err;
 
+	/* more than one secinfo */
+	if (exp->ex_nflavors)
+		return -EINVAL;
+
 	err = get_uint(mesg, &listsize);
 	if (err)
 		return err;
@@ -481,6 +489,10 @@ uuid_parse(char **mesg, char *buf, unsigned char **puuid)
 {
 	int len;
 
+	/* more than one uuid */
+	if (*puuid)
+		return -EINVAL;
+
 	/* expect a 16 byte uuid encoded as \xXXXX... */
 	len = qword_get(mesg, buf, PAGE_SIZE);
 	if (len != EX_UUID_LEN)
-- 
1.9.3

