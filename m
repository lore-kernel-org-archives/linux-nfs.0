Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C2357603A
	for <linux-nfs@vger.kernel.org>; Fri, 28 Jun 2024 21:11:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719609077; cv=none; b=YoF99I8jGMLbjjdcHBoSLsVTmMP+qKhkicT0jcwEVIF64Fp9FCHG7N4/YuQtKMbB8q5OKK3pbuBR1vDCqG7A1Ep8zpryWMGFON9fQdElx6sE0yqsb45rY+dkTAdtrbdcxMRBvC+Fe9DLUblTO4rd8O3gMd49G4+GO27GILIAb1g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719609077; c=relaxed/simple;
	bh=XhEv8fwdZACCNVWBPNo7yZqRCS+Wc21X92zuNOcifjI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=q+zAh2EgGnlrDzODN6g2NQ1z2Xd+xECWaYageQ9X2T9S7uQNKQtlWfEAFeto9bJUD+x4I9Mf+K7NYcNrfN0/NvdAHIu4EaHuk7jpJBuCWpp1rV4v1eMGUBdZJrZq6naosjfFofh2fQbFu1F4BZB10DqYSc5Ac4Gck3k3wVbRGxs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jTpG2mWD; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jTpG2mWD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 736FDC116B1;
	Fri, 28 Jun 2024 21:11:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1719609076;
	bh=XhEv8fwdZACCNVWBPNo7yZqRCS+Wc21X92zuNOcifjI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=jTpG2mWDgzmSIxBy40LEpfyYDlx0V7L+IRzDLkCQn9+KwXM8xHiNXC2Q0EccSzvVD
	 URKvVhgWrQBS0yqmUa0YpSCzNrJ659T3UA2UHgdjwygwDiPp+wTCKVLp50ILwrm828
	 gQPU6xgRQA3SZxay71zn5+3g4CC8RRGym/dh80Lv0UA31/vKDZ9AYG3gDLlxjzHd+Z
	 Bkwe+FDzJzhlrut9J/UMj3qgcDlIEBseh56g1p2sGzmi/HUYV4BiSvhNLXoApzpWOq
	 QkxjMa/rElY1HCo74bvaeg93ILa0uLroQV+VsOqweIFK9G/t+Z9/9iGG1bxkLkgkQ5
	 Agi8Zg7Saix/A==
From: Mike Snitzer <snitzer@kernel.org>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@hammerspace.com>,
	NeilBrown <neilb@suse.de>,
	snitzer@hammerspace.com
Subject: [PATCH v9 07/19] nfs/localio: fix nfs_localio_vfs_getattr() to properly support v4
Date: Fri, 28 Jun 2024 17:10:53 -0400
Message-ID: <20240628211105.54736-8-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20240628211105.54736-1-snitzer@kernel.org>
References: <20240628211105.54736-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This is nfs-localio code which blurs the boundary between server and
client...

The change_attr is used by NFS to detect if a file might have changed.
This code is used to get the attributes after a write request.  NFS
uses a GETATTR request to the server at other times.  The change_attr
should be consistent between the two else comparisons will be
meaningless.

So nfs_localio_vfs_getattr() should use the same change_attr as the
one that would be used if the NFS GETATTR request were made.  For
NFSv3, that is nfs_timespec_to_change_attr() as was already
implemented.  For NFSv4 it is something different (as implemented in
this commit).

[above header derived from linux-nfs message Neil sent on this topic]
Suggested-by: NeilBrown <neil@brown.name>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/localio.c | 48 +++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 39 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/localio.c b/fs/nfs/localio.c
index 0f7d6d55087b..fe96f05ba8ca 100644
--- a/fs/nfs/localio.c
+++ b/fs/nfs/localio.c
@@ -364,21 +364,47 @@ nfs_set_local_verifier(struct inode *inode,
 	verf->committed = how;
 }
 
+/* Factored out from fs/nfsd/vfs.h:fh_getattr() */
+static int __vfs_getattr(struct path *p, struct kstat *stat, int version)
+{
+	u32 request_mask = STATX_BASIC_STATS;
+
+	if (version == 4)
+		request_mask |= (STATX_BTIME | STATX_CHANGE_COOKIE);
+	return vfs_getattr(p, stat, request_mask, AT_STATX_SYNC_AS_STAT);
+}
+
+/*
+ * Copied from fs/nfsd/nfsfh.c:nfsd4_change_attribute(),
+ * FIXME: factor out to common code.
+ */
+static u64 __nfsd4_change_attribute(const struct kstat *stat,
+				    const struct inode *inode)
+{
+	u64 chattr;
+
+	if (stat->result_mask & STATX_CHANGE_COOKIE) {
+		chattr = stat->change_cookie;
+		if (S_ISREG(inode->i_mode) &&
+		    !(stat->attributes & STATX_ATTR_CHANGE_MONOTONIC)) {
+			chattr += (u64)stat->ctime.tv_sec << 30;
+			chattr += stat->ctime.tv_nsec;
+		}
+	} else {
+		chattr = time_to_chattr(&stat->ctime);
+	}
+	return chattr;
+}
+
 static void nfs_local_vfs_getattr(struct nfs_local_kiocb *iocb)
 {
 	struct kstat stat;
 	struct file *filp = iocb->kiocb.ki_filp;
 	struct nfs_pgio_header *hdr = iocb->hdr;
 	struct nfs_fattr *fattr = hdr->res.fattr;
+	int version = NFS_PROTO(hdr->inode)->version;
 
-	if (unlikely(!fattr) || vfs_getattr(&filp->f_path, &stat,
-					    STATX_INO |
-					    STATX_ATIME |
-					    STATX_MTIME |
-					    STATX_CTIME |
-					    STATX_SIZE |
-					    STATX_BLOCKS,
-					    AT_STATX_SYNC_AS_STAT))
+	if (unlikely(!fattr) || __vfs_getattr(&filp->f_path, &stat, version))
 		return;
 
 	fattr->valid = (NFS_ATTR_FATTR_FILEID |
@@ -394,7 +420,11 @@ static void nfs_local_vfs_getattr(struct nfs_local_kiocb *iocb)
 	fattr->atime = stat.atime;
 	fattr->mtime = stat.mtime;
 	fattr->ctime = stat.ctime;
-	fattr->change_attr = nfs_timespec_to_change_attr(&fattr->ctime);
+	if (version == 4) {
+		fattr->change_attr =
+			__nfsd4_change_attribute(&stat, file_inode(filp));
+	} else
+		fattr->change_attr = nfs_timespec_to_change_attr(&fattr->ctime);
 	fattr->du.nfs3.used = stat.blocks << 9;
 }
 
-- 
2.44.0

