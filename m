Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795192825;
	b=BTk0kdX8+43aenBpjucx4sO4vecIBbdtzmtG78v2YzNlDArmxmMAbwYEYnl4YolvFtXu
	 m8SKtnA9IxjmcfrWf6OqUAF6MtAx0Y2mG0i2STQ7T5/wZkYk7rlUTZDtBJL/TUlt/4os7
	 X/Itlq8A/E5+RuCYamHtdX2VDpdfZnN2Pgjos0yXvQMUJvYEjmMWAwxxb9YlHpxT86dSA
	 iig95tGXxcJqb0Gk1pNioRTR0fbUAn2KBMjz09bunIRZPxZPOjUYcEbJ1cG8UYo0oI/tu
	 ikSCjguDGb+L9U1Vumcd4panlfS3Le0AXctT0oi0PZHHnV7i3bL98O3WXyBJXGykn6Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795192825;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=rYFA30ZuwX+NkHQi98bYSFGysxPj05VWLtj+r3tXbCg=;
	b=MpXoNeM23lJr+9m9iw72KV5zI92OYwLR4Ns8YoKd4caoV+gTxdl++IA/1xTz3rlraNpj
	 wxmtMiDBcl8NFZwiDAjNTNbslrtgVSKKMj8CteTKgSKopREFhhTgAKdKrzOPoOexoLn0y
	 Jp1XiO87wNKTw6x8QDA/SniD5hJ6fkKt3POFFuiA5w6N870SWAHdFrljWfcgsBBJLwxOH
	 EU4HZdsPSdv6eOzYvgYSpZtZZ8xmsMEDG+aevyIUi5f3Dz4pRy99ocEc5OpyW2owj8uac
	 /CbUp/dGlb/J4Nfx69GCMkhzOZXl20JfS+iKBTDmOVIKKAQnq6EHDrWKc1eWmmn/Bqg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iY39kPmc;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD9E560A2613;
	Fri, 20 Nov 2026 16:40:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iY39kPmc
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C5EB1F000D0;
	Fri, 20 Nov 2026 16:40:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795192825;
	bh=rYFA30ZuwX+NkHQi98bYSFGysxPj05VWLtj+r3tXbCg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iY39kPmc47DlbV3Joc4c8ZFgCheG18+P+c7HMRnflRnByPIbTRdj33DS/Sn2lN+i6
	 0K+9pmP7Ai8C5mBZ0OYNbihTSyj4UzbUyrogs4EBW6QKPKb7w4TtUQsIHcUpZ/EsmY
	 cDUl7WoON8d6fvfDzyOx1TzKGFV2UUMDCpTQZah6szkr8PH0GkJnzMRMX8baAYEBpX
	 y5vnM0DZVG5nJuvirx8UVeX9WqosUBmxndjoLdX/tUHt3NHWIa8k2HE2WftTgoREnW
	 tyBnbvVAaNoNEqGhLkQR2NpJVZHHczwrYK6tjgN4JbojkqbnztuDJIfC4fdFIUX/Cg
	 EdRYySdvTgqSA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 20 Nov 2026 08:40:14 -0800
Subject: [PATCH 08/11] nfsd: apply delegated times in a separate times-only
 setattr
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
Message-Id: <20261120-delegts-fixes-v1-8-c89b37d2d462@kernel.org>
References: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
In-Reply-To: <20261120-delegts-fixes-v1-0-c89b37d2d462@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=17100; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=DDkWvgbIjjuD0jLFRFbyEpAFVSzXCsJRjW8QIT/gU40=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrAHfyIjiD44ZBNqijVwEaJDzow+ea8v0QRBLCU
 98Y0ccCawWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawB38gAKCRAADmhBGVaC
 FeXnD/9N59WlEP4x6CFNiritCcP3P33/LZYcxcTknJ78rZcTYQZZZ6oU3jLH1VUvXkiRM9WemBs
 N8HhJ4+MoKFlk/0My1v0+VdKtjQfXCVXnnFsw7zI/jPWkYqwE5dMP9U3hDm0sxOV75quiwDQjUm
 eSLn3fTefqA2DpNCd38WGmqGT8AlTiJy9wNnLDCn9hus+REaJiKMffJmuYcYHICN47QZT+MdX76
 g2vOr3FGq12Qfv/EsLzjWA9YGu+5OIhdghiaYeLrZUmhG3CH1ONXgs4Gua397O5sWlx1maEQTgI
 Qsl7asuB/ETNXndIZFylUkRiU+v+zxNq/bUB0HNyuZd8qrF4TsK7mA+DBI/wt+KhiVQ8GZv8ltZ
 Nw41b5ypSVpnmpxewU9bcdjPvDeG2XDHpBhvnAtTEWDR8/WJm8HwkUO0jdp1wsKg7qpdnYMZjPD
 uj/EsZmg3O15lyOTlekluHYmBDcV+Doae8ntNSa2plvRs6Lvh3uWDNhdJC/2zrqulr8Ks+2d759
 hP3Sg+ryhh6rxNO52IfMe4zGg3DDv35cNHJGKD2x8qCQrj8pdtu1KKJFxu8QL7vNjgJY/2EDFJl
 EwULf+suyXWhdyr/tQ9kOErkhN3QhAQymUAimY6HKyh4fXnmMn9ZWOwmh2wgmmSz+b35QSUd1Yj
 K7x/7oxIYPNKTKQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Delegated times were decoded into sa_iattr with ATTR_DELEG and applied
