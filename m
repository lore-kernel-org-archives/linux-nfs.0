Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 753F832A3DA
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 03:05:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788404712; cv=none; b=H4o0Xw9T4LESWbeTGd2vUVaTk108pgvfocPmhA10UbVX4AwhHAikSyEKi65qT8XVunePBgrwbP1qBn5CJRj0sLryLh/z5lZAPXfFiHQFlGiq6q6a2dbTXvxSJAZ4TeitvtMNDsxEngzwWgc4QEJzKDTshoJBg+U0EhRHsddPNMg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788404712; c=relaxed/simple;
	bh=uaguCkxOVO9IVzqr4gnjeWbaVqDvbplfpywozD6yR1g=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=N6pUAJWrfGjwJxAO96JgliO8lLJZUexHMDQawlKzcpJ/gT6cLfnAqCfQFOOpqq+H8L9OrR+fErdR2vbY5148OAChftRKgVh630LkZrbGx8wd4rraVjsU9nrPdQX0UH+iJ7MCTYYjOUEzRC9+7KUzfvawE66ngk1vmczAQT7WSvU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=annN4BIc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="annN4BIc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 55E581F000E9;
	Thu,  3 Sep 2026 03:05:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788404710;
	bh=fpUOfjVn9WpWb1wcXjffcslvbj6PGFeMzNqr03wDIyA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=annN4BIc0AXiwhdeWMm2gded5ueWIY4to20SGiSiKiPjo0aMhxzKqW2xBMI+JgaDu
	 kGJJ0LMGDSRo0xpgDDm9aQZiaRtLVXMAkg0pUlBoI/Hf4sIno25HiFSphTFqNVsyMz
	 ng+pi5LH4TvCYbgxKxb4tw2KHCVEqLDbu7awclS1bCYAz+xVwxlZNxzhQH3VNUbqJD
	 gSN6CfTAMS/uQv6kFToxom5IyiUmWGyM4cc2aNyFuSH40lB5mgWu1LVsLKRt7nXomr
	 7qReP4GiQvV6sd88BhAppHIH/CwpfzT9kcR/iWk081YFwFH4k+EYL5sSuhC0NPdYeG
	 fPo7gfOKiFG7g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5E5C8F40066;
	Wed,  2 Sep 2026 23:05:09 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 02 Sep 2026 23:05:09 -0400
X-ME-Sender: <xms:5eOYapXe7BOvP1vqSY93XB1WN29sMDPyLqAkjvpsN4hSADi-PudEcQ>
    <xme:5eOYakZ3v44mr98qy1EwDAHV8hlDU07Vr3N0E7K7ARNvtsEDs7DBGo7hn-lF8sL_0
    4RG4ajiAxNLADFOkFUeATJPtLqvIyR_LudoBssrl4Z-vA43alteTqc>
X-ME-Proxy-Cause: dmFkZTGgX89dtOQLdhk+AsX9Kx6VU25BnGdUQ0x5nh0wZT7Ss1R9gKR8lJ6guSwE+W+GZq
    5NzvUXzDkG5oSsp6P3RWLT0ZcmAyQt8gtCDG8z52ex43+N9QQrjVU4MVq3H71bYOGfBI0u
    gYGTze7wXTGu/r2gOllJCr+8OtCooJSFW1sbIf9Ag4L21E78cSF42aMDcilBFz9CLiWR6s
    L+8yY6uMTGUAlaQr/9JOv7wskHGaYleKPaUrqpRx0eyRZ4VvZ27TtiMPhQuG50zrGKQtcW
    SVt8comJ8VieH3ZjntllD+YqMc0epSEoEWjggrUT5Gu9gBGrtIoGoGUeuvbKusN5hkyQZt
    HxOsBo0I4w/m27Htcy2DcXGoyMDumwR6oWmTzCgPH55QjGkSfMuZM/+8PCVKulXcWkm/wa
    fyN0cp6ZhK0SNYPzn5oI8if/OOPIULxk8QkBckx30zwEQtDL2bSC0Q7pw+dqBvgbmQeWYR
    YFpAc0vTTYQXdM6gsszn4xquP8uZ0hdfFZB+kW3CXh8GVZg+n2Nnajp8m7Lul9MkWBHiOE
    BYZQ6ZHlMicGy8oO7uX8yIneu9EE3bNgaXoknQh5AnJt9EngUvjIlwMfiUlVku0rhTdOcQ
    uJf/eCEYplWYd3RBf4+2sKUY5jsK8ppwPPhp85gwnyUHw8D9heRGjYdl50SQ
