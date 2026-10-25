Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793050590;
	b=kj/36MgRKThPWdbCgh5sQ7IB8hLzl8gABau3j2HFScHadRk634MXucGYCbwV7AB67m5O
	 H0sLlSC33TLHEu39sl2jZlU1Gc9/zvmgAV5zwTPGEahl2c3d0Z2qBkGaQrkYgWQVo3/jM
	 ltv8KxaA5pOj9l9JV/ekhv+bHq/0qlL5NVLMHUqxtHl2UwFpd/mNDhE4m78t07tHeLwVk
	 LDf2BMNpz1ySUYy82lB1V4tpK5uvxS19SQ1+BkQwrZ9g0eu3KrENwkuUJ91JPKQVgvjGb
	 qmEwbqzqCzRadCZUgDG+8f5NqsSngxrhwKNVx3mFi+eGb5G7RaZh6F9aj+xXRcQFbGg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793050590;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=HarieD7BhEtLMxzo//zT3OKEfJ3HRfK4EC2GbqU25/A=;
	b=gELhjRFQJLRWPSIeFcldWbA+GCk9k15l9EE0ToaxDB6dgJnKn+EkN+ZLg7DCVxkKDLm3
	 JD991EZZoQqQvm6z5B+m4oI8U3apsSVkMHfOQ10flEWJoZihVebQ+EDuWdi+MPpizz2hN
	 fxLQYlN/lnWVO1r92m1Uq5LZNrRr15CFYvWNeHeB/4K0fl0mQBOGRshUUG3RxFBqhwcMv
	 NitdrtfT1tsJorjb4YVSlWAnRhmFp3QA+Mxi750xPjaQiy1L/QE8sQ/zq/ZsqU/nIhkoA
	 ltoOMwtNsiIv9SGhGQu3jGSdSgvqJ4M/Ry4dU0h6CfkagYQWHIK0pPtVoj2nlbHSSRQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XUzwnyV+;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CBC0606A322
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 21:36:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XUzwnyV+
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 509491F01828;
	Mon, 26 Oct 2026 21:36:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793050590;
	bh=HarieD7BhEtLMxzo//zT3OKEfJ3HRfK4EC2GbqU25/A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XUzwnyV+MndhzjzaRaxsfwNMj8qFB39FIzw1n6yDAzxgoYeadrm31Y+Fdbd3n/8VI
	 quooUhpcoYtb4rffye81afDUcFo49MmnTzNC9LLFcgnfr9hZE5fnu5EVMeCWQ4/GG5
	 PU/+KxKTBeH5mmX1aunU4WeoRvZ1bcBe8PH/+StBFmgtZBUuAH0zCxzHlEMMqn28fR
	 JsVd+YL/8wO7Bpx2yFO1Si4C6o5WxW3d8Z3+r/HZjUPmIqquz1pvJfTOsFHpQVqshC
	 V50Jffj0lv8pFxTfJbsrF1dd/T0tJ3qYzColQgL+3GAbAHTcK1zcfraS7nHDUE+rVM
	 5JHo8RtSzpjtQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 13/13] nfs_common: Remove the unused NFS ACL stream codecs
Date: Sun, 25 Oct 2026 11:16:22 -0400
Message-ID: <20261025151622.141025-14-cel@kernel.org>
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

nfs_stream_encode_acl() and nfs_stream_decode_acl() served the
hand-rolled NFSD codecs for the NFS_ACLv2 and NFS_ACLv3 GETACL and
SETACL procedures. Those procedures now encode and decode ACL entries
through generated codecs, and the NFS client has always used the
xdr_buf variants, so neither function has a caller.

Remove both functions, their exports, and their declarations.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs_common/nfsacl.c | 125 -----------------------------------------
 include/linux/nfsacl.h |   6 --
 2 files changed, 131 deletions(-)

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index a66294fcfb6e..cb43fa203a2c 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -141,79 +141,6 @@ int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
 }
 EXPORT_SYMBOL_GPL(nfsacl_encode);
 
