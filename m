Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36007 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbbFRHAS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2015 03:00:18 -0400
Received: by paceq1 with SMTP id eq1so30270014pac.3
        for <linux-nfs@vger.kernel.org>; Thu, 18 Jun 2015 00:00:17 -0700 (PDT)
Message-ID: <55826C74.8020703@gmail.com>
Date: Thu, 18 Jun 2015 15:00:04 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH] nfsd: Prints a suitable length of filehandle
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With nfsd_debug on, fh_verify prints a fixed length of filehandle as,
nfsd: fh_verify(8: 00010001 00000000 00000000 00000000 00000000 00000000)
nfsd: fh_verify(28: 00070001 001c0002 00000000 041f9334 9b432a4c 835d4c95)

This patch lets nfsd prints a suitable length of filehandle as, 
nfsd: fh_verify(8: 00010001 00000000)
nfsd: fh_verify(28: 00070001 001c0002 00000000 041f9334 9b432a4c 835d4c95 8cbea40f)

Also, use snprintf insteads sprintf.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfsfh.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 350041a..dd6a5c1 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -650,16 +650,14 @@ fh_put(struct svc_fh *fhp)
 char * SVCFH_fmt(struct svc_fh *fhp)
 {
 	struct knfsd_fh *fh = &fhp->fh_handle;
-
-	static char buf[80];
-	sprintf(buf, "%d: %08x %08x %08x %08x %08x %08x",
-		fh->fh_size,
-		fh->fh_base.fh_pad[0],
-		fh->fh_base.fh_pad[1],
-		fh->fh_base.fh_pad[2],
-		fh->fh_base.fh_pad[3],
-		fh->fh_base.fh_pad[4],
-		fh->fh_base.fh_pad[5]);
+	/* 9 * NFS4_FHSIZE / 4 = 288 for fh_pad, 4 for fh_size, 1 for '\0' */
+	static char buf[293];
+	int pos = 0, i = 0;
+
+	pos = snprintf(buf, sizeof(buf), "%d:", fh->fh_size);
+	for (i = 0; i < fh->fh_size / sizeof(__u32); i++)
+		pos += snprintf(buf + pos, sizeof(buf) - pos,
+				" %08x", fh->fh_base.fh_pad[i]);
 	return buf;
 }
 
-- 
2.4.3

