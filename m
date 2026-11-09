Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794257095;
	b=gjA1ob30X1YD0cf2P4lGeXpLen0W+faZHU7IyCE+B/TCHCVO5HpVEKIoBtP0XjV2lwOY
	 oxZM6pcD0ubxnJE4monTFR8Uxr7hEbwMvEvIK2yp5Ac8smxkDBkWKboZB549tDVJ+gYRa
	 MgKGDo+6WAEIP69cvRcANyL5RPc4qqSV/6wjtdMW/TmWYtLPoK9tnoiTGGgCHqZXgqX/6
	 ygYSOWq+j8SleOIfFQrXIbTAdHEECgsY4XYmp+f8tz9TNE4a0wfVqQwspcSV8r0lj+tWA
	 Ib68C+Aka/ce5HwvBYFFyozrrlGX6hZDp/cXo3VsE/e8wOYn5KKv9z9dyPEJBELIxPA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794257095;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=PT4qNdAVgNcP+Z1rBfN7L8rcVqRdXgkGRwEp1ADfZh8=;
	b=p2XeJiVeUzM5UfPctork2I4mGxcNL6GQgdRoXxXw6hejWzJKLVBZc5kUnWOSl1kMEibN
	 zI6CRDXoyq4IT35LDNJB6iuVd+io7XTOX+xmK1svrd+AnO9tl/RHqWmgoRkT8yYhV0jUn
	 dxZWPEkSyaHd4SZKAozoP7rugbw+ZKJU5jF5gw9Ri5icpBZbGlk2lG+PHhZQyBj0TACii
	 gCqlUQz+htCQ/HsUCPUwFntUgkyERf9lNndzwk9v9VDXDIxRWB4FEA7rrUr1zK6m0CcUC
	 Sl8kGUy5xbx3TXGKPCobLdU/Niy0+W1ip5M4UB3dwauvorEZw7Tvq1JWvs3C5rXVLIw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=I08M7gHT;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06093606A330;
	Mon,  9 Nov 2026 20:44:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=I08M7gHT
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F138C1F008A5;
	Mon,  9 Nov 2026 20:44:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794257094;
	bh=PT4qNdAVgNcP+Z1rBfN7L8rcVqRdXgkGRwEp1ADfZh8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=I08M7gHTC6+683vySY5yg1BDlv6CLlEKbEpgR/I+EuWmlO2sQFap3DtJZ0RkwmnG2
	 4c5y9uLXZVnC8wOYmBzjPsgdIby8aTgv0inAQvHHW3ZkT1iU1nKQv8Bxb3RwPF6eGx
	 r+RopQokPal2y6BOZfLTQFNb0iDHhrPerUpXCiB4QJRuZdH7WrXmEXJuSD53+fxb3P
	 HsGizurpJUcCCHU0cUaBHRtdn0syY7Qq5+GUPi1cF2smcwWcmp3hS2ALqZgTl0+zsB
	 fgIjmyyxoqhJJPdew15G7jVvQwVhk8hcjGyd2uemSRBXi77iO00sfbPbk0v+Z/WFvU
	 xpTWJ5C43KW1w==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 09 Nov 2026 15:44:48 -0500
