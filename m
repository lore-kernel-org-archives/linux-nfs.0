Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4409C3BF685;
	Mon,  1 Jun 2026 15:33:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780327999; cv=none; b=oGc2c/Wkt2ckav7VXJu+4iVr+ngT4OSW+lR7uzuwksew5TRgfYPqA7RefK/L3htvpa6gy2UvqbyB+PRvsam0tPxB4UAYhovevx9tM/5KLpG2w061nCWFXUbMGN+O23P6WQYUBZ15YXHwG/NfNKsoekSXfKBiiSAQwHtWmDUwqvI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780327999; c=relaxed/simple;
	bh=2JSSds37orrgHUBtwWjHRE+G+SHglTtRDVxdgIYfXkg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=VPpfJdgBc1PpeiO9PyDYjw28bBZAqCT1F2aVgWeo7TkK1bAjmeqA+DCwYgOIwvUkMG3PY1INUduRcSXXu+5prn0UdW6Fx1n1hqCegpFQwKo5K4lW2iSdX/Vp7repwwu+h4onPPB+sDhUm9TILZrivnNGPG+4HzVl/Vazj/HBC30=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZWmx9gW9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZWmx9gW9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BD1E31F00893;
	Mon,  1 Jun 2026 15:33:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780327994;
	bh=fD3aSZ3SFUCPCMbJGPiFvi/n4zO8rK0KW0EWugYZtlg=;
	h=From:Date:Subject:To:Cc;
	b=ZWmx9gW9f/pq6XiZ8Ne9MXqnk8lLhn7ZVrW5pvBvkeZU0UbWP0qhZaUq+QD/DQA5I
	 Kh9JyrZg8wab3+ytI2icyizUYoRUIMlN8jUwcD9EZ+bJiM0E3be7ryWcIptT7RjxwW
	 eH2T7fNucMDBHgS7/fdi8LVjXoj7xFtVIrAtVfI/r9qhWtMxb5PyjiHmEsXU0s20uR
	 HTiOXQXLCTw4AvaExeppEmYVJvyxyLju3VOgY+osJFbTLhbb8RbzXERFuL5wI3G2Cl
	 LX434qkglvz/0o5QfywE44kwd97BrFZSr3/4g8BloFBzfwWDHWbtHZX/z75EXl4h97
	 w6+PO6BePVzow==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 01 Jun 2026 11:32:56 -0400
Subject: [PATCH v3] nfsd: release OPEN-decoded posix ACLs via op_release
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260601-nfsd-testing-v3-1-a31cd10bdd4f@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/32Myw6CMBAAf4Xs2TXdloJ48j+MBx5baDStaUmjI
 fy7hZsHPc4kMwtEDpYjnIsFAicbrXcZ1KGAfmrdyGiHzCCFrIRWhM7EAWeOs3UjNiRlZzT13Gj
 IyTOwsa99d71lnmycfXjv90Sb/TFKhALrzrTliTqhS3G5c3D8OPowwnZK8l8tkZBJcaW0Nr2ov
 +p1XT9ptHBI5wAAAA==
X-Change-ID: 20260531-nfsd-testing-9122bf51ce95
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Rick Macklem <rmacklem@uoguelph.ca>, 
 Chris Mason <clm@meta.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4597; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=2JSSds37orrgHUBtwWjHRE+G+SHglTtRDVxdgIYfXkg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqHaY0YhEsiihElIgrvLLHd2AZTgYACtLDIEPEP
 5dMxsMN2pCJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCah2mNAAKCRAADmhBGVaC
 FZwCEAC2yLr/5WqH+erdhPdZU8KFCeoWlPuRdPHUKedXtW0e3F40ZefBAX8l1J5kU/D3vdD8882
 t7VeAiJA0qRdsxTC16nX8GEtNhr2I33UGvIDbx0goVr3oekrkdN3iPrRzUXn2nciqVQAynPy8jz
 H2VyzsNpagXNGKwDo5xWnNh2vJoIwjbqDMdyU832q8Q9Ve4uGtpp4JyQPJvzEWmANSc/Am6XYpL
 2TwhzbAGqSAeg/ASsrliCHYSKFX/Pa/95gE5TjTJ7jyF889Kup0u8SquCVklIRE1WASh9kpc7XJ
 7GI2/bDG9BHC1/qfFUucX9rpSg+RHdt6R8oU88hSOOmUKzsF7+AOZILKY0mMgDNm/8Uzj9boUO4
 kcNN2xaFUFqAAhYLzDcLnShGJ8IkKSkqc+u/tefMsgMF42bUEonRrrfP7dx6XBQ09enslGGAnEh
 PpFlcWh0QLRAsSqOJcU/R4DUeKURivWVP28afiRpGhPXj3DsBc/Ul+XDfkPFWbUeNxMH8+sCZ31
 U7BUlBXkP45RkKWSi/mYiPNI1D+34H2n6CfQ56FGFZnhDx/PQ9e5UeM7LX3dL4bHUGb4Te2g38d
 ZSAbmvy9a6oce1r/m3jV8+oO+r4cPYRQRmcT/KDS6WQFnxQeLd6HjT9KQV+vwOuajeADXMvX4e1
 qAD4wagHpyhqG1Q==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_decode_createhow4() calls nfsd4_decode_fattr4(), which allocates
