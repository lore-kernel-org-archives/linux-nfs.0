Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.173
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795780980;
	b=GBA2eiqqHF/zuBZ67Es0PZqB+K4H40GZOXbfnTwh8DCliJ+XzRoA91ng0308STDI1rgM
	 foUTatMUeKRRUomXguHbC2CmyMFlwPGZNg/IoJSAcl/Eveow84n0ygwQoFdnr8fDUSvci
	 gWh88gchdcRAceVnkwxDAWtJmBiUT+7L7+5PwUcKXZXL7XyEA2AR3ZsELaKsoGAuM+xsH
	 1eU2RM3hI/3RC2GziHaXeJE3D/GO5DzB46jVDsAZfiXIsAuckvcVCS2cQfDBWciwXGVYm
	 00u4hMIA+N/Lu2tmUos4i2FS7CbMKLeFbmxyukjVL3jicx5N8ZVv7oHYZ40V9XGRuag==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795780980;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=sKBAqoHb6dKCB8lGd+jVvxodjbVVN2AMGRa9Yq/Mby4=;
	b=wfQ2f492tHlEwGlB0B7oiQD8HxYJSxzL+PEIJbqfAO6y1eq77GFFPbWDwizuZl8skPEZ
	 r2PuRQZck6wSLXnPYthmcODA+k8/tmSV4rCr44UJSqRxfDF9UU4vaam33WEbKy2y2aVEm
	 AQQjV/qipGn4GVkVGxbfVQecogkw+v7B+dxY4yaUJ9MOz1vT+AHY7Rc20/xwCu9aEchT1
	 wheQTrHj1NMqgwRDscPOanxgLKqvXt4ItPEIeuMUXGlyspZOHRc59OXLnyiWfNX0EuKnF
	 ypz/8cOWLp+IuUVJ+hTgax4fruSTZXNoJJS8DSLkiGeOhi30NQ/CBZDYaq3UrWt8xwg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=SnFA07cx;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.173
Received: from mail-lj1-f173.google.com (mail-lj1-f173.google.com [209.85.208.173])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C028F606A31F
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 12:02:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C028F606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=SnFA07cx
Received: by mail-lj1-f173.google.com with SMTP id 38308e7fff4ca-3ae25dcbd81so74695411fa.3
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 04:02:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795780978; cv=none;
        d=google.com; s=arc-20260327;
        b=BiWSFQ8+n8B3tKux4CFZQZcRJLPwAWAHfV8BmGheK/oLqpxrfbAKzeeXF2lqW47sCZ
         cRMWHekAnJj/DcZBVVOQ0Aph3+88FTo89M690vj2CzWNVIRHYRLKeqNBO+sOj0LtLukM
         udiCzGoD9ZYf/ssoioFz0mBR6DeOf4eVE7MI1cOJbAgw2BbY7QEKZx65x79T/DmbF/dT
         mk093Q+rt/jvih8ZB1rYp8S0xfdjAfT7Gg/xn6pdwHEFxD3BNzdYT9OwzC5JFqYBhOJ5
         3LjWMkXlzo7+Y+/cwJs3uuo2MIwxWdBB3PdDMYvpnk7M1s1/YJMFdOSW2Q+hUGebpqRa
         LMRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=sKBAqoHb6dKCB8lGd+jVvxodjbVVN2AMGRa9Yq/Mby4=;
        fh=PeSoqs6e4WEGgLy/XJFbpqL4j3/JMTqUqWegqDF/llU=;
        b=clEOMTvB+4icSlDUT3yogKfari4Qq3R7cq+h+mMV7ZimVYf4Vx5DiY2AwwLO3FfKmG
         JfpKm2ftxYZVSphiwPuuME0/9UOl0UH3+aJ9flP+4SHFLGpN+d8U8oOv7pJCZHY6PRut
         IJ0vE2yGoWmM1G2vqroNJnRUPerVb67jmJmZ18Krmvf6Iyabqdm9A+annfzMTXYatxBO
         MyI1eE29HTZZQUzan5DvmYyvCafSsLVlTHOToixM3hATDHGi9+Ho42YTm2tk+Gmqe6ft
         Se62D1/giULj8gI6NGnzVt+TKzZIuP3ZClQapRiQPtms6IP+JnHDsNz+AJtfyzfw42Wl
         Bzag==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795780978; x=1796385778; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=sKBAqoHb6dKCB8lGd+jVvxodjbVVN2AMGRa9Yq/Mby4=;
        b=SnFA07cxVyuwSSQ2WlqVldYscrENhFj8PVisFe6EUr/u+zjaGcOlyf+NO4/VeKXXX7
         4E5nqOC+Z3I662UCySIHIiaMwrjJK+ZjK9X5FK/V848T+A65ClvPxk5bvJvrsV+MWdo/
         JIM89r7vSI7FFB67/tWpYnfwZs9/cVksgSfXEE4llKDhqleU1ZWfSy+N4AE/zsZMEKkf
         FXtLBubySwAUA91pvO8XAdbubi6E7QFc7BDt/+z27xlpQGmIW0sbpzCnfaiUYkOVUtJK
         S6zwuiZQCA+1rzhAC+jCChTTNWgaEmMmc18deOG2Q+9ze1ubEHLrjAXDP7U1S018fipI
         jn7Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795780978; x=1796385778;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=sKBAqoHb6dKCB8lGd+jVvxodjbVVN2AMGRa9Yq/Mby4=;
        b=D3VExHDN50fGvqCN6Rq1akr8KSCBCs9h+J/OBzqM09gqGk1mJlthwgOS0OqfPI0sqX
         gxhU+NKpA2W3/tsBlfGCHovRDTx7SzXsxgz9Kejw+va6orCWe4CNkJUbUMxivWT8b8c0
         bSGIEhT1HQSbWLxzwRNBJZwrfd6xbMHstii21kM4xhn+IsEw5XUilXZ5gmI5PoT4zc4n
         2APYATbUFRF1V52gZJltXawvowdUzFzOaO/ErqpzQoTBFLrjhvOMZD0AdzkOZvRzSIaR
         ro4pF0AI/wE/TKcQC2OwWUae/R2aw3E4gL7Y3eZBKGve7fs9I/jao+K5t5TJFTrphrrz
         AT3A==