in the same nfsd_setattr() call as every other attribute. Problems:
- a holder that doesn't own the file gets EPERM: notify_change() checks
  ownership for explicit times, but the stateid is what grants the
  authority (RFC 9754);
- ATTR_DELEG applies to the whole iattr, so __nfsd_setattr() needs
  special ctime handling for the non-time attributes;
- if the times are rejected, attrsset can't report the attributes that
  were set.

Decode time_deleg_access/time_deleg_modify into new sa_deleg_atime and
sa_deleg_mtime fields. After nfsd_setattr() handles the other
attributes, nfsd4_deleg_set_times() applies the vetted times with
notify_change(ATTR_FORCE) and an iattr that holds only times:
- fh_verify(NFSD_MAY_SATTR) first, since a times-only request skips
  nfsd_setattr() and with it the export's read-only and immutable
  checks;
- no ATTR_DELEG: nfsd_breaker_owns_lease() keeps the holder's own lease,
  and any other lease is broken;
- base vetting against dl_*time is kept. When the vetted mtime is
  applied but the delegated ctime is rejected, ctime now moves to the
  current time instead of being left alone, since the inode's mtime
  did change.

nfsd_setattr() is skipped for a request with only delegated times. A
request that sets both the plain and delegated form of a time gets
NFS4ERR_INVAL. That is checked, as is the stateid, only after the minor
version's supported attributes, so a minor version without delegated
times gets NFS4ERR_ATTRNOTSUPP for them. attrsset keeps the non-time
bits when the times step fails. A failure inside nfsd_setattr() still
reports nothing as set, since its interface can't report a partial
update.

Delegated times in CREATE and OPEN createattrs get NFS4ERR_INVAL:
RFC 9754 allows them only in SETATTR by a delegation holder, and
EXCLUSIVE4_1 already rejects them via suppattr_exclcreat. A minor
version that doesn't support them still gets NFS4ERR_ATTRNOTSUPP.

ATTR_DELEG no longer reaches __nfsd_setattr(), so drop its ATTR_DELEG
branch and always add ATTR_CTIME. commit_metadata() is made visible to
nfs4proc.c.

Fixes: 7e13f4f8d27d ("nfsd: handle delegated timestamps in SETATTR")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c | 165 +++++++++++++++++++++++++++++++++++------------------
 fs/nfsd/nfs4xdr.c  |  53 +++++++++--------
 fs/nfsd/vfs.c      |  16 +-----
 fs/nfsd/vfs.h      |   1 +
 fs/nfsd/xdr4.h     |   3 +
 5 files changed, 146 insertions(+), 92 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 71d6a473c1bc..ae6ee42d169a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1361,33 +1361,58 @@ nfsd4_secinfo_no_name_release(union nfsd4_op_u *u)
 		exp_put(u->secinfo_no_name.sin_exp);
 }
 
+#define NFSD4_DELEG_TIME_BITS	(FATTR4_WORD2_TIME_DELEG_ACCESS | \
+				 FATTR4_WORD2_TIME_DELEG_MODIFY)
+
 /*
- * Validate that the requested timestamps are within the acceptable range. If
- * timestamp appears to be in the future, then it will be clamped to
- * current_time().
+ * Apply a delegation holder's times in a times-only setattr. The stateid,
+ * not file ownership, grants the authority to set them, hence ATTR_FORCE.
+ * ATTR_DELEG isn't needed: nfsd_breaker_owns_lease() keeps the holder's
+ * own lease intact, and any other lease is broken.
  */
