Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:38505 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbaGHSEw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:04:52 -0400
Received: by mail-qg0-f46.google.com with SMTP id q107so5257474qgd.5
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:04:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 012/100] nfsd: remove nfs4_file_put_fd
Date: Tue,  8 Jul 2014 14:03:00 -0400
Message-Id: <1404842668-22521-13-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and replace it with a simple swap call.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 ++-----------
 1 file changed, 2 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2c49cd909115..478f8f6d797e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -385,15 +385,6 @@ static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
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
 	might_lock(&fp->fi_lock);
@@ -402,9 +393,9 @@ static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
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

