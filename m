Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795769328;
	b=q+gkdt8XzVz4aA1F2lfZTX1/m8sdzN5kn12lT/hdNHzWpX4LeN4eyr4UPuNDOXCABxjA
	 FpN73XC7NhmQMa5lt5hW0xXA0w29mB1DxVVw9xKtimUo7SjTQ7HFnXQp0QhHFj3o9+uMP
	 kQOtRoxGPJq4QkrP68TxsLyDG23iwqoNKWaa6PpAwGzjTYCBNreCkWcR8sV54TPsJRihK
	 xuFusM3ORXc7QHZrZYS2QAO8dfhULVqyBHScnV1x72nWLgxXOml1KpHTypZX5B7UsJTl+
	 bhGOJOznLV+bhibXJUHojncgOqo3Qc7pMckgxr8YeAcZImCukKQRE3/134bOzk6RhMA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795769328;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Mime-Version:Content-Type:Date:Message-Id:Cc:Subject:From:To:X-Mailer:
	 References:In-Reply-To;
	bh=IDez9NqT7Tj1QDvV6FYEN7zWNFn2T031QM3aseBOhj8=;
	b=HIEPLmlhvnykt9295OeGKbgLLDM35m8JkM6RH7yKJuaYnM8feps5QRCRIj2xzDdCYN3n
	 YJriw6FciHq+4TvN9bUsetdx564igppQyKopqnJ75IP/i/4uX9HnBuPTC4J7SwSO688bY
	 6NAXPEVn1QonNX4cPLwCccjJh32reYrtdVJGcPBbDpV7FNJQx5rlTOw9iRL2XjfQQ7UTu
	 BVIppWK9SZMmtT8btP/UN/zEAC9VD3c7uw3usCaWOSQ+nvU3oN8y+/VF1WJS2tyKUNPnk
	 kAum0ItXI9pZsKDphskwFqC3hmO241Rq8E80RxOrIyrO+G+msOTxifqQtQ+V+EL9urw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=dbJOZn5M;
	arc=none smtp.remote-ip=209.85.128.53
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A08DE606A32C
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 08:48:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A08DE606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=dbJOZn5M
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-4bb666304fdso76852805e9.0
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 00:48:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795769324; x=1796374124; darn=vger.kernel.org;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=IDez9NqT7Tj1QDvV6FYEN7zWNFn2T031QM3aseBOhj8=;
        b=dbJOZn5M3rCgRLPPOUJ++VnJKMJQm3Ohn3x6VlLjqOyC2bNT9/mOFF1yxLOyrzF1bl
         C+Kj5lfk/G5v+Ibl6kXxQpP75b5N2GOnPrygQfOpb+hL8pJdLWW2ruCSdOPWljpoOom9
         3k2U5q90CgtKcvQNVpmkgFpbHw4JRD8hnkpuKZMsHjBoE3LC1jnUEnzmSEuovDxk9r9t
         Wtqp53MEml1QkDIqwqCWvYw2/rzLoJc4/KbtnJ3GcoNMKSCSq01qjbob847q1eNmgWQu
         Cney17f61yibRSRiKAu1tIAGEODdNaIqbSZsxA3cV2i7XAT3GC/VSTY+hR3Urp47LrxJ
         8cOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795769324; x=1796374124;
        h=in-reply-to:references:to:from:subject:cc:message-id:date
         :content-type:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=IDez9NqT7Tj1QDvV6FYEN7zWNFn2T031QM3aseBOhj8=;
        b=mKUtzBXvJmOpnXwhdjRYecvIDlIruQpk4oxJgV4E1x5UpPhfLjyaD0JGeMBwz9mkNf
         4YuGVB+qDsL9HGvN0KJem170LDjQERgSUfex4aNtvFVGMW4roG8qEi05f8aL+IeXGuVf
         +mNxMQravvxqwRs2YgCky2Gp2FrZXJNi/crMfN2mQnOPPFYkAT5cQ0uCNKSl+uxa5U6w
         j74BSjATY12o63OrWoOCyAX8z0kFxu0OObFvAGiBu70BwalznRULbCN/Y+FgbMISN8qV
         FtiEZc1kUd0cedTbBp/M1mFNDmLyB2jHcmSvJ/TQW8rR/8TPCT56F+PFev3pFc7tSJGT
         oZhQ==
X-Forwarded-Encrypted: i=1; AL+hErE2mIVQcTD/+qq2uCXp7dWwJyXYdyfQnh/HLJnbHGDAXv1PULuckA2+Woh/ldqhVho+kwTFkFTeMhw=@vger.kernel.org
X-Gm-Message-State: APuU4Z/hli/9P6NNG7WaUQa/1ynwu0hAk2cE9b3KwTj2Uj4Zx75XzQLy
	QjQo8f+APDjMoUILSxfFLqklzQ0MHnVkSAZECuCIubgtG660+1UNF4Yr