-static void
-vet_deleg_attrs(struct nfsd4_setattr *setattr, struct nfs4_delegation *dp)
+static __be32
+nfsd4_deleg_set_times(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		      struct nfsd4_setattr *setattr, struct nfs4_delegation *dp)
 {
-	struct timespec64 now = current_time(dp->dl_stid.sc_file->fi_inode);
-	struct iattr *iattr = &setattr->sa_iattr;
+	struct iattr iattr = { };
+	struct timespec64 now;
+	struct inode *inode;
+	__be32 status;
+	int host_err;
 
-	if ((setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS) &&
-	    !nfsd4_vet_deleg_time(&iattr->ia_atime, &dp->dl_atime, &now))
-		iattr->ia_valid &= ~(ATTR_ATIME | ATTR_ATIME_SET);
+	/* nfsd_setattr() is skipped for a times-only request */
+	status = fh_verify(rqstp, fhp, 0, NFSD_MAY_SATTR);
+	if (status)
+		return status;
+	inode = d_inode(fhp->fh_dentry);
 
+	now = current_time(inode);
+	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS) {
+		iattr.ia_atime = setattr->sa_deleg_atime;
+		if (nfsd4_vet_deleg_time(&iattr.ia_atime, &dp->dl_atime, &now))
+			iattr.ia_valid |= ATTR_ATIME | ATTR_ATIME_SET;
+	}
 	if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_MODIFY) {
-		if (nfsd4_vet_deleg_time(&iattr->ia_mtime, &dp->dl_mtime, &now)) {
-			iattr->ia_ctime = iattr->ia_mtime;
-			if (nfsd4_vet_deleg_time(&iattr->ia_ctime, &dp->dl_ctime, &now))
+		iattr.ia_mtime = setattr->sa_deleg_mtime;
+		if (nfsd4_vet_deleg_time(&iattr.ia_mtime, &dp->dl_mtime, &now)) {
+			iattr.ia_valid |= ATTR_MTIME | ATTR_MTIME_SET | ATTR_CTIME;
+			iattr.ia_ctime = iattr.ia_mtime;
+			if (nfsd4_vet_deleg_time(&iattr.ia_ctime, &dp->dl_ctime, &now)) {
+				iattr.ia_valid |= ATTR_CTIME_SET;
 				dp->dl_setattr = true;
-			else
-				iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET);
-		} else {
-			iattr->ia_valid &= ~(ATTR_CTIME | ATTR_CTIME_SET |
-					     ATTR_MTIME | ATTR_MTIME_SET);
+			}
 		}
 	}
+	if (!iattr.ia_valid)
+		return nfs_ok;
+
+	iattr.ia_valid |= ATTR_FORCE;
+	inode_lock(inode);
+	host_err = notify_change(&nop_mnt_idmap, fhp->fh_dentry, &iattr, NULL);
+	inode_unlock(inode);
+	if (!host_err)
+		host_err = commit_metadata(fhp);
+	return nfserrno(host_err);
 }
 
 static __be32
@@ -1401,16 +1426,34 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		.na_pacl	= posix_acl_dup(setattr->sa_pacl),
 		.na_dpacl	= posix_acl_dup(setattr->sa_dpacl),
 	};
-	bool save_no_wcc, deleg_attrs;
+	struct nfs4_delegation *dp = NULL;
+	u32 *bmval = setattr->sa_bmval;
 	struct nfs4_stid *st = NULL;
-	struct inode *inode;
+	u32 deleg_bits, other_bits;
 	__be32 status = nfs_ok;
+	struct inode *inode;
+	bool save_no_wcc;
 	int err;
 
-	deleg_attrs = setattr->sa_bmval[2] & (FATTR4_WORD2_TIME_DELEG_ACCESS |
-					      FATTR4_WORD2_TIME_DELEG_MODIFY);
+	deleg_bits = bmval[2] & NFSD4_DELEG_TIME_BITS;
+	other_bits = bmval[0] | bmval[1] | (bmval[2] & ~NFSD4_DELEG_TIME_BITS);
 
