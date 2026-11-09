Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794257096;
	b=fdZmo3cRvyhKD9cT3JQWAcVEfiq7iq610Y2+pRhT+EOFtr+2+NLLBKPNUl4yPbgK3Ui2
	 xxEnK2zopMfZl46UJFPgsMrODRzXgFYKOBThglZ5aAbf2g55pSH7As/27eq+734Ro+4hy
	 zF5JjkZfRN53v68nhUu9WV3fzi96qQtYUJR2tuym1QbBrF20XaxSr8chIch6srTAVvpYl
	 H47HV/CJnJ3tCf/nizMkjUqIN363vRfvWNDmu/wBU6r9ataqCOMhQQvtmmbFIW4C+qiO7
	 +p5rY46jTMC/IjIB3NNNxVE3uUTeqE/c8qMGughFzjUjzkh/AKjpUDtHxaUfJ6t6KSw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794257096;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=EvtGLzC16JVEkSNGJ3HsHG8HsYJk0ieesatCfJD6Adk=;
	b=uMU7zOFaQ0/oBw2FWO3XDbrVEaRkfxAZ/INWxeWotM2NGI9JGmg/Q47ejbHN/kgD3CNW
	 fneEKKChuI/lwHb5yAumN1eCCgRD32l1SqzM8MQVlas97QAN9RT62sgpw6lUFV6qqVJVR
	 Po09pd3nfBMkC3aB32/SXZD+1btQjsSlpd/H59wJ1N/o1OVWo7a5vHbDE/md0ElcXBHWk
	 B9r2bx3L4eK9Z8aB4ztPyVAv0r6qLGgaZtbDtHTU0ef5xMyUKJq2GgIGvSyM1cYzgJKYo
	 6d/xUHqi5j/eHbtgGa3P9a3q063MvFq4nGPeEbf/xb2VIMJi3I7gJEJPk4vQfBKCaYQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gPAAx3VI;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8708606A33A;
	Mon,  9 Nov 2026 20:44:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gPAAx3VI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CBAC31F008A2;
	Mon,  9 Nov 2026 20:44:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794257095;
	bh=EvtGLzC16JVEkSNGJ3HsHG8HsYJk0ieesatCfJD6Adk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gPAAx3VIa2Z/aMs5LyvUoqomIcVDPeI9Ct6Ul0cqTE89nLLQfNM1n2XI1W67ouGLv
	 SQD7Uw4CPaAue8OdhokEqEO1HYl4GsvKhyZw5v+DJF0Sd1Ac5oYYt5YrnL5OaDnH21
	 YLFAJleAtCKxPkwg69pIJ6HnOrStRR8CkReNG0cdDQ5sGzwfJWK7mOuvWsbEVLpff5
	 olQwUiokyhYxPF5DJ1UrWZoGrFgviGAMAcQMCxvFws1L3G5Etf4U1HN83R0vcoqUBy
	 lYMjwxy10Xg6U8B8us5CNuewQaCvWIourxTuHO6dNpaDj3/SqcqSrSre2YRzbJIFi9
	 v9i6aTO+DvE3g==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 09 Nov 2026 15:44:49 -0500
