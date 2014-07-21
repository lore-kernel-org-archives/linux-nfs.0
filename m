Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:60873 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932219AbaGUNfb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 09:35:31 -0400
Received: by mail-qg0-f54.google.com with SMTP id z60so5357490qgd.27
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 06:35:28 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v5 09/10] nfsd: clean up nfs4_set_delegation
Date: Mon, 21 Jul 2014 09:35:05 -0400
Message-Id: <1405949706-27757-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
References: <1405949706-27757-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the alloc_init_deleg call into nfs4_set_delegation and change the
function to return a pointer to the delegation or an IS_ERR return. This
allows us to skip allocating a delegation if the file has already
experienced a lease conflict.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 171ab5a2c60c..18d1b60f506f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3546,12 +3546,20 @@ out_fput:
 	return status;
 }
 
-static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
+static struct nfs4_delegation *
+nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
+		    struct nfs4_file *fp)
 {
-	int status = 0;
+	int status;
+	struct nfs4_delegation *dp;
 
 	if (fp->fi_had_conflict)
-		return -EAGAIN;
+		return ERR_PTR(-EAGAIN);
+
+	dp = alloc_init_deleg(clp, fh);
+	if (!dp)
+		return ERR_PTR(-ENOMEM);
+
 	get_nfs4_file(fp);
 	spin_lock(&state_lock);
 	spin_lock(&fp->fi_lock);
@@ -3559,7 +3567,8 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	if (!fp->fi_lease) {
 		spin_unlock(&fp->fi_lock);
 		spin_unlock(&state_lock);
-		return nfs4_setlease(dp);
+		status = nfs4_setlease(dp);
+		goto out;
 	}
 	atomic_inc(&fp->fi_delegees);
 	if (fp->fi_had_conflict) {
@@ -3567,10 +3576,16 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 		goto out_unlock;
 	}
 	hash_delegation_locked(dp, fp);
+	status = 0;
 out_unlock:
 	spin_unlock(&fp->fi_lock);
 	spin_unlock(&state_lock);
-	return status;
+out:
+	if (status) {
+		nfs4_put_delegation(dp);
+		return ERR_PTR(status);
+	}
+	return dp;
 }
 
 static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
@@ -3644,12 +3659,9 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
 		default:
 			goto out_no_deleg;
 	}
-	dp = alloc_init_deleg(clp, fh);
-	if (dp == NULL)
+	dp = nfs4_set_delegation(clp, fh, stp->st_file);
+	if (IS_ERR(dp))
 		goto out_no_deleg;
-	status = nfs4_set_delegation(dp, stp->st_file);
-	if (status)
-		goto out_free;
 
 	memcpy(&open->op_delegate_stateid, &dp->dl_stid.sc_stateid, sizeof(dp->dl_stid.sc_stateid));
 
@@ -3657,8 +3669,6 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
 		STATEID_VAL(&dp->dl_stid.sc_stateid));
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
 	return;
-out_free:
-	nfs4_put_delegation(dp);
 out_no_deleg:
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
 	if (open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS &&
-- 
1.9.3

