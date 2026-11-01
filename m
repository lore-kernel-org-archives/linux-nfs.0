Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793548283;
	b=rQZpvPyBFxi735bux1w5DFGD/w+hT/iPS+kdJl5QlvMSQ4qkBTeynvw1mXjG8buqOGHa
	 BGDTL5ewN5TW4cgPc3N+QixoX4XWcaSnLTS72kDvCGAl3Twhn6u3BWTwtKvTp+OImuBS2
	 4rYftha+A0wCxJhX7cCVnt0Kp3Gc9ag/UZ6ZvbJ4XAjNcnJI8n3W33LuzEibg8p19bVaP
	 vA6SM/VAyyOc+ajEzl67bWiVOgMRrNDkVSWjLtuXEICmoC4vMxrdognodmk264+BoRlYb
	 E8xS3y0naqmFvYgHSFEOg3Hpktzu2O+wTnpyJaDiO9A8rZbls8+9jTiLdD3kkc67Opg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793548283;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=n3JSBBdaCe1ZIysvNzG1sTuqR2czpuqFuNyuQ44Xrfw=;
	b=Vw0JjQ3EkC1uGki/DaVvEjPq48UQlH1IN1NOn68GeWpdpqOulzbdA8eI4KLjYRjlQsPB
	 KVnFvfiHljD17KTDKCpCBfn164SglhOGGti1GQumQNc5CcQ7tN8SkJYTW3QWJkY6ioqK9
	 z+9t0LWBD1VnXvmGTVyhaETnLk3Le9jx/7Blpui6+EVSwLtxaZYEhjoVtpDrqNJv+Dqhw
	 +zLKRbIxTNF1OIUW6+yrnbETJhVayzgQ2vKK6M4h6aVH0K8BWIZatFMvIJEx+ksH5Jgfm
	 wGPCz2SlLblTDp342BQnTkyqY0TovPQ412UQ1eXBQsSH+eEcuARYEiYKIF2hG/ZycMg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KKfy9155;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67C9D606A32F
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2026 15:51:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=KKfy9155
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4DF851F0093A;
	Sun,  1 Nov 2026 15:51:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793548283;
	bh=n3JSBBdaCe1ZIysvNzG1sTuqR2czpuqFuNyuQ44Xrfw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=KKfy9155cwj4Jr7XjHclTYy7bXMVcJZrXeaLaEynYR8a9zAqVEyol3dUysGQwn/MS
	 tu33Q1ySgnw/qHn825Q+O5yME8uKRFK+zysAGDUHDeancwGr7fqOhCTLbXMW5vbk/U
	 4iDfT06tlHcvSOx963xIVX+m+GD2QBDa+XC42yA9BtciONO7+JMOQEOSBxQtdQ8Vnr
	 X0Hj0JPjrwhihsetystp77qfi4vHf4/RBJj2hZVmSjBqWMp8ysyCeHwR1eWQrNKNuF
	 NbQl3xftI9HxABt2EJKvEXlN6qwu9p4mE1DHdkKtWNqavpanx4MgE/6AhzHzWAwDWQ
	 Q0OW5jZTulbnQ==
