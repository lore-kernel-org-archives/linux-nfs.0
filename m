Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.51
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795185854;
	b=JgJcLoBdgiF1cwrDtq/yRzhbUijHJYAneddpzrubzrD+tXfgGbPNlV2ZG1FtUNVrNRUO
	 nBqeO5Bm9j/dSKVUl6i9KNo9bzVsqbZCc9MQ5gpCQVXf4mI/wBT3enxxBb1VqjNsIhNCK
	 G5uVoVtJmtO/aAeFxEBkspsgVbV+4oskOeEDtMHeSpdop3gSM7tSJ7S9I/0LJ4lbc5jo+
	 Ov0aY7V4Km3zBRKk8hVJ1G3TnZ2AGWpnU3X9bfwcpXGoFxn39GWYkz9J+f873bSWFysjx
	 EjcBUfwZcyS9ZYQQuU9qBS3sfX+gUuEqsj9agN7Wt5A5p4DevFqaFETcWm+u404v3MA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795185854;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=aeb62NrfYX2nWbFpQ3h7rH0au2pU37+u990yshAdsq8=;
	b=k84P4diPnd9hvt7YoFjXkc//WBVjAeZeDJbNF91w3OQuJgCb4qVobKLd7Zmo9zjf5FAL
	 I3B/eFedFB2MdZOMV3pqCYWJVLR6aLtRmfsJGUaRG7GVNpYVP4p6ZTPrY1Lo15ixibQzE
	 YNvzIgDTom8wUT0XXyFO20pd68c9aPqQzC2scphraOUNuNViCh91Pnu+Ma9B7G+mFPIpd
	 HV8rvR4CGhOt98WIimHLzzy2QNuTUfcCd8Bk6AielrNYhLkO04NXBp+s+ddisJb0qkL86
	 ed6IDvmyKlPQUtmgBe1x8Z1bVN4L3OawJXaWPQG07H1+a4zQQXMkE4r1/EddfYlAXag==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=UCx2E0Sw;
	arc=none smtp.remote-ip=209.85.221.51
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C6ED8606A326
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 14:44:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C6ED8606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=UCx2E0Sw
Received: by mail-wr1-f51.google.com with SMTP id ffacd0b85a97d-492fcbfaa88so604839f8f.3
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 06:44:13 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795185852; x=1795790652; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=aeb62NrfYX2nWbFpQ3h7rH0au2pU37+u990yshAdsq8=;
        b=UCx2E0SwKcK/oqyYNLOz686VusYmii+3mMDSe2hm1s34x/9j7y81gtRcvRwLvYBz3L
         8OWonxeJ7ONGBIAdCYN28kX+LRG6+zE1qzjaKqtJdHF3MJBPWqGI5u3OnZMZ4nUYhE9m
         PEaUWEoqsvQP3IAgHgg36VjHmqvLstmO20zMnptGeWfnBQnfV8Xwbcf2i+5+HPE/je1g
         UffyYR0okyEW/XxdVXBfUQ2+CTA3+deWuJyIBQP4+m3bQJNmt6Az6/sbA917Q6G5mzbK
         Rj5vUQAl8Up+44D/OFiKqlCYJFj+9wTD4uBgXkGE6VmgSc/N2pGJihXdIl+6jSPw+Tjd
         ggNw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795185852; x=1795790652;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=aeb62NrfYX2nWbFpQ3h7rH0au2pU37+u990yshAdsq8=;
        b=JQp7cRDRnwIxvf5dYl5OjBH7RLxLJh1HO3CFHDuOb1DeaBPdlC7/kurk96a8Nszzd/
         2IR/WG+GjGjPvkEV/KOck3/WeN6XAuBOM6zGfLRdk4wTTfUVPlWzib13mUmLs0MpiKc7
         wvQ8FCYLijfAGp9CuXOo9TgBleNIW4cVDeWZeyTgmH1cQamE3SGn7rU1kLJfU7Oc2rvW
         CycivKjfEvN0lXEW5OOcSshPetTuqmrbirI2oFiixft/wgq6dJA2HOJuSb4vmjV1DXGO
         /cjpZWcYxuLixWnxqXOcoT18OuwcGsQuco3mFQjB0IcUotS2pjKUjzJhnDs6WsFgL7Mq
         LBDA==
X-Forwarded-Encrypted: i=1; AL+hErHWUTw4dHVkM+myk3WemDytnw884/bDJSienIKiRQIhN5pOznuGw/DjhO/AihyfXiiq1jpV89K3X54=@vger.kernel.org
X-Gm-Message-State: APuU4Z8Wz0M6R+QbD+lYdbypg9pjqgQ/585XWwqmpHus5+yhry82EZRb
	JTSD6A99vo3wot9izye2Uo08Cm8FHDK+CIQ2iCbLNXxtWLw0oFWJANhw
