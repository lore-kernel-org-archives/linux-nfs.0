Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:54863 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756323AbaGVQtz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 12:49:55 -0400
Received: by mail-qa0-f50.google.com with SMTP id s7so6790644qap.37
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 09:49:54 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: [PATCH 3/4] nfsd: nfs4_check_fh - make it actually check the filehandle
Date: Tue, 22 Jul 2014 12:49:43 -0400
Message-Id: <1406047784-1578-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406047784-1578-1-git-send-email-jlayton@primarydata.com>
References: <1406047784-1578-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

...instead of just checking the inode that corresponds to it.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c540a46f6305..4c9404500a8e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3953,7 +3953,7 @@ laundromat_main(struct work_struct *laundry)
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
 {
-	if (fhp->fh_dentry->d_inode != stp->st_file->fi_inode)
+	if (!nfsd_fh_match(&fhp->fh_handle, &stp->st_file->fi_fhandle))
 		return nfserr_bad_stateid;
 	return nfs_ok;
 }
-- 
1.9.3

