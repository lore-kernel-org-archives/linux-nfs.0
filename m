Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.48
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1795685018;
	b=jvfGYg6pgRAlgaybSebReLuWNmsu0PVQwnohCrIblRVwxSRSF/99aqK4RF2WPhQDUR8p
	 DvGlzWZr7DdepIMRz13gQfsqrSJ6R5OVv7SYFkXdZTCVblIk53TmEkWoEFt/5d59djckF
	 bo9+EbVMHW0mX3UT2uI7WRlLCzivv669GgdtaD8cMM3b383O20vT9aC6nS4Z0UiMON6zT
	 XEYSo+OtA1HeHF0PDew3dQfeWLsyZ0OMEDa+ngr/yAkFu4r/pieWnwARYyaOc2LXKm74u
	 MYZf1Hic8vm0IxvMeVpGkaqS/S2fM1YzdKJLZCcJLetj+6AQrYTHCfp7O3oYnU6Ismw==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795685018;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=xckR6blDjDVAhqTSlG7y2c/dJk+7MAk3ZiUn44VZKcw=;
	b=NEUKkFl0D3jBuxRKvSuCcDOmu/kpb8AcX6/FEZx0gKFeRZtg9J6R5VYJH20uScuLJlkV
	 /ZxVjW+BTgnCDEuhrikCyfKswvXzyU1QwuV9ATGwmJdX1bvP6aQMGKs9alKN963QcAqkQ
	 hc0J/mYFPIkRdOQzrIxHT1AUkYAyFaH8jN9Mzxy0ciWr+gyFbriy6ZF516a3Ro+GYypC1
	 fWrswUyvett8NvBE7IeYXQRJPROOMYsFQjL+hZTtmXwPHNf+Ju3RFhNvj8fhtk+lLqFpq
	 xGUzcm2xlLZQrGt25v5aP6UJhxV5u26KZn0TZntGnKACPZ4L8oEsTBvpxAeaoZ5CyUw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=htZC86Pa;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.218.48
