Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677225;
	b=rRndZRsnnY7lj2pXyw+MT/AoE9Am/cI4dq+aoG3rSUfsFoqPwI/97ZISV/AOIEBOzXfC
	 f50G6v4JThF16H5JWm5asMRhiusAQcD3Rmh0WuwREaqZY/jHntAw3WNIxoDjjYWMELcZc
	 6hzspXTvcjNbxg44+jeByLKpvcoHXWr2gOCjs+NmhIEz+D8IGJnbFPgGk44jxyPcxfn8H
	 7q2OwRvAUQQq1mjQcIiir6tcJ71EzOmd9NKtBi3DhljbUoQuYtzk0VURvqMrBELfVbOxc
	 TCT+i6ZFbpyOe3ncAw/dHAt/JEBPllzdwSgLJZmZ9ID+r4naSNvuY/qV37KCQ6cMQbQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677225;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=tVhO3tHya4egC9V54NcxoBCZoXiVnuvil4nFc+ebzBo=;
	b=4UV0kW+AdjWFJE7wwQFERLYfOXoOnDwI1V6fmA0Dc4Ufrnmdr06Pa6XyNfP3WJM3hvfY
	 L/nMt890zkuQCQISbQf1oQX4m1RabsLk3kCUW6IH7tgdCInVybnwg2oyQfBRr2kE+L3Kr
	 Hag4xO+uN4+2fO9xXt4fkVH3vekvaEewfWiwTe4XzgZTmwWdn1+FcT3BB35duilgd8lMf
	 DYs0p5w7caKME5Bw7PLne4isHNvsKNeQthf+wy6msgl9X0xP23k7pEm1ekkZlUruRkApl
	 UeB+DXs8yPI+JdunZi7bLZYg7LZVQY7hZ6k57IWpy0x0tIGbseAHibam6365ypN4ELQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K6Ll5rxc;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2982760A260E
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=K6Ll5rxc
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 480361F000C8;
	Thu, 22 Oct 2026 13:53:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677224;
	bh=tVhO3tHya4egC9V54NcxoBCZoXiVnuvil4nFc+ebzBo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=K6Ll5rxcQjXbnv5Y1/FWVtMbrcwD1PidmCBO71sTNkqSU2kXskorXHxQANbq4KTIK
	 vv3lfodhG8x24qyn8kWFNRhTt3vlYBOO8XDTsxO52raqQJ8LgEC1BFyfx8/vuE0kMq
	 HfLYvLWOZbN4v7h3MnIE8bSOPWMhbILkcbn/i1poXSBBfQVh6Y8gO6q64UbFHDCUZ9
	 gKOe9cQ4T09CldakUUoMJnaReW3Prz8n4qt62HA38uyHf6hR5aovodqDeXUwyGp1C/
	 apK/oa2XE2mroUzMAJdVH27hW5kJPRuo5z0QkkeqPJfI6GqD6UulHA+f/m+/wVu0J5
	 r27VkejeDtjDg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 03/17] nfs_common: Export posix_acl_from_nfsacl for server ACL codecs
Date: Thu, 22 Oct 2026 09:53:27 -0400
Message-ID: <20261022135341.14265-4-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261022135341.14265-1-cel@kernel.org>
References: <20261022135341.14265-1-cel@kernel.org>
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

The NFS_ACLv2 secattr decode is moving off the hand-rolled
nfs_stream_decode_acl onto generated code driven by application hooks in
nfsd.  Those hooks finalize a decoded ACL with the same
Solaris-to-POSIX normalization nfs_stream_decode_acl performs
internally: the entry sort and the removal of the bogus ACL_MASK
entry Solaris adds to a minimal ACL.

Export that normalization and describe its contract so the hook
layer shares one implementation instead of duplicating it.  The
still-hand-rolled callers keep using it internally, unchanged.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs_common/nfsacl.c | 13 ++++++++++---
 include/linux/nfsacl.h |  2 ++
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index 24ee7f622b18..09d941303d16 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -288,10 +288,16 @@ cmp_acl_entry(const void *x, const void *y)
 		return 0;
 }
 
-/*
- * Convert from a Solaris ACL to a POSIX 1003.1e draft 17 ACL.
+/**
+ * posix_acl_from_nfsacl - Normalize a decoded Solaris ACL in place
+ * @acl: a posix_acl decoded from the NFSACL wire form, or NULL
+ *
+ * Sorts the entries into POSIX 1003.1e draft 17 order and removes the
+ * bogus ACL_MASK entry Solaris adds to a minimal ACL.
+ *
+ * Return: 0.  Always succeeds; a NULL @acl is a no-op.
  */
-static int
+int
 posix_acl_from_nfsacl(struct posix_acl *acl)
 {
 	struct posix_acl_entry *pa, *pe,
@@ -327,6 +333,7 @@ posix_acl_from_nfsacl(struct posix_acl *acl)
 	}
 	return 0;
 }
+EXPORT_SYMBOL_GPL(posix_acl_from_nfsacl);
 
 /**
  * nfsacl_decode - Decode an NFSv3 ACL
diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
index e4155e69c8dd..7d7709a0a56e 100644
--- a/include/linux/nfsacl.h
+++ b/include/linux/nfsacl.h
@@ -45,5 +45,7 @@ nfs_stream_decode_acl(struct xdr_stream *xdr, unsigned int *aclcnt,
 extern bool
 nfs_stream_encode_acl(struct xdr_stream *xdr, struct inode *inode,
 		      struct posix_acl *acl, int encode_entries, int typeflag);
+extern int
+posix_acl_from_nfsacl(struct posix_acl *acl);
 
 #endif  /* __LINUX_NFSACL_H */
-- 
2.56.0

