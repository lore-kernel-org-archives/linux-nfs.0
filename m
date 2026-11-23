Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.44
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795447798;
	b=SK+jAkfk0bOFOXj0VpT3abYjzIqHNBu5dul2TdfytDr0HVWxjHkDsWzIQCuPsAHebARe
	 5vj7VnaKFXJ7otcS2ybA1n3c7r/ivM/XyMpMn7tV/ygKv/buc4Mp875lcacTq1WkUg64U
	 yRBDrzuVeDL9HaQbtk7aZeRrcmXM4RzzqZPa8FmmI9q6uEzG+nEVMFPaII8itd+dk6BVB
	 5UBAAM14QFNMUpeMb+/vuxZeAmI8JKVNMRy2O0x062Mza5FHDkKw7ge/77qyPR6dbYnXk
	 BCVvJik2ThNuJpEKe7JdI3u4p6x3EGnmbOHSoC8k00uQBHL/Fhsz4LpnVc4/uCpe6fA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795447798;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=XTqD3jTsvce7PV4dxiBL4DNg4qThdQn7thVX1pxBbRQ=;
	b=kKi029KL8UwXwQkYIehOOtQHIrBO6TkowTOoUVgJHHUMAdFbpbIrLE4a3GWQVXwm7j5e
	 zer0FKSvhaeJlmjDtm8UMBBeUM6deMu2R4Cz76za1bHx6zX+1w7TUeJM+5N9GkAMcmH5Q
	 oqUogzt7UHLPnW+PGKrScNvxwl2PfUiqGQV6u4fVf0jkZ4CmYElK/Tv07OL2Flk/aVLUA
	 2c5pQcjEWeCA36TQsBwHdP6zm/6HresHZaI9zGqRMOyUuK81Pi6xMMtKnfdXTcIrOAB+L
	 9Ip93gVaV12lynoNDmD4t1hZljHUZ2QBKgYsmiMQAh26+NvwsEqv2fo88Ked1IiB9rA==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=U3UavhO0;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.44
Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 528B0606A32D
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 15:29:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 528B0606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=U3UavhO0
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-6b887ca9f5cso4749211a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 07:29:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795447797; cv=none;
        d=google.com; s=arc-20260327;
        b=EdsnlO7JOahKHSjDcKTCHX+8awKBJaarKAKPwAZG2pBuHGnIGeQq0AjfWQkPp/S8JG
         pkkr5ECTtOYLVhXzQsu0AyQOdRq8v/4qWXGu+QlJrrUJ4lUZ2SZg0qmp7wvN+zrXrup2
         YN5DCu4k+uO1CQbOu9O3EatUQTUp7MYHghwNbjcSbg76l0Vypf/HNoSuRbf+LpzTQ+DN
         Q+gObk3PX4qsKWkj7JhgD2CxvooE7SrCRVf66utNnZXzSyYw2+z6PcrGa4BjAack9J23
         NmkhK4UKcv/8z5FHhh6cdQ0bFoQtp9lbT4wDsCmkMBvL6jgCpGPi2mID8EaBLLiGQLYB
         rz8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=XTqD3jTsvce7PV4dxiBL4DNg4qThdQn7thVX1pxBbRQ=;
        fh=AAt7NeZath2jKqijhbmZxUwZuppRHWIO2jRVc3cTkdY=;
        b=IhYNmalOkG1a47OMw2UyQyJegcmPNlSkEy8ojG40s0Ag141v/WpfDL5gFhtcEpr4Iw
         WmNMd4cO7fFsqmmuP4OD2AhRn9/cxoLz3T+OQH6/GgbVtMQXq+UMSbj9dhqPtnUj07od
         Tq0GaIejSqDDIGvKqMRbSEsBbcDjby3RYDrmUeWjXxnzCCGEtPPLSuRLv2ePCvZmRxLZ
         39j45S4li3JtBaMb4On3EQbkaD+2G7UEIbpUaMEvbdJj/5AJ+v4pO81WXtUulGkuCtxr
         tUDw/u219RSRLVUGxpKtmwc7Fso8M8uADKlcN+TPP9YqNQ7F6EwypIsHQJnQ1NtsVpv4
         9bsw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795447797; x=1796052597; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=XTqD3jTsvce7PV4dxiBL4DNg4qThdQn7thVX1pxBbRQ=;
        b=U3UavhO0vHfet44jf/aYXoS79W6o76/gvGmauPo8EJm4ak5yEu10LKFJc+bYM6DlNU
         dCfYYbZo4XhCpeXp62rA0WhWPdxwGSBPkk4yinisKQ/3HfliRazobfQ9a7wzP5P/SNIj
         eY6Fkypy+Iu144S/pfklmW+0egIWItbVB08gm8qw5tnR8zDbFxxrzY0hnU6BZ3IwGmbE
         LsikLplsus57/TtIIXYJNnBuJ+PJ0Bp+wTkqaQckcSlNsFqJe0wHdq3V547JgL9TtAhO
         QOlSChEk/jL5J2GuElsY4mHz8m3/NfdWUNuOhXFy5X6AjFyJdiPpdHYlxE7EGBx26kpc
         vI5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795447797; x=1796052597;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=XTqD3jTsvce7PV4dxiBL4DNg4qThdQn7thVX1pxBbRQ=;
        b=xqYsR25aHde9NB2rnOdYO5as9SUnDvp5Rhfonu1YQdiMywIDjAp4gbCKODU8v1Etsi
         3qgHwozeqWoHDHBY0CRV+uAifJAs48rUoMvIOkA9TXt3F0N2s5ZpBMfQOKS2JcrZvlwS
         ZuMOzJvWMewYlI/MWQN+FVyG81TPTtg8gESYqZ17HNNYk3gd5S3sKxiA3Kw4NknJX3dt
         1J8XEUXIGkPTutN17+H7pDkaFxzj7+QETLydd5k9E18dG8PhB5MtavJKcXvPQsePDWwG
         9+vdE7LorNgTOD+8PZwBgIGwVRDgYwUH4TDReoyEOxaD45VUUfbXJgPGEgxVckxNlrMf
         gipQ==
