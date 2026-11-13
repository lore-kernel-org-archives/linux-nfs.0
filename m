Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564919;
	b=U8xBossrvV/PijQDGVk/dfTI8+4uKUkW1PVlIO9virZbfcu4tF6mYV89d7MOxbKTNZ/b
	 58qMrv+7rckVgoAlR8dn5eAOi4EVLdRMcOD/BNXcVU9Ig5IeyhJKvzwtmQYvbGYG6x67g
	 3rKbPSR7sY2Msdv1u9uykJP6h2XSxe4aAcUS9VtwwiFMTHk8CZCiMCMYbDLj41lbo1rNG
	 8l49ND2ggq1n3fgxnCT9PgT2hvsUTeBSOOh+qDRLFz0yjCoduD1I+UYTTO7hBQxyWMgHH
	 QpygAq+iDacvDqvdhbrz3DLEF4L0/0dT6YApmO6zikttwRSJ/7P4B59zzhjZPnEmnvw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564919;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=QtOsdPCKGJ1fBhMqXd/zLQfd50NEx4L7veNiE/G2OUE=;
	b=um7PLZDq9eTWA6OKh65CE8xNTeHJiuw22mge1TsZFNfJ5YpcUyCr4hfv+UN8+gXABIP0
	 CYYIGhM8Tp6WjuI4LISBgAJ1xwquiIpUczHDIoIiMWWl02IoNQF2gX5Smd/6dHVIOQvWP
	 9R0mP81mJi+TPPv8+y/G7cyEfNDstFd9cmZ3ayXEb1hdo/TvkTemngFVuiohYOs/fvxoe
	 kp5evsZpAEciq7yquHrJqqp7NCXpdStgVbgfU3KDESIAJPiJP5p1Turm3gaDtzBmI+hTp
	 iTUAJh1f2hzVksqdRLGKNv+EQ5xXSw8H8YJIKtfrqqitaei5pHlIh5mGCyYiI8bNLkA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=XokUN4uh;
	arc=none smtp.remote-ip=209.85.128.53
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0B9760A2601
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:15:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B0B9760A2601
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=XokUN4uh
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-4a5087a5348so5469185e9.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:15:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564917; x=1795169717; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=QtOsdPCKGJ1fBhMqXd/zLQfd50NEx4L7veNiE/G2OUE=;
        b=XokUN4uhZ5cnIDNPS9kLjfaPp8ZSmyDY7nHz3ffF9uftFGQzzc0NaUd0CPxl6tmm/G
         EB2bqVZrrrQULKzHfxmMlarOF7+NP4G1EuGLp1x7hwkFzcf5DKQIlYH5+zTWTg0qLXK8
         Q27+pu7matN83z4kFimCCYFY9EtcVBpSYh+f+WbPWczzC82gi2dU1+IxENiNgIvD4ssI
         1POQJndyP8zOY9I/drEtHc8Rir/wcokVwFCL8xkdsULqRcKqvw/m2pftg5e6OYSufYMA
         FPm06vn59Z5lYx4UA2FpKr0UjB0BBdejlJLIE+RKFWt9/d0/clXrD3SuYpmwDbHdW+74
         JQJg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564917; x=1795169717;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=QtOsdPCKGJ1fBhMqXd/zLQfd50NEx4L7veNiE/G2OUE=;
        b=zzgbG6t2pxwSgblMoNwLfVfH48mhAQXX2LG6MamfqYdBGhgfz4m+isoYEtLWy2zAGz
         jy72cAVlglyK/UsugZV3c//JMiiCbReKlx8WIGWQqNTgwqg8bd6fZ/6Q7/Um2E3ZPbZ5
         GUh+Sa4n71gWBW5NtZZOKHSDoqwaWw1Zh+BnHiPJIrOWWteKt+5X0b0M2UMCftfvvBge
         fXKUFNjLcx6HH2RjnvLLRK2M7/xnuv2jb8an3z1PCqpoNXW1/pPuYbxYU79DAdKi47og
         4kQT+6MKUuNljoQVlVWfRmzK5RxlbvdmN4q6woInVRT9DNjVFqjevoBGB/nIQxrN7rX2
         IWXw==
X-Forwarded-Encrypted: i=1; AL+hErErL50PpeXSVWYVnfzs02bjeuO6hK4pQH5L6nDyaRRQxM/wBlMwE/gpedFz9OwYDEbs9iFuYgqIIfk=@vger.kernel.org
X-Gm-Message-State: APuU4Z+YOvnuUhjjEgdaSxBn7e6z9voe7L31QT/ENDGxf2j8oi2uSH2K
	uE0/fDrhHp79amFBp7uhAAbPLbGCT/ZvCbW+zCNnkCnanNV8psuVeYNT3wqAzM36Ri2k
