Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795786080;
	b=rGMV2xrBHXW0VlBTbVkIzlnqiV0yIV9Jrx7Lrc7s0fevp8XgZhPleufilqgq750baSyt
	 pt0XKmYxsukfz4pWZxCXVpSry6W7xMVdGL7TCyKfz7QQuIP8j78JFD7/V4mLa3jBpLqpY
	 +RWywJ0TJP+5nIuUAhRjJKjhvfnQxBExdG7X3wt9zSFW4K2pElyO2viKh69kiBqKGS3wW
	 cplywD61IEv2iMbBRZcNO89oPJriv1Gk9yFEqsUKn+Iy1+5SKfNU4j+o+etctmapEFbnh
	 Ku1bRRoQZuqr2iwvtk8jma0uuczvYmwRXnHHVZL2l7LtSNSKFTtS4utZdwTrPJrx/sg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795786080;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=okZXC5I/K86cgvvij4oWErtnvy9kUT7CDkXwETxaVYw=;
	b=idaRbZYTb3MteNWmOLv14BVBLE/05b9YEq6Hoa19ERzwBq6q1Bt+9f/Vetop9tt5yZCS
	 qOuTMMIr6dOYRlQ+NJ8VIwAbziG7ki2vr/lZvBUX5uVDzMpXBrIhmMDo/Rwh+cw21OFgA
	 qY+dANVJdsPqoV2okkZuZGOq0YrEgUeSDasD9bV65Xj5sKWtT1kh9w6bTrK8IwOslUJ2W
	 +TE04J+r2jwhWzOMQkCqf4MqUnH3iql4mMgkcOzGmins7sD3msrGm/wLTh3EJonNQQPgp
	 4P+En4u+I5VaqT81zrFdwE09a/ujWUM4LwSbsBkaAS6vZLCjyfFwdM5/1Uoj7tjiZAA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=srMHe+8G;
	arc=none smtp.remote-ip=209.85.221.47
Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AEA7B606A324
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 13:27:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AEA7B606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=srMHe+8G
Received: by mail-wr1-f47.google.com with SMTP id ffacd0b85a97d-48dfc0421d9so7395656f8f.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 05:27:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795786078; x=1796390878; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=okZXC5I/K86cgvvij4oWErtnvy9kUT7CDkXwETxaVYw=;
        b=srMHe+8GPkHQSDd3GxXgXcH8alKFkin92CAhTHUF/v+NPyvAtHzktQBRvVwRoJ1bPR
         RIAEbIwfiWLs+k4gSXnXMGzUbdXiPVMFZ2Nq9k635sk6RSyDKje4LkGSPdfCWm3yMB2W
         RemSf9xew7mvYX8Dp6s1X95CBeQwK2Mz/UGwDGXd7jhcK2kkAmaWiqa6ucFxr+k3kPml
         ZqbCEmaAOJmGDloFw1pVe2ahNznLATSuHkTdCzL5FQSuP/dGhZ7tkOUpI5kcY0ddMLEb
         VCT239fQQBBaoa48c8LWCe9TVn2raJwxUUJbx3wp/cHBsMjU7yMk4RkhJwSw5ygjHbh7
         TuLg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795786078; x=1796390878;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=okZXC5I/K86cgvvij4oWErtnvy9kUT7CDkXwETxaVYw=;
        b=GLXeXNr9ZJEoIKfpR1DA/TD+br8p5b2QsWWEBHojFr+7JGpsayzp78YNzleqlz0yLa
         xjpXbacfAU7ggM8IpxXPMlFVfgeozfrClOB1Tg744PdWI7VHP3Opn40W3wCpt3Le30wf
         tNVeJx62ROYJgpibujtJYiBN4InDsroY2y1DMWqyk6ftteCAa1OoJqN5FBeX8MlXKm2E
         EX/N/ZZJk+dcYtFGZzYl34DKVdWQE0K29ic37kX6CdAJR6Lb0lEqLSae5s8SmniqUkH8
         hxxw9pInWUgtWi4jZd1QPLqwVkMZydmbbQZv30EiytC9ShCksrs7jOSmRg/Z+MV3C1L5
         y++A==
X-Forwarded-Encrypted: i=1; AL+hErEZuCXFPLOTrYLhDlG43R+GPGLGyf6WLphC/hO570w8FHG46pU/q3HfwagZ+TD97oXxp8h4GgI6DVc=@vger.kernel.org
X-Gm-Message-State: APuU4Z/29IfG2yV/NTRund1ho1vaFSJtJ1Lj57U1NJcMKDIXat5BH3CN
	yylNil9rSrQqJ+z4BEi2ECEkh/8cNQ/CMvhPyStmj8dYbrLj/qUwbjRM
