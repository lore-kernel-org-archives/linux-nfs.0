Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78D52471408;
	Wed, 12 Aug 2026 18:08:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786558105; cv=none; b=HMTsl7SWpSsA8Pt2ZLKUx8pU5gLSQWQlmEahP0sy7DIeqmzSYb1KlR7KvHOOXB7dOZ4NEdO/g9/0MDwv6gwDEdNdHcmptA+DzTcCxYPPFJ23JER50zicJ3A/2mm0sZ9bDC/5nCD1zFfusCOjGM+ppQsrnDsRlg8tVKzBlMT+gog=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786558105; c=relaxed/simple;
	bh=h8CS5Q+rkx5ibF6+m98ciIhCHpeeIsV8A9y3QTswmto=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=KGYzs968ekeVQTakV+S0bvEkChio6SnXRRFDxWYjga2UsWHPIHI2ApG15zZHWTQ230JhPw6kHGdH9Yq6Tl0e3yfgYPoBzezKgZeOA1R8d7HpAz8sN47+evbI/duGlR1G/8aWNMypfyl/7xMzO/svg/0KXBvNwYykFAsQvdIeZDA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=k3TeWktk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="k3TeWktk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 95ABD1F00A3A;
	Wed, 12 Aug 2026 18:08:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786558104;
	bh=AYGLgNHX2Cxh2ohIRv9ErfRwgVHubviL8bLo7Q9ZaGE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=k3TeWktkKI3ytyg/sgffixFp1ggJhfH3Mw/cM68d3/5fbt6X1hW63gkMNhwInvUXZ
	 EssyMEHj1rWC/yzMB6lOfthReu3hJ52imYK+HfHpzFaAzLtG/Sbi+2BVBNGHGBizZc
	 ByFRvhU7EehJq66dCKEUaAwUEWLg5R3GiwPQ6BJv/MVHJFlR/2nWoTVVajb5e2SMbk
	 /VETj50/dQaDRF4S3cK719nP1K1U9BygisYdcBagLrwAKF5CE9s/6lOfw/K7RG4aFW
	 ovf7EUBHOCmVU6Ztr1tEVNw8f+2k0M8Q4rE9019Vg3jAhoBjKohSYijjfQgxNbhQSG
	 shRMJAAHmOnmg==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 12 Aug 2026 14:08:14 -0400
Subject: [PATCH 1/2] nfsd: pass caller-provided attrmask storage into
 nfsd4_setup_notify_entry4()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260812-dir-deleg-v1-1-411faa713068@kernel.org>
References: <20260812-dir-deleg-v1-0-411faa713068@kernel.org>
In-Reply-To: <20260812-dir-deleg-v1-0-411faa713068@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4988; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=h8CS5Q+rkx5ibF6+m98ciIhCHpeeIsV8A9y3QTswmto=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqfLaWSnrHoM1dxHDCivZctxslayTejtvG8LQuX
 1l+mmHm4AqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCany2lgAKCRAADmhBGVaC
 FbAND/4yAM+ZZJn7WyAn0P7YnFfEeD4p/cajuT9hvENY18tVRFySvuRFbLwmHVAhry9CJlf/+Nl
 OvCh2qtUc2qAmYBZUAzksxTIwZTR4tVH8nJghlyYHT7UTVZmxDbLDSP+8ZGqUez2SAmZziU0+gC
 ttK3DuBXBtItfZHILKQRlkwi7/z/z5drWHVvKX84UDpdGTLl/vKdL2srCMaGFZnlZ/jYYOEIbMx
 0fvfBtjGRCDDZwwMx5O/dZaTSuWi9vJ1dvupv1z/5gCQzQSbSBjHkGm29sETSRTLut5ULxD3Z2O
 DWr9hCvNKJvP2A5Zusk/KAC+9arPluvPar53OjmwRgg3Gc+/7uXxEUCaDDCDd8fJQR2+JTkIhQP
 bT6GJEuvjOTiRCxL6K9RzrUfDiOUuFc9hSSe/JD4C8tS9mL0ojREQKqwdUSEJqy4cZjEWROSeut
 nlHr0RaPlDBVixYUWaO8/9fRDErFmTZR/a3dzFkY45b7q1uRwCpIpRGDxPf6Qr6saWqDQsI65JW
 X9fYa7ZcPbvN6SBmb9Pl+J77VFXAmsS5ZK8KT3Ooxc87TLyCPUecHQ/Itl8NQnCO78nYug5ePvK
 Dy25xvPNFh5NsuannqksMRJXJqwClgymSL6g+m0492OR0F3yTdJipxheHHu9mL0pz4g2rcM91u/
 Xqg9eCdSde6/d6Q==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_setup_notify_entry4() stole 3 words from the xdr stream via
xdr_reserve_space() to hold the host-order bmval[3] attrmask that
nfsd4_encode_attr_vals() consumes and ne_attrs.attrmask.element points
at. Stashing host-endian scratch in an XDR stream buffer is fragile:
the buffer layout is not guaranteed by sunrpc, and it blocks moving the
encoder to pages or xdrgen.

The attrmask only needs to live until the enclosing encode call
serializes the notify_entry4, so hand it caller-provided stack storage
instead. The two callers keep the words on the stack: up to three
concurrent entries for a rename in nfsd4_encode_notify_event(), one in
nfsd4_encode_dir_attr_change().

