Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E08584302FC
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 14:04:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787580296; cv=none; b=NBgDrnpyrf1g0czW7EOkngj7/POSPJ3X7vQjQoTwd5Rm3MNxPQbiSMiQieyedAOLccKSBymdEPjTCYJq8qu9rgA8dF7Sttfok/XG/6bepoSi+q8pld2l+RlhgX4qFGQXL8pyMfepT2aVgcpXJBe3qWO4f7HXURw+sJW6KG6cfcg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787580296; c=relaxed/simple;
	bh=MpbVfuYUYftfYtIbRcmpcRG8S+j8EpwMNj3a+Au4QCI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Qethj//GLReKaJs3NTBaAS4aNwtYLHT6o593l0wppNHIk87XDHMpOD3ngsDY9KIRVbdfv4cGpSaPokUQ/Ajw2JNV8SUxIq63h3zFQGOugcUnySLnEt+HDWKYbdVQtpk3DklExfeAZzI3R6Kz4cHO/18IIKeDDrAw+DXCaKNAbyk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LVzlmkC8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LVzlmkC8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CC7381F00A3D;
	Mon, 24 Aug 2026 14:04:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787580294;
	bh=zSs+Ff9vn0HpIPZjeQGAGU8zRcpcIzlknuS+4GB5CL0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LVzlmkC8RIRhhUA7qvWFa2blcb01V2blpgTqj+cMZ8+dx/3BFSzUnJgWRGZFm1LSr
	 /+itK+P2hANYlaLeX0ESRCQIwfigc2VvjB9pHyyAAmCRmGLFbuO8yw9I9WFzAmrlqb
	 IsA2Ni1SGMEWsT7Fo+UMUSZY1Xai+RFjoX7yk377wyMT7YNaHt7sjkBOC/AWNgiJb6
	 V4D9/IUiclFKx0ea+jmI+8KQsQk/UB6h46bwD3QapjW5I43fSKaYMi9xzgjZXW9lc1
	 WqS+xDZjJbBtsLpv/Fq0wEnHfrmv1YVE/xi6uxRawfPIE/TGjoUxzMb//orgigMWt+
	 F4Nm0qHKZjkyg==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 24 Aug 2026 10:04:41 -0400
Subject: [PATCH 2/2] NFSD: Fix POSIX ACL leak in unexecuted NFSv4 COMPOUND
 operations
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260824-nfsd-posix-acl-ownership-v1-2-090fffc608ec@kernel.org>
References: <20260824-nfsd-posix-acl-ownership-v1-0-090fffc608ec@kernel.org>
In-Reply-To: <20260824-nfsd-posix-acl-ownership-v1-0-090fffc608ec@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Lorenzo Bianconi <lorenzo@kernel.org>, 
 Rick Macklem <rmacklem@uoguelph.ca>
Cc: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, linux-nfs@vger.kernel.org, 
 stable+noautosel@kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=7353; i=cel@kernel.org;
 h=from:subject:message-id; bh=MpbVfuYUYftfYtIbRcmpcRG8S+j8EpwMNj3a+Au4QCI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqjE+DDgq0vTgyEesKjoJKhoXSmeRrhpjHk87+Q
 dKKxZw7FIiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoxPgwAKCRAzarMzb2Z/
 l6RnD/473qjjIvZQeeQx2qMR8fbZYGAG6ir5GxlWMlhOYrQrtBjNN/EP6DlxJT8H5FVoNB2/Ugs
 YhibzuOjN2Wl+quXm5oDHKFHCMh6KqF7sK2OszI6VZROI021bIJ/uU5OIg6p0jIxH2VeDrmUBJX
 vPnlSFH4ZxgkeL03kKPZW7tQhqzvqqt5e+Et2R5LAgxtuhcFIkP/XJ3cLSHACfFOuXLTIHIM72C
 Nj0Jak4pbg/LizOf+LXU0mns0vvNE8Ag6L9/PM7W/jwj6Y3Bh8L5/yVyW5pcaMBTd/v+9DOMsip
 nisB8nTDbu247JqQ2cK2+LwF54n0h5OLvfNyOapiUhyz4v6d7nSRP6t/AV7VvFOyUiW8DaS0gkn
 t7T/zLTQ4iS3gDTnTURdWZDYRzlQu4x9hs7voFv6ohE3uifLfLwtfvrFanAMIrzRUIUIj6ncB/o
 XMgXwgcpijjZeBVBqeUp+IK//cdrWNdye1UKVVySkDiSqYEweLM/psARmITKXYRrAX1Q+Yn9ZNF
 EN/6z+QO/o2dMMslhpxdxGAograOet9ZKqP6S90PhfMJUx0mMi0fpXFmArpQbFP/8u8mwvUAhXy
 NK9B9ZC+Nz+deeD4BSumnvF7EO2bYldy7gyJiFMNtAnG2zsyLV3EqHUlcNgKk121cDMhLayU2Ip
 sqgAiNT/wfjzMwA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_decode_fattr4() allocates POSIX ACLs while decoding OP_OPEN,