Subject: [PATCH v2 2/3] NFS: stamp after the server's ctime when truncating
 under delegated times
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
Message-Id: <20261109-delegts-nfs-v2-2-9d1e926cc3d5@kernel.org>
References: <20261109-delegts-nfs-v2-0-9d1e926cc3d5@kernel.org>
In-Reply-To: <20261109-delegts-nfs-v2-0-9d1e926cc3d5@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Lance Shelton <lance.shelton@hammerspace.com>, 
 Olga Kornievskaia <okorniev@redhat.com>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2896; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=jTklTz9WAknWTty2zyrDg3XUt/Gl6uXBLVG+hpjv5DQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8jDDnT74PjQqQZIKiqEzH9GG/lxijBfyCQoj8
 KVqqJGlYdyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIwwwAKCRAADmhBGVaC
 Fcg8EACpBZdAIdv3l4NqZjfwAQ79qSVVI6wtexUX0bLRnfEicP5iCfUGuUge/52XrSbbxnlY96l
 cy/RBoKXSiQIRNVoU3BaSYmqUkPa2CDTXCyqp8uDbMVCnU05/TpdU8X5tWeEKgxBcBxsrgWKTP9
 CMBW0f9+W2RltnBH0CQFurwNTrCX+xXZ/OxnfY1sH+v5liBtJbLnrQ3XS2v0VZRmoNdDwnrDOxz
 0t+IuCDTCgUVXD4Eizvxnc3c/urow/fdOSaxQZmD/vgSv2WEbFz+1wmRk6i2bAgsHEg3N+KQVjR
 35OvHHvSvDA6aIXCHkcq+IPolAIDj3TAFux5EKnOAE+CVbOC2Y07eoq1VrJ430YMlx9GCmROT6g
 WuaYAmmSdmMLQmKfZbBfBclvQWSpBY4vFGawFfIdpAVAuOv+5fo9Z2rhzo96kbxEmhFxPwFwZtu
 nfagKgMSQUHYNmd5dL4rf94+6441P8QtnwbHBu0LQdzeAg2/3/w2xsfVfE01AxIkygLONb9EVls
 Sr8vK2HgoHF1fARJE5JcXgdgXaMfiEPU1NhLjG24kMZYAqWDFURhIuofGic3MplrANAM4zjFYoD
 aoMQU/jt/IQP6CnfJGXNhkA9KISH/5r16Vs0mgQ8nnMtSuYGDVhyXnX7iB3/M1oJZFKCWSE51UF
 8NjzKRyRMjKLfwA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

A size-changing SETATTR always has the server stamp c/mtime
(__nfsd_setattr(), per RFC 5661 section 18.30.4). With delegated
timestamps the client discards the reply's ctime and stamps its own in
nfs_vmtruncate(), clamped only against its cached ctime. A coarse client
stamp can still land before the server's, which then won't move ctime
back when the holder returns its times, so ctime changes after
DELEGRETURN.

- Raise the cached ctime to the reply's before nfs_vmtruncate() stamps,
  so the delegated stamp lands after the server's.
- Stamp before nfs_vmtruncate() drops i_lock for truncate_pagecache(),
  not after. A delegation return starting in that window made the stamp
  a no-op, and DELEGRETURN sent the pre-truncate mtime, which the server
  could apply over its own truncate stamp.

Fixes: e12912d94137 ("NFSv4: Add support for delegated atime and mtime attributes")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/inode.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 98d8a34fab9d..270d8bb46110 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -647,6 +647,21 @@ static struct timespec64 nfs_delegated_stamp(struct inode *inode)
 	return now;
 }
 
+/*
+ * The server stamped c/mtime itself (e.g. for a size change). Raise the
+ * cached ctime to the server's so that the next delegated stamp lands
+ * after it.
+ */
+static void nfs_delegated_ctime_raise(struct inode *inode,
+				      const struct nfs_fattr *fattr)
+{
+	struct timespec64 ctime = inode_get_ctime(inode);
+
+	if ((fattr->valid & NFS_ATTR_FATTR_CTIME) &&
+	    timespec64_compare(&fattr->ctime, &ctime) > 0)
+		inode_set_ctime_to_ts(inode, fattr->ctime);
+}
+
 static void nfs_set_timestamps_to_ts(struct inode *inode, struct iattr *attr)
 {
 	unsigned int cache_flags = 0;
@@ -820,10 +835,14 @@ static int nfs_vmtruncate(struct inode * inode, loff_t offset)
 		nfs_ooo_clear(NFS_I(inode));
 	}
 	NFS_I(inode)->cache_validity &= ~NFS_INO_INVALID_SIZE;
+	/*
+	 * Stamp in the same i_lock section that checked the delegation and
+	 * raised ctime, before a delegation return can start.
+	 */
+	nfs_update_delegated_mtime_locked(inode);
 
 	spin_unlock(&inode->i_lock);
 	truncate_pagecache(inode, offset);
-	nfs_update_delegated_mtime_locked(inode);
 	spin_lock(&inode->i_lock);
 out:
 	return err;
@@ -849,6 +868,8 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr,
 	if ((attr->ia_valid & ATTR_SIZE) != 0) {
 		if (!nfs_have_delegated_mtime(inode))
 			nfs_set_cache_invalid(inode, NFS_INO_INVALID_MTIME);
+		else
+			nfs_delegated_ctime_raise(inode, fattr);
 		nfs_set_cache_invalid(inode, NFS_INO_INVALID_BLOCKS);
 		nfs_inc_stats(inode, NFSIOS_SETATTRTRUNC);
 		nfs_vmtruncate(inode, attr->ia_size);

-- 
2.56.0