Subject: [PATCH v2 3/3] NFS: stamp after the server's ctime following a
 CLONE
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
Message-Id: <20261109-delegts-nfs-v2-3-9d1e926cc3d5@kernel.org>
References: <20261109-delegts-nfs-v2-0-9d1e926cc3d5@kernel.org>
In-Reply-To: <20261109-delegts-nfs-v2-0-9d1e926cc3d5@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Lance Shelton <lance.shelton@hammerspace.com>, 
 Olga Kornievskaia <okorniev@redhat.com>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5985; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=F/T5qRcBFZHKvCcKilkvvFSLkFlxkA/4B6gqzSyX66M=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq8jDDpwMReoSepMzT88TWCQGKRLJqBqjo5Nf5b
 rahq4k3HE+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCavIwwwAKCRAADmhBGVaC
 FXnuEACKaPOCSzd2cMataL4IWL65eXYwHJYEoO7nTdBJ7Vqo1Tt57aT8EpoIkGm6q0YaniB4rBG
 RU1zM69jKNLgJddn2dTFO3sP0GfpWsh1JqTabNGk18fJn4gaQ5Hu2rervNE8jUwDrUxluOnXyBQ
 MVFuZvGJhn+02gLf76fBMIFBIx7TqmEjmClM1z+RzCMOTpksfDl52guIzDakNyGLF+Ks38k7cI2
 DcprgvnUhcEFVdDhnrJtfkLHXwvHQDgbdaff+PxZkxl1WpWN/gL4rht918HA3+omBwOgMQdSBkj
 624q1yhBhetA16RjigRnGEhVbndV+RzASiZqzyoUKSdLJQU+ChL4EN9hA6/nOIuvtNQ1Dy30tdw
 foqiPX+56WXcfKfStEyYcztFllYyr/IN2V0I0RYJsUa3ad4wBlgIBz0bOdO5Y3D35dNjuNKy8l7
 vnivYksBxellYE/T3Z8cVJ3aNJ2gTyDnO+3gWko6G461nY2xexC9tTJ9ATZJr8UNcD8TPjJkUpN
 X9vd+RUjTJ3qpbdsNHPRihpWYypZNAHPnMWfvabc6E5S75N21r9o8xhCAsT7NrIZLinOEpPebc3
 ky6hMdwBvaViY4eYZVa3l7+289P11nrCkBGg/a6BMoTX2nc/X0TA1fr2GpSTZbF0rXhOgMzTSa0
 J4xUFV75aefRmHA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfs42_copy_dest_done() stamps the client's own c/mtime when it holds
