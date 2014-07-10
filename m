Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:53198 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbaGJSHw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 14:07:52 -0400
Received: by mail-qg0-f45.google.com with SMTP id f51so740833qge.18
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 11:07:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH 05/11] nfsd: remove nfs4_file_put_fd
Date: Thu, 10 Jul 2014 14:07:29 -0400
Message-Id: <1405015655-12469-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and replace it with a simple swap call.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a19257f91f25..c02bad6d7e90 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -394,15 +394,6 @@ nfs4_file_get_access(struct nfs4_file *fp, u32 access)
 	return nfs_ok;
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
 	might_lock(&fp->fi_lock);
@@ -411,9 +402,9 @@ static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
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