X-ME-Proxy: <xmx:5eOYau5rx__LQMOcsI4ZOa8xPmBQfELqoX5Kuwos8_1U9O-jpbzaqA>
    <xmx:5eOYapby6Xs6VoRyLiWWRSUPQuyZjRCRRq9j7ePWd-K8T4qBcANEtQ>
    <xmx:5eOYatjK7N2-T8EuNrZV87LDfmXdomnBz3nzN-ML448_Fd0vk39CLg>
    <xmx:5eOYaq_HLI8EiJEwc-oDJCI752CIG2QbT5cE3gVf9txNOtgXqJj0lA>
    <xmx:5eOYaoqHBV-vKJLu-kgF7-hd9MRdvmyZgjEYVO81ZUncL6LZXZ6meKHU>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 373667811F0; Wed,  2 Sep 2026 23:05:09 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Wed, 02 Sep 2026 23:04:49 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>, "Chuck Lever" <chuck.lever@oracle.com>,
 "Jeff Layton" <jlayton@kernel.org>
Cc: "Christian Brauner" <brauner@kernel.org>, linux-nfs@vger.kernel.org
Message-Id: <8212e77c-fced-476b-ba64-3b8defcc65ad@app.fastmail.com>
In-Reply-To: 
 <178831622346.3510150.10735958308429473076@noble.neil.brown.name>
References: <178831622346.3510150.10735958308429473076@noble.neil.brown.name>
Subject: Re: [PATCH] nfsd: switch nfsd4_open() to use vfs_lookup_open()
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

=E2=80=9Cnfsd: switch nfsd4_open() =E2=80=A6=E2=80=9D

IIUC the patch modifies nfsd4_create_file(), not nfsd4_open() ?

Several more issues below.

On Tue, Sep 1, 2026, at 10:30 PM, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
>
> The functionality that was recently gathered into do_lookup_open() is
> now available from the vfs as vfs_lookup_open().
>
> This implementation shares more code with syscall open paths and so us=
es
> some filesystem interfaces slightly more correctly.  It also takes the
> responsibility for locking out of nfsd so that planned changes can
> happen entirely in VFS code.
>
> One difference is that do_lookup_open() would use nfsd_check_obj_isreg=
()
> to get an error when the name exists but is not a regular file.
> vfs_lookup_open() uses slightly different error code, particularly
> returning -ENODEV when a device-special file is found.  So we need
> to map that error to -EFTYPE.
>
> Unfortunately vfs_lookup_open() doesn't allow O_LARGEFILE so we need
> to patch it to avoid a warning.
>
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/namei.c         |  2 +-
>  fs/nfsd/nfs4proc.c | 66 ++++++++++------------------------------------
>  2 files changed, 15 insertions(+), 53 deletions(-)
>
> This patch is against nfsd-test.  I would like it to land there so it
> best good nfsd testing over the coming weeks.

Since it touches fs/namei.c, Christian will want to take this through
the VFS tree. To get the testing you requested, I=E2=80=99ll have to mer=
ge the
VFS tree into nfsd-next / nfsd-testing when it is ready for exposure.
That might be a while.


> Thanks,
> NeilBrown
>
>
> diff --git a/fs/namei.c b/fs/namei.c
> index d95249dd527c..85fd5e8221e2 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -4632,7 +4632,7 @@ struct file *vfs_lookup_open(struct path *parent=
,=20
> struct qstr *last,
>  	int error =3D 0;
>=20
>  	WARN_ONCE(mode & ~S_IALLUGO, "mode must only have permission bits");
> -	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR=
),
> +	WARN_ONCE(open_flag &=20
> ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR|O_LARGEFILE),
>  		  "open_flag has unsupported flags");

Two subtle behavior changes here. Were these intentional?

