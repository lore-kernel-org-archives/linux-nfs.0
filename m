Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:50079 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445AbaEWMyF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 May 2014 08:54:05 -0400
Received: by mail-qc0-f178.google.com with SMTP id l6so7904294qcy.23
        for <linux-nfs@vger.kernel.org>; Fri, 23 May 2014 05:54:05 -0700 (PDT)
Message-ID: <537F44D8.2060606@gmail.com>
Date: Fri, 23 May 2014 20:53:44 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 2/5] NFSD: Cleanup unused variable in nfsd_setuser()
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 8f6c5ffc8987f4f5b5a3e9d557d94bbf3a9bf216 have remove
the last using of "ret", just remove it right now.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/auth.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfsd/auth.c b/fs/nfsd/auth.c
index 1042325..72f4482 100644
--- a/fs/nfsd/auth.c
+++ b/fs/nfsd/auth.c
@@ -24,7 +24,6 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 	struct cred *new;
 	int i;
 	int flags = nfsexp_flags(rqstp, exp);
-	int ret;
 
 	validate_process_creds();
 
@@ -85,8 +84,7 @@ int nfsd_setuser(struct svc_rqst *rqstp, struct svc_export *exp)
 	return 0;
 
 oom:
-	ret = -ENOMEM;
 	abort_creds(new);
-	return ret;
+	return -ENOMEM;
 }
 
-- 
1.9.3

