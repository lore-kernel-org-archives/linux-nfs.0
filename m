Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:40358 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933336AbaGWURw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jul 2014 16:17:52 -0400
Received: by mail-qg0-f47.google.com with SMTP id i50so2106248qgf.34
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jul 2014 13:17:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: [PATCH v2 3/4] nfsd: nfs4_check_fh - make it actually check the filehandle
Date: Wed, 23 Jul 2014 16:17:40 -0400
Message-Id: <1406146661-9794-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406146661-9794-1-git-send-email-jlayton@primarydata.com>
References: <1406146661-9794-1-git-send-email-jlayton@primarydata.com>
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
index ab96718df3cc..6ced8d566c0b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3951,7 +3951,7 @@ laundromat_main(struct work_struct *laundry)
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
 {
-	if (fhp->fh_dentry->d_inode != stp->st_file->fi_inode)
+	if (!nfsd_fh_match(&fhp->fh_handle, &stp->st_file->fi_fhandle))
 		return nfserr_bad_stateid;
 	return nfs_ok;
 }
-- 
1.9.3

