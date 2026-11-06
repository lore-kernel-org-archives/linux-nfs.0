Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793998092;
	b=2mKNI9pH03/T13/lJ04MLRvitVpFdDe87FymLfrv/46HvnBolGSaZUGPJoxAV1e8M/tX
	 qx/8qo0Tr6zYsmjcIfhgDpL4plgY+MzsuA8vHkjx9zXk5rjGVWGXSqxz53CJs/48t6t0z
	 M7gQ82V7MI/052Ke8kDhdsrhart3WltD+HcPMVKQ7MVoatEGxEnkR0wGzVMsrTxvZgk+o
	 8Hhi3LyfDKhuSh2zw012v+MeB/PAhDcsm0QwR7kIFqNpzyMgFGSGBFYikbe9ak9uBCAFy
	 t7O1MLz8cuulqwdH0b6vPt4BYYvLOxKPAGWfZgHbS08KqtdiBmof2pjQd3YAqZrngwQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793998092;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=9mcowaLQivUNdvM89Yuh1lfv6rcilApeJpxtB9I7g5E=;
	b=yrUoOEemPtDvdbw68HXvPiGJKpdEnTN9ahg2SP5sLCJW52xjGWv2VXq3p1GiUMBmpjJ8
	 xvxZbUubuGrUr+zkCtVCJ8wBn7fY6E0ljY0WQW+hBRmZwki/KtQxze5l/V+DJIJs37mAo
	 S5A7f0WZ722+JG7fYGYnvA1s9Zi3Tz1al5pO5HrMIe/n3WtFEIxJM0hiBPXQrfOx/iCCl
	 ntndSls223caneh+2bKysIPEqPx83NRJPUaP2MkMPH7otRL+I8bTzqeckE8OzGEBMJYHO
	 YiLWrygrXdg+HFU7k44LIkoLMj3rIIfCSeNRSdXX1sZwNM64sR+Q5n0AL+7SCVYECow==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Brsw5uem;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F037F606A33F;
	Fri,  6 Nov 2026 20:48:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Brsw5uem
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3ACAC1F008BE;
	Fri,  6 Nov 2026 20:48:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793998091;
	bh=9mcowaLQivUNdvM89Yuh1lfv6rcilApeJpxtB9I7g5E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Brsw5uem2zye8EyJfZ4QkvOqL97IjYX8KwX8kMFnB9fPJopYfsqgQNqXhdE8ce/6H
	 W733pvxVC+B0f7J1j1O7/5I+Ju3/3YAmiKJxWu6Bv6Mtya67f4DEFa05CEBunQdtaR
	 onSSQGASbrxvY+7E1q8GJrI4yhlvZIoqV1i09kqowLbJRiD84zw8g72rnxCmTRshVZ
	 j+a0QxmuFCmLwAdgUPXm8HALqrpR2KLRKbUhULlbw2Szs5bYak0XxCD+bbYyXhhzzk
	 Yg1h7Myv7eruA7c3ZJ8R1HbpBtqDzLSoJNW3+YUBJrqMWrGtgPs8IeDTcl+EUfdTBX
	 AJhB+cwofaUxA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 06 Nov 2026 15:48:06 -0500
Subject: [PATCH 3/3] NFS: stamp after the server's ctime following a CLONE
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
Message-Id: <20261106-delegts-nfs-v1-3-1d5c5e364a07@kernel.org>
References: <20261106-delegts-nfs-v1-0-1d5c5e364a07@kernel.org>
In-Reply-To: <20261106-delegts-nfs-v1-0-1d5c5e364a07@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Lance Shelton <lance.shelton@hammerspace.com>, 
 Olga Kornievskaia <okorniev@redhat.com>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4672; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=GRpSX0npmP7doNYHui+WBCD5KEIccYoqey7961YEBEY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq7j0I6BIhkeywnV6PO5af8hEGWFsDtW17ibeG1
 nccAgqdrh2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCau49CAAKCRAADmhBGVaC
 FToSD/9mIhB6qP9nEcIYw2Woyw7yvNtvhNNV0DceEznLQgB1NV0Wf4FSA6nGYEq8VeE3+Ug0YrK
 gnlxWByyp5TUiXWSKIcPVYNlDqARUbC51+vWr/ZchGwPxx59aizZGXT+W4vY/Jy3Gbxm6I3MIXW
 JFgzTCiuhfJpotwlsevSAnjwQmbwpjxfe6Im2+XtXizY1fye2nBprBcXlbXTbL6FFipteeTWlIN
 hlw13UBQQQbC/1MHqBd70IFfXNWMi7WE/Fuiurz1M156q+ZXqJAmY5ZwF6zI76jcNK6+RxluKVx
 Z1y9LT4ogfrV/X5BkZCQ7Nhf+bQyv16xamFQ0xKVmnjb4yDepv806/nBDOVCbTpa9jbdn+ekPdv
 ru3XWDW8/Vdfa2S8u/tf5toZD7kol3AYZQ2M359moUQaJw+ccJpLHQC3ftEs3mVguXRUdmE8Eqo
 tjn53IVVgz8DLjsWqbmTn+D/NjtkPRgCa2FaDUVRgredciuh+J5ICIdiUAknKJH4Nnp/RkyKUo2
 Fp21OkDHNYvSzF2gk/od7XF44KrsHym95gJIz1ezs2LfHNjs1BXJLPM0Y0xsSMmiQQhw3yBeZb4
 spQcn9/E/v2W07CWEzL2SaJC1mz7sfZrbT/3vKKB5fVnZcS72O+ryo6KEjUTzJT3r5lKakf6Oue
 lOjbbKikvUBY8oA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfs42_copy_dest_done() stamps the client's own c/mtime when it holds