-	if (deleg_attrs || (setattr->sa_iattr.ia_valid & ATTR_SIZE)) {
+	/* Before the checks below, which assume the minor version has them */
+	if (!nfsd_attrs_supported(cstate->minorversion, bmval)) {
+		status = nfserr_attrnotsupp;
+		goto out_err;
+	}
+
+	/* Setting both forms of the same time is ambiguous */
+	if (((deleg_bits & FATTR4_WORD2_TIME_DELEG_ACCESS) &&
+	     (bmval[1] & FATTR4_WORD1_TIME_ACCESS_SET)) ||
+	    ((deleg_bits & FATTR4_WORD2_TIME_DELEG_MODIFY) &&
+	     (bmval[1] & FATTR4_WORD1_TIME_MODIFY_SET))) {
+		status = nfserr_inval;
+		goto out_err;
+	}
+
+	if (deleg_bits || (setattr->sa_iattr.ia_valid & ATTR_SIZE)) {
 		int flags = WR_STATE;
 
 		if (setattr->sa_bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS)
@@ -1423,20 +1466,15 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out_err;
 	}
 
-	if (deleg_attrs) {
+	if (deleg_bits) {
 		status = nfserr_bad_stateid;
-		if (st && (st->sc_type & SC_TYPE_DELEG)) {
-			struct nfs4_delegation *dp = delegstateid(st);
-
-			/* Only for *_ATTRS_DELEG flavors */
-			if (deleg_attrs_deleg(dp->dl_type)) {
-				vet_deleg_attrs(setattr, dp);
-				status = nfs_ok;
-			}
+		/* Only for *_ATTRS_DELEG flavors */
+		if (st && (st->sc_type & SC_TYPE_DELEG) &&
+		    deleg_attrs_deleg(delegstateid(st)->dl_type)) {
+			dp = delegstateid(st);
+			status = nfs_ok;
 		}
 	}
-	if (st)
-		nfs4_put_stid(st);
 	if (status)
 		goto out_err;
 
@@ -1445,36 +1483,55 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfserrno(err);
 		goto out_err;
 	}
-	status = nfs_ok;
 
 	status = check_attr_support(cstate, setattr->sa_bmval, nfsd_attrmask);
 	if (status)
 		goto out;
 
-	if (setattr->sa_acl && (attrs.na_dpacl || attrs.na_pacl)) {
-		status = nfserr_inval;
-		goto out;
-	}
+	if (!deleg_bits || other_bits) {
+		if (setattr->sa_acl && (attrs.na_dpacl || attrs.na_pacl)) {
+			status = nfserr_inval;
+			goto out;
+		}
 
-	inode = cstate->current_fh.fh_dentry->d_inode;
-	status = nfsd4_acl_to_attr(S_ISDIR(inode->i_mode) ? NF4DIR : NF4REG,
-				   setattr->sa_acl, &attrs);
+		inode = cstate->current_fh.fh_dentry->d_inode;
+		status = nfsd4_acl_to_attr(S_ISDIR(inode->i_mode) ? NF4DIR : NF4REG,
+					   setattr->sa_acl, &attrs);
+		if (status)
+			goto out;
+		save_no_wcc = cstate->current_fh.fh_no_wcc;
+		cstate->current_fh.fh_no_wcc = true;
+		status = nfsd_setattr(rqstp, &cstate->current_fh, &attrs, NULL);
+		cstate->current_fh.fh_no_wcc = save_no_wcc;
+		if (!status)
+			status = nfserrno(attrs.na_labelerr);
+		if (!status)
+			status = nfserrno(attrs.na_dpaclerr);
+		if (!status)
+			status = nfserrno(attrs.na_paclerr);
+		if (status)
+			goto out;
+		/*
+		 * A failure inside nfsd_setattr() may follow a partial
+		 * update, but its interface can't report which parts were
+		 * applied, so such a failure reports nothing as set.
+		 */
+		setattr->sa_attrsset[0] = bmval[0];
+		setattr->sa_attrsset[1] = bmval[1];
+		setattr->sa_attrsset[2] = bmval[2] & ~NFSD4_DELEG_TIME_BITS;
+	}
 
-	if (status)
-		goto out;
-	save_no_wcc = cstate->current_fh.fh_no_wcc;
-	cstate->current_fh.fh_no_wcc = true;
-	status = nfsd_setattr(rqstp, &cstate->current_fh, &attrs, NULL);
-	cstate->current_fh.fh_no_wcc = save_no_wcc;
-	if (!status)
-		status = nfserrno(attrs.na_labelerr);
-	if (!status)
-		status = nfserrno(attrs.na_dpaclerr);
-	if (!status)
-		status = nfserrno(attrs.na_paclerr);
+	if (deleg_bits) {
+		status = nfsd4_deleg_set_times(rqstp, &cstate->current_fh,
+					       setattr, dp);
+		if (!status)
+			setattr->sa_attrsset[2] |= deleg_bits;
+	}
 out:
 	fh_drop_write(&cstate->current_fh);
 out_err:
+	if (st)
+		nfs4_put_stid(st);
 	nfsd_attrs_free(&attrs);
 	return status;
 }
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e6131095024f..b945712fa051 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -510,7 +510,9 @@ static __be32
 nfsd4_decode_fattr4(struct nfsd4_compoundargs *argp, u32 *bmval, u32 bmlen,
 		    struct iattr *iattr, struct nfs4_acl **acl,
 		    struct xdr_netobj *label, int *umask,
-		    struct posix_acl **dpaclp, struct posix_acl **paclp)
+		    struct posix_acl **dpaclp, struct posix_acl **paclp,
+		    struct timespec64 *deleg_atime,
+		    struct timespec64 *deleg_mtime)
 {
 	unsigned int starting_pos;
 	u32 attrlist4_count;
@@ -529,6 +531,15 @@ nfsd4_decode_fattr4(struct nfsd4_compoundargs *argp, u32 *bmval, u32 bmlen,
 		return nfserr_attrnotsupp;
 	}
 
+	/*
+	 * RFC 9754 section 5: delegated times are valid only in SETATTR.
+	 * A minor version without them doesn't support them at all.
+	 */
+	if ((bmval[2] & FATTR4_WORD2_TIME_DELEG_ACCESS && !deleg_atime) ||
+	    (bmval[2] & FATTR4_WORD2_TIME_DELEG_MODIFY && !deleg_mtime))
+		return nfsd_attrs_supported(argp->minorversion, bmval) ?
+				nfserr_inval : nfserr_attrnotsupp;
+
 	if (xdr_stream_decode_u32(argp->xdr, &attrlist4_count) < 0)
 		return nfserr_bad_xdr;
 	starting_pos = xdr_stream_pos(argp->xdr);
@@ -658,9 +669,8 @@ nfsd4_decode_fattr4(struct nfsd4_compoundargs *argp, u32 *bmval, u32 bmlen,
 			return nfserr_bad_xdr;
 		if (access.nseconds >= NSEC_PER_SEC)
 			return nfserr_inval;
-		iattr->ia_atime.tv_sec = access.seconds;
-		iattr->ia_atime.tv_nsec = access.nseconds;
-		iattr->ia_valid |= ATTR_ATIME | ATTR_ATIME_SET | ATTR_DELEG;
+		deleg_atime->tv_sec = access.seconds;
+		deleg_atime->tv_nsec = access.nseconds;
 	}
 	if (bmval[2] & FATTR4_WORD2_TIME_DELEG_MODIFY) {
 		fattr4_time_deleg_modify modify;
@@ -669,12 +679,8 @@ nfsd4_decode_fattr4(struct nfsd4_compoundargs *argp, u32 *bmval, u32 bmlen,
 			return nfserr_bad_xdr;
 		if (modify.nseconds >= NSEC_PER_SEC)
 			return nfserr_inval;
-		iattr->ia_mtime.tv_sec = modify.seconds;
-		iattr->ia_mtime.tv_nsec = modify.nseconds;
-		iattr->ia_ctime.tv_sec = modify.seconds;
-		iattr->ia_ctime.tv_nsec = modify.nseconds;
-		iattr->ia_valid |= ATTR_CTIME | ATTR_CTIME_SET |
-				   ATTR_MTIME | ATTR_MTIME_SET | ATTR_DELEG;
+		deleg_mtime->tv_sec = modify.seconds;
+		deleg_mtime->tv_nsec = modify.nseconds;
 	}
 
 	*dpaclp = NULL;
@@ -1014,7 +1020,8 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, union nfsd4_op_u *u)
 				    ARRAY_SIZE(create->cr_bmval),
 				    &create->cr_iattr, &create->cr_acl,
 				    &create->cr_label, &create->cr_umask,
-				    &create->cr_dpacl, &create->cr_pacl);
+				    &create->cr_dpacl, &create->cr_pacl,
+				    NULL, NULL);
 	if (status)
 		return status;
 