X-Forwarded-Encrypted: i=1; AL+hErGtM3fIPu6DXzeuWiEui37W6BQgGWcn3BsARubP1IXZSVyyQ/45h04O6bgYuQDtHnGpTqR9WMZIA1k=@vger.kernel.org
X-Gm-Message-State: APuU4Z/NULb5izPsSiDvVhxYmEn6K5wod9k1Vba8hSVZndZ87Zi/Kcro
	/CCujv/uen0+f7byEPRchTFC1frSS/d8CkhoTTH2fOTWPCI4HGYCBFzzmfPo88PQF/nw2O3WzM1
	0LPA8YjzYx5xkrcR3famyqsColaqlU7I=
X-Gm-Gg: AZFdTZdb6eBtVErhCxC0crF87WV3vs1F/kld6JwwA/wLy/toXv1hrSScvU6qIGkGTFt
	Wt2D1hnZxxnOtnzWQzSSb+6EvEzYpSceF35tOhjjLcF7DT9kkkI7PjnrOR0uKwuv/DYDnDRrc5w
	Dpl2RO3plyvNxQYr10NXg5YcJPv+g+EMRZuJQzxPGJYqarmB5nRK9bRGk/DP+ZXEeyGbKyEBgE4
	6ZNatfgcLHOM0Bk0OYK3K6ZR7nixSDYCKz8EM1s9eIk7iTUYdSvXjEX2JC57sTH7xrjnvUck9wc
	OTeFoKV3OV9tAwT+LNaedVgwvVWIJj86/aqtK1R60+afNBRTv1/n1j/BowGgKbOpZG/atJrHvhb
	4ivZXWFxlFRX/ZQ1xkGUiBOUokf9PjzKQ0A4kxqqGbceMVP1P8MZHjhhObPodKoTiof8T4A==
