Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795007805;
	b=tDLr6lvcaRxkwrRFr4vQenHWkKuD6IyckuvgQVqVm89CgkobTFvRNSC7eHBMufG0ri+6
	 Bp8Ilg+El5s/P9Jk+ax1CB+71VD6J2OeMpr5arulO5rxH1nOUA3exOU5+Aaqsy2XUHCZo
	 Gef01ntnQl/U/Xj4fVLgEnZnS7d18UtqXFOBoQrKkxx3nNAaTffxcuyGw4/FX/Q/J8BkJ
	 VF81KSEGd/HyiRjMNn00PLqil6ia/7kmURM36/62WVfEnXF8L661nsRX093EhyOPBoJkI
	 yEDtSaj88L1cYylSn03kHvmCB/I+By0EYlGGYVyFYEmL51g/QD3+fKfAyz5pevFv5vw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795007805;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=xFUxVJ82of+81BcfAiGTxodU+qDDLwr8zTrCgbO4Xf8=;
	b=WiRSZnWyeRN1eCfVER01pNtWkcy/3KwToCw8diI3CEjm0sz8jK87fQcGW2Bb8DIftBu5
	 f7ZCpbNHHx1cDxN7/CRBLDvvcDhJnLhu3Eg1u4dHKPh/QxXV4CvFPCnbDgd6VVw1+s6es
	 i3DnNmc/lD/h6sEAgL9Q20upvxhuIFkufwFORvU0gS9pufMYp9Nn9n78NogfP2VNLrUiT
	 d2bcs2S0ajv5b+1ZYyaqPOaYstWNBIMMo3AVpzs9ViRn/Huaxycl+fraydjRK6hqHNB2M
	 etoDycL8nxk/Aa+vXRSP0Ho659Inh6mL0sq5SMOiV+3GcMybNg+f/zVh3lUFZWo7ptg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NOImXiOd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3293B606A31C;
	Wed, 18 Nov 2026 13:16:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NOImXiOd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9D9241F000C4;
	Wed, 18 Nov 2026 13:16:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795007804;
	bh=xFUxVJ82of+81BcfAiGTxodU+qDDLwr8zTrCgbO4Xf8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=NOImXiOdmK3buFe/HDJTkxuqy8I/J9y0B8deC8iJnaAY4kBJ2UP3LKnWFsiW+k142
	 LvZWZZurckhrni1yamxVDfWkG1z+3q24u4GgvG14shWHLoPfRzMM6rbuL4LoDMOfPl
	 rU0geJ1TsW/8ZOieiUtrUvxpC7/xbl17VGdGVrSS2BZtNFg/pWMIHtqK2R5lUAtnkP
	 7ITVX3V7EQghyXnv3+If1Rf7GcIZ1EZHAppiz03PJLjJ5pPx0rQgDJ+hTVwwSygEOn
	 L6uMK3om2sXiOQbokqXRcO3+hcqC7AXHtM48iTDt7y2Jy5VoWSmbCBrivti6IIB4lI
	 3kSaG7UCTVcvg==
From: Christian Brauner <brauner@kernel.org>
Date: Wed, 18 Nov 2026 14:16:17 +0100
Subject: [PATCH 1/2] fs: reintroduce SB_I_MULTIROOT
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
Message-Id: <20261118-work-nfs-multiroot-v1-1-66e4458b7d32@kernel.org>
References: <20261118-work-nfs-multiroot-v1-0-66e4458b7d32@kernel.org>
In-Reply-To: <20261118-work-nfs-multiroot-v1-0-66e4458b7d32@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, Amir Goldstein <amir73il@gmail.com>, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-04696
X-Developer-Signature: v=1; a=openpgp-sha256; l=5696; i=brauner@kernel.org;
 h=from:subject:message-id; bh=evCel8Lfavk/ILfSiBOb7n+hcYCaBBgPt1nMiB4dWKE=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9XWp8cpbSKQfxkyeXBflL/7v/8NWCZOX1k3PZD8QnX
 JRgc1z0uaOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAikXcZGaZqaHw+/u30WvYc
 xh+ejJVvtOPff3SxKNq+K+fk0x1hzVWMDO0VpdasD44rrhD7fFJRJnvLVr5N6n+ldx+4fve+xO5
 tviwA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

On NFSv2 and NFSv3 ".." can walk out of a mount and out of a chroot as
well (again).