X-Forwarded-Encrypted: i=1; AL+hErHb5qi3HQpqlGgDT1Y94YWi6aqVecDhuRQ2Ny7POE0fmV71+CxKZGiPoJgIgThXsLMnX5k+v8MHg6s=@vger.kernel.org
X-Gm-Message-State: APuU4Z8VLl79kuhZsXqCNLkRsYo2OuXnxVeRPK9xu03E6MjLHRXnKlYe
	ZMCsullbomc6fdu99WHdWUZAOhUoU3aSknNMdA+B4XaJe4E6y2GuLoArEL8GinDM4Ckvq4kd8Wp
	zV0AbqpEcaaCyqN/NMscRzG42P2NOqwU=
X-Gm-Gg: AZFdTZcWtVnp7B9uUSo8IoNvhvEErw9iJz9Z123d8tXbx4HoSVklXKjPIVQDqB/51hX
	sWSY5T4VXSqxvktOxpHlf+IW5FwoAevYW33zPJLPn+c0KhanCoSqEsmXVUahN7MHJlxs1LoVW3m
	QvrUSEQvF1PpOKhb9Za3teYYDAr2xUtj82nJYQWzP0vm3ibIfbT0RJBhOYrKS1TOOJ1B/7I4wGp
	Ivo0wa3IkYCDEZpZTMJj/a45ZssOQfOTkB76Xt4aaSO8Eof6dQqCFQxy/El7qngv1af7BIQPUed
	KgRjgVPHk4uQaDft09pRJl2+ibF6mVCbAeqb2fYZi9i2QxPea3GU9piP2gnyyTxnMYiw88nIZpp
	yBsHR1gLbNKTeX1t48PK6aQRz28gGhdWgz5fj78CrsAqwiV9an6BeDCY3AACfXNd+zpFByA==
X-Received: by 2002:a05:6512:1148:b0:5bc:cc46:1849 with SMTP id
 2adb3069b0e04-5c1bc874b3cmr6981033e87.54.1795780976912; Fri, 27 Nov 2026
 04:02:56 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261126163114.403846-1-koray.fra@gmail.com> <20261126163114.403846-3-koray.fra@gmail.com>
 <CAOQ4uxjGLfuZMFABCwMvdXwnU+P24G_aTJLudWbjeSmWwyDF6Q@mail.gmail.com> <DN5YPR39J7QI.1S1LCFLNUCZNL@gmail.com>
