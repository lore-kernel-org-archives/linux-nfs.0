Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795022497;
	b=YIGcT0HVMG0hcAOBZMjbdgd8x0sAqCOEMsFzu0AjYpwnu6IV1oJpOB6/hEnnLm2ibvnq
	 trD5GYncCj09yjinzAUMc8/s0UxfHznZiMvw6dS65G5rnZbmhgakAvZov5YtvGi0RD7jF
	 QlTYyyPWoT2w2S+DiM/t4mFUwMUmadt0suLEjk0g6ac5DI2y0zdsDWBT0ZXmzfOPOvLo1
	 zUS2FdgQsh4Vy+WXH0p7/kyivtbDEY/D+GFS0K4pEly1dkFrSX4VyXOoZh1znad2U4o1S
	 nHIns0MGfPMBi58c1VC+TsIUuvjMOPeQYFNM0q2rdDHH+CZnu/2oAHK1hCClTJ0VLjA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795022497;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=VLI20SqQTUV+izL6bGiN91Pkgn48s3smOlPhk2XgdVY=;
	b=jIS12D9vu/gMYE4nkkwpBmc5fbDZ9Jkq25S7r5wvGFhA3vT1WlgXd5txskvuh/J0ySfo
	 q98HkdrgmUbhspCF72skslxlmCZ6IYWF70sBcRvNz77XVhgGPtV2UuvMfc7jSpvKAg7ay
	 Vbl+LkbDYPW3x2nCBqr9RLJ8O0Tb1XLK/1uJOiA2f/+hAXTFX5zM+LZRZU55kCahzmgGH
	 bv/LV2qm9bAt7TvWPZcOokQBQOyWLyV2Dp9kciFrElIw1aafEsE8JevOhAv+hshvOmNRq
	 y90pbld4Ap8WlheSSeP7a4qNogbfv3L3cmj1RJ23/SZpNNSDzNCd/dg3GYZlIaokqyw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EKSCcSKJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3623606A320
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 17:21:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EKSCcSKJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6F19C1F000C7;
	Wed, 18 Nov 2026 17:21:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795022497;
	bh=VLI20SqQTUV+izL6bGiN91Pkgn48s3smOlPhk2XgdVY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=EKSCcSKJw+i3veS6BZaZlbKZXP8cfAQvyZcTH/nspB7BUIuml5uPCEYDh5dmtwssV
	 k3SFQiGpUyowB7pxfQbDrA31khEoeHkKWsa5PgPdG/jhFTgAxnMtu7ULzqg+rjnaMj
	 gF0uk2V+0rhF70CjizvyVgXW1mut7zxgn6vnZLRhAy8iHos8UOGZAUfUwXa2cASZV3
	 rvPA4K0UuDiTkS1Ie1to1cAdEXwNOSzcJvVrglrMAS0p1LzFn5Shc/lbW4wRfqb/FR
	 cGIn5bdU4aP4KXFBu0qMtyEaPdyQkAj5PnC/F1rXqft3Zetwxf5Qlt2yRBwIrR2Lex
	 w79ViKYHNlQwA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id BCB48F40067;
	Wed, 18 Nov 2026 12:21:36 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Wed, 18 Nov 2026 12:21:36 -0500
X-ME-Sender: <xms:oN79ajaxcT9gL8dHMZ7XKuduoKxTnDPc1VrJK6EnxqGk3isY7n-hfg>
    <xme:oN79atPL9TWxgtqtIEDAssidCDYubRDUxOagDLRrKtRVuag9FFMkut7sQwD4xbte8
    Vn0gwHFbsxTaKRbtffS4YxBsuOa57SMD5lEtMsewps0z1YsMVU_O87A>
