Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:48684 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaGUWy1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 18:54:27 -0400
Received: by mail-ie0-f173.google.com with SMTP id tr6so7336098ieb.4
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 15:54:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] knfsd: nfs4_check_fh - make it actually check the filehandle
Date: Mon, 21 Jul 2014 18:54:30 -0400
Message-Id: <1405983271-61861-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1405983271-61861-2-git-send-email-trond.myklebust@primarydata.com>
References: <1405983271-61861-1-git-send-email-trond.myklebust@primarydata.com>
 <1405983271-61861-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2e9519db4927..2b2cd6814615 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3958,7 +3958,7 @@ laundromat_main(struct work_struct *laundry)
 
 static inline __be32 nfs4_check_fh(struct svc_fh *fhp, struct nfs4_ol_stateid *stp)
 {
-	if (fhp->fh_dentry->d_inode != stp->st_stid.sc_file->fi_inode)
+	if (!nfsd_fh_match(&fhp->fh_handle, &stp->st_stid.sc_file->fi_fhandle))
 		return nfserr_bad_stateid;
 	return nfs_ok;
 }
-- 
1.9.3