From: Chuck Lever <cel@kernel.org>
Date: Sun, 01 Nov 2026 10:51:12 -0500
Subject: [PATCH v6 3/3] NFSD: Enforce export security on LOOKUP, READDIR,
 and SECINFO
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261101-verofess-v6-3-4d70097db7d3@kernel.org>
References: <20261101-verofess-v6-0-4d70097db7d3@kernel.org>
In-Reply-To: <20261101-verofess-v6-0-4d70097db7d3@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=20725; i=cel@kernel.org;
 h=from:subject:message-id; bh=WUWEDkCSzgLumoCONnEToXVEWRiBX+LB+WXTN0NDa30=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq51/3H3bbLjthK2vCPi1OjhqM5+q7wq/qdc4O0
 z+Z+isDIAeJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaudf9wAKCRAzarMzb2Z/
 l1toEACz9JZaNq76yT2onBTcvRz6+m1fGWohblCuJUcZXMXfAHW0CudfFPgjS0PgL+qDi5oEAYx
 myjNdBKaLAa8FIA6Lm1zriGscGb9SXN4S/TEdyvUy7a/9pnsE8OjgYUD1G8DEd9WkYF/L3cxtNu
 gzX2l7DtnZzIsZYXY6RYQANIUK00ifcJgEIbjMYm050gAGg5RtIWdRJ7H4dzS9gBM2eBWZivImu
 oF7bcGG8EFM81hB/LeILQwPjc2rGHlAmEN0OQkrduc/i4AqLhtb1SjwFS5MTmFvm9ZTWRwJ1WCs
 STY1dzJs4on5RmAwVHL+jF1Fp/Vjmap5/Vg3Q/7vMofw1dBE6bVaxcoZrFdM49ZfS215cXx76H3
 Nx1ejJ9I8Z1mTxEZTK5i8BXOTvGZutJeAYfwPbAPTbqEok4WF56gmdiyEqCl+pFgngvf2HJAwEI
 ABhxduADs8WmPWicCehtu5ddcKectcnrXsAREiZ1fg2OyWiZ3/SdWeD59kmMnRV11oPZ+zAuErV
 FRPyfF9UOBZzAAVSpRxoDQ7X/xeZw+vgGs8J/YODHBScZE+5EHHLOdX75FG4I1msYeEbInF6yhp
 8FHfv4DQ9RntE33rAY9CBS1mvRLDCgyxU85y8p3W+bg6eC1MqYG2BiXqYj6oKOL8UdcQ4k6Xaea
 gqme9qyhwbA9fxg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

From: VeroFess <coderzeng@gmail.com>

A bind-mounted regular file can have a stricter export than its
parent. nfsd_cross_mnt() checks the request's flavor against the
export being left, not the one being entered, so LOOKUP, READDIR, and
the NFSv2 and NFSv3 CREATE paths all hand out filehandles on the child
export without consulting its sec= list. Stepping up with ".." has the
same gap: nfsd_lookup_parent() switches to the parent export without any
check, so LOOKUPP from the root of a sec=sys export returns a filehandle
on a sec=krb5p parent. Every caller has already passed fh_verify()
on the export being left, so check only the export being entered, in
nfsd_cross_mnt() and in nfsd_lookup_parent().

READDIR crosses into child exports to fetch entry attributes, so the
new check also fires there. When the client requests rdattr_error,
report NFS4ERR_WRONGSEC in that attribute, as RFC 8881 Section 2.6.3.1
directs. Otherwise the whole READDIR fails, as Section 18.23.3 requires;
NFS4ERR_WRONGSEC is not a READDIR status, so report NFS4ERR_ACCESS. The
Linux, FreeBSD, illumos, and Windows clients all request rdattr_error on
every READDIR.

SECINFO and SECINFO_NO_NAME report export security policies. RFC
8881 Section 2.6.3.1.1.5 forbids NFS4ERR_WRONGSEC from either
operation, which allows a client using any flavor to learn whether
a name exists in a directory on a sec=krb5p export. The starting
directory's fh_verify(..., NFSD_MAY_EXEC) call rejects SECINFO and
SECINFO_NO_NAME(PARENT) when that export does not allow the request's
flavor, and a mount crossing rejects it again on the crossed-into
export. SECINFO_NO_NAME(CURRENT_FH) never calls fh_verify() at all, so
after PUTROOTFH it reports the pseudo-root's flavors without checking
that export's transport policy or secure port requirement.