Received: from mail-ej1-f48.google.com (mail-ej1-f48.google.com [209.85.218.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 461A0606A327
	for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2026 09:23:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 461A0606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=htZC86Pa
Received: by mail-ej1-f48.google.com with SMTP id a640c23a62f3a-c4322d310e7so166027466b.0
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2026 01:23:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1795685016; cv=none;
        d=google.com; s=arc-20260327;
        b=ssQoGjNXnih/uPKXNmplQyYTmtUdqdtrpQ/64zVJEQd3nAU/mrdz0cgDrz/gYpr2FN
         8z7ZH9CcJ/arwrDwhsMQVy+Q7rtqWLiQRWeOuGiKjvGZXSRsoJ6k6YIZsDkWcwmgXTvG
         ovgLsnnt/gxbdUDn5xeTaZCmi58GWS99Yoe24zoEvN2IEvNA/XD1R+MOUmQsfpC7FBUx
         frDuJCMUriwmy99yjfmBShSLe8k84ABFjhgyPizJNWA1gc1S03dWt0ooBdMfWwT6Ia2U
         ywz1LU5DE7zHKeOom6UWDxtr3d69G/rQxAPbcqKSkLPoJZYzppHIyt6Ef/KkKQqcWCVp
         Djww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=xckR6blDjDVAhqTSlG7y2c/dJk+7MAk3ZiUn44VZKcw=;
        fh=XIQOUithpUvjXnCU58kxRmR8uHjHfbz9BoVMPjsIxps=;
        b=JGS0idKd4pA0rFGNRQoQet7yAJHJCBMf5YVdv0R9HCiY7qHh4IJ4alMyIUCKKIY83a
         shCFSD6Q19teuuq67fZEyOYlQkF4xAjeReQEb+jn98Wzxk6FC1HC/EidnjXmDnkfnyFp
         D0yDVDMPR7c5EsJb67WxqSUDHywHNbQZrM8Q2mkTGmow9HU+tJPqEXflVXHXyvmw+uaN
         9gEDBoLjgUmWeTsNjJKkc4Vrr0cyeGdJQHH4wc7s9MPgvEnJGVtT0t3w4UupvjPRRELc
         Ahm9jsP9Rg68+Rdt6U8dgLZb53T5lb2YEA6b4UqtzzoQdwz3EiusUYBzhydMLOP820nB
         ajNQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795685016; x=1796289816; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=xckR6blDjDVAhqTSlG7y2c/dJk+7MAk3ZiUn44VZKcw=;
        b=htZC86PaPTG34kYWAisdWcgHJD1UzaMIQvA1regyq5nViPY53KsD3NsllAndQX1evi
         Ni4eoDAvoFkwSVjRH2aLo8DK1It6q5/8NfVeByru4dF9S6/VEXj+TZJ5U8mChY30w0Uv
         jcCx/2OSR9wIj7x8YmXDsxOsBKo6p3Q3ujwy/4TdmbIF5u+YX04R1Bv1QF0hLopIVtio
         PngI5fpJQ1uCiosc+uFsN8S0QqiNZJdqLTNdOL6uay7GyqwBy7ErG/e7G5Nk2oTVO/wr
         64NWwOk7mZ5vgAa+kdjPvHzrMIdBU6PYX15ePP1qntAbHhcwn6ZQtcGoRW3QJj2GibeU
         nxqg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795685016; x=1796289816;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=xckR6blDjDVAhqTSlG7y2c/dJk+7MAk3ZiUn44VZKcw=;
        b=diSq7Qt6LP6JvRSilQdVeJ0+9Nd8kE15QcWWW7tgR9AghbyGqHwBfPrjPF8O1RmUyh
         hfA1Eo+gbTFULs4BjaxHpMkIix0VnI4XsPqZcUo52o7AM5x8GHPf5mbs0dCa76gz/1GV
         3RnmsVlIGb7D/LcFvVwAf02hL67golUBQjwIsObawjJ1cT9AGavBDcMIjBGjsOTOsNKs
         Z6FgGsr1br6kJ2z6cvSkBKzRluJDrdRl9sxyKm36zmRjWx0LxVb+M3mC4fe6f72XR30d
         aZr507SFMM21oQD57Wr/az39BO88pJy6bQuhQaHu0DsgECIY8RC4l3FePgBhtf+GBDh5
         OYug==
X-Forwarded-Encrypted: i=1; AL+hErGLytK+fHjZJIIqXNBj7Sa5EEtZLYfLi2ZCdMlWVxeJmooZAQ7gqPmRPW7DmgWt0X1lpN4OrgMtRak=@vger.kernel.org
X-Gm-Message-State: APuU4Z9C88ee7SRW0HHNLdyOEJx0wFvVwhP6r7zC/2TSW3T9ACGUmmLo
	gcMYJIQXjHlH0vmVAs99UOMUVy37YWaFmhKtZLxgC6DLMbhVqcNgbvKTyMrp+59UTr7UO/8x6cN
	kdBHABwvZBR8Rq4AbOjciR0mp06oNxK0=
X-Gm-Gg: AZFdTZdJvEhOOjYwy2tsbqCcBCKitsHWPaZYhBK9yVrLEukP0BpsZ523IkGTApwmpdp
	/cyvk7i3f5CE+6ls63ErYn+aAvH89vArPE1nCvMki9bUatpEVUCjqpa9VTUwFPe0eBjcFIajet1
	8hDMDOVr5Es4Qm9JYh1UA4aycbb1RblejYcPgL3unA7qEty1CwxeEnfaIZMaQa4QzlGtlCtEv5g
	VEk9j64d0IYFWGg/zE66cRmQ0ZuS14yMER4YKgah+4JC2oiL6s2JkZszDwtHDg+9Ba4M14yEOck
	wae++U61PRD6ZzbcnyI7igdr8MmCHe2InX6V2Z2gXRpsnRisRUs/fiSXpcKxTLNFdhRcTDSge3u
	EKMF0OGN5NPqFHI8DbxWZayRYybuloPYeDmNmnmAXez1AGBvunq/N0cc1BfRJ27vYJkXylA==
X-Received: by 2002:a05:6402:1501:b0:6b7:182c:5d4e with SMTP id
 4fb4d7f45d1cf-6ba37c7c3a6mr11134218a12.5.1795685016112; Thu, 26 Nov 2026
 01:23:36 -0800 (PST)
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
 <CAOQ4uxhegn1z=41_MHL1Zu2hXuPtzNhC=x4gd371oaeJE4-weQ@mail.gmail.com>
 <DN2N6A68PBO1.2QT8ZOARF4I6L@gmail.com> <CAOQ4uxhDQqEQ3T9NveBFpUmSU032BxrNV5D+_zHj8u9LOQY+qg@mail.gmail.com>
 <DN4DRUYPHYMP.20U4DYV5VBN7P@gmail.com> <CAOQ4uxg0g+XkPb3-kQS5ez1-rp7Q=BkYDHW0CGOFhpbcf70yMg@mail.gmail.com>
 <DN4KLSM2OO0K.2C8Q5CPFBVNL6@gmail.com> <CAOQ4uxhpJygZH-arLFSUYEEfqFG96Sr3_6CWakfSkdWxEsOxMg@mail.gmail.com>
 <DN50PH7HHSWZ.3H4T25JFPQECY@gmail.com>
In-Reply-To: <DN50PH7HHSWZ.3H4T25JFPQECY@gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 26 Nov 2026 10:23:23 +0100
X-Gm-Features: Aa3M54qgNadyHP5LQf6BsvKupVU6AY9XgOmNRBH-yAFSYibTS_3xHgBMtDNHcI0
Message-ID: <CAOQ4uxgJTSspRJqRFaSJxKUShVULaJpMv8UhBFR-DV2kUe1sXw@mail.gmail.com>
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

On Thu, Nov 26, 2026 at 9:59=E2=80=AFAM koraynilay <koray.fra@gmail.com> wr=
ote:
>
...
> >> > Attributes that have X_value like fsx_projid have few types:
> >> > 1. 0 means disabled (all existing values incl. projid)
> >> > 2. 0 is a valid value but cannot be unset (btime)
> >> > 3. 0 is a valid value and NULL/unset is also a valid value
> >> >
> >> > Only for type 3 does can the interpretation of
> >> > (!XFLAG_X && !fsx_X) be considered as an "unset"
> >> > and anyway, this will require support in individual fs.
> >>
> >> IMO !(xflags & XFLAG) && (rw_mask & XFLAG) should clear/unset the valu=
e
> >> in all cases, ignoring what's in fsx_X.
> >>
> >> And all existing values would be of type 1 for VER0, but of type 1 + 3
> >> for VER1.
> >>
> >
> > I agree that this will be more consistent.
> >
> > With explicit opt-in to FILEATTR_MASKS API
> > vfs can determine that
> > (!XFLAG_X && !!fsx_X) is alway -EINVAL
> >
> > When fsx_X =3D=3D 0, the value of XFLAG_X does not really matter
> > so filesystems can decide themselves if they want to act on
> > an "unset" flag or not.
>
> Hmm, I think fsx_xflags should have priority over the value in this
> _masks API.
>
> In my mind, to clear PROJID a userspace program would only need to do:
>
>   struct file_attr fa =3D {
>         .fsx_xflags =3D 0,
>         .fsx_xflags_rw_mask =3D FS_XFLAG_PROJID
>   };
>   file_setattr(&fa, AT_FILE_ATTR_MASKS);

If the program (e.g. chattr -p) internationally sets rw_mask =3D FS_XFLAG_P=
ROJID
what do we gain from not requiring the program to also set fsx_projid =3D 0=
?
I just don't see any wins for anyone from this design choice.

Maybe I am missing something.

>
> and have projid cleared (same for EXTSIZE/EXTSZINHERIT/COWEXTESIZE),
> while to set/change it:
>
>   struct file_attr fa =3D {
>         .fsx_xflags =3D FS_XFLAG_PROJID,
>         .fsx_xflags_rw_mask =3D FS_XFLAG_PROJID,
>         .fsx_projid =3D 67,
>   };
>   file_setattr(&fa, AT_FILE_ATTR_MASKS);
>
> and this:
>
>   struct file_attr fa =3D {
>         .fsx_xflags =3D FS_XFLAG_PROJID,
>         .fsx_xflags_rw_mask =3D FS_XFLAG_PROJID,
>         .fsx_projid =3D 0,
>   };
>   file_setattr(&fa, AT_FILE_ATTR_MASKS);
>
> would have the same result as the first snippet, but not the same
> meaning, since this would mean "set projid to 0" while the first snippet
> means "clear/unset projid" (but in this case, for projid and all the
> other already existing fsx_* it would have the same result).
>

As I wrote it could matter per attribute and per filesystem
whether set to 0 or unset is different.

The man page language should be flexible enough about this point.

It only needs to document the invalid combinations.

When proposing an UAPI change I often included a man-page draft
as a proof that the UAPI can make sense to human readers.

Thanks,
Amir.
