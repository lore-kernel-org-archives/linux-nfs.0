Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.46
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795443738;
	b=w88X9r51knZAxCSDhgVWg4Lds2smzUsfh/YLSYJvANYh2bR4BcQDPP+kZLswtPdkWKJg
	 aPH82KiWp/WrUkx5M7DVe+RquuPdT+6M3RoYIoZgO6Fq80zLNbS5Udaa3/G/0YuL6VqX6
	 p3TxrnTyb/3vnGbtVd3ihQu1tUZhUxvef5e3lRUY8P+OgYKqCUtwFBTLIjY4IdP7LXIeQ
	 +b7fJyXoWT113heCBRXvdgDpVdmnZbhNt9obBPWqWVqK1tEJ0IWNwKcgEu4G8/nVYmZIv
	 tBeNaKZB9zYXE+hp2uUQ4wYDxZ0CJgA3Vr7LLEwwTOCt+G0buarIuXDMCc54dF+Cciw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795443738;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=MWpQl1xkyrhsa4v1aNpU05mPb+pCD8JS1KWXDWW/Gpo=;
	b=AQVJBn+oq3mWEbxpSNDlmllTwnWA2KMIpvKiLZ2oL9o/+DTV0sqbpy31XPiLIiI+IKwa
	 LHUz8pIjLMHp9Nqgzux6BwlhygUccGg4Rk7uaZFPM6yD6drQwdq7YvaHHu0ujfh5EBAtE
	 kn4gCYTmZe8G+Zva5tHumiR6JqX897IGJ/lgdXWl1AmAEjUXpXBrhQuafdMfiwUthQ+jr
	 0nlCOxf13E3fL5tsBnHM4jaVEZEunBLoWmv5/IKjptBo/S9BlA3KAK0NFFqYBiseQ+S+U
	 rx1YEFmHXKg9SAefVBxXZbkvAqI1bJwCcJcR2/ZauRPLF/YTG+IFrMMOOLMTuY6dUpg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=00fZwspv;
	arc=none smtp.remote-ip=209.85.128.46
Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com [209.85.128.46])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C9D6606A337
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 14:22:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7C9D6606A337
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=00fZwspv
Received: by mail-wm1-f46.google.com with SMTP id 5b1f17b1804b1-4a214c5c4c0so31210175e9.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 06:22:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795443737; x=1796048537; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=MWpQl1xkyrhsa4v1aNpU05mPb+pCD8JS1KWXDWW/Gpo=;
        b=00fZwspvrkZHzlXeIp1sk0DPnZy6zbXYi6zIJ3d5v+w1NsTls89lOgHp7t/tKAch7D
         Hd4wIO6XRRuOp6DsoVpuy1fI1JBPDAuB4H2ar/Lx9QF9UMM3I2Bn+apTm6C02HriyEjS
         KA72OMzw0B/nPuHEn1s5VR5vbpTHGND2TpdI0u8SjlASUOf9KvX7qqbdv4pthaNSOPjC
         CBP+ouQep439U4VPJ4zVW33k/OEd+wxFLAmiROh0/cG1vbpp0ujnO+YiOIBm4UWAjdd7
         OjHijbDRGvuUxSrmtMDu3hyafB2uG4C7Vi4d2cljbIB0BPnpF3JySA7ndBemr4CxbXa8
         8Zpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795443737; x=1796048537;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=MWpQl1xkyrhsa4v1aNpU05mPb+pCD8JS1KWXDWW/Gpo=;
        b=pR2FnEV9pYS3J/HwbHvAY/BXRPnMmRhLWJ8MWPzAdm4YRKvzHbLVzZq3PORAUyoxHG
         YuYeVY0A+U6MYvmLYuL/Xc0Fu8vxbuZrzP1vm4XMcAKdhHX1WhPAOlHHPPmRL5VA1Yp3
         NdePRPRZARqMNjuEUFLqdmOCJYNnvA/L15VephMpt+AE5Yy5BdsK4BetfFbPQJhbwoQr
         vlVz0AWJ6Oxe9K5zR/HC7jbh0py6eFl9d0WGaRofy2SeX6mm5mQQcFX+312chSUUeb61
         ttZtJGh1e6rTm52x2twZPi+eTjIkcZ6DAcKRR0Iw5ylAfrCpeF32oZO7cIt2TdCxG53/
         Bvhg==
X-Forwarded-Encrypted: i=1; AL+hErFpIIT+S/HIUnq46DtrsysmhH3u0gK+5Mr9mwS4fRugDJQZ67MrH2Js5lilzZ8TWiEAYlhH4+lIrTs=@vger.kernel.org
X-Gm-Message-State: APuU4Z+J9rMw+1FC0Td+KemQTlnZbSxN/Be1LgxsVFCByaOn8qeE1Tf/
	7MOy5L6d+aRsZUPoAdsyi0d9w3ygLuyLy/eFLKbliw4+NGHTxh4w2/kL
