Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795013893;
	b=nYMGvlRfYfdl2bDtsxP6OuTzMv9EkyQDtygZS7UG3i3HlTshO9kox2M1Q2c/4vwKj7aC
	 a0W+alGRRZACxcAOUsFxPf6Y9pOlc1QWSxPBqlZOd3cMbG/5PYBiSt7pv10QZD+FvevPC
	 hTqE1mCZUNSM7ZoNEUdfYuCCmkHQ1csQywVTA6dzrU/QIyOEtg0AjWE+t1DsvL0oU1+ud
	 mVehaYMJ94V5A0COdNBX3v//Genn6HnX9I7jijVYnaaUdlRYyMMKxCbwX0zvi0C75Z2MV
	 cbsRdxxip7R9q8szbcEOF2BGKwha/dRh0f9uEudbvjBUduFRzx/gEp7mmYZuHvp8osw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795013893;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=Pp/RLPMZ3GifsKTDdh8Pk/uftsOfh5azJIs0J3c6Xr8=;
	b=ukupy9uJzlLke/ZGNQwPSoHtwpY7Mp9fcB9eHAc7D+jV/lpTXhQezfLuvQZdfELa5p3V
	 yuIAokvC4tLNrBAC5Mbq/459gaVwft0KCkafDT8WDwsZOhxLAtsJjL619arFSjLJhyHWV
	 soOiSQX+bdisNMkACNA+ydDtQMXkUnQn3vNyk9j374OA8ar7QiEOZaNzcdG8DeLj0K1+C
	 AeRJWfWsVIKYsA1e4v9rYOkk1uZdwJXxfIzHRa5RbyfaMLK98PVVkquWHxe1ph/1b+7g0
	 HmYRG7Vblu6hkpOaLucKNikz5mC47iyeSDCYZK/39QONV76601pV2lALOulQEQ14cwA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=WIynCKYl;
	arc=none smtp.remote-ip=209.85.221.51
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6BD53606A320
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 14:58:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6BD53606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=WIynCKYl
Received: by mail-wr1-f51.google.com with SMTP id ffacd0b85a97d-4a5506f09f5so674433f8f.0
        for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 06:58:13 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795013892; x=1795618692; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=Pp/RLPMZ3GifsKTDdh8Pk/uftsOfh5azJIs0J3c6Xr8=;
        b=WIynCKYls1N8nEyEmKDwpbFtK4fRYUUmPMeyj1Lc9KrBLr4DNDXRTqxqglZZe6Ifn/
         rnLkHwm2hphWg/c9Bfvobg9Xh3gOHmCC39W5EhYmE2vXc7oQ8QkoZqlQnR0DV/jsH1GX
         0zzmewpfcvfatXcXxZYAaoXNifblQeQTqV9d1MYWR9E61n5n3sGbMTxRnTnaL0nDt2oW
         nQRU8AFvYlvH+9vQ96dlbf/TUEFEwX2A0JC+XqUxCoPLcHF9R+OCRlpqai8JZglyJgPk
         qdEM9PuU3prps6Ygbz0r7hOM9uQF4f9gUmI0QuSofnln19TV9ZuOiZ8w6K8QMEHi7Fbn
         NPUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795013892; x=1795618692;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=Pp/RLPMZ3GifsKTDdh8Pk/uftsOfh5azJIs0J3c6Xr8=;
        b=FwphO1AMhtulr6lgEBLxXTFGF08xyZN4WmzNKmLRByh5Kzdq0BOnZuj7zyD1MVEf/v
         FWqkK6Ti1Gb6DEey1APgTdRJ+UOxQnjWR5FjZxfAnQBu4pfrT9u7xiF4E6xMd7re4G0t
         U6Ual0eKi2SebX1a09xUfcAR0aQAsCMSFRjPwRyesHXo16IiiYqreC9H8NzRvFY4vobb
         DTq5GMOR7Q0JWpbA6ToxvusPAezLF/vp6kEbxp9fJ80KivU3pZ3Apflj3O0OaRJ6MdNa
         THYtMP4/wuMjC+x6VQfEfTYloB/LBpFxUOsjV77uDIvjDKCxRhfzRqbcWeBpDFBTaEhv
         sFdA==
