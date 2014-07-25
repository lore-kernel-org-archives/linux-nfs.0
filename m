Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:37352 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759947AbaGYLev (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 07:34:51 -0400
Received: by mail-qa0-f50.google.com with SMTP id s7so4355520qap.37
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 04:34:51 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v6 7/9] nfsd: clean up nfs4_set_delegation
Date: Fri, 25 Jul 2014 07:34:25 -0400
Message-Id: <1406288067-20663-8-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
References: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
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
index 24065e1b2bb2..85d7ac664691 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3552,12 +3552,20 @@ out_fput:
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
@@ -3565,7 +3573,8 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	if (!fp->fi_lease) {
 		spin_unlock(&fp->fi_lock);
 		spin_unlock(&state_lock);
-		return nfs4_setlease(dp);
+		status = nfs4_setlease(dp);
+		goto out;
 	}
 	atomic_inc(&fp->fi_delegees);
 	if (fp->fi_had_conflict) {
@@ -3573,10 +3582,16 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
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
@@ -3650,12 +3665,9 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
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
 
@@ -3663,8 +3675,6 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
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