X-Gm-Gg: AZFdTZcYsO7FJxGJVrI2X685/NxF/sh3YJVBD+XRJIhJF4oZEOKbZ/lPJOItEDJUYxP
	bEPO2AzhnJxbDjg4Od6UPJYn9dbTBAczeVE+bWdgI7GNWVTshcjQf8xJ8y509eKtaNX3gnxLygQ
	dOG3YT/mbmLKxq07Dx8IwNAYIR3RwcUgRtYU0nrxE8UZ8F4ZFQD1BFyshhGwmoa5PDt2UFqqPum
	JO2/QPz7TU/nJVMyLHwU355Jy32YjQZ2XD6QWesWZq9I3NIHNaFNkyGGW0SgzT8SjUoBtUtuojW
	c8e6oJn1Iwa2dhu1r/59DbBxj37Nv3gTzC45zhRQZ0k8BW+srLfF1mfj7l8ATlELJ18UHS9BP2W
	jWEgDcG0HPOX6X4c5MLjOkIbFzINAy3LdmcQ7EFV7FprQ2uyKdZ/frMnk6XudWEIjdSpnG96vQ8
	DnUE6TnGWz7hK4mUVG8pVfJbMPGhnqeKpWZyEwc4Vlv91lg+y/zoidCRPDUUpAZNGmEb5pMmYxG
	c/40jycOGDiXrzDWWM0IbpC+Jo6MMxB1gP1mC90xm6rWOh/c+oJesF5fCV/1c11KcWy8IrhmZgA
	Kw6TpQetQRCwufdo30M8aokWsA==
X-Received: by 2002:a05:600c:64c9:b0:4bb:679a:86ee with SMTP id 5b1f17b1804b1-4bb88938dbemr253115345e9.29.1795443736768;
        Mon, 23 Nov 2026 06:22:16 -0800 (PST)
Received: from localhost ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb906cdcc1sm170939525e9.2.2026.11.23.06.22.13
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 23 Nov 2026 06:22:15 -0800 (PST)
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
 boundary=6835006247ad5b556582ac77c37dad0d5918ae309cf17b9da0cf6b359cde;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Mon, 23 Nov 2026 15:22:13 +0100
Message-Id: <DN2NOOG9J6HX.1L4IO84SKCYOG@gmail.com>
Cc: "Andrey Albershteyn" <aalbersh@kernel.org>, "Namjae Jeon"
 <linkinjeon@kernel.org>, "Hyunchul Lee" <hyc.lee@gmail.com>, "Alexander
 Viro" <viro@zeniv.linux.org.uk>, "Christian Brauner" <brauner@kernel.org>,
 "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>, "Jan
 Kara" <jack@suse.cz>, "Darrick J . Wong" <djwong@kernel.org>,
 =?utf-8?q?Pali_Roh=C3=A1r?= <pali@kernel.org>, "Lauri Gates"
 <lauri.gates@gmail.com>, "Christoph Hellwig" <hch@infradead.org>, "Dave
 Chinner" <dgc@kernel.org>, <linux-btrfs@vger.kernel.org>,
 <linux-xfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
 <linux-fsdevel@vger.kernel.org>, <ntfs@lists.linux.dev>,
 <linux-nfs@vger.kernel.org>, <linux-api@vger.kernel.org>
Subject: Re: [PATCH 1/3] vfs: use goto out on error in vfs_fileattr_set()
From: "koraynilay" <koray.fra@gmail.com>
To: "Amir Goldstein" <amir73il@gmail.com>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261122000856.536902-1-koray.fra@gmail.com>
 <20261122000856.536902-2-koray.fra@gmail.com>
 <awP8S5KF9v-nqWVY@aalbersh-thinkpadx1carbongen13.rmtcz.csb>
 <DN2NJH234CC4.2LSWRSOO4TX5I@gmail.com>
 <CAOQ4uxiREfVU-WKiUVRZLb-uzMXzDEsmG13FVMW7YBoyq10=Nw@mail.gmail.com>
In-Reply-To: <CAOQ4uxiREfVU-WKiUVRZLb-uzMXzDEsmG13FVMW7YBoyq10=Nw@mail.gmail.com>

--6835006247ad5b556582ac77c37dad0d5918ae309cf17b9da0cf6b359cde
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Mon Nov 23, 2026 at 3:18 PM CET, Amir Goldstein wrote:
> On Mon, Nov 23, 2026 at 3:15=E2=80=AFPM koraynilay <koray.fra@gmail.com> =
wrote:
>>
>> On Mon Nov 23, 2026 at 9:42 AM CET, Andrey Albershteyn wrote:
>> > On 2026-11-22 01:08:54, koraynilay wrote:
>> >> Switch from using if (!err) { ... } to the cleaner if (err) goto out;
>> >> in the main body of vfs_fileattr_set().
>> >>
>> >> Signed-off-by: koraynilay <koray.fra@gmail.com>
>> >
>> > Looks good to me
>> > Reviewed-by: Andrey Albershteyn <aalbersh@kernel.org>
>>
>> Thank you, can I add this tag to the v2 version of this patch (since it
>> won't be changed, and link to this thread in the comment section of the
>> patch)?
>
> You should always keep RVB when re-posting without meaningful
(RVB =3D Reviewed-by, right?)
> changes to a patch.
>
> That's how reviewing works.

Ok perfect, thanks.

Best,
koraynilay

> Thanks,
> Amir.

--6835006247ad5b556582ac77c37dad0d5918ae309cf17b9da0cf6b359cde
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQSgVimKafU5DQMcjcDmj22qf5IGXAUCawRMFQAKCRDmj22qf5IG
XCZkAQDH8wiuPEqDaB1cat+NLbwVTy9AgTGpQeVFZlTodz2juwEA00+c7xq8+RtC
rQ07nQ+3av0Gvb1S4BH2IP+66ik5awQ=
=/Ubu
-----END PGP SIGNATURE-----

--6835006247ad5b556582ac77c37dad0d5918ae309cf17b9da0cf6b359cde--