OP_CREATE, and OP_SETATTR, leaving the only reference to these ACLs
in the operation's argument structure. Executing the operation hands
that reference to struct nfsd_attrs, which drops it. However, if the
operation is decoded but never executes, those ACLs are leaked. A
client can repeat an aborting compound to force the server to leak
memory.

Give struct nfsd_attrs its own reference with posix_acl_dup() so
nfsd_attrs_free() still balances the reference the operation took.

Release the ACLs when the compound completes. Have the decoder record
each ACL on the compound's temporary allocation chain, and give each
chained item an optional release callback. The chain holds a reference
for the life of the compound, so OP_OPEN no longer needs an op_release
method.

Fixes: 5fc51dfc2eb1 ("NFSD: Add support for XDR decoding POSIX draft ACLs")
Reported-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
Closes: https://lore.kernel.org/linux-nfs/20260823113255.3417-1-prabhakar.pujeri@dell.com/
Cc: <stable+noautosel@kernel.org> # experimental, disabled by default
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 30 ++++++------------------------
 fs/nfsd/nfs4xdr.c  | 41 +++++++++++++++++++++++++++--------------
 fs/nfsd/xdr4.h     |  1 +
 3 files changed, 34 insertions(+), 38 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 88385a161b4d..bb74eef43938 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -391,11 +391,8 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (status)
 			return status;
 	} else {
-		/* The dpacl and pacl will get released by nfsd_attrs_free(). */
-		attrs.na_dpacl = open->op_dpacl;
-		attrs.na_pacl = open->op_pacl;
-		open->op_dpacl = NULL;
-		open->op_pacl = NULL;
+		attrs.na_dpacl = posix_acl_dup(open->op_dpacl);
+		attrs.na_pacl = posix_acl_dup(open->op_pacl);
 	}
 
 	v_mtime = 0;
@@ -795,13 +792,6 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
 	return nfsd4_open(rqstp, cstate, &op->u);
 }
 
-static void
-nfsd4_open_release(union nfsd4_op_u *u)
-{
-	posix_acl_release(u->open.op_dpacl);
-	posix_acl_release(u->open.op_pacl);
-}
-
 /*
  * filehandle-manipulating ops.
  */
@@ -922,16 +912,13 @@ nfsd4_create(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd_attrs attrs = {
 		.na_iattr	= &create->cr_iattr,
 		.na_seclabel	= &create->cr_label,
-		.na_dpacl	= create->cr_dpacl,
-		.na_pacl	= create->cr_pacl,
+		.na_dpacl	= posix_acl_dup(create->cr_dpacl),
+		.na_pacl	= posix_acl_dup(create->cr_pacl),
 	};
 	struct svc_fh resfh;
 	__be32 status;
 	dev_t rdev;
 
-	create->cr_dpacl = NULL;
-	create->cr_pacl = NULL;
-
 	fh_init(&resfh, NFS4_FHSIZE);
 
 	status = fh_verify(rqstp, &cstate->current_fh, S_IFDIR, NFSD_MAY_NOP);
@@ -1341,8 +1328,8 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfsd_attrs attrs = {
 		.na_iattr	= &setattr->sa_iattr,
 		.na_seclabel	= &setattr->sa_label,
-		.na_pacl	= setattr->sa_pacl,
-		.na_dpacl	= setattr->sa_dpacl,
+		.na_pacl	= posix_acl_dup(setattr->sa_pacl),
+		.na_dpacl	= posix_acl_dup(setattr->sa_dpacl),
 	};
 	bool save_no_wcc, deleg_attrs;
 	struct nfs4_stid *st = NULL;
@@ -1350,10 +1337,6 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status = nfs_ok;
 	int err;
 
-	/* Transfer ownership to attrs for cleanup via nfsd_attrs_free() */
-	setattr->sa_pacl = NULL;
-	setattr->sa_dpacl = NULL;
-
 	deleg_attrs = setattr->sa_bmval[2] & (FATTR4_WORD2_TIME_DELEG_ACCESS |
 					      FATTR4_WORD2_TIME_DELEG_MODIFY);
 
@@ -3943,7 +3926,6 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_OPEN] = {
 		.op_func = nfsd4_open,
-		.op_release = nfsd4_open_release,
 		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN",
 		.op_rsize_bop = nfsd4_open_rsize,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a154b02d82b3..5bfbeb87394e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -114,27 +114,27 @@ static int zero_clientid(clientid_t *clid)
 	return (clid->cl_boot == 0) && (clid->cl_id == 0);
 }
 