delegated timestamps. A server that stamps c/mtime on CLONE (as nfsd did
before "nfsd: mark the delegation written on COPY/CLONE instead of
stamping c/mtime", and as btrfs did before "btrfs: honor FMODE_NOCMTIME
when cloning") can end up with a ctime newer than the client's coarse
stamp, which it won't move back when the holder returns its times.

The stamp didn't survive anyway: nfs_post_op_update_inode() then marks
ctime invalid, so nfs_fattr_fixup_delegated() keeps the reply's ctime
and nfs_update_inode() writes it over the stamp. Against a server that
no longer stamps on CLONE, the client's ctime goes back to its old value
until DELEGRETURN.

- Pass the CLONE reply's attributes to nfs42_copy_dest_done() and raise
  the cached ctime to the server's before stamping. COPY returns no
  attributes, so it passes NULL.
- Stamp before dropping i_lock, so a concurrent refresh can't take the
  server's times while ctime and mtime are marked invalid.
- Under delegated timestamps, apply the reply with nfs_refresh_inode(),
  which doesn't mark ctime invalid.

Fixes: 6e7daa3dad29 ("NFSv4.2: fix CLONE/COPY attrs in presence of delegated attributes")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/delegation.h |  2 ++
 fs/nfs/inode.c      |  6 ++++--
 fs/nfs/nfs42proc.c  | 25 ++++++++++++++++++++-----
 3 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index fba4699952b8..cd6142939d34 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -95,6 +95,8 @@ void nfs4_inode_make_writeable(struct inode *inode);
 void nfs_update_delegated_atime(struct inode *inode);
 void nfs_update_delegated_mtime(struct inode *inode);
 void nfs_update_delegated_mtime_locked(struct inode *inode);
+void nfs_delegated_ctime_raise(struct inode *inode,
+			       const struct nfs_fattr *fattr);
 
 static inline int nfs_have_read_or_write_delegation(struct inode *inode)
 {
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 270d8bb46110..5a682f74d7d1 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -652,8 +652,8 @@ static struct timespec64 nfs_delegated_stamp(struct inode *inode)
  * cached ctime to the server's so that the next delegated stamp lands
  * after it.
  */
-static void nfs_delegated_ctime_raise(struct inode *inode,
-				      const struct nfs_fattr *fattr)
+void nfs_delegated_ctime_raise(struct inode *inode,
+			       const struct nfs_fattr *fattr)
 {
 	struct timespec64 ctime = inode_get_ctime(inode);
 
@@ -661,6 +661,7 @@ static void nfs_delegated_ctime_raise(struct inode *inode,
 	    timespec64_compare(&fattr->ctime, &ctime) > 0)
 		inode_set_ctime_to_ts(inode, fattr->ctime);
 }
+EXPORT_SYMBOL_GPL(nfs_delegated_ctime_raise);
 
 static void nfs_set_timestamps_to_ts(struct inode *inode, struct iattr *attr)
 {
@@ -711,6 +712,7 @@ void nfs_update_delegated_mtime_locked(struct inode *inode)
 	    nfs_have_directory_delegation(inode))
 		nfs_update_mtime(inode);
 }
+EXPORT_SYMBOL_GPL(nfs_update_delegated_mtime_locked);
 
 void nfs_update_delegated_mtime(struct inode *inode)
 {
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ab86246fc364..09b4a6ecad88 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -380,6 +380,7 @@ static int process_copy_commit(struct file *dst, loff_t pos_dst,
  * @pos: destination offset
  * @len: copy length
  * @oldsize: length of the file prior to clone/copy
+ * @fattr: destination attributes from the reply, or NULL
  *
  * Punch a hole in the inode page cache, so that the NFS client will
  * know to retrieve new data.
@@ -387,7 +388,7 @@ static int process_copy_commit(struct file *dst, loff_t pos_dst,
  * invalid cached values for change attribute, ctime, mtime and space used.
  */
 static void nfs42_copy_dest_done(struct file *file, loff_t pos, loff_t len,
-				 loff_t oldsize)
+				 loff_t oldsize, const struct nfs_fattr *fattr)
 {
 	struct inode *inode = file_inode(file);
 	struct address_space *mapping = file->f_mapping;
@@ -405,8 +406,12 @@ static void nfs42_copy_dest_done(struct file *file, loff_t pos, loff_t len,
 					     NFS_INO_INVALID_CTIME |
 					     NFS_INO_INVALID_MTIME |
 					     NFS_INO_INVALID_BLOCKS);
+	/* The server may have stamped c/mtime; stamp after it */
+	if (fattr && nfs_have_delegated_mtime(inode))
+		nfs_delegated_ctime_raise(inode, fattr);
+	/* Before a refresh can see the times invalid and take the server's */
+	nfs_update_delegated_mtime_locked(inode);
 	spin_unlock(&inode->i_lock);
-	nfs_update_delegated_mtime(inode);
 }
 
 static ssize_t _nfs42_proc_copy(struct file *src,
@@ -506,7 +511,8 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 			goto out;
 	}
 
-	nfs42_copy_dest_done(dst, pos_dst, res->write_res.count, oldsize_dst);
+	nfs42_copy_dest_done(dst, pos_dst, res->write_res.count, oldsize_dst,
+			     NULL);
 	nfs_invalidate_atime(src_inode);
 	status = res->write_res.count;
 out:
@@ -1311,8 +1317,17 @@ static int _nfs42_proc_clone(struct rpc_message *msg, struct file *src_f,
 		/* a zero-length count means clone to EOF in src */
 		if (count == 0 && res.dst_fattr->valid & NFS_ATTR_FATTR_SIZE)
 			count = nfs_size_to_loff_t(res.dst_fattr->size) - dst_offset;
-		nfs42_copy_dest_done(dst_f, dst_offset, count, oldsize_dst);
-		status = nfs_post_op_update_inode(dst_inode, res.dst_fattr);
+		nfs42_copy_dest_done(dst_f, dst_offset, count, oldsize_dst,
+				     res.dst_fattr);
+		/*
+		 * nfs_post_op_update_inode() would mark ctime invalid, so the
+		 * reply's ctime would overwrite the delegated stamp.
+		 */
+		if (nfs_have_delegated_mtime(dst_inode))
+			status = nfs_refresh_inode(dst_inode, res.dst_fattr);
+		else
+			status = nfs_post_op_update_inode(dst_inode,
+							  res.dst_fattr);
 	}
 
 	kfree(res.dst_fattr);

-- 
2.56.0