X-Received: by 2002:a05:6402:e05:b0:6b4:9919:b54 with SMTP id
 4fb4d7f45d1cf-6ba37f04a34mr8166206a12.42.1795447796335; Mon, 23 Nov 2026
 07:29:56 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261122000856.536902-1-koray.fra@gmail.com> <20261122000856.536902-3-koray.fra@gmail.com>
 <CAOQ4uxhegn1z=41_MHL1Zu2hXuPtzNhC=x4gd371oaeJE4-weQ@mail.gmail.com> <DN2N6A68PBO1.2QT8ZOARF4I6L@gmail.com>
In-Reply-To: <DN2N6A68PBO1.2QT8ZOARF4I6L@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 23 Nov 2026 16:29:44 +0100
X-Gm-Features: Aa3M54rXlfF1ti3csfwg-SOdn_z3DGpZ_P359TQjfteI3PWichkZOxWgdTC23l0
Message-ID: <CAOQ4uxhDQqEQ3T9NveBFpUmSU032BxrNV5D+_zHj8u9LOQY+qg@mail.gmail.com>
Subject: Re: [PATCH 2/3] vfs: add xflags mask to fileattr API
To: koraynilay <koray.fra@gmail.com>
Cc: Namjae Jeon <linkinjeon@kernel.org>, Hyunchul Lee <hyc.lee@gmail.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Jan Kara <jack@suse.cz>, 
	"Darrick J . Wong" <djwong@kernel.org>, Andrey Albershteyn <aalbersh@kernel.org>, =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, 
	Lauri Gates <lauri.gates@gmail.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <dgc@kernel.org>, 
	linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	ntfs@lists.linux.dev, linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 23, 2026 at 2:58=E2=80=AFPM koraynilay <koray.fra@gmail.com> wr=
ote:
>
> On Mon Nov 23, 2026 at 2:24 PM CET, Amir Goldstein wrote:
> > On Sun, Nov 22, 2026 at 1:09=E2=80=AFAM koraynilay <koray.fra@gmail.com=
> wrote:
> >>
> >> Add fa_xflags_rw_mask and fa_xflags_ro_mask to struct file_attr and
> >> equivalent masks to struct file_kattr.
> >>
> >> Also add has_masks selector to struct file_kattr so we can know when a
> >> user of this API (userspace or filesystem) supports them.
> >>
> >> This lets filesystems advertise their support for specific xflags, lik=
e
> >> statx.stx_attributes_mask does, and userspace can specify only which
> >> xflags it wants to change without needing a RMW cycle:
> >> - on GET: each filesystem that wants to support this new API fills the
> >>   masks according to its supported and read-only xflags, then:
> >>   * for boolean xflags: it fills fsx_xflags with the current on-disk v=
alue
> >>   * for value xflags: it sets the xflag bit to 1 in fsx_xflags and the
> >>     xflag value in the struct field;
> >> - on SET: userspace fills the rw_mask with the bits of the xflags it
> >>   wants to change, then:
> >>   * for boolean xflags: it provides the xflag value as a bit in fa_xfl=
ags
> >>   * for value xflags: it sets the xflag bit to 1 in fa_xflags and then
> >>     provides the value in the struct field; if the xflag bit is set to=
 0