X-ME-Proxy-Cause: dmFkZTF4QZQ6CJCsz8TFY2okhta0umwviVF56T4+tgBrrdn+GTmNMl6dA1ROfTkbwYrOem
    UW8iEBWr2T0zXHaeRypSgE6+lK5+G3rPNAvQt7y+yU8X+6CHGUMV7BT4rldWo8GtRAPKWH
    rZ5DBPW70xu5TVqNkAFEtXRu5dHdCx2BB9EP40RlAKv10Ro25e5PU18QmcTuccOR3CKD9r
    RjH+R2AiRA5f+R8z3EZ2J955yBI/DTlLZemDL/73vhPxgL21q/BijvmVKiYSvuMkogxHGo
    CmBmonRy4Q2p3EQqUKC4QwkxTyb/vuQ3d7ctcXt+46MDBYI0l9TUL2IOWyZUGx08i0qbB3
    hczlE7rSDGQJvsgGKL9W1FICP3bgi/3wzeKMcFYVX5rux8zwGoeg2nQqg/m9PJbFRyI1fk
    344W67bHmc58JhXbNJI7tQrLkCEb5cIcJcdnfCqdeQr1QKz/K79I9TzVhVi5FZt9LJXv0o
    XEgxux5bOxVSSrLbBFz/lJ+yKStr2hdL9Ghyyk6tzbR6hXyZScWC8loM9cd2zWZt0iyynZ
    8svUcBMEAyTqdaaeITQG6Mvkgf134mkT/5X2sCqxSqBrtR8bvDOtCTPd3mmMwLQE2v/1Kh
    cGAqB/MCH1gwP5ninqUv2r+4aXRGnh9xfMzliuh3UbZvxrnujvPyoSZYZJOA
X-ME-Proxy: <xmx:oN79aoGYT7KWAwkc3Q1_BRxtcx473oidrmt5Y8kVZeWKbzoUGDlgJA>
    <xmx:oN79anVM1rw8K7TAcT1iqYk1vNGnDu6lWn3rFHBHkXFwygenxULrog>
    <xmx:oN79as8UjHVmJb0MX451DbyrDE3e8gz4E1wm6WthXuAc9WvXN7dpUA>
    <xmx:oN79as7mnFoXsRpAEQLlNNoODmO6o1QNU83lOOIG4n2G3tWjnkG9Ag>
    <xmx:oN79atkbjn_c7lOlb4NuSdTkHxB_U8pNsGefinDInrgmBjsx-qmjyclu>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 9A879B6006E; Wed, 18 Nov 2026 12:21:36 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AvFucsYTRhyJ
Date: Wed, 18 Nov 2026 12:20:03 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Christian Brauner" <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Jan Kara" <jack@suse.cz>, "Chuck Lever" <cel@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, "Amir Goldstein" <amir73il@gmail.com>,
 stable@vger.kernel.org
Message-Id: <82b7c5ed-5736-48f7-8f65-e7984ea140bb@app.fastmail.com>
In-Reply-To: <20261118-work-nfs-multiroot-v1-1-66e4458b7d32@kernel.org>
References: <20261118-work-nfs-multiroot-v1-0-66e4458b7d32@kernel.org>
 <20261118-work-nfs-multiroot-v1-1-66e4458b7d32@kernel.org>
Subject: Re: [PATCH 1/2] fs: reintroduce SB_I_MULTIROOT
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Christian,

