Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794962121;
	b=b8FOcY67uft3so0E1ON8zC1Sbyl+yEI/TU8aVchlI+qgBw0Jiy67FrWvntPlhcBoMt/N
	 Su/cefs6EHw25wAwzujNHsGEMDB5Zc0cJRfoIBX3NhYfda7EYixZ5YdCLWbjJgUHxoYdI
	 dnDyJpgsL82eUSFLBlRfMlljabXiRArifix9idEapNBlHIL2gGP+QJIBSpBUc6p/OdG0/
	 i3grwvrf2C8D3WFc/x/Aqlei8rd/CeuvMax5lSbYCtinFgqfLbFkC2hU+lY8Wc33P3QFA
	 H/pbzio3HwFL2sDSr1AgZArxkrXUI+40nSzJBR0iya1kZeJa7yvRKeJhvkPHypndBfQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794962121;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:
	 Content-Transfer-Encoding:X-Mailer:References:In-Reply-To;
	bh=WbIzd+ctnJR4yFdsTDfSvvEGuowj5ndViMpewtBSJFs=;
	b=OZFqDUeBcTfIlKXbwRjxyDgGz4csOSZbSF5fOgKncCxVXL1aDXZy2CbLXMATYCB5ZEaD
	 ndOk4CaLfEAXAfBZeySWOoZsQm7SE9MnuGu2VAfGPnzDg6qt1SjDGZJkOskoFfPD440Fl
	 9Xac1cJjbAXCUXWJNbzA8fyi7pKZ38hevuipIICcRK4UbKmDIMRaThDEoJ1+p4kqjqoD3
	 TRR9OyxkgbmlfjDoyLP83UcPePMEZk/wokvboegbdlWV04mzbL7f0pDb7+A9By3VFwRX1
	 zrwfcGzy457Xd35oG+d1Cm3DTcE6yCL38a44vAMcALQ2/3aM9iK/0vVVDl+bhtCs8XQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=I7EoaNRr;
	arc=none smtp.remote-ip=209.85.128.53
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE428606A32A
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 00:35:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CE428606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=I7EoaNRr
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-4a35d5d4a20so4278205e9.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 16:35:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794962119; x=1795566919; darn=vger.kernel.org;
        h=in-reply-to:references:content-transfer-encoding:to:from:subject:cc
         :message-id:date:content-type:mime-version:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=WbIzd+ctnJR4yFdsTDfSvvEGuowj5ndViMpewtBSJFs=;
        b=I7EoaNRrjYH4pzshKWe3F3r2aVYu25lUfqy5WzaHWCsQFKNGu2CKyZEl8M77OEW20l
         ElFzDsY6y02yTK05Ld0CMF9SYfA3AZzm7GlAM8+4GYI7al7Ka+Qq7fK1eMo/foXENPr2
         u76HGEs1y1xGkF0GRs/MmlqkTIm0rZpSWYFjkEOW/yy49GI1HandgmmL2+P8W9lTwJ4v
         FbVJjCCpckG0p6epK7f5LESg5tBDdjuPqtcs0BxKjaA2x+BLQJCOpe6Cwhw48vSPUBWx
         atap5758sdew29z3hrp1l19YFfRLrLEF+dHij5BqeLeXUPNVcfW0rq6WcfiiQgmnzLUl
         lWHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794962119; x=1795566919;
        h=in-reply-to:references:content-transfer-encoding:to:from:subject:cc
         :message-id:date:content-type:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=WbIzd+ctnJR4yFdsTDfSvvEGuowj5ndViMpewtBSJFs=;
        b=ZgzJ2w/BEX8NrFfH+r8OCn8RGzQaymMJnAMuBlId4iQGcUvKhL6lWrscywjSbuC0dJ
         WEZ9B3EAqm4OnD9SYnAbtYRIYQp3F/XEhHJ/oCsKoFDh/TKU7v8P/lJ6XytE/c2egVy+
         OhDpM6H7pIWIPNvQ3p6gB7OxXx7IX+Lsl8UUKhEPrjPIPAeAOluuWxo1Kc4z1c0EaUqp
         44kWYjbhdrCLkAM3fgJk4S3AaLcxWVE/fi5r60fzkkuk9KjUaAjNzIvYLQ6+jn9nr8A6
         c86vLRvLk8LHYCuUx6LiINkgDlttXXThv48gxXQ5A75R4koazedQukkxrE5RObB6NYKK
         l2Ww==
