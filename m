Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FA44344D8B
	for <linux-nfs@vger.kernel.org>; Sat,  8 Aug 2026 16:34:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786206900; cv=none; b=FaQ1GZtexx30X/+h0OaqHsqRREOPNo3miTFJ5kZr5/gBxBKQPbOsnz1nWFBrszQo4s3pnOlkXjx3GxfG1h1Mf7OQb+A1RZWVYJpT26mHYMkpAQQT4G6Xws4jF+Dmb8JJa0qj0m4Ai3hRi2FMkk9c+zTrZ5R0wf/ER7hc5iT4emA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786206900; c=relaxed/simple;
	bh=DUWT1fjlQUtMfWbII/5c0wp/FRMCqV7z9cBiVi/lHNI=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=tPtdCYKVdEvaOf8377NAwjsZfMoRC9LPFR/vNGnP0GRNWk56dfD4PqscEApFir23BdoFSRaXjgt3E+At0rKJys9lgGHuBhaBO8rXLdyxYKR9Hb+iEdPUS1SBhb1jlDnIRFL5iKUYlr+xPO4VLG5Ka2HIEE6S+1D64At0RmwTHXY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LLRkswvG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LLRkswvG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 26E4C1F00A3A;
	Sat,  8 Aug 2026 16:34:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786206898;
	bh=qDprKWiGHEY28u6TBB5ZrGg7uWSo6mCWnvalmRWKgLY=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=LLRkswvGc416UN6XydlGeBMPAh0bsSedYCOknRHiADG+RFmhfzCfr32ewuaxH7i9n
	 ao08BOEfz2wx5swl4OfsyOpcNxh3bOiLV+0M7aYyIuxQ8nede0CMWKQ7Pji1m7Ys+Y
	 uGL2j2Mm+Q1Ftze2xg+j0Q1ZF5RR/0NmCyV58TpRXqp+E/XtHeNudDIHnk67bJNPxd
	 OSTT+KwvUq+Z3MOg0Emqe+P+Wfj8seoO6KX3ac7pH38zP0FrGeH7cUOhXXRPkQfPiq
	 I67a9GSso4JxD/ONqQFW1nFIeGK/0PC+CenILtt9WgS4eNmruJGk3EHa3kBCjAyHfZ
	 9mnhQ+UUA4/9w==
Message-ID: <c887ed23d456542f97168ffeda4abb5d55ba0fa6.camel@kernel.org>
Subject: Re: [PATCH v2] nfs: fix ENXIO on O_CREAT open of existing symlink
 over NFSv3
From: Trond Myklebust <trondmy@kernel.org>
To: Michael Nemanov <michael.nemanov@vastdata.com>, anna@kernel.org, 
	neil@brown.name
Cc: linux-nfs@vger.kernel.org
Date: Sat, 08 Aug 2026 12:34:57 -0400
In-Reply-To: <20260806131358.398096-1-michael.nemanov@vastdata.com>
References: <20260806131358.398096-1-michael.nemanov@vastdata.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Thu, 2026-08-06 at 13:13 +0000, Michael Nemanov wrote:
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
> finish_no_open(file, NULL) so the VFS follows the symlink through the
> normal open path. NULL is passed because nfs_do_create() instantiates
> the inode on the dentry already owned by the caller; passing dentry
> back
> would cause atomic_open() to dput() it a second time.
> !S_ISREG() is used rather than S_ISLNK() to cover any other non-
> regular
> types a server might return.
>=20
> Changes in v2:
> - Pass NULL to finish_no_open() per Trond's feedback.
>=20
> Fixes: 7c6c5249f061 ("NFS: add atomic_open for NFSv3 to handle
> O_TRUNC correctly.")
> Link:
> https://lore.kernel.org/linux-nfs/20260614122911.3485467-1-michael.nemano=
v@vastdata.com/
> =C2=A0(v1)
> Signed-off-by: Michael Nemanov <michael.nemanov@vastdata.com>
> Tested-by: Michael Nemanov <michael.nemanov@vastdata.com>
> ---
> =C2=A0fs/nfs/dir.c | 7 +++++++
> =C2=A01 file changed, 7 insertions(+)
>=20
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index e9ce1883288c5..c3481d9c74334 100644
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

Hmm... I'm changing the above to "if (!d_inode(dentry) ||
!S_ISREG(....))" so that we don't inadvertently try to open a negative
dentry. That can happen with NFSv2 if we hit an existing directory that
has been renamed on the server.

> +				return finish_no_open(file, NULL);
> =C2=A0			file->f_mode |=3D FMODE_CREATED;
> =C2=A0			return finish_open(file, dentry, NULL);
> =C2=A0		} else if (error !=3D -EEXIST || open_flags & O_EXCL)

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
