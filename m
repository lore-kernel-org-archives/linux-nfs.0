Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F37F047DD72;
	Thu, 24 Sep 2026 12:25:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790252725; cv=none; b=fmwx+ZVCKkWgrM2yCTZAqtdPF2dKgTG430eUPrBU1L4DFlUmeBMgUUBX6XlxFVbE6+Mmc0TC0bB6L29lgjAhOmzXC7wy6689fGb4BmDlE1lb2dzCWWMF9CvdwtKqsqd6GwCR/GPdBN6gbnVVzNxYZ1f6+gwNZ+2n/H+BsrFXS3U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790252725; c=relaxed/simple;
	bh=01i9WejsLdiMX6G/FL2digLaVsJEX/S7apwqrd48yoc=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=CLvWg3t5ZLMY5MTIQhQEyJQ831gCwbWHNyAFBfdR5m+TJcpZIBnFv7qwmVdtfDnWhRAq5sWzCMQi/pjgZyD0ix57ra6lg13nXjpZPewW/+MjfUpvVLFvs2DD4NwI32B9yjQXUUHXLB2eBGzunlwnpThVNCh0Z1DluFUxl22xw+k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=d1OYfSDc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="d1OYfSDc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1C15C1F000FF;
	Thu, 24 Sep 2026 12:25:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790252723;
	bh=i1wc7mco9mhAsE81iNGHYJRTKDBGIOxL8y/hhOoeRqI=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=d1OYfSDcHGlPiGc5qF/mIK/jytBkjw5fGcsDZ1VUx+sv/BotsB4Gbwoq1cu7hUHCd
	 ebi8x0Hi/vuszK/DnAaLZk6mhEUDFEcHPC3yt3vtvrzVu9FctxDsOJaD31ODnZf5lb
	 ChvfGllTDpJYWfZ6LAmSYV9RHkzL63m2ZXjB1UST6QlBfGLODN1Vn7mfuzvgD+Tqwb
	 uOwti8ANNX6yqa7JVdZHU6t9bIe3VR5EFA0SlzU3i4sgG0iQcyr+Ov3Mp3e8sOtJVK
	 x0uTMHrBXBWk97skEgLp6ymm0kjxfhmUVoGVe9ti8T4e6hOqZx1ErzkYIDvdNwn3j5
	 d0I/Yf/N8Sa0A==
Message-ID: <0880c8baea48edbca372bd54060000b27dd5fcbb.camel@kernel.org>
Subject: Re: [PATCH v2 01/14] VFS: revise and expand documentation for
 atomic_open.
From: Jeff Layton <jlayton@kernel.org>
To: NeilBrown <neil@brown.name>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner
	 <brauner@kernel.org>, Chuck Lever <cel@kernel.org>, Jori Koolstra
	 <jkoolstra@xs4all.nl>, Mateusz Guzik <mjguzik@gmail.com>, Dorjoy Chowdhury
	 <dorjoychy111@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Andreas Gruenbacher	 <agruenba@redhat.com>, gfs2@lists.linux.dev, Ilya
 Dryomov <idryomov@gmail.com>,  Alex Markuze <amarkuze@redhat.com>,
 Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org,  Paulo
 Alcantara	 <pc@manguebit.org>, Namjae Jeon <linkinjeon@kernel.org>, 
	linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	linux-nfs@vger.kernel.org
Date: Thu, 24 Sep 2026 08:25:20 -0400
In-Reply-To: <20260919022441.3305170-2-neilb@ownmail.net>
References: <20260919022441.3305170-1-neilb@ownmail.net>
	 <20260919022441.3305170-2-neilb@ownmail.net>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Sat, 2026-09-19 at 12:06 +1000, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
