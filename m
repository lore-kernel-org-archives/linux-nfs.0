Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794822116;
	b=5Ev03nY4/0uSQ6H/ARijX1NCxcvNyjCBEAnIlYe1PYK4LbbHEblB5ZzpG22ojKEK3IQS
	 V3zAQ4Rr7cCC/zP88Xq7vGHC3a6YIrwZf59xAKxHRQp/8I+av11yF1wYE94WqrFR85KRO
	 N/PVKnyd033NIi1RPqWJ84o8yzhdYCHSOfuWr2DFcV2IcVFF1zwiVCjxDwzGCOnD3Gz2T
	 D1HaNhbMo9EUxjGcJhd4MQRPUVEz6gMKTwxqzCxRGmW+2VcPyM7C4UZipBiJPWoIXkqwf
	 Sz+nNJs0aXbRILgoMkfnDcA8QNw32M1B0a9CyCtrTXmtWClANat8e/TiKGXIktH5VNQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794822116;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=hXng9hYJH3diUcfIm+3EkeLNi/DrI5XwE9hJbmJZ9MI=;
	b=oUierVuHroArdb2avcHbgg00z1/++vjuSRFkaEhrt2R8Gh9cFowsD7nKYUNx1l6aBsv1
	 Ls/1ZJvVOdTnAQkm/k0LFdKjYZHovybI9Nt/4oWC52TDAxQcjK5zWTAnrVf/ZHilN3XVh
	 vHCstgcUlugf6yZKaY8FNZJw4aFamHtG7IZKUQ+DHfu/tqtNE5sWggMfS0zCPnCcA7629
	 iNbdpaozy/aQytQG0ArBTa6zUGSV7iUGa2cmBnTyJ0afkDWT39CO6dA7fsZw4fAh6WsAh
	 po6H9u4aoBp4rfILauspuhaC3beTYR0U4664m9br/ypLwVeu2yG7+ufwjAnIBED14+w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kzkbn6tP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3138C606A329;
	Mon, 16 Nov 2026 09:41:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kzkbn6tP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E5A231F000C5;
	Mon, 16 Nov 2026 09:41:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794822116;
	bh=hXng9hYJH3diUcfIm+3EkeLNi/DrI5XwE9hJbmJZ9MI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=kzkbn6tPB2bS/Zn/Pn5gXJRXwYUjckO+3EyZRv12Tme1m2pQkOlyS27Q2NJx0bLjq
	 iAF35/8jh5WK0aPjealgqEWqPtYQ2eIjwus2l7uEA6Rw6F/DzFARz9BZlmZeeRX4IA
	 a8T9Xm8NCDxJP3dX2atLlDz9ZBm8mqYBsqZVK7vDVaxJ/ohv+LFKZYXH6eS5lGqyub
	 cuo0dCjJOQ9Cm7L88ZJ23RQ4pRGG9KOeHzD56rkH8lmKmPt3M3ylorww7aaA+S2CPt
	 kiO/myHptFlIERKjXIXwXpMeNSX+FLQjdkTiW70P+l/3Lf4R8ggQC98SE8Kxc70N4V
	 A+Zhh9qKrjqLA==
Date: Mon, 16 Nov 2026 10:41:49 +0100
From: Christian Brauner <brauner@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jan Kara <jack@suse.cz>, Shakeel Butt <shakeel.butt@linux.dev>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, io-uring@vger.kernel.org, linux-block@vger.kernel.org, 
	linux-nvme@lists.infradead.org, linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
	linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, linux-nfs@vger.kernel.org, 
	stable@vger.kernel.org
Subject: Re: [PATCH 07/12] zloop: take freeze protection when recording write
 pointers
Message-ID: <20261116-biegen-flaute-flanke-cebddae97444@brauner>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
 <20261114-work-fs-frozen_writes-v1-7-f5ae61c898b1@kernel.org>
 <20261116064820.GB2964@lst.de>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20261116064820.GB2964@lst.de>

On Mon, Nov 16, 2026 at 07:48:20AM +0100, Christoph Hellwig wrote:
> Looks good:
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> Can we get some kind of debug check into vfs_setxattr to enforce
> callers have taken the write protection?

I considered that and decided against it becuase it will mean everyone
starts splatting which means everyone needs to get their act together by
7.5.

You might not have seen it but I sent out a bunch of bug reports for
subsystems that suffer from the same bug class but that need way more
invasive fixes than anything I'm doing here.

But I guess we can do it if we use the VFS_* macros which are compiled
out unless CONFIG_DEBUG_FS is set. This will still mean that syzbot will
start splatting at these subsystems. If we're fine with that I'm good to
go with this.

