Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050587;
	b=bU9uIaAcXN+JKVImXA8cihBwROekC4B09GoX752U92TuDZOAojSoNF2QRU7CR8JP4quC
	 LF1OnitIFOhIMKzTPW+ZTPWzzZigeMYGFbmDP+kD52+on1DtnRPSTrztjN/yba0L8eHZO
	 pmd/dG+u1MdiUhD/h0PofWXJJ28ZzuWCe3hXoL+gLzCbB4zcvil5fJ17cE3sIoWYqfn8B
	 CJextQCk0anegEMKAboNEWkaK34s8icdsk3vPSn58iqzlGz0UpKJPwSnVMBcVK1IZbtM0
	 dgTOEMr3pByT+GXFTtq9E/5gptC3tLW+tK6F3tG3mF4YwobFw036PA3ZcKKGlU97xEA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050587;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=2pQui1yfbk9fnICdFxblzwIJThp1Kp8eTqD2zvSQfmw=;
	b=H4Vr/XuKLg15Dp7JngHcaICH27NEW3Pbsv63HB7YQru2lTUDyCdM6YS549JJ5mZiR8gt
	 AuktdXeW8c4HaGjj15+uvBj0UciTezXwgGehtDRm5K7x10nhjeGN17M0kY6PLGF9IUz+b
	 uXJlFOmh3e7blS1e+8e43ZJguUVYPm9U0ygr8cwdibxhJKc0h98anDtNj7g+wMCR6hXVY
	 aH7GkJVRhd5E4w3Ew0fixWFxytKGWNjwUI3pKaK4gJNEnYaoKYDLQmoVSBHaBi8BBHpXO
	 DwT7ZVY71QuWb+NcgC7x+UTZOIGjrkGIK1w4zIRvohNw9XvopPVTdAFXL1Eud0GedLw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fkBaubn0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 526E2606A31F
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fkBaubn0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 70EA71F031F3;
	Mon, 26 Oct 2026 21:36:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050587;
	bh=2pQui1yfbk9fnICdFxblzwIJThp1Kp8eTqD2zvSQfmw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=fkBaubn06TvGWHDPCCTjOO2CqKGvidZl95esEIZ6gR3kbcl0Bwb69y17HApeiewvB
	 M7xNSqq/B1IqZzG9ID7y+BPtbAYsHhudcKIeMf9eFXNWJiDxUsmZfePtvUansDcXJp
	 rTgIud8wDTidJYB+bYzsv02q1M2ZnIQ2qsoVHVreTYk46QUPQg12XSDmkkE9hLS37l
	 KnmyR5qwMVytZkwD59+bnnAwpby6ZuwUv8i5G8Q7ZLO4gq2baNgdLOk+tGLioFV/3k
	 b/vumPqm15cI1HxWmiVjWB559Ef6Vc38UY+ZePdU2hOXEbCAur4cjODp+2ux2xjsIR
	 BHJxuX8CBc+cw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 10/13] NFSD: Remove the hand-coded XDR helpers for the NFS_ACLv3 procedures
Date: Sun, 25 Oct 2026 11:16:19 -0400
Message-ID: <20261025151622.141025-11-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261025151622.141025-1-cel@kernel.org>
References: <20261025151622.141025-1-cel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The NFS_ACLv3 GETACL and SETACL procedures were the last callers of
svcxdr_decode_nfs_fh3(), svcxdr_encode_nfsstat3(), and
svcxdr_encode_post_op_attr(). With their arguments and replies now
handled by xdrgen, the three helpers have no caller, and
svcxdr_encode_fattr3(), nfs3_ftypes[], and encode_nfstime3() have no
caller other than svcxdr_encode_post_op_attr().

Remove the hand-coded helpers and their declarations in xdr3.h.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3xdr.c | 166 ----------------------------------------------
 fs/nfsd/xdr3.h    |   5 --
 2 files changed, 171 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 850647ac98bb..8e231e0eb0f8 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -20,172 +20,6 @@
 
 #include "nfs3xdr_gen.h"
 