delegated timestamps, and the CLONE reply's attributes are then
filtered out. A server that stamps c/mtime on CLONE (as nfsd did before
"nfsd: mark the delegation written on COPY/CLONE instead of stamping
c/mtime", and as btrfs did before "btrfs: honor FMODE_NOCMTIME when
cloning") can end up with a ctime newer than the client's coarse stamp,
which it won't move back when the holder returns its times.

Pass the CLONE reply's attributes to nfs42_copy_dest_done() and raise
the cached ctime to the server's before stamping. COPY returns no
attributes, so it passes NULL.

Fixes: 6e7daa3dad29 ("NFSv4.2: fix CLONE/COPY attrs in presence of delegated attributes")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/delegation.h |  2 ++
 fs/nfs/inode.c      |  5 +++--
 fs/nfs/nfs42proc.c  | 12 +++++++++---
 3 files changed, 14 insertions(+), 5 deletions(-)

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
index 8b86d93f8101..0175e7719ab4 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -653,8 +653,8 @@ nfs_delegated_ctime_after(struct inode *inode, const struct timespec64 *old)
  * cached ctime to the server's so that the next delegated stamp lands
  * after it.
  */
-static void nfs_delegated_ctime_raise(struct inode *inode,
-				      const struct nfs_fattr *fattr)
+void nfs_delegated_ctime_raise(struct inode *inode,
+			       const struct nfs_fattr *fattr)
 {
 	struct timespec64 ctime = inode_get_ctime(inode);
 
@@ -662,6 +662,7 @@ static void nfs_delegated_ctime_raise(struct inode *inode,
 	    timespec64_compare(&fattr->ctime, &ctime) > 0)
 		inode_set_ctime_to_ts(inode, fattr->ctime);
 }
+EXPORT_SYMBOL_GPL(nfs_delegated_ctime_raise);
 
 static void nfs_set_timestamps_to_ts(struct inode *inode, struct iattr *attr)
 {
diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ab86246fc364..3ab36730688e 100644
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
@@ -405,6 +406,9 @@ static void nfs42_copy_dest_done(struct file *file, loff_t pos, loff_t len,
 					     NFS_INO_INVALID_CTIME |
 					     NFS_INO_INVALID_MTIME |
 					     NFS_INO_INVALID_BLOCKS);
+	/* The server may have stamped c/mtime; stamp after it */
+	if (fattr && nfs_have_delegated_mtime(inode))
+		nfs_delegated_ctime_raise(inode, fattr);
 	spin_unlock(&inode->i_lock);
 	nfs_update_delegated_mtime(inode);
 }
@@ -506,7 +510,8 @@ static ssize_t _nfs42_proc_copy(struct file *src,
 			goto out;
 	}
 
-	nfs42_copy_dest_done(dst, pos_dst, res->write_res.count, oldsize_dst);
+	nfs42_copy_dest_done(dst, pos_dst, res->write_res.count, oldsize_dst,
+			     NULL);
 	nfs_invalidate_atime(src_inode);
 	status = res->write_res.count;
 out:
@@ -1311,7 +1316,8 @@ static int _nfs42_proc_clone(struct rpc_message *msg, struct file *src_f,
 		/* a zero-length count means clone to EOF in src */
 		if (count == 0 && res.dst_fattr->valid & NFS_ATTR_FATTR_SIZE)
 			count = nfs_size_to_loff_t(res.dst_fattr->size) - dst_offset;
-		nfs42_copy_dest_done(dst_f, dst_offset, count, oldsize_dst);
+		nfs42_copy_dest_done(dst_f, dst_offset, count, oldsize_dst,
+				     res.dst_fattr);
 		status = nfs_post_op_update_inode(dst_inode, res.dst_fattr);
 	}
 

-- 
2.56.0

