Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:34314 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbbJTReN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Oct 2015 13:34:13 -0400
Received: by qgem9 with SMTP id m9so21703984qge.1
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2015 10:34:13 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v6 16/19] nfsd: have nfsd_test_lock use the nfsd_file cache
Date: Tue, 20 Oct 2015 13:33:49 -0400
Message-Id: <1445362432-18869-17-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b72fa6816860..4348af408ccb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5596,11 +5596,11 @@ out:
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