X-Gm-Gg: AZFdTZc1Ygaj3EywDNaFAPjjWiiiYoDxv58Wzv+2sEE1BWWIg7s68GRYikv5i4QRLRb
	YpzM5LTQ6vMKlMXFzMc5d1f+t5esFZwkj1kuspKYwwMXcchr4rwLa4LqMf+tIb6gToVccMQlW0Q
	C3tT8OEz7zPsLG9ePs7yCiW8sGOk74EeNnvzp6g3Iu4bOTzIp3yqaXo9gWAa+IcBCNcr2ukM2uo
	MF0iY7TorWmMYBwrXCVIGyU90CRXyEjWVfKUoxVyxQOVyE3lU+LZ3JQK1XSrTtBrSqrtc+KXM13
	kZxY/b05arDcbq35sX1KD3481w1RTMzy0b5sQlWPgEyaOrfiTd72M/ISOtFhHke9EGz09DY1M2f
	T8up/7Ha5VvJSKHHZRHePlx8eNdGFoS4HDHi5dAgNidhDj3EpSsLWowg0S2FGBScFwUS89ohSuH
	lbALDjRrtjas80LjfJryCEBOeKgE9eZrhmqWK5wUW47vPdmwDRsy6/5ulaS4XBLNY86Z16m9Q5c
	EM2WapcQwxDDR3NOPo8fJMmhRdujVRVrqYIDP179XMBo9PQeEQPqJR7R1CMebgwc+4Epz5xWppu
	ZKZ7g1dnpnDcJCeRlZFCpe92bMWuhW5oQ4bNBtZ7r4U9Nd+F
X-Received: by 2002:adf:e014:0:20b0:491:8462:20cc with SMTP id ffacd0b85a97d-4abb400c0cbmr5198457f8f.37.1795185852061;
        Fri, 20 Nov 2026 06:44:12 -0800 (PST)
Received: from localhost ([130.192.98.149])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab69bf62f7sm6426849f8f.13.2026.11.20.06.44.10
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 20 Nov 2026 06:44:11 -0800 (PST)
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
 boundary=8a2bc4e8bd35bb6d32db85e9ae6f5058abdd79d3019902d3de598560ffbd;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Fri, 20 Nov 2026 15:44:07 +0100
Message-Id: <DN049T7Y67NZ.10CIWW8DE6PP5@gmail.com>
Cc: "Lauri Gates" <lauri.gates@gmail.com>, "Dave Chinner" <dgc@kernel.org>,
 "Christian Brauner" <brauner@kernel.org>, "Christoph Hellwig"
 <hch@infradead.org>, <linux-xfs@vger.kernel.org>, "Carlos Maiolino"
 <cem@kernel.org>, "Christian Brauner" <christian@brauner.io>, "Darrick J.
 Wong" <djwong@kernel.org>, <linux-api@vger.kernel.org>,
 <linux-fsdevel@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
 <ocfs2-devel@lists.linux.dev>, <linux-nfs@vger.kernel.org>,
 <linux-cifs@vger.kernel.org>, "Theodore Tso" <tytso@mit.edu>
Subject: Re: Concurrent FIEMAP on reflinked files serialises on the AGF
 buffer lock
From: "koraynilay" <koray.fra@gmail.com>
To: "Amir Goldstein" <amir73il@gmail.com>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <av4Hn9u80fs8iHZ6@dread>
 <20261119095943.85048-1-lauri.gates@gmail.com>
 <DMZ4VQ7SZ07T.29WMPQ0BQZGSS@gmail.com>
 <CAOQ4uximow25oc=3XEN1ATgQvonQaTXtDPmQufxo75tJ=e355A@mail.gmail.com>
 <DMZJDGMJ1RVF.32ES391JKNFGP@gmail.com>
 <CAOQ4uxjVQ9cjV=_jBjQtNg9zCuWUEJT9KNYMKV+1jwBkHen5OA@mail.gmail.com>
 <DN03LWNSDYP5.11FTQ5KCWU2X7@gmail.com>
 <CAOQ4uxg0oq7VjhSQ0h8dBucdPfON2Q6tJQQqUy05sCaE10QRoQ@mail.gmail.com>
In-Reply-To: <CAOQ4uxg0oq7VjhSQ0h8dBucdPfON2Q6tJQQqUy05sCaE10QRoQ@mail.gmail.com>

--8a2bc4e8bd35bb6d32db85e9ae6f5058abdd79d3019902d3de598560ffbd
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Fri Nov 20, 2026 at 3:35 PM CET, Amir Goldstein wrote:
> On Fri, Nov 20, 2026 at 3:12=E2=80=AFPM koraynilay <koray.fra@gmail.com> =
wrote:
>> > With non-zero xflags_mask, internal contact masks
>> > can be used for -EINVAL not for silent ignoring.
>>
>> What do you mean by "internal contact masks"?
>>
>
> I mean that users do file_setattr() with a bunch of flags
> some of them are just ignored randomly without any any way
> for user to know about it, because this logic is some internal kernel con=
stant,
> which cannot and should not be documented in the API.

Ah ok.

Thanks,
koraynilay

> Thanks,
> Amir.



--8a2bc4e8bd35bb6d32db85e9ae6f5058abdd79d3019902d3de598560ffbd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQRJ2XvJtXGwULYEerQ0bnTtJTDoOAUCawBctwAKCRA0bnTtJTDo
OG67AP99DCLnFsLMHCsRAeUitR3pAiNRglGbALKnTbw7U718dAD/Rbb718IIJvnz
/T8g9StMlY2VrgWntvlMz+RabJ8OUgY=
=dJIP
-----END PGP SIGNATURE-----

--8a2bc4e8bd35bb6d32db85e9ae6f5058abdd79d3019902d3de598560ffbd--