Add NFSD_MAY_SECINFO, which fh_verify() and the lookup path both
read: it skips the starting export's security flavor check and
the flavor check on a mount crossing or parent step-up. Verify the
current filehandle with it in SECINFO_NO_NAME(CURRENT_FH) as well.
NFSv4.0 is different: RFC 7530 permits NFS4ERR_WRONGSEC from PUTFH and
from neither SECINFO nor the operation after it, and a v4.0 SECINFO
leaves the current filehandle in place. A v4.0 put-filehandle operation
followed by SECINFO therefore keeps its own export check, so the error
is reported where RFC 7530 allows it. The Linux and illumos clients
send SECINFO only with a parent directory they already hold under the
same flavor, and FreeBSD does not send SECINFO at all, so the check does
not fire for any of them. The export's transport policy (xprtsec=) is a
transport-layer requirement, not part of the flavor negotiation SECINFO
performs, so SECINFO still enforces it on the starting export and on any
export a crossing enters. When SECINFO or SECINFO_NO_NAME itself detects
the transport policy mismatch, report NFS4ERR_ACCESS, the error RFC 8881
Section 18.29.3 specifies for a SECINFO access failure. The directory
type, secure-port, and execute-permission checks still apply.

The put-filehandle operation that precedes SECINFO is unchanged.
Its fh_verify(..., NFSD_MAY_BYPASS_GSS) call waives the flavor check
only for AUTH_NULL and AUTH_SYS, so a krb5 or krb5i request against a
sec=krb5p export still gets NFS4ERR_WRONGSEC from PUTFH, and so does a
plaintext request against an xprtsec=tls export. Section 2.6.3.1.1.5
forbids both for NFSv4.1 and later.