path_connected() makes ".." fail with ENOENT when the parent isn't
reachable from the root of the mount anymore. It was added in
commit 397d425dc26d ("vfs: Test for and handle paths that are
unreachable from their mnt_root") for directories that get renamed out
from under a bind mount. To avoid calling is_subdir() for every ".." it
takes a shortcut. If the root of the mount is the root of the superblock
every dentry is assumed to be reachable and the check is skipped.

That doesn't hold for nfs. By default the client shares a single
superblock between mounts of the same server filesystem, i.e. mounts
that report the same filesystem identifier and use the same mount
options. Those mounts can be of disjoint subtrees, e.g. two
subdirectories of one export. NFSv2 and NFSv3 provide no way to find
the common root of these trees so s_root is simply the root of whatever
subtree got mounted first. For that mount mnt_root == s_root and
path_connected() never calls is_subdir().

This was fixed in commit 95dd77580ccd ("fs: Teach path_connected to
handle nfs filesystems with multiple roots."). That added SB_I_MULTIROOT
which nfs raised on every superblock it might share, and
path_connected() stopped taking the shortcut for such superblocks.

When nfs was converted to the new mount api in commit f2aedb713c28
("NFS: Add fs_context support.") nfs_fs_mount_common() was rewritten
into nfs_get_tree_common() and the two lines raising SB_I_MULTIROOT got
lost on the way. The changelog doesn't mention it. Nothing else raised
the flag so from v5.6 onwards path_connected() took the shortcut for nfs
again.

Then commit 402dd2cf46b1 ("fs: remove the unused SB_I_MULTIROOT flag")
noticed that the flag was dead, named the fs_context conversion as the
commit that removed its last user, and removed the flag together with
the check in path_connected().

But the flag was only unused because the conversion had dropped it by
accident. Et voila, we're back in 2018. Mount two disjoint
subdirectories of the same export with vers=3 and without nosharecache:

    mount -t nfs -o vers=3 srv:/export/a /mnt/a
    mount -t nfs -o vers=3 srv:/export/b/sub /mnt/b

Both mounts share a superblock and s_root is the root of /mnt/a. A
process sits in /mnt/a/D1/D. Someone with write access to both trees
renames D into b/sub, either on the server, through another client or
through a mount of a common parent on the same client. For a rename on
the server it's enough that anyone looks up /mnt/b/D afterwards.
nfs_lookup() finds the cached directory inode and d_splice_alias()
moves the existing dentry under the root of /mnt/b.

Now ".." from the old working directory lands in /mnt/b which isn't
reachable from /mnt/a at all. That works from inside a chroot to /mnt/a
as well. And if the root of the export is mounted too and someone walks
down to b/sub through it then the root of /mnt/b gets spliced in below
it and ".." climbs all the way up to the root of the exported
filesystem.

This reproduces on v7.4-rc3 with a single ext4 filesystem exported by
knfsd and both subdirectories mounted over loopback. With this patch
applied ".." fails with ENOENT instead.

Only mounts whose root is s_root are affected, i.e. the subtree that got
mounted first and bind mounts of its root. Mounts with nosharecache get
their own superblock.

Reintroduce SB_I_MULTIROOT and raise it again in nfs_get_tree_common()
where nfs_fs_mount_common() used to raise it. Like before nfs raises it
on every superblock it may share, independent of the protocol version.
That means ".." on such superblocks always goes through is_subdir()
again.

Fixes: f2aedb713c28 ("NFS: Add fs_context support.")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/namei.c                     | 4 ++--
 fs/nfs/super.c                 | 2 ++
 include/linux/fs/super_types.h | 1 +
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index 925aeb63bfa1d..a08c93369f4f1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -822,8 +822,8 @@ static bool path_connected(struct vfsmount *mnt, struct dentry *dentry)
 {
 	struct super_block *sb = mnt->mnt_sb;
 
-	/* Bind mounts can have disconnected paths */
-	if (mnt->mnt_root == sb->s_root)
+	/* Bind mounts and multi-root filesystems can have disconnected paths */
+	if (!(sb->s_iflags & SB_I_MULTIROOT) && (mnt->mnt_root == sb->s_root))
 		return true;
 
 	return is_subdir(dentry, mnt->mnt_root);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 23292680adbd5..99e883e7a4890 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1315,6 +1315,8 @@ int nfs_get_tree_common(struct fs_context *fc)
 		error = nfs_get_cache_cookie(s, ctx);
 		if (error < 0)
 			goto error_splat_super;
+		if (!(server->flags & NFS_MOUNT_UNSHARED))
+			s->s_iflags |= SB_I_MULTIROOT;
 	}
 
 	error = nfs_get_root(s, fc);
diff --git a/include/linux/fs/super_types.h b/include/linux/fs/super_types.h
index 6ce105fe8359c..b09e8b2087252 100644
--- a/include/linux/fs/super_types.h
+++ b/include/linux/fs/super_types.h
@@ -359,5 +359,6 @@ struct super_block {
 #define SB_I_NOIDMAP	0x00002000	/* No idmapped mounts on this superblock */
 #define SB_I_ALLOW_HSM	0x00004000	/* Allow HSM events on this superblock */
 #define SB_I_NO_DATA_INTEGRITY	0x00008000 /* fs cannot guarantee data persistence on sync */
+#define SB_I_MULTIROOT	0x00010000	/* Multiple roots to the dentry tree */
 
 #endif /* _LINUX_FS_SUPER_TYPES_H */

-- 
2.53.0

