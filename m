Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:56429 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762012AbaGRPN4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 11:13:56 -0400
Received: by mail-qg0-f45.google.com with SMTP id f51so3280527qge.18
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jul 2014 08:13:55 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH v4 09/10] nfsd: clean up nfs4_set_delegation
Date: Fri, 18 Jul 2014 11:13:35 -0400
Message-Id: <1405696416-32585-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move the alloc_init_deleg call into nfs4_set_delegation and change the
function to return a pointer to the delegation or an IS_ERR return. This
allows us to skip allocating a delegation if the file has already
experienced a lease conflict.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1834d9bd5935..a2c6c85adfc7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3553,12 +3553,20 @@ out_fput:
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
@@ -3566,7 +3574,8 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	if (!fp->fi_lease) {
 		spin_unlock(&fp->fi_lock);
 		spin_unlock(&state_lock);
-		return nfs4_setlease(dp);
+		status = nfs4_setlease(dp);
+		goto out;
 	}
 	atomic_inc(&fp->fi_delegees);
 	if (fp->fi_had_conflict) {
@@ -3574,10 +3583,16 @@ static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
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
@@ -3651,12 +3666,9 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
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
 
@@ -3664,8 +3676,6 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
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