X-Forwarded-Encrypted: i=1; AL+hErEQMJOyD8Q8NjYd2SeU90391WtZxLqv3pADosuy2ly5VSDEbfXgJJ6BzHlTWVMfnC2f5BBx/Sl0G70=@vger.kernel.org
X-Gm-Message-State: APuU4Z/LEhEJwA5h0RBOloalYrZUpIoG0Yk6BziBtqvRPioB9Gk6GIAn
	zdgTyMqCd5mo00Cvcmgz1QP/X6mmLPWdNa8ItWAgwawYlTaCOynqfhWw
X-Gm-Gg: AYBFou2UDiQEs4hZXmhOKM4NtnQCtAbNW2iYLISPXIauYEzhsnn68gm8xeKFmptXJ+w
	9HI9MOUkMEpg4dn/9Z8HKs+yE1nMTcfhQdTMw2Sau/FERI8BfJg1IYZSvkEGMqP8XAu6YiPHk7w
	00AohMEZVNnmIBDarARowK7lPmtePg6ILIfBMcsdR5ZPy80SGjlnQ86vSA3eYAvzPa+jlP+45kR
	C/bJsU6RSF8pt5E6SLBf2fuqm9N3sCuKFp1+lZeWXpRyWS7Tp9gKmhwfPqEamOmFRAJ8j4X+4Rl
	zKC3bgsvI7MQlBhc/XSN6smg0584OG6S0Ny0gEW4tP35vIM3vEAgDw1XfeLuKjSlWGUpgm8IH69
	kdjOVyDI+bge9zHg2lkCvgxWV5gEXuTHHxuM2jKTOgX3Ug11ksA/cwgfto/mk2v+/E6oKqUZ8f1
	PVUulXGYy4JYb6JI3xFFn0Y50T+smPdr4GYuZ4RjM/qa5UbCP0ChMjfnNIlLr7bPIrbvyFWNF9j
	yIvvXq84fKjqSpGKdZMu8gN7XktHjONOr/8X8yUKjGsXGXMHOCMMLWE36P7CFTxHSAF3/rnhDz8
	ncAdDykT9G2kTaDAexERCJNS9g==
X-Received: by 2002:a05:600c:1906:b0:4b2:2ec5:8a2b with SMTP id 5b1f17b1804b1-4bb7da13900mr16206835e9.10.1794962118973;
        Tue, 17 Nov 2026 16:35:18 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4a65560bd46sm1551151f8f.31.2026.11.17.16.35.14
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 17 Nov 2026 16:35:17 -0800 (PST)
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
 boundary=3f37a8250c17ef201a283aa9d15331a4c7b5582752331b03c03104ec5ba6;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Wed, 18 Nov 2026 01:35:11 +0100
Message-Id: <DMXWYQ9MORA5.XHWI9GTCCUMN@gmail.com>
Cc: "Chris Mason" <mason@kernel.org>, "Yuezhang Mo" <yuezhang.mo@sony.com>,
 "Jan Kara" <jack@suse.cz>, "NeilBrown" <neil@brown.name>, "Olga
 Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom
 Talpey" <tom@talpey.com>, "Ronnie Sahlberg" <ronniesahlberg@gmail.com>,
 "Shyam Prasad N" <sprasad@microsoft.com>, "Bharath SM"
 <bharathsm@microsoft.com>, "Sergey Senozhatsky" <senozhatsky@chromium.org>,
 "ChenXiaoSong" <chenxiaosong@chenxiaosong.com>, "Darrick J. Wong"
 <djwong@kernel.org>, "Sean Smith" <defendthedisabled@gmail.com>, "Andrey
 Albershteyn" <aalbersh@kernel.org>, "Pedro Falcato" <pfalcato@suse.de>,
 "Amir Goldstein" <amir73il@gmail.com>, =?utf-8?q?Pali_Roh=C3=A1r?=
 <pali@kernel.org>, <linux-btrfs@vger.kernel.org>,
 <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
 <exfat@lists.linux.dev>, <ntfs3@lists.linux.dev>,
 <linux-cifs@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
 <linux-api@vger.kernel.org>
Subject: Re: [RFC PATCH v4 07/10] nfsd: add provenance time (ptime) via
 FATTR4_TIME_CREATE
