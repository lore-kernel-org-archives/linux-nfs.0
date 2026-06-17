Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6ACF5367B61;
	Wed, 17 Jun 2026 18:12:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781719976; cv=none; b=qf+MvFEPmxKDFUslzt+dwZ7uF//TOylrN9cK/5KuF3R34i+p/mr1jb2VnhaXdmMEwnAbjQ2zvUiS0ZmBGx+JzBmZZ2ADumhN23tQjAzz80vRm4R7OpmilqxQRnY4BLfsGDa405xyitkVvxJwuSjgFoAn4iXOh9RgLgnXxzMc1gM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781719976; c=relaxed/simple;
	bh=97y7VHn+7/tr1IBpQgPzzcTR3w1ikl2Cyirbs15m0Tg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=dAtyz9YLZ1nYPVGjasEs+X/zaAEYqZ3NKfV5ZNlwnpXDa2BZQG/cYCI9YuyXbtfKk8oS9o0hgfhZL7taE6EaUfY4dU9WgbyACw1KV5uchv7vP5SAtbPxQ3XvGoZtwrk3p0hdsUiFnN2B5KRFOAVe360Cras5SdEYWfDH6DiG+i4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Tj/Njt98; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Tj/Njt98"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8F78E1F00A3D;
	Wed, 17 Jun 2026 18:12:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781719975;
	bh=JnPX0YVhGh5MqHxVC+905A7av802f5NhccwvTiDw+AE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Tj/Njt98g+D0WWnoqBpfJlBxfrszzoi93fufNa57pfGaBDPDC2mSLwLlZYOjHzmGD
	 DuGUFHvPJrHn7shH/uP9BYKfJ/xcCPcIqlsfG7yl3fmO8Nb/mxccXjrnvOIANwSh/E
	 9bo6+MGGKVSGV5i92JexerZYQORZdrjcgC9jjy0DUMIqtMZ8mK8Mnv8vkjmIrfQtqj
	 OO46JyxgI+2R8Tl8aHhBDWNYrf3hx7rVm+2teMhME85xMgLXBBRMPB86NCvZ5CUEwL
	 bhPGSLpFcJJ+hd7i3+ogDCfJqF7DN/EhyuK5T81WPKZQgEhK9YDpWOUuD4q5RHQUAh
	 01AN6WZSCm0yw==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 17 Jun 2026 14:12:30 -0400
Subject: [PATCH 2/3] nfsd: fix NULL deref / UAF of sc_export in
 setup_notify_fhandle
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260617-dir-deleg-fixes-v1-2-32b85b366c29@kernel.org>
References: <20260617-dir-deleg-fixes-v1-0-32b85b366c29@kernel.org>
In-Reply-To: <20260617-dir-deleg-fixes-v1-0-32b85b366c29@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3690; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=97y7VHn+7/tr1IBpQgPzzcTR3w1ikl2Cyirbs15m0Tg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqMuOkn35RcQCqwPiu2Wzo7k8Od0GSy2undwPAn
 zOtg2qLHQ6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajLjpAAKCRAADmhBGVaC
 FZFVEACCZCnWG04Apbd9VLzJWE6JNFhJI88skj5eqHCnOUcEjmDmp7NN75O7/1XAvUookXu4DoE
 9F7/sJQ67GTFrpJ5HDSWf/ZD6fW+Ww66ZfUp8kYlkX1bwJbDQVnCoBGGXqY4DeVy5LlMJcz2O9J
 2jVSb8FT6tOyT8aDHtx5qITF5YUKRh6h4vQXpJr/OY0p76XVyWnw18fTGnOE518tg+D7JvUqX0V
 RYnV1xEe+SnAdzykojIDxhjDqycmJgdFyqea7tjOnYRNdCPMWNnnu1wGu57NG6SI8taV1kH0iqr
 y/G2GFoHK6wpOv/4VGOuA8pufZi3Ks+ZQBbyNB+0/3E+VCgHWeCLBRu36YtweTiaGcYpvUxiQBp
 agVtmvq/nJegZ3qM86PjnuoWkXfAcTD3Vvr3B7VyfEcS6E+pNL8/kWfbzqshS3YRDncnfgPxZ0y
 ezfHVWV9vEguHYftI6+d6PXt+m4Mtbf08yYQFGNZRsBKRpavest1xVD+1OyV4NQ/MNZ4zu5sP7f
 Ges1mDg0voGL9mxrZiN0v0RIOmHH+QpLrw9MYkqea1axhiqAQc6g4Dj1o6BKkrkYvxaaEE/KT3x
 CuyxZCn+ARXXGmiugTESYiVRKSNPpom5EG5nsBpI6Q/JVclaArqpLuEUSY6mBUfn9XnEKj7Hejh
 odkzzAW3z6jOUMg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