X-Gm-Gg: AZFdTZe82ittHIh5Ctqe376AR2T90z6LEt5YRVBL1ReBHvh+2jGCJTYmGsgOJnAnPr9
	22eiTjUCy23XlonSiurAX1DBbrWOi8/e3hAADKWhapW76ZjxThx8CwxhmJLcHxBTplL6wE0ylr0
	jFFFRZwEGDzO8exZ0vAN9W1RD9EXDXTCVIhic6u9TQ602300rgZqn2+HzmML9fXEUBGfoPdY7MR
	lex8OQMC//UESuZHTwrochN7jp++0AoBPtqPk5rBURwwNbdR5jnKyNAt6pP0MExzaDoMUS1s5vg
	W+v82awtQRc+JsJ80txJg8UxNLTxMcYPlKN2Fd7YyTo100Mnk4Uj7MeAu9WXRfDFSqy4UisKCOW
	Dud2NSt6HG8LQBgD+jSKbH7REwlgXY1HhHB+v5dUCJaA627ojrNBOdge/FOSJgITT0bCKHtEAkd
	0b9kjUqRAAVur9eydEZHdpTTFgiARGBxmjreFh634dFWJbLnc/Iy2xDoULFPUnRP1/EmKJ9DuYo
	Eu3liUygbnqYg8unNpLgNKRp8OIilrnfcEduj425shK0vzl71sP9S0hSFHq48HuACXWNpUHtERa
	v/IACLT7q04yPFrY1w3NP401q6mTGmKHrwrGN78oU71vkDssCQdFQgvl3axO
X-Received: by 2002:a05:6000:4009:b0:4ab:7c3:101 with SMTP id ffacd0b85a97d-4abb514617emr50449630f8f.22.1795786077592;
        Fri, 27 Nov 2026 05:27:57 -0800 (PST)
Received: from localhost (mob-176-246-245-5.net.vodafone.it. [176.246.245.5])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab65cb42absm47951199f8f.1.2026.11.27.05.27.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 27 Nov 2026 05:27:56 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
Content-Type: multipart/signed;
 boundary=1f8dd9411e3204ed63cbc5af2d1a4dd06cdcf953434d520fb1bee6abdc83;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Fri, 27 Nov 2026 14:27:35 +0100
Message-Id: <DN6110Y4TV0X.12P1SWQPPC0GE@gmail.com>
Cc: "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>, "Jan
 Kara" <jack@suse.cz>, "Alexander Aring" <alex.aring@gmail.com>, "Darrick J
 . Wong" <djwong@kernel.org>, "Andrey Albershteyn" <aalbersh@kernel.org>,
 "Amir Goldstein" <amir73il@gmail.com>, =?utf-8?q?Pali_Roh=C3=A1r?=
 <pali@kernel.org>, "Lauri Gates" <lauri.gates@gmail.com>, "Christoph
 Hellwig" <hch@infradead.org>, "Dave Chinner" <dgc@kernel.org>,
 <linux-btrfs@vger.kernel.org>, <linux-xfs@vger.kernel.org>,
 <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
 <ntfs@lists.linux.dev>, <linux-nfs@vger.kernel.org>,
 <linux-api@vger.kernel.org>
Subject: Re: [PATCH v2 3/4] vfs: add xflags mask to fileattr API
From: "koraynilay" <koray.fra@gmail.com>
To: "koraynilay" <koray.fra@gmail.com>, "Namjae Jeon"
 <linkinjeon@kernel.org>, "Hyunchul Lee" <hyc.lee@gmail.com>, "Eric Biggers"
 <ebiggers@kernel.org>, "Theodore Y . Ts'o" <tytso@mit.edu>, "Jaegeuk Kim"
 <jaegeuk@kernel.org>, "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261126163114.403846-1-koray.fra@gmail.com>
 <20261126163114.403846-4-koray.fra@gmail.com>
In-Reply-To: <20261126163114.403846-4-koray.fra@gmail.com>

