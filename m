Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:33108 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbaGJSIB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 14:08:01 -0400
Received: by mail-qa0-f52.google.com with SMTP id j15so1038459qaq.11
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 11:07:59 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH 11/11] nfsd: cleanup and rename nfs4_check_open
Date: Thu, 10 Jul 2014 14:07:35 -0400
Message-Id: <1405015655-12469-12-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rename it to better describe what it does, and have it just return the
stateid instead of a __be32 (which is now always nfs_ok). Also, do the
search for an existing stateid after the delegation check, to reduce
cleanup if the delegation check returns error.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index da88b31c0afe..225f98c7d00d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3297,10 +3297,10 @@ out:
 	return nfs_ok;
 }
 
-static __be32
-nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_stateid **stpp)
+static struct nfs4_ol_stateid *
+nfsd4_find_existing_open(struct nfs4_file *fp, struct nfsd4_open *open)
 {
-	struct nfs4_ol_stateid *local;
+	struct nfs4_ol_stateid *local, *ret = NULL;
 	struct nfs4_openowner *oo = open->op_openowner;
 
 	spin_lock(&fp->fi_lock);
@@ -3308,14 +3308,13 @@ nfs4_check_open(struct nfs4_file *fp, struct nfsd4_open *open, struct nfs4_ol_st
 		/* ignore lock owners */
 		if (local->st_stateowner->so_is_open_owner == 0)
 			continue;
-		/* remember if we have seen this open owner */
 		if (local->st_stateowner == &oo->oo_owner) {
-			*stpp = local;
+			ret = local;
 			break;
 		}
 	}
 	spin_unlock(&fp->fi_lock);
-	return nfs_ok;
+	return ret;
 }
 
 static inline int nfs4_access_to_access(u32 nfs4_access)
@@ -3658,12 +3657,10 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	 */
 	fp = find_or_add_file(ino, open->op_file);
 	if (fp != open->op_file) {
-		status = nfs4_check_open(fp, open, &stp);
-		if (status)
-			goto out;
 		status = nfs4_check_deleg(cl, open, &dp);
 		if (status)
 			goto out;
+		stp = nfsd4_find_existing_open(fp, open);
 	} else {
 		open->op_file = NULL;
 		status = nfserr_bad_stateid;
-- 
1.9.3