refcounted struct posix_acl objects via posix_acl_alloc() and stores
them in open->op_pacl and open->op_dpacl. These pointers must be
released once the OPEN compound finishes.

When nfsd4_decode_open_claim4() returns a non-seqid-mutating error,
the dispatcher short-circuits before op_func runs:

    nfsd4_proc_compound()
      opdesc->op_func == nfsd4_open_omfg
        if (!seqid_mutating_err(ntohl(op->status)))
            return op->status;   /* nfsd4_open() never runs */
      opdesc->op_release(&op->u)  /* must still release op_pacl/op_dpacl */

Before this change OP_OPEN had no .op_release in nfsd4_ops[], and the
release pair lived inside nfsd4_open() at its out_err: label. On the
short-circuit path nfsd4_open() is never invoked, so both posix_acl
refs leak on every malformed OPEN compound that carries valid POSIX
ACL createhow4 attributes.

Add nfsd4_open_release() and wire it as .op_release for OP_OPEN.
posix_acl_release() is NULL-safe, so the single release site covers
both the normal path and the nfsd4_open_omfg short-circuit. Remove
the matching posix_acl_release() pair from nfsd4_open()'s out_err:
label to avoid double-releasing.

The compound loop has two encoding branches: nfsd4_encode_operation()
for normal ops, and nfsd4_encode_replay() for v4.0 replayed ops.
op_release was only called from nfsd4_encode_operation(), so resources
attached to op->u leak on the replay path.

Move the op_release() call out of nfsd4_encode_operation() and the
replay branch, placing it after the if-else in nfsd4_proc_compound().
This gives a single call site in a fairly obviously-correct place,
covering both the normal encoding and replay paths.

Fixes: 5fc51dfc2eb1 ("NFSD: Add support for XDR decoding POSIX draft ACLs")
Signed-off-by: Chris Mason <clm@meta.com>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: NeilBrown <neil@brown.name>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v3:
- Move op_release to a single callsite that accomodates all cases
- Link to v2: https://lore.kernel.org/r/20260531-nfsd-testing-v2-1-e13e6355fc07@kernel.org

Changes in v2:
- Ensure that op_release is called in the v4.0 replay case as well
- Link to v1: https://lore.kernel.org/r/20260531-nfsd-testing-v1-0-7bfa481b0540@kernel.org
---
 fs/nfsd/nfs4proc.c | 13 +++++++++++--
 fs/nfsd/nfs4xdr.c  |  3 ---
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 017474cd63b5..9e86f5907f06 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -681,8 +681,6 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_cleanup_open_state(cstate, open);
 	nfsd4_bump_seqid(cstate, status);
 out_err:
-	posix_acl_release(open->op_dpacl);
-	posix_acl_release(open->op_pacl);
 	return status;
 }
 
@@ -704,6 +702,13 @@ static __be32 nfsd4_open_omfg(struct svc_rqst *rqstp, struct nfsd4_compound_stat
 	return nfsd4_open(rqstp, cstate, &op->u);
 }
 
+static void
+nfsd4_open_release(union nfsd4_op_u *u)
+{
+	posix_acl_release(u->open.op_dpacl);
+	posix_acl_release(u->open.op_pacl);
+}
+
 /*
  * filehandle-manipulating ops.
  */
@@ -3219,6 +3224,9 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 			status = op->status;
 		}
 
+		if (op->opdesc && op->opdesc->op_release)
+			op->opdesc->op_release(&op->u);
+
 		trace_nfsd_compound_status(args->client_opcnt, resp->opcnt,
 					   status, nfsd4_op_name(op->opnum));
 
@@ -3718,6 +3726,7 @@ static const struct nfsd4_operation nfsd4_ops[] = {
 	},
 	[OP_OPEN] = {
 		.op_func = nfsd4_open,
+		.op_release = nfsd4_open_release,
 		.op_flags = OP_HANDLES_WRONGSEC | OP_MODIFIES_SOMETHING,
 		.op_name = "OP_OPEN",
 		.op_rsize_bop = nfsd4_open_rsize,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a5cfce95d2d7..487a1f62ce15 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -6654,9 +6654,6 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	write_bytes_to_xdr_buf(xdr->buf, op_status_offset,
 			       &op->status, XDR_UNIT);
 release:
-	if (opdesc && opdesc->op_release)
-		opdesc->op_release(&op->u);
-
 	/*
 	 * Account for pages consumed while encoding this operation.
 	 * The xdr_stream primitives don't manage rq_next_page.

---
base-commit: 6c0004650ba248a12937ada16f9ba961b35ce2b5
change-id: 20260531-nfsd-testing-9122bf51ce95

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

