Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp01.smtpout.orange.fr ([80.12.242.123]:27127 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbcGBGYo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Jul 2016 02:24:44 -0400
From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: jlayton@poochiereds.net, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH 1/2] nfsd: Fix some indent inconsistancy
Date: Sat,  2 Jul 2016 08:24:32 +0200
Message-Id: <1467440672-8320-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Silent a few smatch warnings about indentation

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 fs/nfsd/nfs4state.c | 2 +-
 fs/nfsd/nfsfh.c     | 2 +-
 fs/nfsd/nfsxdr.c    | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ebfcebd..bc2173a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3130,7 +3130,7 @@ nfsd4_reclaim_complete(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 		 * We don't take advantage of the rca_one_fs case.
 		 * That's OK, it's optional, we can safely ignore it.
 		 */
-		 return nfs_ok;
+		return nfs_ok;
 	}
 
 	status = nfserr_complete_already;
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index a891944..4e19a92 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -533,7 +533,7 @@ fh_compose(struct svc_fh *fhp, struct svc_export *exp, struct dentry *dentry,
 	 * the reference filehandle (if it is in the same export)
 	 * or the export options.
 	 */
-	 set_version_and_fsid_type(fhp, exp, ref_fh);
+	set_version_and_fsid_type(fhp, exp, ref_fh);
 
 	if (ref_fh == fhp)
 		fh_put(ref_fh);
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 79d964a..41b468a 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -240,7 +240,7 @@ nfssvc_decode_diropargs(struct svc_rqst *rqstp, __be32 *p,
 	 || !(p = decode_filename(p, &args->name, &args->len)))
 		return 0;
 
-	 return xdr_argsize_check(rqstp, p);
+	return xdr_argsize_check(rqstp, p);
 }
 
 int
-- 
2.7.4

