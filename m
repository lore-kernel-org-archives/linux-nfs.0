From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 4/6] nfsd4: filehandle leak or error exit from fh_compose()
Date: Fri,  4 Sep 2009 15:47:04 -0400
Message-ID: <1252093626-5560-5-git-send-email-bfields@citi.umich.edu>
References: <1252093626-5560-1-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-2-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-3-git-send-email-bfields@citi.umich.edu>
 <1252093626-5560-4-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50167 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757294AbZIDTrE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 15:47:04 -0400
In-Reply-To: <1252093626-5560-4-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A number of callers (nfsd4_encode_fattr(), at least) don't bother to
release the filehandle returned to fh_compose() if fh_compose() returns
an error.  So, modify fh_compose() to release the filehandle before
returning an error.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfsfh.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index bce0b2b..01965b2 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -557,8 +557,10 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 
 		if (inode)
 			_fh_update(fhp, exp, dentry);
-		if (fhp->fh_handle.fh_fileid_type == 255)
+		if (fhp->fh_handle.fh_fileid_type == 255) {
+			fh_put(fhp);
 			return nfserr_opnotsupp;
+		}
 	}
 
 	return 0;
-- 
1.6.0.4