X-Gm-Gg: AZFdTZemRPIe9ezK8STAm++IdS5+84U2+rhjOX8BMzHCFHvW0HrRysIODeh0aF6MaP8
	plsBQfhozh44eMLT4kTL0ZL+NuLrYpyq3FnwH8ymyrYs6gQy2v1d2ilf762q12UxBbGy9n9WrSv
	GBlhcNch8ABUSER4Kch6h1EwOM4eioEM0Xtp85Rh4HoGkmJYOlDRyQI4rLR0QOk1Ucl4XteP2gb
	otuTDWK4+vOoPoEUsoCne6Fg0AVrn88KJ2YzYKEIyu5aNfb/4eWd5BY4Ajc3w5yLELujCVxyxP+
	u1sjoBrNysBUZQFc4yKl/rwlDH/GS7KNRTLMX/g8vFRX/tbx16/4cR879PkSjyKe42ojThnLWvt
	xVGsnUHHAap0dQOcLz4tkF4ueeBfpswNgDsjOSxrL8Pz9vOItm9J5kIX05S8z+7HETJp+7ovYY4
	gbMESBcAuwQLKa8wehsFigsrhX3/20tfIVBtW9Z8OF1QqGZw9sbfksReq5nyeIP//xKc/2DG6+T
	nccJ8vKYjC1BgL88xt8wu2Km2ORmExpfBIHd6OUcCILbf1q/yecrTAJgiYqxMlaSQbKLW6e7JZi
	PGxKdppOKwfi7i5aav9QsEHU9mSnzUr4Ie57eqRDc8ojK3IIje39LTBAH3oiI3I6U6+X5Q==
X-Received: by 2002:a05:600c:4f81:b0:4bb:5e8c:13bc with SMTP id 5b1f17b1804b1-4bb88805902mr454676765e9.7.1795769323802;
        Fri, 27 Nov 2026 00:48:43 -0800 (PST)
Received: from localhost ([130.192.98.149])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4bb906635c7sm426511305e9.2.2026.11.27.00.48.39
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 27 Nov 2026 00:48:43 -0800 (PST)
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
 boundary=c6f8ca06bd0087fb130def184d18448cb7c766d554c063c5f32d1cf88680;
 micalg=pgp-sha512; protocol="application/pgp-signature"
Date: Fri, 27 Nov 2026 09:48:36 +0100
Message-Id: <DN5V3F9BWZNC.ZIJY7Q6XMDOM@gmail.com>
Cc: "Namjae Jeon" <linkinjeon@kernel.org>, "Hyunchul Lee"
 <hyc.lee@gmail.com>, "Eric Biggers" <ebiggers@kernel.org>, "Theodore Y .
 Ts'o" <tytso@mit.edu>, "Jaegeuk Kim" <jaegeuk@kernel.org>, "Alexander Viro"
 <viro@zeniv.linux.org.uk>, "Christian Brauner" <brauner@kernel.org>, "Chuck
 Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>, "Jan Kara"
 <jack@suse.cz>, "Alexander Aring" <alex.aring@gmail.com>, "Darrick J .
 Wong" <djwong@kernel.org>, "Andrey Albershteyn" <aalbersh@kernel.org>,
 "Amir Goldstein" <amir73il@gmail.com>, =?utf-8?q?Pali_Roh=C3=A1r?=
 <pali@kernel.org>, "Lauri Gates" <lauri.gates@gmail.com>, "Christoph
 Hellwig" <hch@infradead.org>, "Dave Chinner" <dgc@kernel.org>,
 <linux-btrfs@vger.kernel.org>, <linux-xfs@vger.kernel.org>,
 <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
 <ntfs@lists.linux.dev>, <linux-nfs@vger.kernel.org>,
 <linux-api@vger.kernel.org>
Subject: Re: [PATCH v2 1/4] vfs: use goto out on error in vfs_fileattr_set()
From: "koraynilay" <koray.fra@gmail.com>
To: "Greg KH" <gregkh@linuxfoundation.org>, "koraynilay"
 <koray.fra@gmail.com>
X-Mailer: aerc 0.22.0-0-gc2f86b7abde3
References: <20261126163114.403846-1-koray.fra@gmail.com>
 <20261126163114.403846-2-koray.fra@gmail.com>
 <2026112647-earful-frosted-6ef3@gregkh>
In-Reply-To: <2026112647-earful-frosted-6ef3@gregkh>

--c6f8ca06bd0087fb130def184d18448cb7c766d554c063c5f32d1cf88680
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

On Thu Nov 26, 2026 at 8:05 PM CET, Greg KH wrote:
> On Thu, Nov 26, 2026 at 05:31:11PM +0100, koraynilay wrote:
>> Switch from using if (!err) { ... } to the cleaner if (err) goto out;
>> in the main body of vfs_fileattr_set().
>>=20
>> Signed-off-by: koraynilay <koray.fra@gmail.com>
>
> Real name please.

Hello, this is the handle I use for everything online, thus my "known
identity", and even Linus himself in Commit d4563201f33a
("Documentation: simplify and clarify DCO contribution example
language") said
> And despite the language, we've always accepted nicknames and
> that language was never meant to be any kind of exclusionary wording.

Also, I already have a few accepted commits (here[1] and elsewhere[2])
with this DCO, so it shuold stay like this.

Thanks,
koraynilay

[1]: https://lore.kernel.org/linux-cifs/?q=3Dkoraynilay+%22Applied+it%22+f%=
3Ajeon
[2]: https://sourceware.org/git/?p=3Dglibc.git;a=3Dcommit;h=3D29803ed3ce

--c6f8ca06bd0087fb130def184d18448cb7c766d554c063c5f32d1cf88680
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iHUEABYKAB0WIQRJ2XvJtXGwULYEerQ0bnTtJTDoOAUCawlD5AAKCRA0bnTtJTDo
OA8rAQDeEx1D2WxXRvyGunXEuOW+Cj+dElpy7MJchlEm/WMNBwD+JvucXkEupO3z
6yiHSY99QVuCP3aqlN/orccezZlLGQ4=
=mM8H
-----END PGP SIGNATURE-----

--c6f8ca06bd0087fb130def184d18448cb7c766d554c063c5f32d1cf88680--
