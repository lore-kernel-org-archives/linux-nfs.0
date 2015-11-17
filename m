Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:33184 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513AbbKQLxh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 06:53:37 -0500
Received: by qgea14 with SMTP id a14so3418489qge.0
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 03:53:37 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH v1 19/38] nfsd: have nfsd_test_lock use the nfsd_file cache
Date: Tue, 17 Nov 2015 06:52:41 -0500
Message-Id: <1447761180-4250-20-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e7adb6b60005..5007095d0228 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5707,11 +5707,11 @@ out:
  */
 static __be32 nfsd_test_lock(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file_lock *lock)
 {
-	struct file *file;
-	__be32 err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
+	struct nfsd_file *nf;
+	__be32 err = nfsd_file_acquire(rqstp, fhp, NFSD_MAY_READ, &nf);
 	if (!err) {
-		err = nfserrno(vfs_test_lock(file, lock));
-		fput(file);
+		err = nfserrno(vfs_test_lock(nf->nf_file, lock));
+		nfsd_file_put(nf);
 	}
 	return err;
 }
-- 
2.4.3

