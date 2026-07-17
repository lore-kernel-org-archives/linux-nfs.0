Received: from fout-b1-smtp.messagingengine.com (fout-b1-smtp.messagingengine.com [202.12.124.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B9752737E0
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 04:33:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784262787; cv=none; b=PcxfWtM8I/txlbmMFUpcF+MIs3XV+eBqv166VwxsxxCHCk+uelzpZgUhgENmySVGNX9Md5SHYup4zRPTgYpUN20L5nvlN1otEJCTyHsz6Nb0O3SSZGr4cu4bhiaZw34pd8SthgxpFawBV5gxrB79dHb0Kg29gHggEctsn6cgMYI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784262787; c=relaxed/simple;
	bh=PyNTXAqkMZFwpANOBSr1RUp1a7dd8JLhQn9VYVDThaw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=F060Yjp5zjQzPWkI3iwrYSiPM6NtlId7A9/qc4V44UnkqmG00fCSGT3eyUopNkp+Yy39HRf54OZzWMjv/2nc5sq9OGfFM28iLL7MrfKvdLF1gqc/gXSRVbIRsWE5qI5PBBFPfrnY9XTi7jNf9nKmJJl9CBYHltnD6Vrmd4mx4Hw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Pl9efX/B; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=hE6fC75j; arc=none smtp.client-ip=202.12.124.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Pl9efX/B";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="hE6fC75j"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.stl.internal (Postfix) with ESMTP id 2BBE81D000C0;
	Fri, 17 Jul 2026 00:33:05 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Fri, 17 Jul 2026 00:33:05 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1784262785;
	 x=1784349185; bh=/q8p7xveHHjAYHH7V0rqJ3PT/1fW6FbQzSkwmEojazU=; b=
	Pl9efX/B66VzPBM2Mf120zfUPb9ssZBxcHo+9JprqUaDJqFFNjkbRdXDGQwYD9wy
	3/UaPnhAifqv+OGmTjIPPjR3+k9AJkaA38o9kvYgV8usLjKjjOdSxZjB+B9HjRwG
	GMUA+8fsJpvtDZNSsmxO2jQ/um2uNK510gbicvlJt9il6udSkaSgtdvnQ+T+KBwp
	c0gTJSIQkbgNzBR2n3v9sjymiD7DGtD7nkpL9CtTphaXHmMNL22YEemmcYwYCaIT
	s6WwCTU96oafHu8OIK6qV5GEy+4QYB9jxamxL4qX9EgbVxiRq5T2t3dRJCac0oPc
	JQJaXfUczPN5CbRC6IUBMA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1784262785; x=1784349185; bh=/
	q8p7xveHHjAYHH7V0rqJ3PT/1fW6FbQzSkwmEojazU=; b=hE6fC75j8xjY6Qb/e
	W0SNY0XcMK8mwKMkWNBv2Fs8rMO5r88OvUupgAwOnV45x36HhNUPk8rIuJv/CkKD
	k0754f+xg/Kw2kNqQuMbBXxz+AKss+bUyztMcFig0K1vTBdyz9gUrm1WBfqVrK8q
	0b+ssb7lbPj7xi5bTmj7BrUoZwnSzcJWWkGc1G6/qHXQXR0Ws2ITzo/Ciw9h2+DN
	3QiHXNddk4It4DyXYolsmjXZRFjFmXg0k0G1PlZXlSalSIGr7Z3uwsvnThcw6Qsa
	3qpe6IqXMCS6oMkLi/KpRpKNo6GX29Nqkjh+bdDUdAkrkNq8EGwaYfVsrJNzsc0N
	jp9FQ==
X-ME-Sender: <xms:gLBZasYD7HQ6CjQAz85xlj6lb6_mToytrv2OZSOXl3nVvloRW_mGYA>
    <xme:gLBZav3ZLEsaT6s7Vklk95gPHMESWvp_iVPCOEIadB5lhAY7YX03DjBrI9ErSMjKd
    2MEPw9gK7YN8UVc7Nvl5AaW2-4cEmLE3p5OReH65stb3ziO1Q>
X-ME-Received: <xmr:gLBZanaOG41gqi8mBgpEyN5bzYDogEMOqqbzMTdy8iRTYWsT_VntOf9Gk0cEjKzuXjCeX5geVseIZFlAR-djXqYDJSlGDqg>
X-ME-Proxy-Cause: dmFkZTFf1QU68ccbCX8W2k8Y1nGREK2lfBZ8muLx/9jWiTseOaEvZ5XgO1veuwpDDLDOh8
    GTBUmiRJRPyTQkIt2BUTpACGqxcYNQqe9Tcjx6k+JMfW40TZxrio5AhHmqjioKB7znJTir
    ATb1v/hlECnvAs6heOVcOHOlHDBfVnNe9pooX5hb/po3RqsBkktpkbuLKQfQYMMzr+JzB9
    /njxHQoF8AY+jho0jMT1tubTiNoCuayOLJLgFmAfFIsropGRO+BVYqdpkyAIA5dLkXTXCV
    Ha4vNgb6VzTYvk/ZKP8hUsX7dik9VUXtlC+e2jQNq5KVv1wL7YMoKmhY7BOqudAWlfzyFR
    ATf/owJXlF3PAHjc4zrxmKv7VtjZal2uuCB8sJ9XJMzRYZg0P7Xn/SLo0c9MJu4H8RZHts
    IYXrXNY0B69bz5GNxexPA86b0c3g4HK0b9Nof4PzzGIUXJ5dDW5mFJIz/j8XrjlXvTZec3
    nYl8hBpnR0yeIfK9jbeS6YlWsJZNEPhEmoF9iJZT/TFQmuhDVPWW4tdy6DQl0Xxs6+lKgV
    XDQObmXsu1i7S0OXtmb4mmWJ8cz5mK2KE6df+qSOTHl+YDJEzYmnBJkmKoePJz3eb8OfMF
    UhQAY/HSkXktzlRdZQbAhZTgnTjDGKV1t1Hflz/nw+5vujh91fMvUx8mDT3g
X-ME-Proxy: <xmx:gLBZanJ79-W2PFxk9do8FuGGW8DCrRcsFnPMm7RmTUOhmxjC3cSQNg>
    <xmx:gLBZamEakHsOn3ji1pOOvjBEBT3YhCyxF-QpW0hkVitBJpVsZeSfxg>
    <xmx:gLBZauvXgpH8Qck-mb8e2_Cp7MYIl4ceZsVfq8Zt0d-4lJnj_4LDWg>
    <xmx:gLBZalsVJVgSEwScWc-JmH1jefEs9ldf-sZo413_IgLYOVWGkBzQuQ>
    <xmx:gbBZapmqp2wXG0Vo6HxJ7VU2pZ7SWNofBBq881HO3V1it04U1Gz4kiWc>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 17 Jul 2026 00:33:02 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: [PATCH v4 03/18] nfsd: correctly handle CREATE of mounted-on files
Date: Fri, 17 Jul 2026 14:31:01 +1000
Message-ID: <20260717043242.1865905-4-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260717043242.1865905-1-neilb@ownmail.net>
References: <20260717043242.1865905-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Linux allows a file (non-directory) to be mounted on a file.  nfsd
mostly supports this if the crossmnt option is in effect.  However if
CREATE is used on an existing mounted-on file, the filehandle for the
underlying file is returns.  The client will then continue to use that
filehandle.

So
  cat /mnt/file
will show the contents of the mounted file as expected, but if
the dcache is flushed with "drop_caches" or similar, then
  >> /mnt/file
  cat /mnt/file
will show the mounted-on file.

For exclusive or checked creates this is not a problem as the creation
will fail no matter which file is seen. For unchecked creates we need to
see if the name is in the dcache, and if it is mounted.  If so, we
simply provide that filehandle, possibly truncating.

This probably has always existed since before the git history.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs3proc.c | 19 ++++++++++++++++++-
 fs/nfsd/nfs4proc.c | 27 +++++++++++++++++++++++++++
 fs/nfsd/nfsproc.c  | 17 ++++++++++++++++-
 3 files changed, 61 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index bbaef884f893..61272a6d2211 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -282,6 +282,7 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct nfsd_attrs attrs = {
 		.na_iattr	= iap,
 	};
+	struct svc_export *exp;
 	__u32 v_mtime, v_atime;
 	struct inode *inode;
 	__be32 status;
@@ -320,7 +321,23 @@ nfsd3_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			goto out;
 	}
 
-	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
+	exp = exp_get(fhp->fh_export);
+	if (argp->createmode == NFS3_CREATE_UNCHECKED) {
+		/*
+		 * If name is already in dcache we need to check for mountpoints
+		 */
+		if (d_is_reg(child) &&
+		    unlikely(nfsd_mountpoint(child, exp))) {
+			status = nfsd_cross_mnt(rqstp, &child, &exp);
+			if (status != nfs_ok) {
+				exp_put(exp);
+				goto out;
+			}
+		}
+	}
+
+	status = fh_compose(resfhp, exp, child, fhp);
+	exp_put(exp);
 	if (status != nfs_ok)
 		goto out;
 
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0317ff3f1c39..a13dc1756b1b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -271,6 +271,33 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	parent = fhp->fh_dentry;
 	inode = d_inode(parent);
 
+	if (open->op_createmode == NFS4_CREATE_UNCHECKED) {
+		/*
+		 * If name is already in dcache we need to check for mountpoints
+		 */
+		child = try_lookup_noperm(&QSTR_LEN(open->op_fname,
+						    open->op_fnamelen),
+					  parent);
+		if (child && !IS_ERR(child) && d_is_reg(child) &&
+		    unlikely(nfsd_mountpoint(child, fhp->fh_export))) {
+			struct svc_export *exp = exp_get(fhp->fh_export);
+			status = nfsd_cross_mnt(rqstp, &child, &exp);
+			if (status == nfs_ok)
+				status = fh_compose(resfhp, exp,
+						    child, fhp);
+			if (status == nfs_ok)
+				status = fh_fill_both_attrs(fhp);
+			open->op_truncate =
+				(iap->ia_valid & ATTR_SIZE) &&
+				!iap->ia_size;
+			dput(child);
+			exp_put(exp);
+			return status;
+		}
+		if (!IS_ERR(child))
+			dput(child);
+	}
+
 	host_err = fh_want_write(fhp);
 	if (host_err)
 		return nfserrno(host_err);
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index f60043632575..20fe4411f666 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -291,6 +291,7 @@ nfsd_proc_create(struct svc_rqst *rqstp)
 	struct nfsd_attrs attrs = {
 		.na_iattr	= attr,
 	};
+	struct svc_export *exp;
 	struct inode	*inode;
 	struct dentry	*dchild;
 	int		type, mode;
@@ -319,8 +320,22 @@ nfsd_proc_create(struct svc_rqst *rqstp)
 		resp->status = nfserrno(PTR_ERR(dchild));
 		goto out_write;
 	}
+	/*
+	 * If name exists we need to check for mountpoints
+	 */
+	exp = exp_get(dirfhp->fh_export);
+	if (d_is_reg(dchild) &&
+	    unlikely(nfsd_mountpoint(dchild, exp))) {
+		resp->status = nfsd_cross_mnt(rqstp, &dchild, &exp);
+		if (resp->status != nfs_ok) {
+			exp_put(exp);
+			goto out_unlock;
+		}
+	}
+
 	fh_init(newfhp, NFS_FHSIZE);
-	resp->status = fh_compose(newfhp, dirfhp->fh_export, dchild, dirfhp);
+	resp->status = fh_compose(newfhp, exp, dchild, dirfhp);
+	exp_put(exp);
 	if (!resp->status && d_really_is_negative(dchild))
 		resp->status = nfserr_noent;
 	if (resp->status) {
-- 
2.50.0.107.gf914562f5916.dirty