Fwiw, the check can't go into __vfs_setxattr(), __vfs_setxattr_noperm()
or __vfs_removexattr(). cap_inode_killpriv(), IMA and EVM call those
from ->write_iter() via file_remove_privs() and kiocb_start_write()
hides the freeze protection from lockdep for aio and io_uring. I have
not bothered to figure out why. Maybe you already know? In any case,
until that's fixed we can't place it there which means this doesn't
catch IMA/EVM at which point this patch becomes pointless.

So that kiocb_start_write() stuff needs to be sorted first by someone.
I'm about 300+ patches or more deep into various tree-wide cleanups. I'm
going to defer this as this seems minor to all the other sh*it that's
waiting to be cleaned up.

-- >8 --
Subject: [PATCH] fs: assert freeze protection for xattr and acl writes

Writing an xattr or a POSIX ACL modifies the filesystem but
vfs_setxattr() and friends leave freeze protection to the caller. Most
callers get it from mnt_want_write(). Some in-kernel callers forgot
about it. zloop and overlayfs are fixed earlier in this series and
ecryptfs and ksmbd have been reported. Christoph asked for a debug check
to catch the next one (cf. [1]).

So warn in __vfs_setxattr_locked(), __vfs_removexattr_locked(),
vfs_set_acl(), vfs_remove_acl() and set_posix_acl() if SB_FREEZE_WRITE
isn't held. This only does something with CONFIG_DEBUG_VFS and lockdep.
Without lockdep sb_write_started() can't tell and claims it's held.
Until ecryptfs and ksmbd are fixed this will warn for them.

Note that __vfs_setxattr(), __vfs_setxattr_noperm() and
__vfs_removexattr() don't get the check. They're also called from
->write_iter() via file_remove_privs() -> notify_change() for
security.capability and by IMA and EVM. aio, io_uring and the in-kernel
async writers call kiocb_start_write() which hides the freeze protection
from lockdep before ->write_iter() is called. So the check would fire
for writes that are perfectly fine.

[1]: https://lore.kernel.org/r/20261116064820.GB2964@lst.de

Suggested-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/posix_acl.c | 6 ++++++
 fs/xattr.c     | 4 ++++
 2 files changed, 10 insertions(+)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index fe77934ea8f20..61de6f105ff4f 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -942,6 +942,8 @@ set_posix_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
 {
 	struct inode *inode = d_inode(dentry);
 
+	VFS_WARN_ON_ONCE(!sb_write_started(inode->i_sb));
+
 	if (!IS_POSIXACL(inode))
 		return -EOPNOTSUPP;
 	if (!inode->i_op->set_acl)
@@ -1099,6 +1101,8 @@ int vfs_set_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
 	struct inode *inode = d_inode(dentry);
 	struct delegated_inode delegated_inode = { };
 
+	VFS_WARN_ON_ONCE(!sb_write_started(inode->i_sb));
+
 	acl_type = posix_acl_type(acl_name);
 	if (acl_type < 0)
 		return -EINVAL;
@@ -1220,6 +1224,8 @@ int vfs_remove_acl(const struct mnt_idmap *idmap, struct dentry *dentry,
 	struct inode *inode = d_inode(dentry);
 	struct delegated_inode delegated_inode = { };
 
+	VFS_WARN_ON_ONCE(!sb_write_started(inode->i_sb));
+
 	acl_type = posix_acl_type(acl_name);
 	if (acl_type < 0)
 		return -EINVAL;
diff --git a/fs/xattr.c b/fs/xattr.c
index 0705801a62cc5..715d04111c274 100644
--- a/fs/xattr.c
+++ b/fs/xattr.c
@@ -302,6 +302,8 @@ __vfs_setxattr_locked(const struct mnt_idmap *idmap, struct dentry *dentry,
 	struct inode *inode = dentry->d_inode;
 	int error;
 
+	VFS_WARN_ON_ONCE(!sb_write_started(inode->i_sb));
+
 	error = xattr_permission(idmap, inode, name, MAY_WRITE);
 	if (error)
 		return error;
@@ -564,6 +566,8 @@ __vfs_removexattr_locked(const struct mnt_idmap *idmap,
 	struct inode *inode = dentry->d_inode;
 	int error;
 
+	VFS_WARN_ON_ONCE(!sb_write_started(inode->i_sb));
+
 	error = xattr_permission(idmap, inode, name, MAY_WRITE);
 	if (error)
 		return error;

-- 