X-Gm-Gg: AYBFou0t2w+ClxBw5lrIB997zLNYmyq3ZHrdXNjJ5ggCalna9qSuyfRHrYwKigqxLWl
	wO2rLI1uJVnB+CU9p71oz0tMpO8L2nX5SsiRNY2rom2zbUbxtvVmCnqvKOwPZ4GLZdkgPjgv+YT
	8t2yGzl4piRyNsrPhQTP3imkshXoN7BmWJy9XmDwpeeFsA+wy0RsIX8frLaFBTEVEPcAAEMKCNl
	mmfqE8J2dotyUxDooZSRo+qmZ0oxliImkcNuAcmdnUo0u3T7t4sG+0dEJh9RD3uG16lUq+oSxYu
	tasUJawfZPoW2mz4a1JaiYI5pmujJ4Wkbeb27uYiK+1sNoeKqbUQPhWVVFw+5fiH4mQSZPJnBjx
	7vpjQixH0D2f2F/RS5VT5HVZAuyY2UtKo+LgaxnkEumd5lnioJxjsV1S2k1OXZtXitFSf1w6cld
	ZKGYoi0BL/cp/2J0fQi+yz2tCk9RsZGvPI1J0CptU+ngtolMFrgu076tBNa64vjJsxK3o52NlqS
	YlxjlussN6HySxJeZSm2g7VwXr259W8DKBpNvpKBSBP6fS6IzwJDuPixMTgXA8wBEZkxmnWrPGU
	ycrFSQHHw9lm77z6X8y6cpYuASaGveTX9gdoN9D9EfD2hsJR4lfmyq/9M9iO5bU=
X-Received: by 2002:a05:600c:4f84:b0:4a7:7f3f:6f8e with SMTP id 5b1f17b1804b1-4bb5599ade1mr43492835e9.0.1794564916955;
        Fri, 13 Nov 2026 02:15:16 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb56680ea9sm31982365e9.0.2026.11.13.02.15.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:15:16 -0800 (PST)
Message-ID: <e2edfa06d185acd86b46945622b6eb6dff97b307.camel@amutable.com>
Subject: Re: [PATCH RFC 33/41] fs: add file_is_pseudo()
From: Alexander Mikhalitsyn <alex@amutable.com>
To: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, Josef
 Bacik	 <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org,
 target-devel@vger.kernel.org, 	driver-core@lists.linux.dev,
 linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org, 	fuse-devel@lists.linux.dev,
 linux-efi@vger.kernel.org, 	xen-devel@lists.xenproject.org,
 ocfs2-devel@lists.linux.dev, 	linux-s390@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, 	linux-usb@vger.kernel.org, Amir Goldstein
 <amir73il@gmail.com>, 	linux-erofs@lists.ozlabs.org,
 linux-kselftest@vger.kernel.org
Date: Fri, 13 Nov 2026 11:15:14 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-33-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-33-4c998976c6c7@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.56.2-0+deb13u1 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Tue, 2026-11-10 at 10:14 +0100, Christian Brauner wrote:
> Add a helper to check whether a file is a regular file on a pseudo
> filesystem. Only regular files count. Device nodes on pseudo
> filesystems
> such as devpts, binderfs or the block devices on bdevfs are what they
> are.
>=20
> Look at the inode that actually provides the data via d_real_inode().
> overlayfs accepts sysfs, cgroup2, debugfs, tracefs, configfs and
> securityfs as lower layers and reads of such an overlayfs file are
> served by the file on the pseudo filesystem. Checking the overlayfs
> inode would miss that.
>=20
> No functional changes.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0include/linux/fs.h | 12 ++++++++++++
> =C2=A01 file changed, 12 insertions(+)
>=20
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 99caef43ff3c..407ffb6342ec 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2553,6 +2553,18 @@ static inline const struct inode
> *file_user_inode(const struct file *f)
> =C2=A0	return file_inode(f);
> =C2=A0}
> =C2=A0
> +/*
> + * Regular files on pseudo filesystems are kernel interfaces and
> must not be
> + * used as storage. Look through stacking filesystems at the inode
> that
> + * provides the data.
> + */
> +static inline bool file_is_pseudo(const struct file *file)
> +{
> +	const struct inode *inode =3D d_real_inode(file-
> >f_path.dentry);
> +
> +	return S_ISREG(inode->i_mode) && (inode->i_sb->s_iflags &
> SB_I_PSEUDO);
> +}
> +
> =C2=A0static inline struct file *file_clone_open(struct file *file)
> =C2=A0{
> =C2=A0	return dentry_open(&file->f_path, file->f_flags, file-
> >f_cred);
