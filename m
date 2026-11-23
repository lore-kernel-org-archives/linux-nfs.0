Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.52
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795474624;
	b=nBtHFTBgxGHPCg5pZud/Nu3wCXY+W6GiKEGiwreLvggE6aX6LCgTV3ExeEHYf5glBFfV
	 FNBGQy3may/DQcBluuef+LO7FDCpRQafXFi6uGxGEoR8WWpnXW9zNfZVNr8YoWkj39vbK
	 D1ubS87rCievVUduZxWS+b4RWZVmCqJP6VayBb9Rl3Mdf+mks7YTuA81cYDkhSnYM/hcV
	 RZddRQrtb5YAnpFr3CHOPxHh+bIRiIedKQegOS2zNdlLqzPdxMc7TDPz8C10alb1SA32U
	 DoyUA8hWnnXcvQ78XNndVFiAQILSb4mhyqQ069GWWQ0yHkSdjJYvL5sCbKj4I/+H6KQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795474624;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=sPZNFd5TfGrxBwoDp6YQ8+YhzR/t7dsRFdx4A9ccfqM=;
	b=NdmNsm80n1kF1JuD6ds/9ev5wxoh1i3KcEKuWEt4dlKrThT6ynXE01ecT488FSObisZp
	 PmeTsjJVzO0SI5m8BNFoVRJLiOzFvHs6XQ7qkWeyAae/2VZlw0of2CjhqMQkekhHGDJS+
	 KCCKfn+xDz4ArOITcfrxPZXqx1pWuFEfFYwKphD+pdoAO2vr8IJQm0SnfT5OAIKJ+KX5y
	 +lG/5Qy5uT96/vJV4iJv+TO5qmi10cAoMgCwDv8yx0VziCwYM6IJZql9oAhvqzMBCjD0W
	 j8vO1cefjuREanEQiN+h+9lfJ4PVIPBJmP57QKXLs1TFL+bkVNQui8Y8gSBvd12S+sQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=PewkInMK;
	arc=none smtp.remote-ip=209.85.128.52
Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com [209.85.128.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74C66606A32D
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 22:57:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 74C66606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=PewkInMK
Received: by mail-wm1-f52.google.com with SMTP id 5b1f17b1804b1-4a5b2be99a8so33036165e9.2
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 14:57:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795474622; x=1796079422; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=sPZNFd5TfGrxBwoDp6YQ8+YhzR/t7dsRFdx4A9ccfqM=;
        b=PewkInMK7WQWpp6ySCG05xMLjFwiuXGYIL9fT6a9KwzGgdXqRBYaifRH2CCs4oC+TJ
         9yZqvbx2J4HMbE3hwKZNoBP4BEYdOLnO9xsvu1PBjg/7W4cDDVA0+4WXZfc2RE7QhasK
         HBraF594yoj2LikLhvrb2Uv5n0XCn3YbuZuSWNI772TsKs/Q903J6pw0WdUqI96slep9
         QaYENizaotcREWserlmvK7cWFjPgOZzu+Zxvwi5t/OeIxBywZgqVsutE0njlpRfcI7I2
         xvsJnbiQ51KTBY56x1ixrtXxIhGs7unzaQaI1DlshSs+Tk28V9lawW84OB1kZabVzJ1G
         lyAg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795474622; x=1796079422;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=sPZNFd5TfGrxBwoDp6YQ8+YhzR/t7dsRFdx4A9ccfqM=;
        b=UAksZXz331n9XGUW7VRUgX0G7dS2Pssxarthq6hSZ6SpGzIPp1attgVqZCsZXTo9uN
         hCusKnfM4c9Xj2vHKM4DwassUGFUGuBY92H6OfP79kpraMhQCkpbCxYRklp09rmSoJUt
         MxX6uUd3DMWyVl5LvOgiySkcy8fovdn8MsZlfxE3mMGTGq16VxLkF+ccT3GrE8/OJEKN
         6DzQEdZmWe6PF4mkfBNOIRph0jp7DCND00t8doAs+QZg67KMutMch3qFkBCoNerj6C0a
         ascG61wb4LcLhHxm1DdZ5MAZF7bW25OZ+5TGSJOEzRR8m6+bxhj8ha1ye/wSu0nuAdBK
         qsnA==
X-Forwarded-Encrypted: i=1; AL+hErHyDP8FYb0EzON/6Fp1lt9Muu0p+eBSNJhzUabrLwioTm1FWncE/WmjAdwl2U4iH/WP9OkHy3bLXvw=@vger.kernel.org
X-Gm-Message-State: APuU4Z80v5haLRoKiq9m+fevSnEZhNzelYZDyeNirueQBLF4x5+1X/zC
	cjnoPIj7R8/oijCy3LZElLpsgPuP8QDm+CXujWG45TSjJBq9akcFclpZ
X-Gm-Gg: AZFdTZf7LPCD5M8mpQ9/LfiWLsHmEeyoW1IAtANQb/JkNiaYFog/p2IYxXY46Dlhr53
	yk++Hl3bTChieAv8WHoCAJ9KxuFTLe4bkEErDV+1t90bkKPQH4Q9QCQ4Hoawt9qRGAJeqHcVF0j
	3OvvelQiV95x4gZBrIhQ8YiOW1XoUgRVeY0DTLzy92mC4rlDO6YjBO4L/nHwFtiqqpuczdl/K9m
	ooPqUPYZ3iEzq3Wa97g4Bcf0XEeQHNu4gB+ebwed6twEQoi58PKhFrpgxUYz97N8+mgStdNXlsx
	N+CIZ7JmtFxBgV5fzZ7TFT/dI5RPGEWpUvhbXatm18ucR2cM5FYWKSO12UlVl5KmY/kvUXIaWek
	vzbGjZ5FOLAPFRhVugaMXQbEF811AE+exejfN6paev/mKUGOk25YEvHcGONRMpfXg/1Gi6XySsq
	LKXhH+/2iOVRVdRwEC2Ga3uQxUzEtdQ9RLe7Ye0v8iaTxqEni9/YmfmfizDWa7Bp0NEsI/SIDhj
	Ut82Uq28NXt5BQWpYYzteWU/6DZ+K2I5zMM3q+P/JUZLUCZFNRPMhNDpsFsPTWMkhXzzaM/gGrd
	K3SbuImhb5a/VGMswk2NiGG14A==
X-Received: by 2002:a05:600c:1548:b0:4bb:7347:d5df with SMTP id 5b1f17b1804b1-4bb88814405mr279680765e9.13.1795474622192;
        Mon, 23 Nov 2026 14:57:02 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb884865a2sm387664415e9.3.2026.11.23.14.57.00
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 23 Nov 2026 14:57:01 -0800 (PST)
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
 boundary=087e7b3569ab5fea48a039af92ae6dae8d0b4b3bd53fcaa587687d1ee3aa;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Mon, 23 Nov 2026 23:56:59 +0100
Message-Id: <DN2YMTH77KWE.3IPE9OG8377X0@gmail.com>
Cc: "Namjae Jeon" <linkinjeon@kernel.org>, "Hyunchul Lee"
 <hyc.lee@gmail.com>, "Alexander Viro" <viro@zeniv.linux.org.uk>, "Christian
 Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>, "Jeff
 Layton" <jlayton@kernel.org>, "Jan Kara" <jack@suse.cz>, "Darrick J . Wong"
 <djwong@kernel.org>, "Andrey Albershteyn" <aalbersh@kernel.org>,
 =?utf-8?q?Pali_Roh=C3=A1r?= <pali@kernel.org>, "Lauri Gates"
 <lauri.gates@gmail.com>, "Christoph Hellwig" <hch@infradead.org>, "Dave
 Chinner" <dgc@kernel.org>, <linux-btrfs@vger.kernel.org>,
 <linux-xfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-fsdevel@vger.kernel.org>, <ntfs@lists.linux.dev>,
 <linux-nfs@vger.kernel.org>, <linux-api@vger.kernel.org>
Subject: Re: [PATCH 0/3] Add f*_xflags_{rw,ro}_mask flags to the fileattr
 API
From: "koraynilay" <koray.fra@gmail.com>
To: "Amir Goldstein" <amir73il@gmail.com>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261122000856.536902-1-koray.fra@gmail.com>
 <CAOQ4uxgf2KE=Ag13EPAu5=KnrFwt7zRH=im-qmLc8+i10Tjd+Q@mail.gmail.com>
 <DN2X3RC5JUFQ.2LNGLQOUX4ZPF@gmail.com>
 <CAOQ4uxhsv_1EEqAZ3Ebp5Uy8Q6nvEnE3EAomJjjQO86nTcW0cg@mail.gmail.com>
In-Reply-To: <CAOQ4uxhsv_1EEqAZ3Ebp5Uy8Q6nvEnE3EAomJjjQO86nTcW0cg@mail.gmail.com>

--087e7b3569ab5fea48a039af92ae6dae8d0b4b3bd53fcaa587687d1ee3aa
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Mon Nov 23, 2026 at 11:47 PM CET, Amir Goldstein wrote:
> On Mon, Nov 23, 2026 at 10:45=E2=80=AFPM koraynilay <koray.fra@gmail.com>=
 wrote:
>>
>> On Mon Nov 23, 2026 at 2:35 PM CET, Amir Goldstein wrote:
>> > On Sun, Nov 22, 2026 at 1:09=E2=80=AFAM koraynilay <koray.fra@gmail.co=
m> wrote:
>> >>
>> >> This is a follow up patch series stemmed from [1] and [2], splitting =
the
>> >> _mask change for the fileattr API into its own separate patch.
>> >>
>> >> The first patch is a preparatory patch so that the code in the patch
>> >> after can be formatted better.
>> >>
>> >> The second patch is the actual implementation, which introduces:
>> >> - fa_xflags_{rw,ro}_mask fields to struct file_attr
>> >> - fsx_xflags_{rw,ro}_mask fields and has_masks selector to struct fil=
e_kattr
>> >>
>> >> These masks have the following semantics:
>> >> - rw_mask:
>> >>   * for filesystems: advertise which xflags they support changing
>> >>   * for userspace: specify which xflags it wants to modify
>> >> - ro_mask:
>> >>   * for filesystems: advertise which xflags they support only reading
>> >>   * for userspace: ignored
>> >
>> > Nice!
>> > I think this API description is very clear and coherent
>>
>> By the way, should I use this description in the commit message (and
>
> You could use that as a short TLDR intro

Hmm, then would it be better keep only this for the commit message

>> integrate it with missing information before/after the bullet points),
>> or should I keep the current one?
>>
>> (current one:)
>> > This lets filesystems advertise their support for specific xflags, lik=
e
>> > statx.stx_attributes_mask does, and userspace can specify only which
>> > xflags it wants to change without needing a RMW cycle:
>> > - on GET: each filesystem that wants to support this new API fills the
>> >   masks according to its supported and read-only xflags, then:
>> >   * for boolean xflags: it fills fsx_xflags with the current on-disk v=
alue
>> >   * for value xflags: it sets the xflag bit to 1 in fsx_xflags and the
>> >     xflag value in the struct field;
>> > - on SET: userspace fills the rw_mask with the bits of the xflags it
>> >   wants to change, then:
>> >   * for boolean xflags: it provides the xflag value as a bit in fa_xfl=
ags
>> >   * for value xflags: it sets the xflag bit to 1 in fa_xflags and then
>> >     provides the value in the struct field; if the xflag bit is set to=
 0
>> >     instead, this informs the kernel to unset/clear that value.
>
> You can keep it also but tbh UAPI documentation is more useful in
> comments and in Documentation than in commit messages.

and add a documentation patch that uses this (maybe expanded/clearer
since it would be user-facing docs)?

> You and I have parts of the design in our heads w.r.t backward
> compat with legacy API, both UAPI and vfs internal api.
>
> I think you should put it in writing to see that you and I have
> not left anything out because this v1 surely does get it wrong
> in several places both wrt legacy UAPI breakage and internal
> API correctness.

It would also be useful for this actually, so I'll draft it tomorrow
and then send it as part of the patch series.

Thanks,
koraynilay

> Thanks,
> Amir.



--087e7b3569ab5fea48a039af92ae6dae8d0b4b3bd53fcaa587687d1ee3aa
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQSgVimKafU5DQMcjcDmj22qf5IGXAUCawTEuwAKCRDmj22qf5IG
XJSLAQDMKqaaLRonYupOnklcoeYgChReKj8OE4zSSu89z/D8OQEA7usw5cak0k1z
cR5yX9avh+N9tPTBs/BRmKcdA8wcowk=
=072h
-----END PGP SIGNATURE-----

--087e7b3569ab5fea48a039af92ae6dae8d0b4b3bd53fcaa587687d1ee3aa--
