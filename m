Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3D1D3ACEE2
	for <linux-nfs@vger.kernel.org>; Wed,  5 Aug 2026 19:50:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785959434; cv=none; b=OxLdUgoWz7CYVR0MXbLrtf4ed6erlRMp8mLhGn1NtA5CHjTt55Xtba3vCqI53pAUEyrDr6cJWCAYnB43Hg2DkxrqjOT0b7pemZHFvdei+Q7J4yET+AH7t4OlgnSNjdZRLV6PpiOQWt4ZLr/RgxItFUj/yCDZEFCT6PP78WtmkKg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785959434; c=relaxed/simple;
	bh=JX8cy79pJlbjx72ImZcLdmJCGFZssRBLYMijoi1njUA=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=U7Tk2JSBzw+liF90JInXMQLYOu7g9BRWwHAxt6aTglrxp6pjA8XXy7+owF70WvADLi6hpkX6q9wM0m+E0RuKkmQDms/Ao35bXgjLm/t0IlYJvyGcPAE8nvb/reZ24Xn15j9Sv/sb4EyBVhnUHhCglrtXgJJDCnNKCC/zyrZ0cJc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VxYoBPu9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VxYoBPu9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 632B41F000E9;
	Wed,  5 Aug 2026 19:50:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785959432;
	bh=jSX9/++yPs+X44XwS0REM7OiQ0eoXeoF7h2koRRLdAo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=VxYoBPu96pW4qr+/gD4hV5QCQPpqTFjTJLHAmOmqEGDz+VOSzSmJt4MOpLKk5u1df
	 LExlHSm5YMS8peO8SKo7yRQAasdvUAVyyXmXDHoHiWQUAVt1FwafYfh2baqf4TDOGf
	 x+Ks8RopenzREQ1/nh6IcC9sgxcRTqY1LdadFCdVgwNvOFeH7g7cyzoGGW0vLAJmH3
	 +NK7mJ1Q/OZWnabIGmOYBtSNRrbyadKHdOA3Q7Ktr3LFBZ+tl4p/b4VJScWc23rrFB
	 na1l8215FHRND8I3808c8lGBSipnqSB7/Xwa8TYcPfo9qGFSRs3Pb5Cl6zIKZkyd6a
	 gBhCO/HfhGYqg==
Message-ID: <dc92eb66b8a78429eb81039fde982849e5ef6bee.camel@kernel.org>
Subject: Re: [PATCH] nfs: fix ENXIO on O_CREAT open of existing symlink over
 NFSv3
From: Trond Myklebust <trondmy@kernel.org>
To: Michael Nemanov <michael.nemanov@vastdata.com>, anna@kernel.org, 
	neil@brown.name
Cc: linux-nfs@vger.kernel.org
Date: Wed, 05 Aug 2026 12:50:31 -0700
In-Reply-To: <20260614122911.3485467-1-michael.nemanov@vastdata.com>
References: <20260614122911.3485467-1-michael.nemanov@vastdata.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Sun, 2026-06-14 at 12:29 +0000, Michael Nemanov wrote:
> When open(2) is called with O_CREAT on a path that already exists as
> a
> symlink, over an NFSv3 mount with a cold dcache, the kernel returns
> ENXIO instead of following the symlink to its target.
>=20
> Reproducer script (MNT is an NFSv3 mount, kernel is 7.1-rc6):
>=20
> MNT=3D/mnt/export
> ln -sf /tmp/target $MNT/mylink
> echo 3 | sudo tee /proc/sys/vm/drop_caches=C2=A0=C2=A0 # cold dcache
>=20
> python3 - <<'EOF'
> import os
> fd =3D os.open('/mnt/export/mylink', os.O_WRONLY | os.O_CREAT |
> os.O_APPEND, 0o666)
> os.close(fd)
> EOF
>=20
> Expected: success (follow symlink, open target)
> Actual:=C2=A0=C2=A0 OSError: [Errno 6] No such device or address
>=20
> The bug does not trigger when the dcache is warm (e.g. after a prior
> stat(2)), because lookup_open() then finds a positive dentry and
> skips
> atomic_open entirely, leaving symlink resolution to the VFS.
>=20
> Root cause:
> nfs_atomic_open_v23(), registered as inode->i_op->atomic_open for
> NFSv3, handles O_CREAT by sending a CREATE UNCHECKED RPC. As
> implemented in nfsd3_create_file() (fs/nfsd/nfs3proc.c) and as
> required
> by RFC 1813 (3.3.8), when the name already exists as a non-regular
> file
> the server returns NFS3_OK with the existing object's file handle
> rather
> than NFS3ERR_EXIST causing nfs_do_create() to return 0 with the
> dentry now pointing to a symlink.
> The code then unconditionally calls finish_open(), which dispatches
> through inode->i_fop->open(). Symlink inodes never have i_fop set =E2=80=
=94
> the
> VFS initialises it to &no_open_fops because POSIX requires open(2) to
> follow symlinks, never open them directly. no_open() returns -ENXIO.
>=20
> Fix:
> After nfs_do_create() succeeds, verify the returned inode is a
> regular
> file before calling finish_open(). If the object is not regular,
> return
> finish_no_open() so the VFS follows the symlink through the normal
> open path.
> !S_ISREG() is used rather than S_ISLNK() to cover any other non-
> regular types
> a server might return.
>=20
> Fixes: 7c6c5249f061 ("NFS: add atomic_open for NFSv3 to handle
> O_TRUNC correctly.")
> Signed-off-by: Michael Nemanov <michael.nemanov@vastdata.com>
> Tested-by: Michael Nemanov <michael.nemanov@vastdata.com>
> ---
> =C2=A0fs/nfs/dir.c | 7 +++++++
> =C2=A01 file changed, 7 insertions(+)
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index e9ce1883288c5..6c78b06dd8699 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -2317,6 +2317,13 @@ int nfs_atomic_open_v23(struct inode *dir,
> struct dentry *dentry,
> =C2=A0	if (open_flags & O_CREAT) {
> =C2=A0		error =3D nfs_do_create(dir, dentry, mode,
> open_flags);
> =C2=A0		if (!error) {
> +			/* With UNCHECKED mode, a server may return
> NFS3_OK for
> +			 * a pre-existing non-regular file (e.g. a
> symlink).
> +			 * Let the VFS handle it; calling
> finish_open() would
> +			 * hit no_open() and return -ENXIO.
> +			 */
> +			if (d_inode(dentry) &&
> !S_ISREG(d_inode(dentry)->i_mode))
> +				return finish_no_open(file, dentry);

This will cause the dentry to underflow the refcount. It needs to be
finish_no_open(file, NULL).

> =C2=A0			file->f_mode |=3D FMODE_CREATED;
> =C2=A0			return finish_open(file, dentry, NULL);
> =C2=A0		} else if (error !=3D -EEXIST || open_flags & O_EXCL)

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
