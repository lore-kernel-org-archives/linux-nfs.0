Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:40520 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbaGJSHy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 14:07:54 -0400
Received: by mail-qa0-f47.google.com with SMTP id i13so2235697qae.34
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 11:07:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH 07/11] nfsd: set stateid access and deny bits in nfs4_get_vfs_file
Date: Thu, 10 Jul 2014 14:07:31 -0400
Message-Id: <1405015655-12469-8-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cleanup -- ensure that the stateid bits are set at the same time that
the file access refcounts are incremented. Keeping them coherent like
this makes it easier to ensure that we account for all of the
references.

Since the initialization of the st_*_bmap fields is done when it's
hashed, we go ahead and hash the stateid before getting access to the
file and unhash it if that function returns error. This will be
necessary anyway in a follow-on patch that will overhaul deny mode
handling.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f7f11631c26c..0a54fc956463 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3300,7 +3300,8 @@ nfsd4_truncate(struct svc_rqst *rqstp, struct svc_fh *fh,
 }
 
 static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
-		struct svc_fh *cur_fh, struct nfsd4_open *open)
+		struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp,
+		struct nfsd4_open *open)
 {
 	struct file *filp = NULL;
 	__be32 status;
@@ -3330,6 +3331,9 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
 	if (status)
 		goto out_put_access;
 
+	/* Set access and deny bits in stateid */
+	set_access(open->op_share_access, stp);
+	set_deny(open->op_share_deny, stp);
 	return nfs_ok;
 
 out_put_access:
@@ -3341,20 +3345,15 @@ out:
 static __be32
 nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
 {
-	u32 op_share_access = open->op_share_access;
 	__be32 status;
 
-	if (!test_access(op_share_access, stp))
-		status = nfs4_get_vfs_file(rqstp, fp, cur_fh, open);
+	if (!test_access(open->op_share_access, stp))
+		status = nfs4_get_vfs_file(rqstp, fp, cur_fh, stp, open);
 	else
 		status = nfsd4_truncate(rqstp, cur_fh, open);
 
 	if (status)
 		return status;
-
-	/* remember the open */
-	set_access(op_share_access, stp);
-	set_deny(open->op_share_deny, stp);
 	return nfs_ok;
 }
 
@@ -3602,12 +3601,14 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 		if (status)
 			goto out;
 	} else {
-		status = nfs4_get_vfs_file(rqstp, fp, current_fh, open);
-		if (status)
-			goto out;
 		stp = open->op_stp;
 		open->op_stp = NULL;
 		init_open_stateid(stp, fp, open);
+		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
+		if (status) {
+			release_open_stateid(stp);
+			goto out;
+		}
 	}
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&open->op_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
-- 
1.9.3