From: "koraynilay" <koray.fra@gmail.com>
To: "Chuck Lever" <cel@kernel.org>, "koraynilay" <koray.fra@gmail.com>,
 "David Sterba" <dsterba@suse.com>, "Namjae Jeon" <linkinjeon@kernel.org>,
 "Sungjong Seo" <sj1557.seo@samsung.com>, "Alexander Viro"
 <viro@zeniv.linux.org.uk>, "Christian Brauner" <brauner@kernel.org>, "Trond
 Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>, "Jeff
 Layton" <jlayton@kernel.org>, "Konstantin Komarov"
 <almaz.alexandrovich@paragon-software.com>, "Paulo Alcantara"
 <pc@manguebit.org>
Content-Transfer-Encoding: quoted-printable
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261115180343.576773-8-koray.fra@gmail.com>
 <f297d9ea-ebd7-47f4-ab7b-de5c45980000@app.fastmail.com>
In-Reply-To: <f297d9ea-ebd7-47f4-ab7b-de5c45980000@app.fastmail.com>

--3f37a8250c17ef201a283aa9d15331a4c7b5582752331b03c03104ec5ba6
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

Hello and thanks for replying,

On Tue Nov 17, 2026 at 11:01 PM CET, Chuck Lever wrote:
>
>
> On Sun, Nov 15, 2026, at 1:03 PM, koraynilay wrote:
>> Implement provenance time (ptime) in NFSD, as introduced in a
>> previous commit ("vfs: add provenance time (ptime)").
>>
>> Map ptime to FATTR4_TIME_CREATE, allowing clients to set it across
>> CREATE, OPEN and SETATTR compounds.
>>
>> If the underlying filesystem supports it, use __vfs_fileattr_set_locked(=
)
>> to set it, returning -EOPNOTSUPP in case it's not supported (i.e. when
>> __vfs_fileattr_set_locked() returns -ENOIOCTLCMD).
>>
>> When querying FATTR4_TIME_CREATE, request both STATX_PTIME and
>> STATX_BTIME, preferring ptime over btime if available, and advertise
>> FATTR4_TIME_CREATE support if either ptime or btime is available.
>>
>> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
>> Signed-off-by: koraynilay <koray.fra@gmail.com>
>
>> @@ -3646,7 +3649,14 @@ static __be32=20
>> nfsd4_encode_fattr4_time_access(struct xdr_stream *xdr,
>>  static __be32 nfsd4_encode_fattr4_time_create(struct xdr_stream *xdr,
>>  					      const struct nfsd4_fattr_args *args)
>>  {
>> -	return nfsd4_encode_nfstime4(xdr, &args->stat.btime);
>> +	const struct timespec64 *ts;
>> +
>> +	if (args->stat.result_mask & STATX_PTIME)
>> +		ts =3D &args->stat.ptime;
>> +	else
>> +		ts =3D &args->stat.btime;
>> +
>> +	return nfsd4_encode_nfstime4(xdr, ts);
>>  }
>
> I have trouble with this approach.
>
> We've already established that, for the Linux in-kernel NFS server
> implementation, FATTR4_TIME_CREATE reports a file's birth time and
> does not permit NFS clients to modify that.
>
> After this patch is applied, the server reports the ptime instead
> of the btime on some filesystems but not others.

I implemented it in this way to have a proof-of-concept of how ptime
could be use by filesystems that already support settable btime (as was
suggested to me in [1]).

There was also a discussion in v3[2] on NFS's FATTR4_TIME_CREATE as an
example of such a filesystem

> Essentially this changes the semantics of existing files that have
> a btime set -- technically that's a regression.

and since the NFS protocol itself states that FATTR4_TIME_CREATE should
be user-settable, I think adhering more to it would be better.
This would be fine even for already existing files IMO, since btime =3D=3D
ptime if the user doesn't manually change it (or with --preserve=3Dptime
for the various copying tools).

Thanks,
koraynilay

[1]: https://lore.kernel.org/CAOQ4uxiuy0VwZj+3M-zRqQ49WTpHZpiaQ+6MZ8z8WdLjy=
QM_zA@mail.gmail.com/
[2]: https://lore.kernel.org/20261103094906.n55n5dhrpct5ykmw@pali/

--3f37a8250c17ef201a283aa9d15331a4c7b5582752331b03c03104ec5ba6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQSgVimKafU5DQMcjcDmj22qf5IGXAUCavzyvwAKCRDmj22qf5IG
XOsRAP4vh5FXH5uGRieLcNxmpyXktFYo5TTK0/smQUKH1S3W4AD+OFSrMDbk0OBL
bbF4a80MG9QJTSNaQXnZOrSA4Bhhew4=
=tiHS
-----END PGP SIGNATURE-----

--3f37a8250c17ef201a283aa9d15331a4c7b5582752331b03c03104ec5ba6--