setup_notify_fhandle() read dp->dl_stid.sc_export locklessly and
dereferenced it unconditionally in the subtree-check branch:

	if (!(exp->ex_flags & NFSEXP_NOSUBTREECHECK) && ...

The later NFSEXP_SIGN_FH test already guards with "if (exp && ...)",
acknowledging that exp can be NULL here.

CB_NOTIFY callbacks run asynchronously, holding only an sc_count
reference on the delegation. That keeps the stid (and, on the normal
teardown path, its export) alive, because nfs4_put_stid() only releases
sc_export once sc_count reaches zero. drop_stid_export(), however, runs
on admin revocation (revoke_one_stid() for SC_TYPE_DELEG) and clears
sc_export and drops its reference independently of sc_count, under
cl_lock. A concurrent revocation can therefore make the lockless read
return NULL (NULL deref in the subtree-check branch) or a pointer that
exp_put() frees mid-encode (use-after-free).

Grab a reference to the export under cl_lock, mirroring the locking in
drop_stid_export(), and guard every use of exp with a NULL check. This
closes both the NULL deref and the use-after-free, and leaves the normal
(non-revoked) path unchanged.

Fixes: 121c372b2c55 ("nfsd: add the filehandle to returned attributes in CB_NOTIFY")
Reported-by: Sashiko AI <https://sashiko.dev>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index dfb2cf9239bf..c93eea36a5ea 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4203,12 +4203,26 @@ setup_notify_fhandle(struct dentry *dentry, struct nfs4_delegation *dp,
 		     struct nfsd_file *nf, struct nfsd4_fattr_args *args)
 {
 	struct nfs4_file *fi = dp->dl_stid.sc_file;
-	struct svc_export *exp = dp->dl_stid.sc_export;
+	struct nfs4_client *clp = dp->dl_stid.sc_client;
 	int fileid_type, fsid_len, maxsize, flags = 0;
 	struct knfsd_fh *fhp = &args->fhandle;
 	struct inode *inode = d_inode(dentry);
 	struct inode *parent = NULL;
+	struct svc_export *exp;
 	struct fid *fid;
+	bool ret = false;
+
+	/*
+	 * drop_stid_export() can clear sc_export and drop its reference
+	 * locklessly when the delegation is admin-revoked, concurrently with
+	 * this callback. Grab our own reference under cl_lock so the export
+	 * can be neither NULL-raced nor freed while we encode.
+	 */
+	spin_lock(&clp->cl_lock);
+	exp = dp->dl_stid.sc_export;
+	if (exp)
+		exp_get(exp);
+	spin_unlock(&clp->cl_lock);
 
 	fsid_len = key_len(fi->fi_fhandle.fh_fsid_type);
 	fhp->fh_size = 4 + fsid_len;
@@ -4225,23 +4239,28 @@ setup_notify_fhandle(struct dentry *dentry, struct nfs4_delegation *dp,
 	 * delegation's export rather than the shared nfs4_file, which may
 	 * have been initialized under a different export.
 	 */
-	if (!(exp->ex_flags & NFSEXP_NOSUBTREECHECK) && !S_ISDIR(inode->i_mode)) {
+	if (exp && !(exp->ex_flags & NFSEXP_NOSUBTREECHECK) &&
+	    !S_ISDIR(inode->i_mode)) {
 		parent = d_inode(nf->nf_file->f_path.dentry);
 		flags = EXPORT_FH_CONNECTABLE;
 	}
 
 	fileid_type = exportfs_encode_inode_fh(inode, fid, &maxsize, parent, flags);
 	if (fileid_type < 0 || fileid_type == FILEID_INVALID)
-		return false;
+		goto out;
 
 	fhp->fh_fileid_type = fileid_type;
 	fhp->fh_size += maxsize * 4;
 
 	if (exp && (exp->ex_flags & NFSEXP_SIGN_FH))
 		if (!fh_append_mac(fhp, NFS4_FHSIZE, exp->cd->net))
-			return false;
+			goto out;
 
-	return true;
+	ret = true;
+out:
+	if (exp)
+		exp_put(exp);
+	return ret;
 }
 
 #define CB_NOTIFY_STATX_REQUEST_MASK (STATX_BASIC_STATS   | \

-- 
2.54.0