X-Forwarded-Encrypted: i=1; AL+hErE9aiq2CfQUUxEmC4dlYkpfS71mRqn72Eqj26yHpIukvxZOFcOpy6XE7yMrkyYRGS5JWkTKgtWxwbc=@vger.kernel.org
X-Gm-Message-State: APuU4Z818wBNzzUjRZYVBjysVnpLiv8fnQfqNHypNVazTjsR9HZeZ0HD
	t2Ma5mFtcnrhS8XQNix/TjHmtttn9+X3mFgMOlTYL5FwHgubDPzliWNI
X-Gm-Gg: AZFdTZdL6X3WSKbMklMDqU0ZTtO5FuU5Rvg/GRvKGCvrwOZW0kd9CATzGqXOB9vVGLr
	2d76oJ45MoSg7pmth84caVNiTYvE3LE9Ca0m2xha9oRga1ABJyMqOfESoiusmluFt90cy2xVN0w
	liLWbUNBfZ24KKcsrrYSrqe1m/79ft+isunUjjQif885yE62A2vhlX+ZXMORp65Y/2A7lCvUv9d
	6UVPG/+uA9rmrbmFTvWHJ+7zHKwNghjWt7mv6raRk2U5wUqZk9TsEYw2VD5/iE8KZBaPptVZQxb
	7gbcRxCRtDsFZo4i0XKLm8GP8m3U35yXLZPL0ScATMTSF4/NWFnItAvAIBZqsSaWCo1UHlLLBad
	n/MG5UpXZpIcHZA2cQlUMObFXAYQzYT6O0WZOAykApjTzAZ69B3vvFdUhmY5/htfTok850viQd6
	LZBQfuym1iNo7VSF21O8gWp/13piKxz0D/wzfkXF8xzv1Mr5JxGyvtwDsQBETQ7tBkhJgZx0l2f
	cSRUEdvn/G1u/NMQ0/z6rll3Z914+FJDnAkb4z7d5uIpZ1CoYutL7WOmWvLrEEqzGhwAzq3RPef
	SaqQ3LB4JlVb20qm2H+cfX2Dh8HQg7YS1NIbyyM3pXrL6fRTBkdwTmjnBKVW6smNvA==
X-Received: by 2002:a05:6000:2dc5:b0:4a7:7bec:e159 with SMTP id ffacd0b85a97d-4a84976942fmr1578019f8f.15.1795013891542;
        Wed, 18 Nov 2026 06:58:11 -0800 (PST)
Received: from localhost (mob-176-246-251-118.net.vodafone.it. [176.246.251.118])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4a65541f3b3sm5373344f8f.23.2026.11.18.06.58.05
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 18 Nov 2026 06:58:10 -0800 (PST)
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
 boundary=9e0e009d1054760532dfbb31949a479f82968ef4509cbe81b751bd0d90dd;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Wed, 18 Nov 2026 15:58:02 +0100
