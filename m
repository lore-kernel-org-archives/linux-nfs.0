Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:50496 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751558AbaFZTOa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:30 -0400
Received: by mail-qc0-f178.google.com with SMTP id c9so3518471qcz.37
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:30 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 032/117] nfsd: remove nfs4_file_put_fd
Date: Thu, 26 Jun 2014 15:12:12 -0400
Message-Id: <1403810017-16062-33-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and replace it with a simple swap call.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a6f1549a560e..0b6cd933eac6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -384,24 +384,15 @@ static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
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

