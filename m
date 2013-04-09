Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50127 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765117Ab3DIX6U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Apr 2013 19:58:20 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 01/10] nfsd4: remove some redundant comments
Date: Tue,  9 Apr 2013 19:58:06 -0400
Message-Id: <1365551896-6936-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1365551896-6936-1-git-send-email-bfields@redhat.com>
References: <1365551896-6936-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9cb9f6e..1226ff6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4432,17 +4432,11 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 						locku->lu_length);
 	nfs4_transform_lock_offset(file_lock);
 
-	/*
-	*  Try to unlock the file in the VFS.
-	*/
 	err = vfs_lock_file(filp, F_SETLK, file_lock, NULL);
 	if (err) {
 		dprintk("NFSD: nfs4_locku: vfs_lock_file failed!\n");
 		goto out_nfserr;
 	}
-	/*
-	* OK, unlock succeeded; the only thing left to do is update the stateid.
-	*/
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&locku->lu_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
-- 
1.7.9.5