On Wed, Nov 18, 2026, at 8:16 AM, Christian Brauner wrote:
> On NFSv2 and NFSv3 ".." can walk out of a mount and out of a chroot as
> well (again).
>
> path_connected() makes ".." fail with ENOENT when the parent isn't
> reachable from the root of the mount anymore. It was added in
> commit 397d425dc26d ("vfs: Test for and handle paths that are
> unreachable from their mnt_root") for directories that get renamed out
> from under a bind mount. To avoid calling is_subdir() for every ".." it
> takes a shortcut. If the root of the mount is the root of the superblock
> every dentry is assumed to be reachable and the check is skipped.
>
> That doesn't hold for nfs. By default the client shares a single
> superblock between mounts of the same server filesystem, i.e. mounts
> that report the same filesystem identifier and use the same mount
> options. Those mounts can be of disjoint subtrees, e.g. two
> subdirectories of one export. NFSv2 and NFSv3 provide no way to find
> the common root of these trees so s_root is simply the root of whatever
> subtree got mounted first. For that mount mnt_root == s_root and
> path_connected() never calls is_subdir().
>
> This was fixed in commit 95dd77580ccd ("fs: Teach path_connected to
> handle nfs filesystems with multiple roots."). That added SB_I_MULTIROOT
> which nfs raised on every superblock it might share, and
> path_connected() stopped taking the shortcut for such superblocks.
>
> When nfs was converted to the new mount api in commit f2aedb713c28
> ("NFS: Add fs_context support.") nfs_fs_mount_common() was rewritten
> into nfs_get_tree_common() and the two lines raising SB_I_MULTIROOT got
> lost on the way. The changelog doesn't mention it. Nothing else raised
> the flag so from v5.6 onwards path_connected() took the shortcut for nfs
> again.
>
> Then commit 402dd2cf46b1 ("fs: remove the unused SB_I_MULTIROOT flag")
> noticed that the flag was dead, named the fs_context conversion as the
> commit that removed its last user, and removed the flag together with
> the check in path_connected().
>
> But the flag was only unused because the conversion had dropped it by
> accident. Et voila, we're back in 2018. Mount two disjoint
> subdirectories of the same export with vers=3 and without nosharecache:
>
>     mount -t nfs -o vers=3 srv:/export/a /mnt/a
>     mount -t nfs -o vers=3 srv:/export/b/sub /mnt/b
>
> Both mounts share a superblock and s_root is the root of /mnt/a. A
> process sits in /mnt/a/D1/D. Someone with write access to both trees
> renames D into b/sub, either on the server, through another client or
> through a mount of a common parent on the same client. For a rename on
> the server it's enough that anyone looks up /mnt/b/D afterwards.
> nfs_lookup() finds the cached directory inode and d_splice_alias()
> moves the existing dentry under the root of /mnt/b.
>
> Now ".." from the old working directory lands in /mnt/b which isn't
> reachable from /mnt/a at all. That works from inside a chroot to /mnt/a
> as well. And if the root of the export is mounted too and someone walks
> down to b/sub through it then the root of /mnt/b gets spliced in below
> it and ".." climbs all the way up to the root of the exported
> filesystem.
>
> This reproduces on v7.4-rc3 with a single ext4 filesystem exported by
> knfsd and both subdirectories mounted over loopback. With this patch
> applied ".." fails with ENOENT instead.
>
> Only mounts whose root is s_root are affected, i.e. the subtree that got
> mounted first and bind mounts of its root. Mounts with nosharecache get
> their own superblock.
>
> Reintroduce SB_I_MULTIROOT and raise it again in nfs_get_tree_common()
> where nfs_fs_mount_common() used to raise it. Like before nfs raises it
> on every superblock it may share, independent of the protocol version.
> That means ".." on such superblocks always goes through is_subdir()
> again.
>
> Fixes: f2aedb713c28 ("NFS: Add fs_context support.")
> Cc: stable@vger.kernel.org
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
> ---
>  fs/namei.c                     | 4 ++--
>  fs/nfs/super.c                 | 2 ++
>  include/linux/fs/super_types.h | 1 +
>  3 files changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/fs/namei.c b/fs/namei.c
> index 925aeb63bfa1d..a08c93369f4f1 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -822,8 +822,8 @@ static bool path_connected(struct vfsmount *mnt, 
> struct dentry *dentry)
>  {
>  	struct super_block *sb = mnt->mnt_sb;
> 
> -	/* Bind mounts can have disconnected paths */
> -	if (mnt->mnt_root == sb->s_root)
> +	/* Bind mounts and multi-root filesystems can have disconnected paths */
> +	if (!(sb->s_iflags & SB_I_MULTIROOT) && (mnt->mnt_root == sb->s_root))
>  		return true;
> 
>  	return is_subdir(dentry, mnt->mnt_root);
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 23292680adbd5..99e883e7a4890 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1315,6 +1315,8 @@ int nfs_get_tree_common(struct fs_context *fc)
>  		error = nfs_get_cache_cookie(s, ctx);
>  		if (error < 0)
>  			goto error_splat_super;
> +		if (!(server->flags & NFS_MOUNT_UNSHARED))
> +			s->s_iflags |= SB_I_MULTIROOT;

I assume this is going through the VFS tree?

Acked-by: Anna Schumaker <anna.schumaker@hammerspace.com>

>  	}
> 
>  	error = nfs_get_root(s, fc);
> diff --git a/include/linux/fs/super_types.h 
> b/include/linux/fs/super_types.h
> index 6ce105fe8359c..b09e8b2087252 100644
> --- a/include/linux/fs/super_types.h
> +++ b/include/linux/fs/super_types.h
> @@ -359,5 +359,6 @@ struct super_block {
>  #define SB_I_NOIDMAP	0x00002000	/* No idmapped mounts on this 
> superblock */
>  #define SB_I_ALLOW_HSM	0x00004000	/* Allow HSM events on this 
> superblock */
>  #define SB_I_NO_DATA_INTEGRITY	0x00008000 /* fs cannot guarantee data 
> persistence on sync */
> +#define SB_I_MULTIROOT	0x00010000	/* Multiple roots to the dentry tree 
> */
> 
>  #endif /* _LINUX_FS_SUPER_TYPES_H */
>
> -- 
> 2.53.0