>=20
> atomic_open is a complex operation which different filesystems implement
> quite differently.  The available documentation doesn't give clear
> guidance on how it should be implemented.
>=20
> nfsd has a particular need to open only regular files, but to get
> precise information about what was found if it wasn't a regular file.
> This is slightly different to the syscall calling needs.  In particular
> it suggests that __O_REGULAR shouldn't always result in -EFTYPE.
>=20
> In any case that does involve creating open state, using
> finish_no_open() is simplest as it reduces the need to check
> __O_REGULAR, O_DIRECTORY, O_NOFOLLOW.
>=20
> So refresh the documentation to give guidance on the choice between
> finish_no_open, finish_open, and an error.  Efficiency always wins, but
> when that isn't an issue, prefer finish_no_open().
>=20
> Also clarify the required behaviour when __O_REGULAR is given.  This
> should return -EISDIR if a directory is found as nfsd needs this.  If a
> symlink is found then __O_REGULAR does NOT apply: O_NOFOLLOW must be
> used to decided if it is safe to not return the looked-up dentry.
>=20
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  Documentation/filesystems/vfs.rst | 67 ++++++++++++++++++++++++++-----
>  fs/namei.c                        |  3 ++
>  2 files changed, 59 insertions(+), 11 deletions(-)
>=20
> diff --git a/Documentation/filesystems/vfs.rst b/Documentation/filesystem=
s/vfs.rst
> index d3a93eec3945..00ada8cc85ae 100644
> --- a/Documentation/filesystems/vfs.rst
> +++ b/Documentation/filesystems/vfs.rst
> @@ -599,17 +599,62 @@ otherwise noted.
> =20
>  ``atomic_open``
>  	called on the last component of an open.  Using this optional
> -	method the filesystem can look up, possibly create and open the
> -	file in one atomic operation.  If it wants to leave actual
> -	opening to the caller (e.g. if the file turned out to be a
> -	symlink, device, or just something filesystem won't do atomic
> -	open for), it may signal this by returning finish_no_open(file,
> -	dentry).  This method is only called if the last component is
> -	negative or needs lookup.  Cached positive dentries are still
> -	handled by f_op->open().  If the file was created, FMODE_CREATED
> -	flag should be set in file->f_mode.  In case of O_EXCL the
> -	method must only succeed if the file didn't exist and hence
> -	FMODE_CREATED shall always be set on success.
> +	method the filesystem can look up, create, truncate, and open
> +	the file in one atomic operation.  This is needed if the
> +	filesystem content can be changed asynchronously and
> +	specifically if a negative dentry is not a guarantee that the
> +	object doesn't exist.  It is also useful if it is possible to
> +	perform combinations of revalidate, lookup, create, open, and
> +	truncate more efficiently what with a sequence of individual
> +	operations.
> +
> +	If the object found is not a file or directory, or if
> +	lookup/create succeeded without establishing any "open" state,
> +	then finish_no_open() should be called to confirm that the
> +	dentry is ready to be handled by normal VFS processing.
> +	FMODE_CREATED should be set in the "file" if the object was
> +	created, and this will prevent further access permission checks,
> +	or handling of O_TRUNC and O_EXCL.
> +
> +	If the lookup/create operation established some open state for a
> +	file or directory, the open should be completed by calling
> +	finish_open().  Passing NULL as the "open" function to
> +	finish_open() is unlikely to be useful as that assumes that no
> +	open state has been established.
> +
> +	atomic_open() may generate errors related to O_DIRECTORY,
> +	__O_REGULAR, O_EXCL, O_NOFOLLOW but is not required to as the
> +	caller will check those against the resulting dentry and
> +	generate any error needed, possibly closing the file if it was
> +	opened by finish_open().  atomic_open() is encouraged to handle
> +	these flags only when doing so is more efficient than not.
> +
> +	If __O_REGULAR is handled, it should generate -EISDIR if the
> +	name is known to be a directory or -EFTYPE if it is some other
> +	non-regular file other than a symbolic link.  Handling of a
> +	symbolic link should be guided by O_NOFOLLOW, not __O_REGULAR:
> +	-ELOOP can be return if O_NOFOLLOW is set, otherwise the symlink
> +	should be returned through finish_no_open().
> +
> +	The focus for atomic_open() is to provide the correct dentry and
> +	to set FMODE_CREATED as accurately as possible.  If O_EXCL was
> +	set, FMODE_CREATED should only be set if this operation
> +	certainly created the object.  If O_EXCL was not set,
> +	FMODE_CREATE should be set if it is possible that this operation
> +	created the object.
> +
> +	This method is only called if the last component is negative or
> +	needs lookup.  Cached positive dentries are still handled by
> +	f_op->open().
> +
> +	If the dentry provided is negative (not in-lookup) and O_CREAT
> +	isn't set, then there is no guarantee of exclusive access to the
> +	dentry - another thread might call ->atomic_open() on the same
> +	dentry at the same time.  If needed a filesystem can ensure this
> +	doesn't happen by returning 0 from ->d_revalidate when that is
> +	called with LOOKUP_OPEN on a negative dentry.  This will ensure
> +	that ->atomic_open() only receives an in-lookup dentry, which
> +	always ensures exclusive access.
> =20
>  ``tmpfile``
>  	called in the end of O_TMPFILE open().  Optional, equivalent to
> diff --git a/fs/namei.c b/fs/namei.c
> index d95249dd527c..0f69abb3743b 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -5007,6 +5007,9 @@ static struct file *path_openat(struct nameidata *n=
d,
>  		error =3D -EINVAL;
>  	}
>  	fput_close(file);
> +	if (error =3D=3D -EISDIR &&
> +	    (op->open_flag & __O_REGULAR))
> +		error =3D -EFTYPE;
>  	if (error =3D=3D -EOPENSTALE) {
>  		if (flags & LOOKUP_RCU)
>  			error =3D -ECHILD;
>=20
> base-commit: 9189e6a6f89e32d3a604b221ea64e67e1a35957c

It just keeps growing! But on a more serious note, it's better to have
more clear verbiage here.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