Message-Id: <DMYFBDIV4Y08.35ZKR5G86U1H7@gmail.com>
Cc: "David Sterba" <dsterba@suse.com>, "Namjae Jeon"
 <linkinjeon@kernel.org>, "Sungjong Seo" <sj1557.seo@samsung.com>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>, "Christian Brauner"
 <brauner@kernel.org>, "Trond Myklebust" <trondmy@kernel.org>, "Anna
 Schumaker" <anna@kernel.org>, "Chuck Lever" <cel@kernel.org>, "Jeff Layton"
 <jlayton@kernel.org>, "Konstantin Komarov"
 <almaz.alexandrovich@paragon-software.com>, "Paulo Alcantara"
 <pc@manguebit.org>, "Chris Mason" <mason@kernel.org>, "Yuezhang Mo"
 <yuezhang.mo@sony.com>, "Jan Kara" <jack@suse.cz>, "NeilBrown"
 <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo"
 <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>, "Ronnie Sahlberg"
 <ronniesahlberg@gmail.com>, "Shyam Prasad N" <sprasad@microsoft.com>,
 "Bharath SM" <bharathsm@microsoft.com>, "Sergey Senozhatsky"
 <senozhatsky@chromium.org>, "ChenXiaoSong" <chenxiaosong@chenxiaosong.com>,
 "Darrick J . Wong" <djwong@kernel.org>, "Sean Smith"
 <defendthedisabled@gmail.com>, "Andrey Albershteyn" <aalbersh@kernel.org>,
 "Pedro Falcato" <pfalcato@suse.de>, "Amir Goldstein" <amir73il@gmail.com>,
 <linux-btrfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-fsdevel@vger.kernel.org>, <exfat@lists.linux.dev>,
 <ntfs3@lists.linux.dev>, <linux-cifs@vger.kernel.org>,
 <linux-nfs@vger.kernel.org>, <linux-api@vger.kernel.org>
Subject: Re: [RFC PATCH v4 00/10] add provenance time (ptime)
From: "koraynilay" <koray.fra@gmail.com>
To: =?utf-8?q?Pali_Roh=C3=A1r?= <pali@kernel.org>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261118142613.be3r3s6kobkkxnz4@pali>
In-Reply-To: <20261118142613.be3r3s6kobkkxnz4@pali>

--9e0e009d1054760532dfbb31949a479f82968ef4509cbe81b751bd0d90dd
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Wed Nov 18, 2026 at 3:26 PM CET, Pali Roh=C3=A1r wrote:
> Hello,
>
> I have just one issue with the userspace API. It does not allow me to
> figure out what is the source of statx btime field. If it is fs ptime or
> fs btime because this RFC implementation is mixing both fs ptime and
> fs btime into the statx btime field.
>
> I have feeling that this is quite a mess in API and I would like to see
> a clear distinguish between btime and ptime in the API, like there is a
> difference in the fs storage.
>
> If the btime is used for forensic analysis then somehow I would expect
> that the statx would not report / not fill changeable ptime value into
> the statx btime.

Hi, for native linux filesystems it will report ptime as PTIME and btime
as BTIME (also semnatically), for the windows-like ones that only have
ptime (semantically) I think it's reasonable to not expect btime to be
immutable, since they are meant to be used with other OSs who lack btime
semantics.

> It would be really helpful if the statx API on inode can differ between:
>
> 1. btime is present and its value is ..., ptime is not supported
> 2. btime is not supported, ptime is set to value ...
> 3. btime is present and its value is ..., ptime is set to value ...
> 4. both btime and ptime are not supported
>
> This should cover all cases of different filesystems and also allows
> userspace to do proper backup of both ptime and btime fields (if it want
> to do forensic analysis or anything else).

These should already all be covered by STATX_BTIME/PTIME and their
fields in struct statx, the only problems are windows-like filesystems,
which IMO shuold be handled as mentioned above.

Of course, as in the other discussion, I'm open to changing ptime
NTFS/exFAT/... support to remove btime altogether and only use ptime for
their own crtime if that's what wanted (I'm fairly impartial on this
specific issue).

Thanks,
koraynilay

>
> Pali

--9e0e009d1054760532dfbb31949a479f82968ef4509cbe81b751bd0d90dd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQRJ2XvJtXGwULYEerQ0bnTtJTDoOAUCav28+gAKCRA0bnTtJTDo
OLZcAQD9pG1FmR7nRZDk2H08cDMhIho0sN3gDoVZ9UGDLNS9YgD/Z/0Ge9mFK15R
FEjSmx712gDHXRyPIeZ3A/k22EGaOQc=
=3Ms7
-----END PGP SIGNATURE-----

--9e0e009d1054760532dfbb31949a479f82968ef4509cbe81b751bd0d90dd--