@@ -1166,7 +1173,8 @@ nfsd4_decode_createhow4(struct nfsd4_compoundargs *argp, struct nfsd4_open *open
 					     ARRAY_SIZE(open->op_bmval),
 					     &open->op_iattr, &open->op_acl,
 					     &open->op_label, &open->op_umask,
-					     &open->op_dpacl, &open->op_pacl);
+					     &open->op_dpacl, &open->op_pacl,
+					     NULL, NULL);
 		if (status)
 			return status;
 		break;
@@ -1185,7 +1193,8 @@ nfsd4_decode_createhow4(struct nfsd4_compoundargs *argp, struct nfsd4_open *open
 					     ARRAY_SIZE(open->op_bmval),
 					     &open->op_iattr, &open->op_acl,
 					     &open->op_label, &open->op_umask,
-					     &open->op_dpacl, &open->op_pacl);
+					     &open->op_dpacl, &open->op_pacl,
+					     NULL, NULL);
 		if (status)
 			return status;
 		break;
@@ -1513,7 +1522,8 @@ nfsd4_decode_setattr(struct nfsd4_compoundargs *argp, union nfsd4_op_u *u)
 				   ARRAY_SIZE(setattr->sa_bmval),
 				   &setattr->sa_iattr, &setattr->sa_acl,
 				   &setattr->sa_label, NULL, &setattr->sa_dpacl,
