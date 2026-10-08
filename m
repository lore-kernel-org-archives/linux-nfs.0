Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F1AB4EFFDD
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 18:18:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791483523; cv=none; b=HOScRz2cJbSBb4m/XmCxZ64LND4arxDpmbzyDXQCHpTy/3eddJUcReSanmgBDOCdQWQBlqcBOA37BcDplwrBRiNnmydM/F5/omNii+1pa9KjzhT+H59ij0jBSrSQxo7h4shDuTiLRBLRiqHfFI9LnsGaVO9Svtnfy8t7It+556g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791483523; c=relaxed/simple;
	bh=2KxrF80s4/pXcnihX58n6lWiYh+bEHBbUTEX4TDrnDg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=i+8blNU5v7qm8nB+QJIiFYhsp45e307VwjtuZ+8EEibwwGq0Fz22K/vaMge9P+VQ5o0b1F5ev6ttnPJ5DkX0xBNPMH+KNUiUSZyT2NjuBOfCd50d8D3dA/X55dmLdJFy7MCX2x0KT51LtkYHWYFiNheDVECWKySsfvrv9syDGl8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LqB59AOA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LqB59AOA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 48F211F00898;
	Thu,  8 Oct 2026 18:18:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791483521;
	bh=IJreTwLOPcrw1XLAjOTkD8zl0etiFSe8FsWBdDPfm6A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LqB59AOAugA2wVkg6nWML0n3vj5SQqdtBPCeQoQaqKKi4KT7xPS88RL/xYy/BYgJ8
	 x43PtujnESctbu3LNYQ0kBNd/ZODIcP/klQBuGwyAuPaQYSUfr3DNV61bqMFrP4VqO
	 WAkaFDh9c9V4tWqZeyKcMb2v3ghrGZqpZML7fSbqA78jp5Zc6GLdC0/7AwxZTFY3Zv
	 kKHcdNmrI8m701YYyohBGI4W0j+pVa1pYTj8HETkVX5oZMAIPS+rinWd3hioWYaEVt
	 pO/2Y1GnmqLRxG2xQBxANvXZoCctUa8kdEHlzugXMmLYNCWTDH92t9o0wM36C/l1MR
	 O9ITBmT/0S2CQ==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 08 Oct 2026 14:18:28 -0400
Subject: [PATCH 2/5] NFSD: Report the correct value in an OPEN response's
 ond_why field
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261008-want-read-v1-2-e372262857c8@kernel.org>
References: <20261008-want-read-v1-0-e372262857c8@kernel.org>
In-Reply-To: <20261008-want-read-v1-0-e372262857c8@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3578; i=cel@kernel.org;
 h=from:subject:message-id; bh=2KxrF80s4/pXcnihX58n6lWiYh+bEHBbUTEX4TDrnDg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqx95/gqKU2e765mqTx+XM/utg9IEN6dfmBYker
 1yNe/78Eb2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasfefwAKCRAzarMzb2Z/
 l/MgD/96sj9EvZgmY/mLCJa6jtE8aJkzl6YYonDdjY46++o3mIYwos+QMYRnZy6taSYpkW2NwcO
 Enws5XpBK0PJXIPWt7CwX70stxZblHRV59sf/x1sun641epIT5fmBHJv0/37PfOMjllIhm77h4i
 FSGt8wt4WLjxfXw0bVfila6YJbzbFX4iVHGPbG+fGJG/7uT+GNT5pL6V3kPXT7rDjbHaqn40cuK
 OFEgS+iGfzw+wPDpVmBLm7BiukYJ2KGwo8JDX/j2ZhfQDDz77lsFRiPvp9MhMwpko9c7Cw10jwy
 JFwDlszpcKwFrJ94B9+EeoP+DU0GGoO4xfgjSAHMw8aaoTiy1Ad5T8IAp8VDe2m9KgRLn7HDnoi
 UhvrRV+VuQ7pMD8odtXz6WHhaw7z9aY1WHGqBPTZjcFmC3eNUWP6GaqZN2VA+124cZbj13m3IZw
 M1bt7jzgWye7+YJi787+VsHdJh3wOOPklRuEV0mfZpdv+pN/2Z6SkyUMmBhWcQorsQHyD7eBSEQ
 PJ0nuTNs8BatVZ5V0hN6GNEMWX56rEyKE5o54nDrx0iZBl6YIE28HYGQ9Y9vdhYZ4TfrtqkaOeF
 jKNptcV2m/UlqtVE98YAFNctG2Rc1MFgspjeasFw31fnLWPz3VUDw55AY9shIHj7bhuO4VICWWj
 oEn0fXNVkWlbr8g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Currently, when an NFS client sends an OPEN of a file with an