-/*
- * Mapping of S_IF* types to NFS file types
- */
-static const u32 nfs3_ftypes[] = {
-	NF3NON,  NF3FIFO, NF3CHR, NF3BAD,
-	NF3DIR,  NF3BAD,  NF3BLK, NF3BAD,
-	NF3REG,  NF3BAD,  NF3LNK, NF3BAD,
-	NF3SOCK, NF3BAD,  NF3LNK, NF3BAD,
-};
-
-
-/*
- * Basic NFSv3 data types (RFC 1813 Sections 2.5 and 2.6)
- */
-
-static __be32 *
-encode_nfstime3(__be32 *p, const struct timespec64 *time)
-{
-	*p++ = cpu_to_be32((u32)time->tv_sec);
-	*p++ = cpu_to_be32(time->tv_nsec);
-
-	return p;
-}
-
-/**
- * svcxdr_decode_nfs_fh3 - Decode an NFSv3 file handle
- * @xdr: XDR stream positioned at an undecoded NFSv3 FH
- * @fhp: OUT: filled-in server file handle
- *
- * Return values:
- *  %false: The encoded file handle was not valid
- *  %true: @fhp has been initialized
- */
-bool
-svcxdr_decode_nfs_fh3(struct xdr_stream *xdr, struct svc_fh *fhp)
-{
-	__be32 *p;
-	u32 size;
-
-	if (xdr_stream_decode_u32(xdr, &size) < 0)
-		return false;
-	if (size == 0 || size > NFS3_FHSIZE)
-		return false;
-	p = xdr_inline_decode(xdr, size);
-	if (!p)
-		return false;
-	fh_init(fhp, NFS3_FHSIZE);
-	fhp->fh_handle.fh_size = size;
-	memcpy(&fhp->fh_handle.fh_raw, p, size);
-
-	return true;
-}
-
-/**
- * svcxdr_encode_nfsstat3 - Encode an NFSv3 status code
- * @xdr: XDR stream
- * @status: status value to encode
- *
- * Return values:
- *   %false: Send buffer space was exhausted
- *   %true: Success
- */
-bool
-svcxdr_encode_nfsstat3(struct xdr_stream *xdr, __be32 status)
-{
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, sizeof(status));
-	if (!p)
-		return false;
-	*p = status;
-
-	return true;
-}
-
-static bool
-svcxdr_encode_fattr3(struct svc_rqst *rqstp, struct xdr_stream *xdr,
-		     const struct svc_fh *fhp, const struct kstat *stat)
-{
-	struct user_namespace *userns = nfsd_user_namespace(rqstp);
-	__be32 *p;
-	u64 fsid;
-
-	p = xdr_reserve_space(xdr, XDR_UNIT * 21);
-	if (!p)
-		return false;
-
-	*p++ = cpu_to_be32(nfs3_ftypes[(stat->mode & S_IFMT) >> 12]);
-	*p++ = cpu_to_be32((u32)(stat->mode & S_IALLUGO));
-	*p++ = cpu_to_be32((u32)stat->nlink);
-	*p++ = cpu_to_be32((u32)from_kuid_munged(userns, stat->uid));
-	*p++ = cpu_to_be32((u32)from_kgid_munged(userns, stat->gid));
-	if (S_ISLNK(stat->mode) && stat->size > NFS3_MAXPATHLEN)
-		p = xdr_encode_hyper(p, (u64)NFS3_MAXPATHLEN);
-	else
-		p = xdr_encode_hyper(p, (u64)stat->size);
-
-	/* used */
-	p = xdr_encode_hyper(p, ((u64)stat->blocks) << 9);
-
-	/* rdev */
-	*p++ = cpu_to_be32((u32)MAJOR(stat->rdev));
-	*p++ = cpu_to_be32((u32)MINOR(stat->rdev));
-
-	switch(fsid_source(fhp)) {
-	case FSIDSOURCE_FSID:
-		fsid = (u64)fhp->fh_export->ex_fsid;
-		break;
-	case FSIDSOURCE_UUID:
-		fsid = ((u64 *)fhp->fh_export->ex_uuid)[0];
-		fsid ^= ((u64 *)fhp->fh_export->ex_uuid)[1];
-		break;
-	default:
-		fsid = (u64)huge_encode_dev(fhp->fh_dentry->d_sb->s_dev);
-	}
-	p = xdr_encode_hyper(p, fsid);
-
-	/* fileid */
-	p = xdr_encode_hyper(p, stat->ino);
-
-	p = encode_nfstime3(p, &stat->atime);
-	p = encode_nfstime3(p, &stat->mtime);
-	encode_nfstime3(p, &stat->ctime);
-
-	return true;
-}
-
-/**
- * svcxdr_encode_post_op_attr - Encode NFSv3 post-op attributes
- * @rqstp: Context of a completed RPC transaction
- * @xdr: XDR stream
- * @fhp: File handle to encode
- *
- * Return values:
- *   %false: Send buffer space was exhausted
- *   %true: Success
- */
-bool
-svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
-			   const struct svc_fh *fhp)
-{
-	struct dentry *dentry = fhp->fh_dentry;
-	struct kstat stat;
-
-	/*
-	 * The inode may be NULL if the call failed because of a
-	 * stale file handle. In this case, no attributes are
-	 * returned.
-	 */
-	if (fhp->fh_no_wcc || !dentry || !d_really_is_positive(dentry))
-		goto no_post_op_attrs;
-	if (fh_getattr(fhp, &stat) != nfs_ok)
-		goto no_post_op_attrs;
-
-	if (xdr_stream_encode_item_present(xdr) < 0)
-		return false;
-	lease_get_mtime(d_inode(dentry), &stat.mtime);
-	if (!svcxdr_encode_fattr3(rqstp, xdr, fhp, &stat))
-		return false;
-
-	return true;
-
-no_post_op_attrs:
-	return xdr_stream_encode_item_absent(xdr) > 0;
-}
-
 /*
  * XDR encode functions
  */
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index a6f0e0b7bfe4..90dadcacdf2b 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -151,10 +151,5 @@ void nfsd3_fill_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
 			     struct svc_fh *fhp);
 void nfsd3_fill_post_op_fh3(struct post_op_fh3 *post_op_fh,
 			    const struct svc_fh *fhp, u8 *data);
-/* Helper functions for NFSv3 ACL code */
-bool svcxdr_decode_nfs_fh3(struct xdr_stream *xdr, struct svc_fh *fhp);
-bool svcxdr_encode_nfsstat3(struct xdr_stream *xdr, __be32 status);
-bool svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
-				const struct svc_fh *fhp);
 
 #endif /* _LINUX_NFSD_XDR3_H */
-- 
2.56.0

