Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:49493 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbaF3PvK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:10 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so2125327qga.37
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:09 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 026/114] nfsd: remove nfs4_file_put_fd
Date: Mon, 30 Jun 2014 11:48:55 -0400
Message-Id: <1404143423-24381-27-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and replace it with a simple swap call.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6d8be6c235ca..485a0dc039d5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -381,24 +381,15 @@ static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 		__nfs4_file_get_access(fp, oflag);
 }
 
-static struct file *nfs4_file_put_fd(struct nfs4_file *fp, int oflag)
-{
-	struct file *filp;
-
-	filp = fp->fi_fds[oflag];
-	fp->fi_fds[oflag] = NULL;
-	return filp;
-}
-
 static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 {
 	if (atomic_dec_and_lock(&fp->fi_access[oflag], &fp->fi_lock)) {
 		struct file *f1 = NULL;
 		struct file *f2 = NULL;
 
-		f1 = nfs4_file_put_fd(fp, oflag);
+		swap(f1, fp->fi_fds[oflag]);
 		if (atomic_read(&fp->fi_access[1 - oflag]) == 0)
-			f2 = nfs4_file_put_fd(fp, O_RDWR);
+			swap(f2, fp->fi_fds[O_RDWR]);
 		spin_unlock(&fp->fi_lock);
 		if (f1)
 			fput(f1);
-- 
1.9.3