OPEN4_SHARE_ACCESS_WANT* bit set and NFSD grants no delegation, NFSD
sets ond_why to WND4_RESOURCE, even when a conflicting open or an
earlier recall on that file is the reason. NFSD reports WND4_RESOURCE
whether NFSD has hit its maximum delegation count or a second NFS
client has that file open.

When the server grants no delegation, the ond_why value is how a
client chooses between asking again for a delegation on that file
versus backing off.

Fixes: 0b26693c56cc ("nfsd: clean up nfs4_set_delegation")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5075baac7586..46e7343e050a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1511,7 +1511,7 @@ nfs4_delegation_exists(struct nfs4_client *clp, struct nfs4_file *fp)
  * Return:
  *      On success: NULL if the delegation was successfully hashed.
  *
- *      On error: -EAGAIN if one was previously granted to this
+ *      On error: -EEXIST if one was previously granted to this
  *                 nfs4_client for this nfs4_file. Delegation is not hashed.
  *
  */
@@ -1527,7 +1527,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	lockdep_assert_held(&clp->cl_lock);
 
 	if (nfs4_delegation_exists(clp, fp))
-		return -EAGAIN;
+		return -EEXIST;
 	refcount_inc(&dp->dl_stid.sc_count);
 	dp->dl_stid.sc_type = SC_TYPE_DELEG;
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
@@ -6944,7 +6944,7 @@ nfsd4_verify_deleg_dentry(struct nfsd4_open *open, struct nfs4_file *fp,
 				 &exp, &child);
 
 	if (err)
-		return -EAGAIN;
+		return -ESTALE;
 
 	exp_put(exp);
 	dput(child);
@@ -6967,7 +6967,7 @@ nfsd4_verify_setuid_write(struct nfsd4_open *open, struct nfsd_file *nf)
 
 	if ((open->op_share_access & NFS4_SHARE_ACCESS_WRITE) &&
 	    (inode->i_mode & (S_ISUID|S_ISGID)))
-		return -EAGAIN;
+		return -EPERM;
 	return 0;
 }
 
@@ -7053,7 +7053,7 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	}
 
 	if (!nf)
-		return ERR_PTR(-EAGAIN);
+		return ERR_PTR(-EBADF);
 
 	/*
 	 * File delegations and associated locks cannot be recovered if the
@@ -7067,9 +7067,9 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	spin_lock(&nn->deleg_lock);
 	spin_lock(&fp->fi_lock);
 	if (nfs4_delegation_exists(clp, fp))
-		status = -EAGAIN;
+		status = -EEXIST;
 	else if (nfsd4_verify_setuid_write(open, nf))
-		status = -EAGAIN;
+		status = -EPERM;
 	else if (!rcu_dereference_protected(fp->fi_deleg_file,
 					    lockdep_is_held(&fp->fi_lock))) {
 		rcu_assign_pointer(fp->fi_deleg_file, nf);
@@ -7298,8 +7298,10 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 			goto out_no_deleg;
 	}
 	dp = nfs4_set_delegation(open, &resp->cstate, stp, parent);
-	if (IS_ERR(dp))
+	if (IS_ERR(dp)) {
+		status = PTR_ERR(dp);
 		goto out_no_deleg;
+	}
 
 	memcpy(&open->op_delegate_stateid, &dp->dl_stid.sc_stateid, sizeof(dp->dl_stid.sc_stateid));
 
@@ -10687,7 +10689,7 @@ nfsd_get_dir_deleg(struct nfsd4_compound_state *cstate,
 	spin_lock(&fp->fi_lock);
 	/* existing delegation? */
 	if (nfs4_delegation_exists(clp, fp)) {
-		status = -EAGAIN;
+		status = -EEXIST;
 	} else if (!rcu_dereference_protected(fp->fi_deleg_file,
 					      lockdep_is_held(&fp->fi_lock))) {
 		rcu_assign_pointer(fp->fi_deleg_file, nfsd_file_get(nf));

-- 
2.55.0