> >>     instead, this informs the kernel to unset/clear that value.
> >>
> >> Since fa_xflags_rw_mask means "I want to change the xflags specified i=
n
> >> here", if userspace specifies fa_xflags_rw_mask =3D 0, only check for
> >> permissions and fileattr support without checking any xflags.
> >>
> >> Behaviour of older programs that already use file_[gs]etattr() is
> >> preserved by checking against FILE_ATTR_SIZE_VER*.
> >>
> >> Also add the missing FS_XFLAG_PROJID xflag, to allow userspace to set
> >> the projid using file_[gs]etattr() by leveraging the new masks.
> >>
> >> Finally, in order to prevent the legacy FS_IOC_FSSETXATTR from accepti=
ng
> >> FS_XFLAG_PROJID, add a FS_FILE_ATTR_XFLAGS_MASK to support new xflags
> >> and use it to validate/clamp both the _xflags fields and the masks.
> >>
> >> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.11
> >> Signed-off-by: koraynilay <koray.fra@gmail.com>
> >> ---
...
> >>         err =3D fileattr_set_prepare(inode, &old_ma, fa);
> >> @@ -424,6 +504,14 @@ SYSCALL_DEFINE5(file_getattr, int, dfd, const cha=
r __user *, filename,
> >>                 return error;
> >>
> >>         fileattr_to_file_attr(&fa, &fattr);
> >> +       /*
> >> +        * Remove xflags added in or after VER1 so userspace programs =
compiled
> >> +        * against VER0 don't try to write xflags they don't know abou=
t (since
> >> +        * they do RMW).
> >> +        */
> >> +       if (usize < FILE_ATTR_SIZE_VER1)
> >> +               fattr.fa_xflags &=3D FS_XFLAGS_MASK;
> >> +
> >
> > This looks odd.
> > old struct size with new flags should be -EINVAL not silently drop them
>
> Right, and the GET path should strip any new flags, so old programs
> doing RMW will never see them, correct?
>

Yes, I think so.

> >
> >>         error =3D copy_struct_to_user(ufattr, usize, &fattr,
> >>                                     sizeof(struct file_attr), NULL);
> >>
> >> @@ -460,10 +548,6 @@ SYSCALL_DEFINE5(file_setattr, int, dfd, const cha=
r __user *, filename,
> >>         if (error)
> >>                 return error;
> >>
> >> -       error =3D file_attr_to_fileattr(&fattr, &fa);
> >> -       if (error)
> >> -               return error;
> >> -
> >>         CLASS(filename_maybe_null, name)(filename, at_flags);
> >>         if (!name && dfd >=3D 0) {
> >>                 CLASS(fd, f)(dfd);
> >> @@ -479,6 +563,30 @@ SYSCALL_DEFINE5(file_setattr, int, dfd, const cha=
r __user *, filename,
> >>                         return error;
> >>         }
> >>
> >> +       /*
> >> +        * Userspace said "I don't want to change any flag", so be it =
I guess.
> >> +        * Still check for fileattr support and permissions, also in c=
ase this
> >> +        * is just a probe.
> >> +        */
> >> +       if (usize >=3D FILE_ATTR_SIZE_VER1 && fattr.fa_xflags_rw_mask =
=3D=3D 0) {
> >> +               struct inode *inode =3D d_inode(filepath.dentry);
> >
> >
> > No No this is not what this userspace said!
> >
> > This user space is the same old chattr programs recompiled with a new
> > fs.h header file
> > installed.
>
> Oh, right, I did not think about this case, I hope it doesn't break too
> much of the new code I changed already for v2 :(
>
> > When userspace does not set anything is masks it means "old API"
>
> And so a modern program using masks that passes rw_mask as 0 should be
> also interpreted as "old API", even if it kinda goes against the
> definition of rw_mask right?

Yes, but it is not a problem to describe this backward compat exception:
When (rw_mask | ro_mask) =3D=3D 0, it means "no mask" "set everything"
but then vfs will not accept new xflags that were not supported in v0
syscall.

> And other than VER there is no way to know if it's a SETFLAGS compiled
> against modern fs.h or fileattr VER1 explicitly setting rw_mask to 0,
> right?
>

SETFLAGS with explicit 0 rw_mask is not useful and does not make
sense, so there is no reason to support this in any other meaning than
legacy programs.

Thanks,
Amir.