In-Reply-To: <DN5YPR39J7QI.1S1LCFLNUCZNL@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 27 Nov 2026 13:02:44 +0100
X-Gm-Features: Aa3M54ohq34732gC99y698hjwvA-0NF3EsaW7G0zij4KAugMs04c_-FFLASygdQ
Message-ID: <CAOQ4uxgzmB0dEpQCVGKOc8reJ6OFV=BxDMgRW81aKiCMwDSn_Q@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] fscrypt: update fscrypt_prepare_setflags() to use xflags
To: koraynilay <koray.fra@gmail.com>
Cc: Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Eric Biggers <ebiggers@kernel.org>, "Theodore Y . Ts'o" <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Jan Kara <jack@suse.cz>, 
	Alexander Aring <alex.aring@gmail.com>, "Darrick J . Wong" <djwong@kernel.org>, 
	Andrey Albershteyn <aalbersh@kernel.org>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	Lauri Gates <lauri.gates@gmail.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <dgc@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	ntfs@lists.linux.dev, linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 27, 2026 at 12:38=E2=80=AFPM koraynilay <koray.fra@gmail.com> w=
rote:
>
> On Fri Nov 27, 2026 at 12:35 PM CET, Amir Goldstein wrote:
> > On Thu, Nov 26, 2026 at 5:31=E2=80=AFPM koraynilay <koray.fra@gmail.com=
> wrote:
> >>
> >> Update fscrypt_prepare_setflags() to use FS_XFLAG_* xflags instead of
> >> legacy FS_*_FL flags.
> >>
> >> Signed-off-by: koraynilay <koray.fra@gmail.com>
> >> ---
> >>  fs/crypto/hooks.c       | 10 +++++-----
> >>  fs/file_attr.c          |  2 +-
> >>  include/linux/fscrypt.h |  6 +++---
> >>  3 files changed, 9 insertions(+), 9 deletions(-)
> >>
> >> diff --git a/fs/crypto/hooks.c b/fs/crypto/hooks.c
> >> index 149498bdab94..52d6a33fc9e9 100644
> >> --- a/fs/crypto/hooks.c
> >> +++ b/fs/crypto/hooks.c
> >> @@ -182,10 +182,10 @@ int __fscrypt_prepare_setattr(struct dentry *den=
try, struct iattr *attr)
> >>  EXPORT_SYMBOL_GPL(__fscrypt_prepare_setattr);
> >>
> >>  /**
> >> - * fscrypt_prepare_setflags() - prepare to change flags with FS_IOC_S=
ETFLAGS
> >> + * fscrypt_prepare_setflags() - prepare to change xflags
> >
> > prepare to change the file attributes with file_setattr() or one of
> > the legacy ioctls
>
> Ah yes.
>
> >>   * @inode: the inode on which flags are being changed
> >> - * @oldflags: the old flags
> >> - * @flags: the new flags
> >> + * @oldxflags: the old xflags
> >> + * @xflags: the new xflags
> >>   *
> >>   * The caller should be holding i_rwsem for write.
> >>   *
> >> @@ -193,7 +193,7 @@ EXPORT_SYMBOL_GPL(__fscrypt_prepare_setattr);
> >>   *        another error occurs.
> >>   */
> >>  int fscrypt_prepare_setflags(struct inode *inode,
> >> -                            unsigned int oldflags, unsigned int flags=
)
> >> +                            unsigned int oldxflags, unsigned int xfla=
gs)
> >
> > This here is a backporting landmine -
> >
> > Changing the semantics drastically without changing the helper name
> > or signature.
> >
> > Please rename the helper something like fscrypt_prepare_fileattr_set()
> > so that backporting mistakes will be caught at build time.
>
> Yes, though, would it maybe be better to just use xflags_to_flags() in
> the vfs patch instead of changing the fscrypt function at all?

Yes, much better. I agree.

Now looking at the /* initialize missing bits from old_ma */
hunk my reaction is to look away its huge and it should be
using helpers probably called from within fileattr_set_prepare()
itself - because if this is de-facto preparing for a set.

Thanks,
Amir.