Fixes: f0d6ad5a2f67 ("nfsd: move check_nfsd_access() call into nfsd_cross_mnt()")
Fixes: 29a78a3ed7fc ("nfsd4: make fh_verify responsibility of nfsd_lookup_dentry caller")
Fixes: 04f4ad16b231 ("nfsd4: implement secinfo_no_name")
Signed-off-by: VeroFess <coderzeng@gmail.com>
Tested-by: VeroFess <coderzeng@gmail.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/export.c    |  6 +++--
 fs/nfsd/nfs3proc.c  |  2 +-
 fs/nfsd/nfs4proc.c  | 44 ++++++++++++++++++++++++--------
 fs/nfsd/nfs4state.c |  2 +-
 fs/nfsd/nfs4xdr.c   |  8 ++++--
 fs/nfsd/nfsfh.c     | 12 ++++++---
 fs/nfsd/nfsproc.c   |  2 +-
 fs/nfsd/trace.h     |  3 ++-
 fs/nfsd/vfs.c       | 72 ++++++++++++++++++++++++++++++-----------------------
 fs/nfsd/vfs.h       | 43 +++++++++++++++++++++++++++-----
 10 files changed, 136 insertions(+), 58 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 397767d756c6..0b4c50d82364 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1976,8 +1976,10 @@ static struct svc_export *exp_find(struct cache_detail *cd,
  *
  * Helper function for check_nfsd_access().  Note that callers should be
  * using check_nfsd_access() instead of calling this function directly.  The
- * one exception is __fh_verify() since it has logic that may result in one
- * or both of the helpers being skipped.
+ * exceptions are __fh_verify(), which has logic that may result in one
+ * or both of the helpers being skipped, and the mount-crossing paths in
+ * nfsd_cross_mnt() and nfsd_lookup_parent(), which enforce only the
+ * transport policy for SECINFO.
  *
  * Return values:
  *   %nfs_ok if access is granted, or
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 11e05b2e5e84..1025cec447a9 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -961,7 +961,7 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *dirfhp,
 		 */
 		if (d_is_reg(child) &&
 		    unlikely(nfsd_mountpoint(child, exp))) {
-			status = nfsd_cross_mnt(rqstp, &child, &exp);
+			status = nfsd_cross_mnt(rqstp, &child, &exp, 0);
 			if (status != nfs_ok) {
 				exp_put(exp);
 				goto out;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index b6dcb889b5eb..b2bfa31264c8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -342,7 +342,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		    unlikely(nfsd_mountpoint(child, fhp->fh_export))) {
 			struct svc_export *exp = exp_get(fhp->fh_export);
 
-			status = nfsd_cross_mnt(rqstp, &child, &exp);
+			status = nfsd_cross_mnt(rqstp, &child, &exp, 0);
 			if (status == nfs_ok)
 				status = fh_compose(resfhp, exp,
 						    child, fhp);
@@ -1079,7 +1079,17 @@ nfsd4_link(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
-static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
+/*
+ * RFC 8881 Section 2.6.3.1.1.5 forbids NFS4ERR_WRONGSEC from SECINFO.
+ * Section 18.29.3 has SECINFO report a denied lookup as NFS4ERR_ACCESS.
+ */
+static __be32 nfsd4_secinfo_status(__be32 status)
+{
+	return status == nfserr_wrongsec ? nfserr_acces : status;
+}
+
+static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh,
+			       int access)
 {
 	struct svc_fh tmp_fh;
 	__be32 ret;
@@ -1093,14 +1103,14 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 		return nfserr_noent;
 	}
 	fh_put(&tmp_fh);
-	return nfsd_lookup(rqstp, fh, "..", 2, fh);
+	return __nfsd_lookup(rqstp, fh, "..", 2, fh, access);
 }
 
 static __be32
 nfsd4_lookupp(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	      union nfsd4_op_u *u)
 {
-	return nfsd4_do_lookupp(rqstp, &cstate->current_fh);
+	return nfsd4_do_lookupp(rqstp, &cstate->current_fh, NFSD_MAY_EXEC);
 }
 
 static __be32
@@ -1252,14 +1262,16 @@ nfsd4_secinfo(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct dentry *dentry;
 	__be32 err;
 
-	err = fh_verify(rqstp, &cstate->current_fh, S_IFDIR, NFSD_MAY_EXEC);
+	err = fh_verify(rqstp, &cstate->current_fh, S_IFDIR,
+			NFSD_MAY_EXEC | NFSD_MAY_SECINFO);
 	if (err)
-		return err;
+		return nfsd4_secinfo_status(err);
 	err = nfsd_lookup_dentry(rqstp, &cstate->current_fh,
 				    secinfo->si_name, secinfo->si_namelen,
-				    &exp, &dentry);
+				    &exp, &dentry,
+				    NFSD_MAY_EXEC | NFSD_MAY_SECINFO);
 	if (err)
-		return err;
+		return nfsd4_secinfo_status(err);
 	if (d_really_is_negative(dentry)) {
 		exp_put(exp);
 		err = nfserr_noent;
@@ -1280,11 +1292,16 @@ nfsd4_secinfo_no_name(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstat
 
 	switch (u->secinfo_no_name.sin_style) {
 	case NFS4_SECINFO_STYLE4_CURRENT_FH:
+		err = fh_verify(rqstp, &cstate->current_fh, 0,
+				NFSD_MAY_SECINFO);
+		if (err)
+			return nfsd4_secinfo_status(err);
 		break;
 	case NFS4_SECINFO_STYLE4_PARENT:
-		err = nfsd4_do_lookupp(rqstp, &cstate->current_fh);
+		err = nfsd4_do_lookupp(rqstp, &cstate->current_fh,
+				       NFSD_MAY_EXEC | NFSD_MAY_SECINFO);
 		if (err)
-			return err;
+			return nfsd4_secinfo_status(err);
 		break;
 	default:
 		return nfserr_inval;
@@ -3267,6 +3284,13 @@ static bool need_wrongsec_check(struct svc_rqst *rqstp)
 
 	if (next->opnum == OP_ILLEGAL)
 		return false;
+	/*
+	 * RFC 7530 permits NFS4ERR_WRONGSEC from PUTFH but not from
+	 * SECINFO, and NFSv4.0 SECINFO leaves the current filehandle in
+	 * place for the next operation.
+	 */
+	if (resp->cstate.minorversion == 0 && next->opnum == OP_SECINFO)
+		return true;
 	nextd = OPDESC(next);
 	/*
 	 * RFC 8881 Section 2.6.3.1.1.2: a later put-filehandle operation
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cafdf80f32de..97b4fa30362a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7126,7 +7126,7 @@ nfsd4_verify_deleg_dentry(struct nfsd4_open *open, struct nfs4_file *fp,
 
 	err = nfsd_lookup_dentry(open->op_rqstp, parent,
 				 open->op_fname, open->op_fnamelen,
-				 &exp, &child);
+				 &exp, &child, 0);
 
 	if (err)
 		return -ESTALE;
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d4a88bef8444..111bf2b8ebd1 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4676,7 +4676,7 @@ nfsd4_encode_entry4_fattr(struct nfsd4_readdir *cd, const char *name,
 		 * Different "."/".." handling?  Something else?
 		 * At least, add a comment here to explain....
 		 */
-		nfserr = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp);
+		nfserr = nfsd_cross_mnt(cd->rd_rqstp, &dentry, &exp, 0);
 		if (nfserr)
 			goto out_put;
 		crossed = true;
@@ -4775,8 +4775,12 @@ nfsd4_encode_entry4(void *ccdv, const char *name, int namlen,
 		 * then in accordance with the spec, we fail the
 		 * entire READDIR operation(!)
 		 */
-		if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR))
+		if (!(cd->rd_bmval[0] & FATTR4_WORD0_RDATTR_ERROR)) {
+			/* READDIR cannot return NFS4ERR_WRONGSEC itself. */
+			if (nfserr == nfserr_wrongsec)
+				nfserr = nfserr_acces;
 			goto fail;
+		}
 		if (nfsd4_encode_entry4_rdattr_error(xdr, nfserr)) {
 			nfserr = nfserr_toosmall;
 			goto fail;
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index f1ba5a14bb85..f9fe985c7433 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -471,9 +471,15 @@ __fh_verify(struct svc_rqst *rqstp,
 			&& exp->ex_path.dentry == dentry)
 		may_bypass_gss = true;
 
-	error = check_security_flavor(exp, rqstp, may_bypass_gss);
-	if (error)
-		goto out;
+	/*
+	 * SECINFO reports the export's security flavors instead of
+	 * failing on a flavor mismatch. The xprtsec= policy still applies.
+	 */
+	if (!(access & NFSD_MAY_SECINFO)) {
+		error = check_security_flavor(exp, rqstp, may_bypass_gss);
+		if (error)
+			goto out;
+	}
 
 	svc_xprt_set_valid(rqstp->rq_xprt);
 
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 2f8da62ad6b0..43e6a4b6a259 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -712,7 +712,7 @@ nfsd_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	exp = exp_get(fhp->fh_export);
 	if (d_is_reg(dchild) &&
 	    unlikely(nfsd_mountpoint(dchild, exp))) {
-		status = nfsd_cross_mnt(rqstp, &dchild, &exp);
+		status = nfsd_cross_mnt(rqstp, &dchild, &exp, 0);
 		if (status != nfs_ok) {
 			exp_put(exp);
 			goto out;
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index e7b186307c21..b937217b81d2 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -142,7 +142,8 @@ DEFINE_NFSD_DYNTHREAD_EVENT(trylock_fail);
 		{ NFSD_MAY_BYPASS_GSS,		"BYPASS_GSS" },		\
 		{ NFSD_MAY_READ_IF_EXEC,	"READ_IF_EXEC" },	\
 		{ NFSD_MAY_64BIT_COOKIE,	"64BIT_COOKIE" },	\
-		{ NFSD_MAY_LOCALIO,		"LOCALIO" })
+		{ NFSD_MAY_LOCALIO,		"LOCALIO" },	\
+		{ NFSD_MAY_SECINFO,		"SECINFO" })
 
 TRACE_EVENT(nfsd_compound,
 	TP_PROTO(
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a8cf41e4dfea..a06a92bea95c 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -124,14 +124,13 @@ nfserrno(int errno)
 }
 
 /*
- * Called from nfsd_lookup and encode_dirent. Check if we have crossed
- * a mount point.
+ * Check if we have crossed a mount point.
  * Returns an nfs error leaving *dpp and *expp unchanged,
  *  or nfs_ok having possibly changed *dpp and *expp
  */
 __be32
 nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
-	       struct svc_export **expp)
+	       struct svc_export **expp, int access)
 {
 	struct svc_export *exp = *expp, *exp2 = NULL;
 	struct dentry *dentry = *dpp;
@@ -169,7 +168,9 @@ nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
 			err = 0;
 	} else if (nfsd_v4client(rqstp) ||
 		(exp->ex_flags & NFSEXP_CROSSMOUNT) || EX_NOHIDE(exp2)) {
-		nfserr = check_nfsd_access(exp, rqstp);
+		nfserr = (access & NFSD_MAY_SECINFO) ?
+			 check_xprtsec_policy(exp2, rqstp) :
+			 check_nfsd_access(exp2, rqstp);
 		if (nfserr == nfs_ok) {
 			/* successfully crossed mount point */
 			/*
@@ -204,11 +205,14 @@ static void follow_to_parent(struct path *path)
 	path->dentry = dp;
 }
 
-static int nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent, struct svc_export **exp, struct dentry **dentryp)
+static __be32 nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent,
+				 struct svc_export **exp, struct dentry **dentryp,
+				 int access)
 {
 	struct svc_export *exp2;
 	struct path path = {.mnt = mntget((*exp)->ex_path.mnt),
 			    .dentry = dget(dparent)};
+	__be32 nfserr = nfs_ok;
 
 	follow_to_parent(&path);
 
@@ -216,15 +220,21 @@ static int nfsd_lookup_parent(struct svc_rqst *rqstp, struct dentry *dparent, st
 	if (PTR_ERR(exp2) == -ENOENT) {
 		*dentryp = dget(dparent);
 	} else if (IS_ERR(exp2)) {
-		path_put(&path);
-		return PTR_ERR(exp2);
+		nfserr = nfserrno(PTR_ERR(exp2));
 	} else {
-		*dentryp = dget(path.dentry);
-		exp_put(*exp);
-		*exp = exp2;
+		nfserr = (access & NFSD_MAY_SECINFO) ?
+			 check_xprtsec_policy(exp2, rqstp) :
+			 check_nfsd_access(exp2, rqstp);
+		if (nfserr != nfs_ok) {
+			exp_put(exp2);
+		} else {
+			*dentryp = dget(path.dentry);
+			exp_put(*exp);
+			*exp = exp2;
+		}
 	}
 	path_put(&path);
-	return 0;
+	return nfserr;
 }
 
 /*
@@ -255,7 +265,8 @@ int nfsd_mountpoint(struct dentry *dentry, struct svc_export *exp)
 __be32
 nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		   const char *name, unsigned int len,
-		   struct svc_export **exp_ret, struct dentry **dentry_ret)
+		   struct svc_export **exp_ret, struct dentry **dentry_ret,
+		   int access)
 {
 	struct svc_export	*exp;
 	struct dentry		*dparent;
@@ -277,9 +288,13 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			dentry = dget(dparent); /* .. == . just like at / */
 		else {
 			/* checking mountpoint crossing is very different when stepping up */
-			host_err = nfsd_lookup_parent(rqstp, dparent, &exp, &dentry);
-			if (host_err)
-				goto out_nfserr;
+			__be32 nfserr = nfsd_lookup_parent(rqstp, dparent,
+							   &exp, &dentry, access);
+
+			if (nfserr) {
+				exp_put(exp);
+				return nfserr;
+			}
 		}
 	} else {
 		dentry = lookup_one_unlocked(&nop_mnt_idmap,
@@ -288,7 +303,8 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (IS_ERR(dentry))
 			goto out_nfserr;
 		if (nfsd_mountpoint(dentry, exp)) {
-			__be32 nfserr = nfsd_cross_mnt(rqstp, &dentry, &exp);
+			__be32 nfserr = nfsd_cross_mnt(rqstp, &dentry, &exp,
+						       access);
 
 			if (nfserr) {
 				dput(dentry);
@@ -307,37 +323,31 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 }
 
 /**
- * nfsd_lookup - look up a single path component for nfsd
+ * __nfsd_lookup - look up a single path component for nfsd
  *
  * @rqstp:   the request context
  * @fhp:     the file handle of the directory
  * @name:    the component name, or %NULL to look up parent
  * @len:     length of name to examine
  * @resfh:   pointer to pre-initialised filehandle to hold result.
+ * @access:  NFSD_MAY_* flags for the fh_verify() of @fhp; adding
+ *	     NFSD_MAY_SECINFO skips the export security flavor checks
  *
- * Look up one component of a pathname.
- * N.B. After this call _both_ fhp and resfh need an fh_put
- *
- * If the lookup would cross a mountpoint, and the mounted filesystem
- * is exported to the client with NFSEXP_NOHIDE, then the lookup is
- * accepted as it stands and the mounted directory is
- * returned. Otherwise the covered directory is returned.
- * NOTE: this mountpoint crossing is not supported properly by all
- *   clients and is explicitly disallowed for NFSv3
- *
+ * Variant of nfsd_lookup() that takes the fh_verify() access flags.
+ * The filehandle and mountpoint crossing rules are documented there.
  */
 __be32
-nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
-	    unsigned int len, struct svc_fh *resfh)
+__nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
+	      unsigned int len, struct svc_fh *resfh, int access)
 {
 	struct svc_export	*exp;
 	struct dentry		*dentry;
 	__be32 err;
 
-	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_EXEC);
+	err = fh_verify(rqstp, fhp, S_IFDIR, access);
 	if (err)
 		return err;
-	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry);
+	err = nfsd_lookup_dentry(rqstp, fhp, name, len, &exp, &dentry, access);
 	if (err)
 		return err;
 	/*
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 3cac25adf16b..cdfdb6c4d836 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -33,6 +33,7 @@
 #define NFSD_MAY_64BIT_COOKIE		0x1000 /* 64 bit readdir cookies for >= NFSv3 */
 
 #define NFSD_MAY_LOCALIO		0x2000 /* for tracing, reflects when localio used */
+#define NFSD_MAY_SECINFO		0x4000 /* query export security policy */
 
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
@@ -128,12 +129,42 @@ void		nfsd_maybe_reset_write_verifier(struct nfsd_net *nn,
 						struct svc_rqst *rqstp,
 						int err);
 __be32		nfsd_cross_mnt(struct svc_rqst *rqstp, struct dentry **dpp,
-			       struct svc_export **expp);
-__be32		nfsd_lookup(struct svc_rqst *, struct svc_fh *,
-				const char *, unsigned int, struct svc_fh *);
-__be32		 nfsd_lookup_dentry(struct svc_rqst *, struct svc_fh *,
-				const char *, unsigned int,
-				struct svc_export **, struct dentry **);
+			       struct svc_export **expp, int access);
+__be32		__nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp,
+			      const char *name, unsigned int len,
+			      struct svc_fh *resfh, int access);
+
+/**
+ * nfsd_lookup - look up a single path component for nfsd
+ *
+ * @rqstp:   the request context
+ * @fhp:     the file handle of the directory
+ * @name:    the component name, or %NULL to look up parent
+ * @len:     length of name to examine
+ * @resfh:   pointer to pre-initialised filehandle to hold result.
+ *
+ * Look up one component of a pathname.
+ * N.B. After this call _both_ fhp and resfh need an fh_put
+ *
+ * If the lookup would cross a mountpoint, and the mounted filesystem
+ * is exported to the client with NFSEXP_NOHIDE, then the lookup is
+ * accepted as it stands and the mounted directory is
+ * returned. Otherwise the covered directory is returned.
+ * NOTE: this mountpoint crossing is not supported properly by all
+ *   clients and is explicitly disallowed for NFSv3
+ *
+ */
+static inline __be32 nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp,
+				 const char *name, unsigned int len,
+				 struct svc_fh *resfh)
+{
+	return __nfsd_lookup(rqstp, fhp, name, len, resfh, NFSD_MAY_EXEC);
+}
+
+__be32		nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
+				   const char *name, unsigned int len,
+				   struct svc_export **exp_ret,
+				   struct dentry **dentry_ret, int access);
 __be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
 			     struct nfsd_attrs *, const struct timespec64 *);
 int nfsd_mountpoint(struct dentry *, struct svc_export *);

-- 
2.56.0