A client sending mode 0040755 gets an inode created with S_IFSOCK|0755 a=
nd
trips this WARN_ONCE. The old code clamped the incoming mode with S_IALL=
UGO.

Looks like a GUARDED4 create over a non-regular name now returns NFS4ERR=
_EXIST.
The old code returned ISDIR or SYMLINK. Does this match NFSv3=E2=80=99s =
behavior? Should
the commit message provide a rational that this is intended, or is a type
check needed?


>  	mode |=3D S_IFREG;
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 33dc92d48ce0..ae70f7489d95 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -213,52 +213,6 @@ static inline bool nfsd4_create_is_exclusive(int=20
> createmode)
>  		createmode =3D=3D NFS4_CREATE_EXCLUSIVE4_1;
>  }
>=20
> -static struct file *do_lookup_open(struct path *parent,
> -				   struct qstr *name,
> -				   unsigned int oflags,
> -				   umode_t mode)
> -{
> -	struct file *filp =3D NULL;
> -	struct path path;
> -	struct dentry *child;
> -	int want_write_err =3D 0;
> -
> -	want_write_err =3D mnt_want_write(parent->mnt);
> -
> -	child =3D start_creating(&nop_mnt_idmap, parent->dentry, name);
> -	if (IS_ERR(child)) {
> -		filp =3D ERR_CAST(child);
> -		goto out;
> -	}
> -	path.mnt =3D parent->mnt;
> -	path.dentry =3D child;
> -
> -	if (d_really_is_positive(child)) {
> -		/*
> -		 * open the file so that we consistently have a valid
> -		 * op_filp and consequently a valid ->f_path.dentry.
> -		 */
> -		int err =3D nfsd_check_obj_isreg(child);
> -
> -		if (err)
> -			filp =3D ERR_PTR(err);
> -		else
> -			filp =3D dentry_open(&path, oflags, current_cred());
> -	} else if (!(oflags & O_CREAT)) {
> -		filp =3D ERR_PTR(-ENOENT);
> -	} else if (want_write_err) {
> -		filp =3D ERR_PTR(want_write_err);
> -	} else {
> -		filp =3D dentry_create(&path, oflags, mode, current_cred());
> -		child =3D path.dentry;
> -	}
> -	end_creating(child);
> -out:
> -	if (!want_write_err)
> -		mnt_drop_write(parent->mnt);
> -	return filp;
> -}
> -
>  /*
>   * Implement NFSv4's unchecked, guarded, and exclusive create
>   * semantics for regular files. Open state for this new file is
> @@ -390,13 +344,21 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct=20
> svc_fh *fhp,
>  		/* Might still succeed if no create is needed */
>  		oflags &=3D ~O_CREAT;
>=20
> -	open->op_filp =3D do_lookup_open(&parent,
> -				       &QSTR_LEN(open->op_fname,
> -						 open->op_fnamelen),
> -				       oflags,
> -				       open->op_iattr.ia_mode);
> +	open->op_filp =3D vfs_lookup_open(&parent,
> +					&QSTR_LEN(open->op_fname,
> +						  open->op_fnamelen),
> +					oflags,
> +					open->op_iattr.ia_mode);
>  	if (IS_ERR(open->op_filp)) {
> -		status =3D nfserrno(PTR_ERR(open->op_filp));
> +		int hosterr =3D PTR_ERR(open->op_filp);
> +
> +		/*
> +		 * NFS doesn't differentiate between device files and
> +		 * sock/fifo when reporting an error.
> +		 */
> +		if (hosterr =3D=3D -ENODEV)
> +			hosterr =3D -EFTYPE;
> +		status =3D nfserrno(hosterr);
>  		open->op_filp =3D NULL;
>  		if (status =3D=3D nfserr_noent && create_status)
>  			status =3D create_status;
>

Since NFSD threads now sleep on directory delegation recalls, if lookup_=
open()
passes a real delegated_inode, it waits in break_deleg_wait() and retrie=
s for
up to lease_break_time.

The old path called vfs_create(..., NULL), so the client got NFS4ERR_DEL=
AY
instead. NFSD needs to continue to work this way, otherwise a client can
cause all the NFSD threads to block.


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