--1f8dd9411e3204ed63cbc5af2d1a4dd06cdcf953434d520fb1bee6abdc83
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Thu Nov 26, 2026 at 5:31 PM CET, koraynilay wrote:
> Add fa_xflags_rw_mask and fa_xflags_ro_mask to struct file_attr, both
> __u64 to match fa_xflags' size, and bump FILE_ATTR_SIZE_LATEST to
> FILE_ATTR_SIZE_VER1, which is now 40 bytes.
>
> Add equivalent masks and a has_masks selector to struct file_kattr, so
> we can know when a user of this API (userspace or filesystem) supports
> them.
>
> This lets filesystems advertise their support for specific xflags, like
> statx.stx_attributes_mask does, and userspace can specify only which
> xflags it wants to change without needing a RMW cycle.
>
> These masks have the following semantics:
> - fsx_xflags_rw_mask:
>   * for filesystems: advertise which xflags they support changing
>   * for userspace:   specify which xflags it wants to modify
> - fsx_xflags_ro_mask:
>   * for filesystems: advertise which xflags they support only reading
>   * for userspace:   ignored
>
> And they should be filled according to the following:
> - GET:
>   each filesystem that wants to implement this new API fills the masks
>   according to its supported read-write and read-only xflags,
>   then:
>   * for boolean xflags: it fills fsx_xflags with the current on-disk valu=
e;
>   * for value xflags: it sets the xflag bit to 1 in fsx_xflags and the
>     xflag value in the struct field;
> - SET:
>   userspace fills the rw_mask with the bits of the xflags it wants to
>   change, then:
>   * for boolean xflags: it provides the xflag value as a bit in fa_xflags=
;
>   * for value xflags: it sets the xflag bit to 1 in fa_xflags and then
>     provides the value in the struct field; if the xflag bit is set to 0
>     instead, this informs the kernel to unset/clear that value.
>
> Add AT_FILE_ATTR_MASKS at_flags option that userspace needs to pass
> (with usize >=3D FILE_ATTR_SIZE_VER1) in order to be able to use masks,
> otherwise legacy RMW semantics are used.
>
> If AT_FILE_ATTR_MASKS is not specified:
> - on GET, zero fa_xflags_rw_mask and fa_xflags_ro_mask and strip new
>   xflags added in or after VER1, so older programs doing RMW don't pass
>   them back;
> - on SET, reject non-zero fa_xflags_{rw,ro}_mask with -EINVAL.
>
> If AT_FILE_ATTR_MASKS is specified on SET with fa_xflags_rw_mask =3D 0,
> return early as a no-op after permission and support checks.
>
> To make both legacy and new programs interact correctly with both legacy
> and new/upgraded filesystems, add:
> - xflags_to_flags() / flags_to_xflags(): use fileattr_fill_*() to
>   convert xflags to their flags counterpart and vice-versa;
> - fileattr_set_mask_to_legacy() / fileattr_set_legacy_to_mask(): convert
>   between legacy read-modify-write API and modern rw_mask/ro_mask API.
>
> Also add the missing FS_XFLAG_PROJID xflag, to allow userspace to set
> the projid using file_[gs]etattr() by leveraging the new masks.
> In order to prevent the legacy FS_IOC_FSSETXATTR from accepting
> FS_XFLAG_PROJID, add a FS_FILE_ATTR_XFLAGS_MASK to support new xflags
> and use it to validate/clamp both the _xflags fields and the masks.
>
> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.11
> Signed-off-by: koraynilay <koray.fra@gmail.com>
> ---
>  fs/file_attr.c             | 332 +++++++++++++++++++++++++++++++++----
>  include/linux/fileattr.h   |   7 +
>  include/uapi/linux/fcntl.h |   6 +
>  include/uapi/linux/fs.h    |   7 +-
>  4 files changed, 320 insertions(+), 32 deletions(-)
>
> diff --git a/fs/file_attr.c b/fs/file_attr.c
> index 1687891c526c..35bc2ded2ff8 100644
> --- a/fs/file_attr.c
> +++ b/fs/file_attr.c
> @@ -74,6 +74,22 @@ void fileattr_fill_flags(struct file_kattr *fa, u32 fl=
ags)
>  }
>  EXPORT_SYMBOL(fileattr_fill_flags);
> =20
> +static u32 flags_to_xflags(u32 flags)
> +{
> +	struct file_kattr tmp =3D {};
> +
> +	fileattr_fill_flags(&tmp, flags);
> +	return tmp.fsx_xflags;
> +}
> +
> +static u32 xflags_to_flags(u32 xflags)
> +{
> +	struct file_kattr tmp =3D {};
> +
> +	fileattr_fill_xflags(&tmp, xflags);
> +	return tmp.flags;
> +}
> +
>  /**
>   * vfs_fileattr_get - retrieve miscellaneous file attributes
>   * @dentry:	the object to retrieve from
> @@ -102,13 +118,20 @@ EXPORT_SYMBOL(vfs_fileattr_get);
>  static void fileattr_to_file_attr(const struct file_kattr *fa,
>  				  struct file_attr *fattr)
>  {
> -	__u32 mask =3D FS_XFLAGS_MASK;
> -
>  	memset(fattr, 0, sizeof(struct file_attr));
> -	fattr->fa_xflags =3D fa->fsx_xflags & mask;
> +	/* Pass the masks to userspace if underlying fs uses them. */
> +	if (fa->has_masks) {
> +		fattr->fa_xflags_rw_mask =3D fa->fsx_xflags_rw_mask &
> +					   FS_FILE_ATTR_XFLAGS_MASK;
> +		fattr->fa_xflags_ro_mask =3D fa->fsx_xflags_ro_mask &
> +					   FS_FILE_ATTR_XFLAGS_MASK;
> +	}
> +	fattr->fa_xflags =3D fa->fsx_xflags & FS_FILE_ATTR_XFLAGS_MASK;
>  	fattr->fa_extsize =3D fa->fsx_extsize;
>  	fattr->fa_nextents =3D fa->fsx_nextents;
>  	fattr->fa_projid =3D fa->fsx_projid;
> +	if (fa->fsx_projid)
> +		fattr->fa_xflags |=3D FS_XFLAG_PROJID;
>  	fattr->fa_cowextsize =3D fa->fsx_cowextsize;
>  }
> =20
> @@ -141,15 +164,47 @@ EXPORT_SYMBOL(copy_fsxattr_to_user);
>  static int file_attr_to_fileattr(const struct file_attr *fattr,
>  				 struct file_kattr *fa)
>  {
> -	__u64 mask =3D FS_XFLAGS_MASK;
> +	u64 mask =3D fa->has_masks ? FS_FILE_ATTR_XFLAGS_MASK : FS_XFLAGS_MASK;
> =20
>  	if (fattr->fa_xflags & ~mask)
>  		return -EINVAL;
> =20
> -	fileattr_fill_xflags(fa, fattr->fa_xflags & ~FS_XFLAG_RDONLY_MASK);
> -	fa->fsx_extsize =3D fattr->fa_extsize;
> -	fa->fsx_projid =3D fattr->fa_projid;
> -	fa->fsx_cowextsize =3D fattr->fa_cowextsize;
> +	if (fa->has_masks) {
> +		u64 rw_user_mask =3D fattr->fa_xflags_rw_mask;
> +
> +		if (rw_user_mask & ~FS_FILE_ATTR_XFLAGS_MASK)
> +			return -EINVAL;
> +
> +		/*
> +		 * Pass xflags clamped to the rw_mask, so the rest of the code
> +		 * can assume that if a flag is not in fsx_xflags, it isn't
> +		 * being changed.
> +		 */
> +		fileattr_fill_xflags(fa, fattr->fa_xflags & rw_user_mask);
> +		fa->fsx_xflags_rw_mask =3D rw_user_mask;
> +
> +		/* Like stated in the comment above, no need to rw_mask check. */
> +		if (fa->fsx_xflags & (FS_XFLAG_EXTSIZE | FS_XFLAG_EXTSZINHERIT))
> +			fa->fsx_extsize =3D fattr->fa_extsize;
> +		else
> +			fa->fsx_extsize =3D 0;
> +
> +		if (fa->fsx_xflags & FS_XFLAG_PROJID)
> +			fa->fsx_projid =3D fattr->fa_projid;
> +		else
> +			fa->fsx_projid =3D 0;
> +
> +		if (fa->fsx_xflags & FS_XFLAG_COWEXTSIZE)
> +			fa->fsx_cowextsize =3D fattr->fa_cowextsize;
> +		else
> +			fa->fsx_cowextsize =3D 0;
> +	} else {
> +		fileattr_fill_xflags(fa,
> +				     fattr->fa_xflags & ~FS_XFLAG_RDONLY_MASK);
> +		fa->fsx_extsize =3D fattr->fa_extsize;
> +		fa->fsx_projid =3D fattr->fa_projid;
> +		fa->fsx_cowextsize =3D fattr->fa_cowextsize;
> +	}
> =20
>  	return 0;
>  }
> @@ -185,13 +240,23 @@ static int fileattr_set_prepare(struct inode *inode=
,
>  			      const struct file_kattr *old_ma,
>  			      struct file_kattr *fa)
>  {
> +	u32 rw_user_mask =3D fa->has_masks ?
> +			   fa->fsx_xflags_rw_mask : FS_FILE_ATTR_XFLAGS_MASK;
> +	u32 changed =3D 0;
>  	int err;
> =20
> +	/* Make sure that no filesystem ro flags have been passed as rw */
> +	if (fa->has_masks && (rw_user_mask & ~old_ma->fsx_xflags_rw_mask))
> +		return -EOPNOTSUPP;
> +
> +	/* Use the changed flags, clamped to only the requested ones. */
> +	changed =3D (fa->fsx_xflags ^ old_ma->fsx_xflags) & rw_user_mask;
> +
>  	/*
>  	 * The IMMUTABLE and APPEND_ONLY flags can only be changed by
>  	 * the relevant capability.
>  	 */
> -	if ((fa->flags ^ old_ma->flags) & (FS_APPEND_FL | FS_IMMUTABLE_FL) &&
> +	if (changed & (FS_XFLAG_APPEND | FS_XFLAG_IMMUTABLE) &&
>  	    !capable(CAP_LINUX_IMMUTABLE))
>  		return -EPERM;
> =20
> @@ -204,21 +269,21 @@ static int fileattr_set_prepare(struct inode *inode=
,
>  	 * namespace. Enforce that restriction only if we are trying to change
>  	 * the quota ID state. Everything else is allowed in user namespaces.
>  	 */
> -	if (current_user_ns() !=3D &init_user_ns) {
> -		if (old_ma->fsx_projid !=3D fa->fsx_projid)
> -			return -EINVAL;
> -		if ((old_ma->fsx_xflags ^ fa->fsx_xflags) &
> -				FS_XFLAG_PROJINHERIT)
> +	if ((rw_user_mask & FS_XFLAG_PROJID) &&
> +	    old_ma->fsx_projid !=3D fa->fsx_projid) {
> +		/* Caller is not allowed to change the project ID. */
> +		if (current_user_ns() !=3D &init_user_ns)
>  			return -EINVAL;
> -	} else {
>  		/*
>  		 * Caller is allowed to change the project ID. If it is being
>  		 * changed, make sure that the new value is valid.
>  		 */
> -		if (old_ma->fsx_projid !=3D fa->fsx_projid &&
> -		    !projid_valid(make_kprojid(&init_user_ns, fa->fsx_projid)))
> +		if (!projid_valid(make_kprojid(&init_user_ns, fa->fsx_projid)))
>  			return -EINVAL;
>  	}
> +	if ((changed & FS_XFLAG_PROJINHERIT) &&
> +	    current_user_ns() !=3D &init_user_ns)
> +		return -EINVAL;
> =20
>  	/* Check extent size hints. */
>  	if ((fa->fsx_xflags & FS_XFLAG_EXTSIZE) && !S_ISREG(inode->i_mode))
> @@ -250,6 +315,143 @@ static int fileattr_set_prepare(struct inode *inode=
,
>  		fa->fsx_xflags &=3D ~(FS_XFLAG_EXTSIZE | FS_XFLAG_EXTSZINHERIT);
>  	if (fa->fsx_cowextsize =3D=3D 0)
>  		fa->fsx_xflags &=3D ~FS_XFLAG_COWEXTSIZE;
> +	/*
> +	 * No need for projid here, because
> +	 *  (xflags & PROJID) && (rw_user_mask & PROJID) && fsx_projid =3D=3D 0
> +	 * gives the same result as
> +	 * !(xflags & PROJID) && (rw_user_mask & PROJID) && fsx_projid >=3D 0.
> +	 */
> +
> +	return 0;
> +}
> +
> +/*
> + * Convert legacy RMW input format without masks, coming from userspace,=
 to new
> + * input format with masks, for filesystems that already support masks.
> + */
> +static int fileattr_set_legacy_to_mask(struct file_kattr *fa,
> +				       struct file_kattr *old_ma)
> +{
> +	u32 changed =3D 0;
> +	u32 new_rw_mask =3D 0;
> +	u32 new_xflags =3D 0;
> +
> +	if (fa->flags_valid) {
> +		/*
> +		 * Assume that if the filesystem supports masks it supports its
> +		 * writable FS_*_FL flags via FS_XFLAG_* and fsx_xflags_rw_mask.
> +		 */
> +		changed =3D fa->flags ^ old_ma->flags;
> +		if (changed & ~xflags_to_flags(old_ma->fsx_xflags_rw_mask))
> +			return -EOPNOTSUPP;
> +
> +		changed =3D flags_to_xflags(changed);
> +	} else { /* if (fa->fsx_valid) */
> +		changed =3D fa->fsx_xflags ^ old_ma->fsx_xflags;
> +		changed &=3D FS_XFLAGS_MASK & ~FS_XFLAG_RDONLY_MASK;
> +	}
> +
> +	new_xflags =3D fa->fsx_xflags;
> +
> +	new_rw_mask =3D changed;
> +
> +	if (fa->fsx_valid) {
> +		if (fa->fsx_extsize !=3D old_ma->fsx_extsize)
> +			new_rw_mask |=3D new_xflags &
> +				(FS_XFLAG_EXTSIZE | FS_XFLAG_EXTSZINHERIT);
> +
> +		if (fa->fsx_projid !=3D old_ma->fsx_projid) {
> +			new_rw_mask |=3D FS_XFLAG_PROJID;
> +			if (fa->fsx_projid > 0)
> +				new_xflags |=3D FS_XFLAG_PROJID;
> +		}
> +
> +		if ((new_xflags & FS_XFLAG_COWEXTSIZE) &&
> +		    (fa->fsx_cowextsize !=3D old_ma->fsx_cowextsize))
> +			new_rw_mask |=3D FS_XFLAG_COWEXTSIZE;
> +	}
> +
> +	/* Make sure we're only setting the wanted bits. */
> +	new_xflags &=3D new_rw_mask;
> +
> +	/* Mask aware filesystems shouldn't use fa->flags, but just to be sure.=
 */
> +	fa->flags =3D xflags_to_flags(new_xflags);
> +
> +	fa->fsx_xflags =3D new_xflags;
> +	fa->fsx_xflags_rw_mask =3D new_rw_mask;
> +	fa->has_masks =3D true;
> +
> +	fa->fsx_valid =3D true;
> +	fa->flags_valid =3D false;
> +
> +	return 0;
> +}
> +
> +/*
> + * Convert new input format with masks, coming from userspace, to legacy=
 RMW
> + * input format without masks, for filesystems that don't support masks =
yet.
> + */
> +static int fileattr_set_mask_to_legacy(struct file_kattr *fa,
> +				       struct file_kattr *old_ma)
> +{
> +	u32 rw_user_mask =3D fa->fsx_xflags_rw_mask;
> +	u32 new_xflags =3D fa->fsx_xflags;
> +	u32 new_flags =3D 0;
> +	u32 tmp_xflag =3D 0;
> +
> +	if (rw_user_mask &
> +	    ~((FS_XFLAGS_MASK & ~FS_XFLAG_RDONLY_MASK) | FS_XFLAG_PROJID))
> +		return -EOPNOTSUPP;
> +
> +	/* Do RMW */
> +	new_xflags |=3D old_ma->fsx_xflags & ~rw_user_mask;
> +
> +	/* RMW filesystems expect to not have any globally read-only flag */
> +	new_xflags &=3D ~FS_XFLAG_RDONLY_MASK;
> +
> +	new_flags =3D xflags_to_flags(new_xflags);
> +	new_flags |=3D old_ma->flags & ~FS_COMMON_FL;
> +
> +	tmp_xflag =3D FS_XFLAG_EXTSIZE | FS_XFLAG_EXTSZINHERIT;
> +	/* User didn't turn on any flag for this field. */
> +	if (!(fa->fsx_xflags & tmp_xflag)) {
> +		if ((rw_user_mask & tmp_xflag) && !(new_xflags & tmp_xflag)) {
> +			/*
> +			 * If the user wants to clear one of them and neither
> +			 * is set after the RMW above, clear fsx_extsize.
> +			 */
> +			fa->fsx_extsize =3D 0;
> +		} else {
> +			/*
> +			 * If the user doesn't want to clear either of them OR
> +			 * the other flag is still set after RMW, preserve the
> +			 * old value.
> +			 */
> +			fa->fsx_extsize =3D old_ma->fsx_extsize;
> +		}
> +	}
> +
> +	tmp_xflag =3D FS_XFLAG_PROJID;
> +	if (!(rw_user_mask & tmp_xflag))
> +		fa->fsx_projid =3D old_ma->fsx_projid;
> +	else if (!(fa->fsx_xflags & tmp_xflag))
> +		fa->fsx_projid =3D 0;
> +	/* Strip projid now that we've used it, old format doesn't have it. */
> +	new_xflags &=3D ~FS_XFLAG_PROJID;
> +
> +	tmp_xflag =3D FS_XFLAG_COWEXTSIZE;
> +	if (!(rw_user_mask & tmp_xflag))
> +		fa->fsx_cowextsize =3D old_ma->fsx_cowextsize;
> +	else if (!(new_xflags & tmp_xflag))
> +		fa->fsx_cowextsize =3D 0;
> +
> +	fa->flags =3D new_flags;
> +	fa->fsx_xflags =3D new_xflags;
> +	fa->fsx_xflags_rw_mask =3D 0;
> +	fa->has_masks =3D false;
> +
> +	fa->fsx_valid =3D true;
> +	fa->flags_valid =3D false;
> =20
>  	return 0;
>  }
> @@ -283,20 +485,62 @@ int vfs_fileattr_set(const struct mnt_idmap *idmap,=
 struct dentry *dentry,
>  	if (!inode_owner_or_capable(idmap, inode))
>  		return -EPERM;
> =20
> +	if (fa->has_masks && !fa->fsx_xflags_rw_mask)
> +		return 0;
> +
>  	inode_lock(inode);
>  	err =3D vfs_fileattr_get(dentry, &old_ma);
>  	if (err)
>  		goto out;
> =20
> -	/* initialize missing bits from old_ma */
> +	if (old_ma.has_masks) {
> +		old_ma.fsx_xflags_rw_mask &=3D FS_FILE_ATTR_XFLAGS_MASK;
> +		old_ma.fsx_xflags_ro_mask &=3D FS_FILE_ATTR_XFLAGS_MASK;
> +	}
> +	old_ma.fsx_xflags &=3D FS_FILE_ATTR_XFLAGS_MASK;
> +
> +	/* Convert between formats and initialize missing bits from old_ma */
>  	if (fa->flags_valid) {
> -		fa->fsx_xflags |=3D old_ma.fsx_xflags & ~FS_XFLAG_COMMON;
> -		fa->fsx_extsize =3D old_ma.fsx_extsize;
> -		fa->fsx_nextents =3D old_ma.fsx_nextents;
> -		fa->fsx_projid =3D old_ma.fsx_projid;
> -		fa->fsx_cowextsize =3D old_ma.fsx_cowextsize;
> +		if (!old_ma.has_masks) {
> +			/* FS_IOC_SETFLAGS */
> +			fa->fsx_xflags_rw_mask =3D 0;
> +			fa->fsx_xflags |=3D old_ma.fsx_xflags & ~FS_XFLAG_COMMON;
> +			fa->fsx_extsize =3D old_ma.fsx_extsize;
> +			fa->fsx_nextents =3D old_ma.fsx_nextents;
> +			fa->fsx_projid =3D old_ma.fsx_projid;
> +			fa->fsx_cowextsize =3D old_ma.fsx_cowextsize;
> +		} else {
> +			err =3D fileattr_set_legacy_to_mask(fa, &old_ma);
> +			if (err)
> +				goto out;
> +		}
> +	} else if (!fa->has_masks) {
> +		if (!old_ma.has_masks) {
> +			/* FS_IOC_FSSETXATTR / file_attr VER0 */
> +			fa->flags |=3D old_ma.flags & ~FS_COMMON_FL;
> +		} else {
> +			err =3D fileattr_set_legacy_to_mask(fa, &old_ma);
> +			if (err)
> +				goto out;
> +		}
>  	} else {
> -		fa->flags |=3D old_ma.flags & ~FS_COMMON_FL;
> +		/* file_attr VER1 */
> +		if (old_ma.has_masks) {
> +			/*
> +			 * Don't preserve non-common flags since filesystems
> +			 * with masks only use xflags
> +			 */

And I should probably invert the if/else in this whole block so I don't
put an empty block for a single comment.

> +		} else {
> +			/*
> +			 * Filesystem doesn't support _mask API yet, switch to
> +			 * old rmw format.
> +			 * PROJID is supported like the legacy masks, but will
> +			 * be stripped during conversion.
> +			 */
> +			err =3D fileattr_set_mask_to_legacy(fa, &old_ma);
> +			if (err)
> +				goto out;
> +		}
>  	}
> =20
>  	err =3D fileattr_set_prepare(inode, &old_ma, fa);


(copy-pasted from
https://lore.kernel.org/CAOQ4uxgzmB0dEpQCVGKOc8reJ6OFV=3DBxDMgRW81aKiCMwDSn=
_Q@mail.gmail.com/)
> Now looking at the /* initialize missing bits from old_ma */
> hunk my reaction is to look away its huge

IMO it's compact enough, the huge one is the code for
fileattr_set_mask_to_legacy() (and opposite one), but I can move that if
in a separate helper like fileattr_set_convert()... ok here "prepare"
would be a pretty good name for it but (see below).

> and it should be
> using helpers probably called from within fileattr_set_prepare()
> itself - because if this is de-facto preparing for a set.

I did think about moving the conversions in set_prepare, but I kept the
if/else here because that's where the old preservation of old_ma flags
was, so it makes sense to keep it here.
"fileattr_set_prepare()", as it is now, should probably be something
like "fileattr_set_validate()", since most of the stuff it does is check
for permissions and invalid values (+ also "prepare" the fsx_* fields).

Thanks,
koraynilay

> @@ -390,7 +634,8 @@ SYSCALL_DEFINE5(file_getattr, int, dfd, const char __=
user *, filename,
>  	BUILD_BUG_ON(sizeof(struct file_attr) < FILE_ATTR_SIZE_VER0);
>  	BUILD_BUG_ON(sizeof(struct file_attr) !=3D FILE_ATTR_SIZE_LATEST);
> =20
> -	if ((at_flags & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH)) !=3D 0)
> +	if ((at_flags &
> +	     ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH | AT_FILE_ATTR_MASKS)) !=3D =
0)
>  		return -EINVAL;
> =20
>  	if (!(at_flags & AT_SYMLINK_NOFOLLOW))
> @@ -399,7 +644,10 @@ SYSCALL_DEFINE5(file_getattr, int, dfd, const char _=
_user *, filename,
>  	if (usize > PAGE_SIZE)
>  		return -E2BIG;
> =20
> -	if (usize < FILE_ATTR_SIZE_VER0)
> +	if (usize !=3D FILE_ATTR_SIZE_VER0 && usize < FILE_ATTR_SIZE_VER1)
> +		return -EINVAL;
> +
> +	if ((at_flags & AT_FILE_ATTR_MASKS) && usize < FILE_ATTR_SIZE_VER1)
>  		return -EINVAL;
> =20
>  	CLASS(filename_maybe_null, name)(filename, at_flags);
> @@ -424,6 +672,17 @@ SYSCALL_DEFINE5(file_getattr, int, dfd, const char _=
_user *, filename,
>  		return error;
> =20
>  	fileattr_to_file_attr(&fa, &fattr);
> +	/*
> +	 * Caller doesn't know about masks, so it also doesn't know about
> +	 * xflags added in or after VER1.
> +	 * Zero out the masks and strip VER1+ xflags.
> +	 */
> +	if (!(at_flags & AT_FILE_ATTR_MASKS)) {
> +		fattr.fa_xflags &=3D FS_XFLAGS_MASK;
> +		fattr.fa_xflags_rw_mask =3D 0;
> +		fattr.fa_xflags_ro_mask =3D 0;
> +	}
> +
>  	error =3D copy_struct_to_user(ufattr, usize, &fattr,
>  				    sizeof(struct file_attr), NULL);
> =20
> @@ -443,7 +702,8 @@ SYSCALL_DEFINE5(file_setattr, int, dfd, const char __=
user *, filename,
>  	BUILD_BUG_ON(sizeof(struct file_attr) < FILE_ATTR_SIZE_VER0);
>  	BUILD_BUG_ON(sizeof(struct file_attr) !=3D FILE_ATTR_SIZE_LATEST);
> =20
> -	if ((at_flags & ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH)) !=3D 0)
> +	if ((at_flags &
> +	     ~(AT_SYMLINK_NOFOLLOW | AT_EMPTY_PATH | AT_FILE_ATTR_MASKS)) !=3D =
0)
>  		return -EINVAL;
> =20
>  	if (!(at_flags & AT_SYMLINK_NOFOLLOW))
> @@ -452,7 +712,10 @@ SYSCALL_DEFINE5(file_setattr, int, dfd, const char _=
_user *, filename,
>  	if (usize > PAGE_SIZE)
>  		return -E2BIG;
> =20
> -	if (usize < FILE_ATTR_SIZE_VER0)
> +	if (usize !=3D FILE_ATTR_SIZE_VER0 && usize < FILE_ATTR_SIZE_VER1)
> +		return -EINVAL;
> +
> +	if ((at_flags & AT_FILE_ATTR_MASKS) && usize < FILE_ATTR_SIZE_VER1)
>  		return -EINVAL;
> =20
>  	error =3D copy_struct_from_user(&fattr, sizeof(struct file_attr), ufatt=
r,
> @@ -460,9 +723,9 @@ SYSCALL_DEFINE5(file_setattr, int, dfd, const char __=
user *, filename,
>  	if (error)
>  		return error;
> =20
> -	error =3D file_attr_to_fileattr(&fattr, &fa);
> -	if (error)
> -		return error;
> +	if (!(at_flags & AT_FILE_ATTR_MASKS) &&
> +	    (fattr.fa_xflags_rw_mask || fattr.fa_xflags_ro_mask))
> +		return -EINVAL;
> =20
>  	CLASS(filename_maybe_null, name)(filename, at_flags);
>  	if (!name && dfd >=3D 0) {
> @@ -479,6 +742,13 @@ SYSCALL_DEFINE5(file_setattr, int, dfd, const char _=
_user *, filename,
>  			return error;
>  	}
> =20
> +	if (at_flags & AT_FILE_ATTR_MASKS)
> +		fa.has_masks =3D true;
> +
> +	error =3D file_attr_to_fileattr(&fattr, &fa);
> +	if (error)
> +		return error;
> +
>  	error =3D mnt_want_write(filepath.mnt);
>  	if (!error) {
>  		error =3D vfs_fileattr_set(mnt_idmap(filepath.mnt),
> diff --git a/include/linux/fileattr.h b/include/linux/fileattr.h
> index 09e32b84e02a..725efac15e76 100644
> --- a/include/linux/fileattr.h
> +++ b/include/linux/fileattr.h
> @@ -35,6 +35,10 @@
>  	(FS_XFLAG_COMMON | FS_XFLAG_RDONLY_MASK | FS_XFLAG_VALUES_MASK | \
>  	 FS_XFLAG_DIRONLY_MASK | FS_XFLAG_MISC_MASK)
> =20
> +/* Flags only for fa_ fields */
> +#define FS_FILE_ATTR_XFLAGS_MASK \
> +	(FS_XFLAGS_MASK | FS_XFLAG_PROJID)
> +
>  /*
>   * Merged interface for miscellaneous file attributes.  'flags' originat=
es from
>   * ext* and 'fsx_flags' from xfs.  There's some overlap between the two,=
 which
> @@ -45,6 +49,8 @@ struct file_kattr {
>  	u32	flags;		/* flags (FS_IOC_GETFLAGS/FS_IOC_SETFLAGS) */
>  	/* struct fsxattr: */
>  	u32	fsx_xflags;	/* xflags field value (get/set) */
> +	u32	fsx_xflags_rw_mask; /* supported writeable xflags (get) / flags to =
set (set) */
> +	u32	fsx_xflags_ro_mask; /* supported read-only xflags (get) */
>  	u32	fsx_extsize;	/* extsize field value (get/set)*/
>  	u32	fsx_nextents;	/* nextents field value (get)	*/
>  	u32	fsx_projid;	/* project identifier (get/set) */
> @@ -52,6 +58,7 @@ struct file_kattr {
>  	/* selectors: */
>  	bool	flags_valid:1;
>  	bool	fsx_valid:1;
> +	bool	has_masks:1;
>  };
> =20
>  int copy_fsxattr_to_user(const struct file_kattr *fa, struct fsxattr __u=
ser *ufa);
> diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
> index e43e3de3e9ee..a6ecca6f5e63 100644
> --- a/include/uapi/linux/fcntl.h
> +++ b/include/uapi/linux/fcntl.h
> @@ -191,4 +191,10 @@ struct delegation {
>  #define AT_EXECVE_CHECK		0x10000	/* Only perform a check if execution
>  					   would be allowed. */
> =20
> +/* Flags for file_getattr(2) / file_setattr(2). */
> +#define AT_FILE_ATTR_MASKS	0x001	/* Advertise knowing and being able to
> +					   handle the struct file_attr fields
> +					   fa_xflags_rw_mask and
> +					   fa_xflags_ro_mask */
> +
>  #endif /* _UAPI_LINUX_FCNTL_H */
> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
> index a13c7b32a1bd..63d88ebe3420 100644
> --- a/include/uapi/linux/fs.h
> +++ b/include/uapi/linux/fs.h
> @@ -238,10 +238,13 @@ struct file_attr {
>  	__u32 fa_nextents;	/* nextents field value (get)   */
>  	__u32 fa_projid;	/* project identifier (get/set) */
>  	__u32 fa_cowextsize;	/* CoW extsize field value (get/set) */
> +	__u64 fa_xflags_rw_mask;/* supported writeable xflags (get) / flags to =
set (set) */
> +	__u64 fa_xflags_ro_mask;/* supported read-only xflags (get) */
>  };
> =20
>  #define FILE_ATTR_SIZE_VER0 24
> -#define FILE_ATTR_SIZE_LATEST FILE_ATTR_SIZE_VER0
> +#define FILE_ATTR_SIZE_VER1 40
> +#define FILE_ATTR_SIZE_LATEST FILE_ATTR_SIZE_VER1
> =20
>  /*
>   * Flags for the fsx_xflags field
> @@ -270,6 +273,8 @@ struct file_attr {
>   */
>  #define FS_XFLAG_CASEFOLD	0x00040000	/* case-insensitive lookups */
>  #define FS_XFLAG_CASENONPRESERVING 0x00080000	/* case not preserved */
> +#define FS_XFLAG_PROJID		0x00100000	/* project ID */
> +
>  #define FS_XFLAG_HASATTR	0x80000000	/* no DIFLAG for this	*/
> =20
>  /* the read-only stuff doesn't really belong here, but any other place i=
s



--1f8dd9411e3204ed63cbc5af2d1a4dd06cdcf953434d520fb1bee6abdc83
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQRJ2XvJtXGwULYEerQ0bnTtJTDoOAUCawmFRwAKCRA0bnTtJTDo
OMdvAQCuD2OWXSrdbKRJPNMMcquHB6qyKWjB/3Bhaw/nbfbVHwEAqTmd/bM9sjMm
aeREE/eCU0rYY32KkzjR5OvsPKvj7QY=
=20ih
-----END PGP SIGNATURE-----

--1f8dd9411e3204ed63cbc5af2d1a4dd06cdcf953434d520fb1bee6abdc83--