-				   &setattr->sa_pacl);
+				   &setattr->sa_pacl, &setattr->sa_deleg_atime,
+				   &setattr->sa_deleg_mtime);
 }
 
 static __be32
@@ -5755,17 +5765,10 @@ nfsd4_encode_setattr(struct nfsd4_compoundres *resp, __be32 nfserr,
 	struct nfsd4_setattr *setattr = &u->setattr;
 	__be32 status;
 
-	switch (nfserr) {
-	case nfs_ok:
-		/* attrsset */
-		status = nfsd4_encode_bitmap4(resp->xdr, setattr->sa_bmval[0],
-					      setattr->sa_bmval[1],
-					      setattr->sa_bmval[2]);
-		break;
-	default:
-		/* attrsset */
-		status = nfsd4_encode_bitmap4(resp->xdr, 0, 0, 0);
-	}
+	/* attrsset: also reported on failure (RFC 8881 section 18.30.3) */
+	status = nfsd4_encode_bitmap4(resp->xdr, setattr->sa_attrsset[0],
+				      setattr->sa_attrsset[1],
+				      setattr->sa_attrsset[2]);
 	return status != nfs_ok ? status : nfserr;
 }
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c0d10c263a93..7b84269d52ac 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -410,7 +410,7 @@ commit_inode_metadata(struct inode *inode)
 	return sync_inode_metadata(inode, 1);
 }
 
-static int
+int
 commit_metadata(struct svc_fh *fhp)
 {
 	struct inode *inode = d_inode(fhp->fh_dentry);
@@ -508,20 +508,10 @@ static int __nfsd_setattr(struct dentry *dentry, struct iattr *iap)
 			return 0;
 	}
 
-	if ((iap->ia_valid & ~ATTR_DELEG) == 0)
+	if (iap->ia_valid == 0)
 		return 0;
 
-	/*
-	 * If ATTR_DELEG is set, then this is an update from a client that
-	 * holds a delegation. If this is an update for only the atime, the
-	 * ctime should not be changed. Any other attribute change, such as
-	 * a mode or owner change sent along with a delegated atime, must
-	 * update the ctime.
-	 */
-	if (!(iap->ia_valid & ATTR_DELEG) ||
-	    (iap->ia_valid & ~(ATTR_DELEG | ATTR_ATIME | ATTR_ATIME_SET)))
-		iap->ia_valid |= ATTR_CTIME;
-
+	iap->ia_valid |= ATTR_CTIME;
 	return notify_change(&nop_mnt_idmap, dentry, iap, NULL);
 }
 
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 40115d9aa245..ba07a18d69c6 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -166,6 +166,7 @@ __be32		nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				   const char *name, unsigned int len,
 				   struct svc_export **exp_ret,
 				   struct dentry **dentry_ret, int access);
+int		commit_metadata(struct svc_fh *fhp);
 __be32		nfsd_setattr(struct svc_rqst *, struct svc_fh *,
 			     struct nfsd_attrs *, const struct timespec64 *);
 int nfsd_mountpoint(struct dentry *, struct svc_export *);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 28481a2c8285..3031dace6d1b 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -377,6 +377,9 @@ struct nfsd4_setattr {
 	struct xdr_netobj sa_label;
 	struct posix_acl *sa_dpacl;
 	struct posix_acl *sa_pacl;
+	struct timespec64 sa_deleg_atime;   /* request */
+	struct timespec64 sa_deleg_mtime;   /* request */
+	u32		sa_attrsset[3];     /* response */
 };
 
 struct nfsd4_setclientid {

-- 
2.56.1