-/**
- * nfs_stream_encode_acl - Encode an NFSv3 ACL
- *
- * @xdr: an xdr_stream positioned to receive an encoded ACL
- * @inode: inode of file whose ACL this is
- * @acl: posix_acl to encode
- * @encode_entries: whether to encode ACEs as well
- * @typeflag: ACL type: NFS_ACL_DEFAULT or zero
- *
- * Return values:
- *   %false: The ACL could not be encoded
- *   %true: @xdr is advanced to the next available position
- */
-bool nfs_stream_encode_acl(struct xdr_stream *xdr, struct inode *inode,
-			   struct posix_acl *acl, int encode_entries,
-			   int typeflag)
-{
-	const size_t elem_size = XDR_UNIT * 3;
-	u32 entries = (acl && acl->a_count >= 3) ?
-		      max_t(int, acl->a_count, 4) : 0;
-	struct nfsacl_encode_desc nfsacl_desc = {
-		.desc = {
-			.elem_size = elem_size,
-			.array_len = encode_entries ? entries : 0,
-			.xcode = xdr_nfsace_encode,
-		},
-		.acl = acl,
-		.typeflag = typeflag,
-		.uid = inode->i_uid,
-		.gid = inode->i_gid,
-	};
-	struct nfsacl_simple_acl aclbuf;
-	unsigned int base;
-	int err;
-
-	if (entries > NFS_ACL_MAX_ENTRIES)
-		return false;
-	if (xdr_stream_encode_u32(xdr, entries) < 0)
-		return false;
-
-	if (encode_entries && acl && acl->a_count == 3) {
-		struct posix_acl *acl2 =
-			container_of(&aclbuf.acl, struct posix_acl, hdr);
-
-		/* Avoid the use of posix_acl_alloc().  nfsacl_encode() is
-		 * invoked in contexts where a memory allocation failure is
-		 * fatal.  Fortunately this fake ACL is small enough to
-		 * construct on the stack. */
-		posix_acl_init(acl2, 4);
-
-		/* Insert entries in canonical order: other orders seem
-		 to confuse Solaris VxFS. */
-		acl2->a_entries[0] = acl->a_entries[0];  /* ACL_USER_OBJ */
-		acl2->a_entries[1] = acl->a_entries[1];  /* ACL_GROUP_OBJ */
-		acl2->a_entries[2] = acl->a_entries[1];  /* ACL_MASK */
-		acl2->a_entries[2].e_tag = ACL_MASK;
-		acl2->a_entries[3] = acl->a_entries[2];  /* ACL_OTHER */
-		nfsacl_desc.acl = acl2;
-	}
-
-	base = xdr_stream_pos(xdr);
-	if (!xdr_reserve_space(xdr, XDR_UNIT +
-			       elem_size * nfsacl_desc.desc.array_len))
-		return false;
-	err = xdr_encode_array2(xdr->buf, base, &nfsacl_desc.desc);
-	if (err)
-		return false;
-
-	return true;
-}
-EXPORT_SYMBOL_GPL(nfs_stream_encode_acl);
-
-
 struct nfsacl_decode_desc {
 	struct xdr_array2_desc desc;
 	unsigned int count;
@@ -380,55 +307,3 @@ int nfsacl_decode(struct xdr_buf *buf, unsigned int base, unsigned int *aclcnt,
 		   nfsacl_desc.desc.array_len;
 }
 EXPORT_SYMBOL_GPL(nfsacl_decode);
-
-/**
- * nfs_stream_decode_acl - Decode an NFSv3 ACL
- *
- * @xdr: an xdr_stream positioned at an encoded ACL
- * @aclcnt: OUT: count of ACEs in decoded posix_acl
- * @pacl: OUT: a dynamically-allocated buffer containing the decoded posix_acl
- *
- * Return values:
- *   %false: The encoded ACL is not valid
- *   %true: @pacl contains a decoded ACL, and @xdr is advanced
- *
- * On a successful return, caller must release *pacl using posix_acl_release().
- */
-bool nfs_stream_decode_acl(struct xdr_stream *xdr, unsigned int *aclcnt,
-			   struct posix_acl **pacl)
-{
-	const size_t elem_size = XDR_UNIT * 3;
-	struct nfsacl_decode_desc nfsacl_desc = {
-		.desc = {
-			.elem_size = elem_size,
-			.xcode = pacl ? xdr_nfsace_decode : NULL,
-		},
-	};
-	unsigned int base;
-	u32 entries;
-
-	if (xdr_stream_decode_u32(xdr, &entries) < 0)
-		return false;
-	if (entries > NFS_ACL_MAX_ENTRIES)
-		return false;
-
-	base = xdr_stream_pos(xdr);
-	if (!xdr_inline_decode(xdr, XDR_UNIT + elem_size * entries))
-		return false;
-	nfsacl_desc.desc.array_maxlen = entries;
-	if (xdr_decode_array2(xdr->buf, base, &nfsacl_desc.desc))
-		return false;
-
-	if (pacl) {
-		if (entries != nfsacl_desc.desc.array_len ||
-		    posix_acl_from_nfsacl(nfsacl_desc.acl) != 0) {
-			posix_acl_release(nfsacl_desc.acl);
-			return false;
-		}
-		*pacl = nfsacl_desc.acl;
-	}
-	if (aclcnt)
-		*aclcnt = entries;
-	return true;
-}
-EXPORT_SYMBOL_GPL(nfs_stream_decode_acl);
diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
index 5160f30151e8..4ad81b2b2623 100644
--- a/include/linux/nfsacl.h
+++ b/include/linux/nfsacl.h
@@ -30,12 +30,6 @@ nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
 extern int
 nfsacl_decode(struct xdr_buf *buf, unsigned int base, unsigned int *aclcnt,
 	      struct posix_acl **pacl);
-extern bool
-nfs_stream_decode_acl(struct xdr_stream *xdr, unsigned int *aclcnt,
-		      struct posix_acl **pacl);
-extern bool
-nfs_stream_encode_acl(struct xdr_stream *xdr, struct inode *inode,
-		      struct posix_acl *acl, int encode_entries, int typeflag);
 extern int
 posix_acl_from_nfsacl(struct posix_acl *acl);
 
-- 
2.56.0

