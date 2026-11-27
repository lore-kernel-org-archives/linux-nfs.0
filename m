Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795805298;
	b=n8H7hekl5GU3oBOsU2ewE4oLSFB7BvHOryEQxII4YZ5R51rThFT+GuxY8Hsg9fA3Q3Aa
	 236pEmPuE3SLj7EQK+d/16xY1ZzJNGy9mo1itpu5UsJrHV8mOk2y5jAiP9G1QtTKuxgCr
	 +BkABNS/bSFkdaX+JALIUG4X10UVrsltUuE3kDWR/siCXxjv0wls/gzU+PrOTpcsgSXx7
	 rqcr4e67DJ2xaB2Iekooo39ystRJD6aPzQHOSQzZJbR4GmH+SUaiJIigLhQnBecEx+582
	 zHwVMCh2PqoeGqBfJAqu1+LYXm4wnAnJxGgDu66Ujg+aytKdD39fGCZXjz+ICtNQB7g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795805298;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Subject:From:To:Cc:X-Mailer:
	 References:In-Reply-To;
	bh=oy7FTT2Z4DmSg2OYB5b2jigZEgUI9eD6ki27DGKKGCM=;
	b=uwBSc6J2UmWa80wZk6wqH2xrKvcbs+X3dx5pMAw6AgN7Nt7nKm2noeOWEmHgURhJEsKP
	 tAyHnuRTR6TmRlt5InHlS0GF+R25EyFBWC3QjI0G2V1s9aDYXyIurFwnkrRE1323rgm4J
	 jKu16Pj1xy1LF+SUSykZjHc4+B1pzBTyaqHHmYDOqzrARfsqqqMrREbOdn5zgsynZEUPm
	 eMJgNBZNWaXcgZIRK43F8P6+jbs/3oVrieleKkrGB9IwAZeKdWgO6iQqaHu952QBLLYCQ
	 F9Ht4edlQOkPe7oAmnjXv/1eY0sOqQNZ4R8gNDdHKyLAhPSr65NPRb0qOfa9oVOn6JQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="T/+qZfLV";
	arc=none smtp.remote-ip=209.85.128.46
Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com [209.85.128.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55A9A606A334
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 18:48:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 55A9A606A334
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=T/+qZfLV
Received: by mail-wm1-f46.google.com with SMTP id 5b1f17b1804b1-4a35a60499eso65196115e9.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 10:48:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795805296; x=1796410096; darn=vger.kernel.org;
        h=in-reply-to:references:cc:to:from:subject:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=oy7FTT2Z4DmSg2OYB5b2jigZEgUI9eD6ki27DGKKGCM=;
        b=T/+qZfLV5CjkJ4gFPi4nyjg/gd6831Z+GldIEfpiK46L4apaQ728C4F8xVanPkaGN8
         +dqukTCri/9Z2lEROHzCcX+7h8eB/3SOxZWG0twbXbwnBvC2UNeY+pM4hOrXwXqrnzeO
         Pdiku14AUoK0mzCwX+t3nvaBIymxGT+KxrmWYCMnlx/pzfzhS7brXI3lYQGHw0yXPBQ2
         SlJOy7A2EU9ynQRDDcscE2E9eRToPqWgkJAfwk/T4sq9tD93oXqHe4lzeq0l/lGp3SYa
         Q/Yti1C3lYMQZwaFxWy+39Kane8NUQFff3eN19MEnhb4PMohvJ3C6grSpwhVB4Dko78v
         sEWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795805296; x=1796410096;
        h=in-reply-to:references:cc:to:from:subject:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=oy7FTT2Z4DmSg2OYB5b2jigZEgUI9eD6ki27DGKKGCM=;
        b=uHbl21f9/v+6CI366XdiyoAiRO7r394ybrFSxWZLlOHBFXu9hjXRLWUhaHdJecOScz
         kPKLdWCBre9X4AzsemGFezm+J6ljbMqxRsWcYWbDbqLQGc59qu7GwSzgQss8K6qlBn+v
         5+uyWTbiyhIP6krwC0Ky0NPpR99IBYaMHeeYXSoO8WBBJxcR34Jqaiy9UmVpDSjNFDDY
         NZ/gz3B1EMWUTgkr2GNmnAYwYHxxuX//E0vrHmPnVt9DdfLiywfVt7nr6pGZVD22uoXx
         uas1MXYycN1PuhC7z4TihvzNHPsvP1gg2n1vnkpVEr9v2TXCTjtF8XiCTnLmuLrN3DzC
         TIgQ==
X-Forwarded-Encrypted: i=1; AL+hErGON1kxJQNFjyIFScWP6Uri7xkeetRhMSwfowMeF12b9W79EmnhUhin0OP5Makg4H5KSpANbGOYVoI=@vger.kernel.org
X-Gm-Message-State: APuU4Z/X5ssjIudDiTn7LK3wQTbLCqR9Nkd24ztQRMh5TqhQS/23h0s8
	fgqcsXj64oH/ZLrvz9xq4haVja+u8Tfy5R8w6L9aL5sZR7uPrzppx5C0
X-Gm-Gg: AZFdTZdbocpLL4scmknC6/z8eyPC7GOYgORbn3V442XkdwxfVVEfFbEE7qqoHnYdUCT
	nMhyw9UoE98Vcd2h/qAQBW4Ngg88Jmrg5meDAhSAQLvQWtb53MhYODGtqB6rxl4ae3jlcYLaozY
	XEmPc4evST7DdBonHF4yXSkfd9OTefanO17ug+i0VMcECuhfMEh0BJ/zJXilzMkujmra0p1GASU
	UqCCjKBf6T7GFX+xIlq4R7OmAsMnRgX8S1ZaU80+OFwvGtr3xfWQ7lkn0cIYFupW8Bre38M6rBX
	s4nKrOBAEXuZoOp26laYCEZ1fh8w7rlYBJGLiq1NIs8i5tWTfke8TPmOnPTXW5lVgvhAbqOSKVD
	CwmrCvVzdKXrlk9QeBBXuu3A/k3Z4vZ2/bkktccmcltgfUfl9nQf3E1PfMJhpZk2b+sMPBpLQ51
	r//FY+p0tFqF0OmUBL0reTDxNHElogTee35XVLeSfvvlfxcJaIa5d2TVWIZGYL43/I3R8QPRS70
	IJfJ8Vw63UGgvlPNXRj87oZJ2p7C6Urtgpp6l+fD6wrMeZckiR4HOdgaW1t6UNR9GMtJ2t2ELVE
	tIbjI+N7gapbxfRpnfJQM+IBAA==
X-Received: by 2002:a05:600c:4e0d:b0:4bb:69b2:d3b3 with SMTP id 5b1f17b1804b1-4bb8881eea5mr513199335e9.27.1795805295502;
        Fri, 27 Nov 2026 10:48:15 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb90655f5asm471463405e9.1.2026.11.27.10.48.13
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 27 Nov 2026 10:48:14 -0800 (PST)
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
 boundary=16029ccac70a6b44605f57a804e20e90125af7e99e5e6cc7ae776e1d3bab;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Fri, 27 Nov 2026 19:48:10 +0100
Message-Id: <DN67UHJNHO9H.CKHOY0N86Z9T@gmail.com>
Subject: Re: [PATCH v2 3/4] vfs: add xflags mask to fileattr API
From: "koraynilay" <koray.fra@gmail.com>
To: "Amir Goldstein" <amir73il@gmail.com>, "koraynilay"
 <koray.fra@gmail.com>, "Christian Brauner" <brauner@kernel.org>
Cc: "Namjae Jeon" <linkinjeon@kernel.org>, "Hyunchul Lee"
 <hyc.lee@gmail.com>, "Eric Biggers" <ebiggers@kernel.org>, "Theodore Y .
 Ts'o" <tytso@mit.edu>, "Jaegeuk Kim" <jaegeuk@kernel.org>, "Alexander Viro"
 <viro@zeniv.linux.org.uk>, "Chuck Lever" <cel@kernel.org>, "Jeff Layton"
 <jlayton@kernel.org>, "Jan Kara" <jack@suse.cz>, "Alexander Aring"
 <alex.aring@gmail.com>, "Darrick J . Wong" <djwong@kernel.org>, "Andrey
 Albershteyn" <aalbersh@kernel.org>, =?utf-8?q?Pali_Roh=C3=A1r?=
 <pali@kernel.org>, "Lauri Gates" <lauri.gates@gmail.com>, "Christoph
 Hellwig" <hch@infradead.org>, "Dave Chinner" <dgc@kernel.org>,
 <linux-btrfs@vger.kernel.org>, <linux-xfs@vger.kernel.org>,
 <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
 <ntfs@lists.linux.dev>, <linux-nfs@vger.kernel.org>,
 <linux-api@vger.kernel.org>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261126163114.403846-1-koray.fra@gmail.com>
 <20261126163114.403846-4-koray.fra@gmail.com>
 <CAOQ4uxhA+93bo5WseLxe7cAvJHJ8eQodoQHLwh=iToyEVkeXEA@mail.gmail.com>
 <DN66YKVRVRU7.1062V6NCL4LUW@gmail.com>
 <CAOQ4uxi6oyFj_A9nPbgGeSufGo11L2N=QxLi2DW=ZKy25YQ5Tw@mail.gmail.com>
In-Reply-To: <CAOQ4uxi6oyFj_A9nPbgGeSufGo11L2N=QxLi2DW=ZKy25YQ5Tw@mail.gmail.com>

--16029ccac70a6b44605f57a804e20e90125af7e99e5e6cc7ae776e1d3bab
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Fri Nov 27, 2026 at 7:41 PM CET, Amir Goldstein wrote:
> On Fri, Nov 27, 2026 at 7:06=E2=80=AFPM koraynilay <koray.fra@gmail.com> =
wrote:
>>
>> On Fri Nov 27, 2026 at 6:48 PM CET, Amir Goldstein wrote:
>> > On Thu, Nov 26, 2026 at 5:31=E2=80=AFPM koraynilay <koray.fra@gmail.co=
m> wrote:
>> >>
>> >> Add fa_xflags_rw_mask and fa_xflags_ro_mask to struct file_attr, both
>> >> __u64 to match fa_xflags' size, and bump FILE_ATTR_SIZE_LATEST to
>> >> FILE_ATTR_SIZE_VER1, which is now 40 bytes.
>> >>
...
>> >> +
>> >> +       /* Convert between formats and initialize missing bits from o=
ld_ma */
>> >>         if (fa->flags_valid) {
>> >> -               fa->fsx_xflags |=3D old_ma.fsx_xflags & ~FS_XFLAG_COM=
MON;
>> >> -               fa->fsx_extsize =3D old_ma.fsx_extsize;
>> >> -               fa->fsx_nextents =3D old_ma.fsx_nextents;
>> >> -               fa->fsx_projid =3D old_ma.fsx_projid;
>> >> -               fa->fsx_cowextsize =3D old_ma.fsx_cowextsize;
>> >> +               if (!old_ma.has_masks) {
>> >> +                       /* FS_IOC_SETFLAGS */
>> >> +                       fa->fsx_xflags_rw_mask =3D 0;
>> >> +                       fa->fsx_xflags |=3D old_ma.fsx_xflags & ~FS_X=
FLAG_COMMON;
>> >> +                       fa->fsx_extsize =3D old_ma.fsx_extsize;
>> >> +                       fa->fsx_nextents =3D old_ma.fsx_nextents;
>> >> +                       fa->fsx_projid =3D old_ma.fsx_projid;
>> >> +                       fa->fsx_cowextsize =3D old_ma.fsx_cowextsize;
>> >> +               } else {
>> >> +                       err =3D fileattr_set_legacy_to_mask(fa, &old_=
ma);
>> >> +                       if (err)
>> >> +                               goto out;
>> >> +               }
>> >> +       } else if (!fa->has_masks) {
>> >> +               if (!old_ma.has_masks) {
>> >> +                       /* FS_IOC_FSSETXATTR / file_attr VER0 */
>> >> +                       fa->flags |=3D old_ma.flags & ~FS_COMMON_FL;
>> >> +               } else {
>> >> +                       err =3D fileattr_set_legacy_to_mask(fa, &old_=
ma);
>> >> +                       if (err)
>> >> +                               goto out;
>> >> +               }
>> >>         } else {
>> >> -               fa->flags |=3D old_ma.flags & ~FS_COMMON_FL;
>> >> +               /* file_attr VER1 */
>> >> +               if (old_ma.has_masks) {
>> >> +                       /*
>> >> +                        * Don't preserve non-common flags since file=
systems
>> >> +                        * with masks only use xflags
>> >> +                        */
>> >> +               } else {
>> >> +                       /*
>> >> +                        * Filesystem doesn't support _mask API yet, =
switch to
>> >> +                        * old rmw format.
>> >> +                        * PROJID is supported like the legacy masks,=
 but will
>> >> +                        * be stripped during conversion.
>> >> +                        */
>> >> +                       err =3D fileattr_set_mask_to_legacy(fa, &old_=
ma);
>> >> +                       if (err)
>> >> +                               goto out;
>> >> +               }
>> >
>> > I stand behind my earlier comment - this is too much for open coding
>> > here. I won't suggest a better factoring I am sure you will figure out
>> > one by yourself. focus on readability and reviewability please.
>>
>> Hmm, ok, I'll try.
>> Can I keep the comments though? (changing them a little maybe)
>> I think it's important to have them since we're dealing with bitwise
>> operations and a not so easy to understand logic.
>>
>
> I have no problem with the comments.

Ok.
>
>> >> diff --git a/include/uapi/linux/fs.h b/include/uapi/linux/fs.h
>> >> index a13c7b32a1bd..63d88ebe3420 100644
>> >> --- a/include/uapi/linux/fs.h
>> >> +++ b/include/uapi/linux/fs.h
>> >> @@ -238,10 +238,13 @@ struct file_attr {
>> >>         __u32 fa_nextents;      /* nextents field value (get)   */
>> >>         __u32 fa_projid;        /* project identifier (get/set) */
>> >>         __u32 fa_cowextsize;    /* CoW extsize field value (get/set) =
*/
>> >> +       __u64 fa_xflags_rw_mask;/* supported writeable xflags (get) /=
 flags to set (set) */
>> >> +       __u64 fa_xflags_ro_mask;/* supported read-only xflags (get) *=
/
>> >>  };
>> >>
>> >>  #define FILE_ATTR_SIZE_VER0 24
>> >> -#define FILE_ATTR_SIZE_LATEST FILE_ATTR_SIZE_VER0
>> >> +#define FILE_ATTR_SIZE_VER1 40
>> >> +#define FILE_ATTR_SIZE_LATEST FILE_ATTR_SIZE_VER1
>> >>
>> >
>> > Man... we really need a bot to review all UAPI changes
>> > Please someone tell the bot to check
>> > NO LATEST/LAST/ALL constants in UAPI headers!!!
>> >
>> > Your patch does not introduce this constant in UAPI but if we change
>> > it we risk spreading different versions in installed headers.
>>
>> You mean someone having different versions of the header, each with a
>> different FILE_ATTR_SIZE_LATEST?
>>
>
> Yes, I think this is bad practice.

Ah ok.

>> > Honestly I see no reason for FILE_ATTR_SIZE_VER* to be in UAPI
>> > either. For other UAPIs those constants are not in the UAPI header:
>> >
>> > ~/src/linux$ git grep SIZE_LATEST include/linux/
>> > include/linux/fcntl.h:#define OPEN_HOW_SIZE_LATEST      OPEN_HOW_SIZE_=
VER0
>> > include/linux/seccomp.h:#define SECCOMP_NOTIFY_ADDFD_SIZE_LATEST
>> > SECCOMP_NOTIFY_ADDFD_SIZE_VER0
>> > include/linux/xattr.h:#define XATTR_ARGS_SIZE_LATEST    XATTR_ARGS_SIZ=
E_VER0
>> >
>> > So please move those contacts before adding/changing them
>> > (can be in the same patch IMO).
>>
>> Should I move them to fs/linux/fileattr.h?
>
> Yes please.

Okeh.

>> If so, all of them or only VER1/LATEST? (since they're maybe used by
>> some userspace program already (?))
>
> All of them.
> I doubt that someone is using them and it's easy to
> return them if needed.
>
> Btw, nsfs.h also has this pattern:
>
> $ git grep SIZE_LATEST include/uapi/
> include/uapi/linux/fs.h:#define FILE_ATTR_SIZE_LATEST FILE_ATTR_SIZE_VER0
> include/uapi/linux/nsfs.h:#define NSFS_FILE_HANDLE_SIZE_LATEST
> sizeof(struct nsfs_file_handle) /* sizeof latest published struct */
>
> This is not as bad as defining it to a constant (40) IMO, but
> I also don't really see the point of defining this constant in uapi,
> when programs can just do the sizeof() instead.

Should I make a separate patch for each one just moving them in their
in-kernel headers?
(or a single patch moving both fileattr's and nsfs's? since it's the
same kind of change)

Thanks,
koraynilay

> Thanks,
> Amir.



--16029ccac70a6b44605f57a804e20e90125af7e99e5e6cc7ae776e1d3bab
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQSgVimKafU5DQMcjcDmj22qf5IGXAUCawnQagAKCRDmj22qf5IG
XEPFAP0WY/ogYCs7CZPZ7xJp2AjprhL8TAV6fBXYiDTc2Y1zvwD/Z5SLL/+IDNeH
YSoTy/KESs1KeWq/BbG4JL9FnG6wlwE=
=qxyh
-----END PGP SIGNATURE-----

--16029ccac70a6b44605f57a804e20e90125af7e99e5e6cc7ae776e1d3bab--