No wire change: the reserved words were never emitted; attr_vals.data/len
are still captured relative to xdr->p.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a47eb544b99f..7d1b2d6f57f2 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4378,21 +4378,16 @@ setup_notify_fhandle(struct dentry *dentry, struct nfs4_delegation *dp,
 static bool
 nfsd4_setup_notify_entry4(struct notify_entry4 *ne, struct xdr_stream *xdr,
 			  struct dentry *dentry, struct nfs4_delegation *dp,
-			  struct nfsd_file *nf, char *name, u32 namelen)
+			  struct nfsd_file *nf, char *name, u32 namelen,
+			  u32 *attrmask)
 {
 	struct path path = nf->nf_file->f_path;
 	struct nfsd4_fattr_args args = { };
 	const u32 *reqmask;
-	uint32_t *attrmask;
 	__be32 status;
 	bool parent;
 	int ret;
 
-	/* Reserve space for attrmask */
-	attrmask = xdr_reserve_space(xdr, 3 * sizeof(uint32_t));
-	if (!attrmask)
-		return false;
-
 	ne->ne_file.data = name;
 	ne->ne_file.len = namelen;
 	ne->ne_attrs.attrmask.element = attrmask;
@@ -4476,6 +4471,7 @@ u8 *nfsd4_encode_notify_event(struct xdr_stream *xdr, struct nfsd_notify_event *
 			      struct nfs4_delegation *dp, struct nfsd_file *nf,
 			      u32 *notify_mask)
 {
+	u32 attrmask[3][3] = { };
 	u8 *p = NULL;
 
 	*notify_mask = 0;
@@ -4484,7 +4480,8 @@ u8 *nfsd4_encode_notify_event(struct xdr_stream *xdr, struct nfsd_notify_event *
 		struct notify_remove4 nr = { };
 
 		if (!nfsd4_setup_notify_entry4(&nr.nrm_old_entry, xdr, nne->ne_dentry, dp,
-					       nf, nne->ne_name, nne->ne_namelen))
+					       nf, nne->ne_name, nne->ne_namelen,
+					       attrmask[0]))
 			goto out_err;
 		p = (u8 *)xdr->p;
 		if (!xdrgen_encode_notify_remove4(xdr, &nr))
@@ -4495,14 +4492,16 @@ u8 *nfsd4_encode_notify_event(struct xdr_stream *xdr, struct nfsd_notify_event *
 		struct notify_remove4 old = { };
 
 		if (!nfsd4_setup_notify_entry4(&na.nad_new_entry, xdr, nne->ne_dentry, dp,
-					       nf, nne->ne_name, nne->ne_namelen))
+					       nf, nne->ne_name, nne->ne_namelen,
+					       attrmask[0]))
 			goto out_err;
 
 		/* If a file was overwritten, report it in nad_old_entry */
 		if (nne->ne_target) {
 			if (!nfsd4_setup_notify_entry4(&old.nrm_old_entry, xdr,
 						       NULL, dp, nf,
-						       nne->ne_name, nne->ne_namelen))
+						       nne->ne_name, nne->ne_namelen,
+						       attrmask[1]))
 				goto out_err;
 			na.nad_old_entry.count = 1;
 			na.nad_old_entry.element = &old;
@@ -4521,19 +4520,19 @@ u8 *nfsd4_encode_notify_event(struct xdr_stream *xdr, struct nfsd_notify_event *
 		/* Don't send any attributes in the old_entry since they're the same in new */
 		if (!nfsd4_setup_notify_entry4(&nr.nrn_old_entry.nrm_old_entry, xdr,
 					       NULL, dp, nf, nne->ne_name,
-					       nne->ne_namelen))
+					       nne->ne_namelen, attrmask[0]))
 			goto out_err;
 
 		if (!nfsd4_setup_notify_entry4(&nr.nrn_new_entry.nad_new_entry, xdr,
 					       nne->ne_dentry, dp, nf, newname,
-					       nne->ne_newnamelen))
+					       nne->ne_newnamelen, attrmask[1]))
 			goto out_err;
 
 		/* If a file was overwritten, report it in nad_old_entry */
 		if (nne->ne_target) {
 			if (!nfsd4_setup_notify_entry4(&old.nrm_old_entry, xdr,
 						       NULL, dp, nf, newname,
-						       nne->ne_newnamelen))
+						       nne->ne_newnamelen, attrmask[2]))
 				goto out_err;
 			nr.nrn_new_entry.nad_old_entry.count = 1;
 			nr.nrn_new_entry.nad_old_entry.element = &old;
@@ -4569,11 +4568,12 @@ u8 *nfsd4_encode_dir_attr_change(struct xdr_stream *xdr, struct nfs4_delegation
 {
 	struct dentry *dentry = nf->nf_file->f_path.dentry;
 	struct notify_attr4 na = { };
+	u32 attrmask[3] = { };
 	u8 *p;
 
 	/* RFC 8881 s10.4.3: ne_file must be a zero-length string for dir attrs */
 	if (!nfsd4_setup_notify_entry4(&na.na_changed_entry, xdr,
-				       dentry, dp, nf, "", 0))
+				       dentry, dp, nf, "", 0, attrmask))
 		return ERR_PTR(-ENOBUFS);
 
 	/* No requested attributes to report; omit the event */

-- 
2.55.0