-/**
- * svcxdr_tmpalloc - allocate memory to be freed after compound processing
- * @argp: NFSv4 compound argument structure
- * @len: length of buffer to allocate
- *
- * Allocates a buffer of size @len to be freed when processing the compound
- * operation described in @argp finishes.
- */
 static void *
-svcxdr_tmpalloc(struct nfsd4_compoundargs *argp, size_t len)
+svcxdr_tmpalloc_release(struct nfsd4_compoundargs *argp, size_t len,
+			void (*release)(void *))
 {
 	struct svcxdr_tmpbuf *tb;
 
 	tb = kmalloc_flex(*tb, buf, len);
 	if (!tb)
 		return NULL;
+	tb->release = release;
 	tb->next = argp->to_free;
 	argp->to_free = tb;
 	return tb->buf;
 }
 
+static void *
+svcxdr_tmpalloc(struct nfsd4_compoundargs *argp, size_t len)
+{
+	return svcxdr_tmpalloc_release(argp, len, NULL);
+}
+
 /*
  * For xdr strings that need to be passed to other kernel api's
  * as null-terminated strings.
@@ -442,10 +442,16 @@ nfsd4_decode_posixace4(struct nfsd4_compoundargs *argp,
 	return status;
 }
 
+static void svcxdr_release_pacl(void *p)
+{
+	posix_acl_release(*(struct posix_acl **)p);
+}
+
 static noinline __be32
 nfsd4_decode_posixacl(struct nfsd4_compoundargs *argp, struct posix_acl **acl)
 {
 	struct posix_acl_entry *ace;
+	struct posix_acl **slot;
 	__be32 status;
 	u32 count;
 
@@ -485,6 +491,15 @@ nfsd4_decode_posixacl(struct nfsd4_compoundargs *argp, struct posix_acl **acl)
 	if (count >= 3)
 		sort_pacl_range(*acl, 0, count - 1);
 
+	slot = svcxdr_tmpalloc_release(argp, sizeof(*slot),
+				       svcxdr_release_pacl);
+	if (!slot) {
+		posix_acl_release(*acl);
+		*acl = NULL;
+		return nfserr_jukebox;
+	}
+	*slot = *acl;
+
 	return nfs_ok;
 }
 
@@ -677,7 +692,6 @@ nfsd4_decode_fattr4(struct nfsd4_compoundargs *argp, u32 *bmval, u32 bmlen,
 
 		status = nfsd4_decode_posixacl(argp, &pacl);
 		if (status) {
-			posix_acl_release(*dpaclp);
 			*dpaclp = NULL;
 			return status;
 		}
@@ -687,12 +701,8 @@ nfsd4_decode_fattr4(struct nfsd4_compoundargs *argp, u32 *bmval, u32 bmlen,
 
 	/* request sanity: did attrlist4 contain the expected number of words? */
 	if (attrlist4_count != xdr_stream_pos(argp->xdr) - starting_pos) {
-#ifdef CONFIG_NFSD_V4_POSIX_ACLS
-		posix_acl_release(*dpaclp);
-		posix_acl_release(*paclp);
 		*dpaclp = NULL;
 		*paclp = NULL;
-#endif
 		return nfserr_bad_xdr;
 	}
 
@@ -6846,7 +6856,10 @@ void nfsd4_release_compoundargs(struct svc_rqst *rqstp)
 	}
 	while (args->to_free) {
 		struct svcxdr_tmpbuf *tb = args->to_free;
+
 		args->to_free = tb->next;
+		if (tb->release)
+			tb->release(tb->buf);
 		kfree(tb);
 	}
 }
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b841bc462dac..de43a0da9668 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -800,6 +800,7 @@ bool nfsd4_cache_this_op(struct nfsd4_op *);
  */
 struct svcxdr_tmpbuf {
 	struct svcxdr_tmpbuf *next;
+	void (*release)(void *buf);
 	char buf[];
 };
 

-- 
2.54.0

