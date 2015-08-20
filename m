Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f181.google.com ([209.85.160.181]:33935 "EHLO
	mail-yk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbbHTLRn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 07:17:43 -0400
Received: by ykdt205 with SMTP id t205so33876222ykd.1
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 04:17:43 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@lst.de, kinglongmee@gmail.com
Subject: [PATCH v3 17/20] nfsd: have nfsd_test_lock use the nfsd_file cache
Date: Thu, 20 Aug 2015 07:17:17 -0400
Message-Id: <1440069440-27454-18-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9e390b9fb33e..a92faba3a847 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5542,11 +5542,11 @@ out:
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

