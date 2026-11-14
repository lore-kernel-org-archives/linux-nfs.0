Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794653309;
	b=nP0NqFhi2alKIOhJzigoIe7+J83APgeZMh343QBL7cbZv/nbFhiFH6VpzDbs0lJZLB+8
	 ShUmDR14unM4Kzj+A1onWRgf6iuS3s8djU5aiUT04K1i6MP43WF1UfdWkQuKBSakMqD/C
	 Za3s6cEZfj/1nWDfMhKHfiNtvxPGui8cyphx243NwD3RZetIRkPVPhbHt+LN7LA0o4jHG
	 C1tAH89I0hLDhIRBTysGjJPUrF8gv8RJxdsajQsjbsNzM+rAaf+mQNmt6CvZDkc0sBNEs
	 5SHl2jpJ9QkA8iXW26ARtBHXUUcQeme85bOUhhEkWIbPDCKbEl4bf5ElPDIOsXtnZbA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794653309;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=iQwkLUdwk9b1HJi0bdxPWAy3VpDyPS0j6oQB4RnL5Xk=;
	b=BohOTlZuTojnmd0CHjzVlXfwitFtBalvuGtRWSq1IR0SZEVwZGR1oh7Brg+jC6QC7/U6
	 zRMSIsczqof1gsR+4EYNGAPKW2NN8x01M+n2f2q78J/SlxI6THlEFGLJHjD7fgBRq6v0j
	 8oB58UMqOJX4OrTX1CpBOCHQQn/H4MMiiYC4AqWnKYvqozRx2cRBPtkbrKDMRFHILpr5+
	 9DBIg8WFMWxpwLCpwihTWrh0fYtoFLzobXOfvJHZh5UA5/A872bqe40bHr4VFOT2OVCJn
	 N/LRVtA+SgnB4zDHRZjp15U12b7gGGaiGbOdVVs/M8X702rXqx/4dYMa2xd6cooGqqA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MyzSjZUO;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 59820606B480;
	Sat, 14 Nov 2026 10:48:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MyzSjZUO
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BA93F1F000CA;
	Sat, 14 Nov 2026 10:48:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794653309;
	bh=iQwkLUdwk9b1HJi0bdxPWAy3VpDyPS0j6oQB4RnL5Xk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=MyzSjZUOCkMqwxukt7VaN8gXMiyrREHVgk7OzhnKZrckM70GdKU0qKv0ZdSIzFibC
	 yNcLtgXFEvmLUsACo8/r+ztOlzJz8cPTG/DCDh937l1neOIu2FA9j+VHULxaGnCtHg
	 0T9ACOHXxLignGRROXSQjTsvGu0Qb1iGpVIubsBdkySUjzk8XrPTog/rAj/PC6UB+J
	 xG43+/AfvXWWOICfcVJzbfCPpDTg5CJBRutpyyA/rPh6x2ZxNwApnq6erC/obarzbS
	 jHSE/28xzSlM6Wt6gJiej9FY4WsX2tKG/6XvI+Cj3E/5fiCfP4MZQ6royiIq4JfkMp
	 BEvUvjlVOkAOA==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 11:47:18 +0100
Subject: [PATCH 11/12] bpf: fs/xattr: take freeze protection in the xattr
 kfuncs
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
Message-Id: <20261114-work-fs-frozen_writes-v1-11-f5ae61c898b1@kernel.org>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
In-Reply-To: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeel.butt@linux.dev>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
 io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
 linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
 linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
 linux-nfs@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1908; i=brauner@kernel.org;
 h=from:subject:message-id; bh=NJMGFUseCC73mMaQQ+G2n/tqmaWyJnxTdoOaGvDxcf8=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9sPHs5s9Yy7JGu+PbiikBc887ptxsqtO8JJWkmljwK
 tz/8zLPjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgInoGzD8T935Qvmx/6oghZhf
 19yWiKhOsDtolrNzK8vuHbziS35fl2P4p5k9W/TL4pTyC1w+mnf19U/cb9Y+b2iuenxBT+bLb3f
 F+AE=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

bpf_set_dentry_xattr() and bpf_remove_dentry_xattr() go through
__vfs_setxattr() and __vfs_removexattr() which leave freeze protection
to the caller. BPF LSM programs call them from sleepable hooks such as
file_open where nobody holds it. So a program can modify a frozen
filesystem.

The hook may already hold freeze protection or locks a frozen
filesystem would make us wait under. So don't wait for a thaw. Fail
with -EBUSY if the filesystem is frozen.

The _locked variants are only used from hooks that run inside setattr,
setxattr, removexattr, unlink and rmdir. Their callers hold freeze
protection already.

Fixes: 56467292794b ("bpf: fs/xattr: Add BPF kfuncs to set and remove xattrs")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/bpf_fs_kfuncs.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/bpf_fs_kfuncs.c b/fs/bpf_fs_kfuncs.c
index 35ccd98a4de64..7f61e2efa08ba 100644
--- a/fs/bpf_fs_kfuncs.c
+++ b/fs/bpf_fs_kfuncs.c
@@ -295,9 +295,13 @@ __bpf_kfunc int bpf_set_dentry_xattr(struct dentry *dentry, const char *name__st
 	if (!inode)
 		return -EINVAL;
 
+	/* The hook may hold locks or freeze protection already. */
+	if (!sb_start_write_trylock(inode->i_sb))
+		return -EBUSY;
 	inode_lock(inode);
 	ret = bpf_set_dentry_xattr_locked(dentry, name__str, value_p, flags);
 	inode_unlock(inode);
+	sb_end_write(inode->i_sb);
 	return ret;
 }
 
@@ -323,9 +327,13 @@ __bpf_kfunc int bpf_remove_dentry_xattr(struct dentry *dentry, const char *name_
 	if (!inode)
 		return -EINVAL;
 
+	/* The hook may hold locks or freeze protection already. */
+	if (!sb_start_write_trylock(inode->i_sb))
+		return -EBUSY;
 	inode_lock(inode);
 	ret = bpf_remove_dentry_xattr_locked(dentry, name__str);
 	inode_unlock(inode);
+	sb_end_write(inode->i_sb);
 	return ret;
 }
 

-- 
2.53.0

