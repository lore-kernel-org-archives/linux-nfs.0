Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:60971 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbaEWM4h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 08:56:37 -0400
Received: by mail-qc0-f178.google.com with SMTP id l6so8035388qcy.9
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 05:56:36 -0700 (PDT)
Message-ID: <537F4570.8070903@gmail.com>
Date: Fri, 23 May 2014 20:56:16 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 5/5] NFSD: Add missing comment of "expiry" in expkey_parse()
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 39d15ce..dd32f3e 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -68,7 +68,7 @@ static struct svc_expkey *svc_expkey_lookup(struct cache_detail *cd, struct svc_
 
 static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 {
-	/* client fsidtype fsid [path] */
+	/* client fsidtype fsid expiry [path] */
 	char *buf;
 	int len;
 	struct auth_domain *dom = NULL;
-- 
1.9.3

