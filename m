Received: from mail-pj1-f50.google.com (mail-pj1-f50.google.com [209.85.216.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BFA742EEE95
	for <linux-nfs@vger.kernel.org>; Sun, 26 Jul 2026 18:31:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.216.50
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785090721; cv=pass; b=aeNLzsPHyHtKCNsoYC2+iytL0DtwLmsvqZlYleQmZiizcyOQ0kTGPglU43KBq/aKLKODVvDOvMbHsNYGX2GOsnFmrqtmS4QTXKYN0aDeLnnilH+nLUPiuemsFEzjqt9x3POxX6FLSr2ffWJlp6EqxG+JD7osl4KkS2WQJ81QSWo=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785090721; c=relaxed/simple;
	bh=roce0OY2AFdV4vv7C8LtEaVkWRI7KxA7oxj+4gMsfkI=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=rJqQ6vr/j6IZTumAesr0tylYcQv5sE1GHL2+3R53tDR/XivUv3mRovAr9HcmcvlvZPCOLNQgl5GbZjxQQcrR+QIiBiXInl8s2dy+HgITHUUMCo+abI8FAI2EGhH0uVETUh9Qnecqud5mWi4g1B7Ny20iguEFd+z+dWy9UJ+I/yc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com; spf=pass smtp.mailfrom=paul-moore.com; dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b=QhfGUmg8; arc=pass smtp.client-ip=209.85.216.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b="QhfGUmg8"
Received: by mail-pj1-f50.google.com with SMTP id 98e67ed59e1d1-382ef647e20so1994398a91.1
        for <linux-nfs@vger.kernel.org>; Sun, 26 Jul 2026 11:31:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1785090719; cv=none;
        d=google.com; s=arc-20260327;
        b=bCjYIuzgh5s8l0dsOKbJnulXuZt2FMUrct4XL5r6gQjj+ZGV88m9DBb6Te3v0itXVM
         QwEgQJIWEvSDTXmP9lNW0rGY4pZ8+w6CggmUUBtV0ICl1tRb9iYGkfJeRXzo995FGwHD
         BFxYg1ZV++YU3mXY0i0t2Zd2REYm4OYXWfpo/mHkCufoi5qKwnLc+8QALruM7tlFw0Bh
         z8y2jbnTy3siTp5vbN1cuJb0JnAhox2AV8RfaluAzYLIua9EMxwxfjdUCKvFfl6M8Jhs
         ffc/2A2UCqXtoJHWc2hzOsIcxqIrbcrCFYtVhfMckhlZy/9+uEGM0CxIiMaGCtPGBCC9
         +qHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=roce0OY2AFdV4vv7C8LtEaVkWRI7KxA7oxj+4gMsfkI=;
        fh=bg09xj01e0b+qmsoKbT+J3xK7BpGNkS0aSa8kiMHvQ0=;
        b=I8MoVTHANbhekuc6oOHwH2+u41NZJy8fjFqDjstekWCrCmad5vYdg8B/LmCuQPtqQz
         AuhIUH6BSMl3nbhBpR9CiyQymcVIcIw2xqbbG8C0XUooF/UbClm4EEtsSK6uq+/EJHGJ
         L7fUbMJ7eGZLkgzJhPruBlpMLuRYPZkb3XefG2cvnEKU1jp3eJFbC0RaOSqArT4NhF1B
         Ha0hd6MwVh001bQlCVaSiLYEz77+A6T2HqbWPBZ2/43fw8Bw+aMFwhD8Qn0xzhKFuXdJ
         sGmlK7OYPOfpPpKmmzxO6yBReiSpHMXV2EbKYBYS96gz+U/F0fFFZhcYYDDy9tH4LqPt
         WlBQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1785090719; x=1785695519; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=roce0OY2AFdV4vv7C8LtEaVkWRI7KxA7oxj+4gMsfkI=;
        b=QhfGUmg8I3rPtrSgegmXPOrMxtuAM90LL69pxeCzyvkBgck0+1CIwlPfdQHYcbZ2n7
         NPZsjgWQ6YIJ3a66AZwCZOsQxMqeRTRXTHQK1biARWYSZNJcyWkbXmpYgAlOo/g29vVP
         mt1Yod1Yz6tz2WMced4Q0CCH50v/IAkyDmcoMdNbo0s6bBOY+9ojymv6H8OE/eZomFIW
         098l+4Alxb4NQhFezisDdjNi6PVu+bMrbm2b8IXziiln2JRPF+JwyOYNZBUmz2UP3uwi
         zs/OtRZuudl7wXU36cUtnxA92rzSkZvJZp/BDJLIxFjaU+52CHkksN3Fue8zp+XHHSVA
         0mXg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785090719; x=1785695519;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=roce0OY2AFdV4vv7C8LtEaVkWRI7KxA7oxj+4gMsfkI=;
        b=q1efZgNUwcPIaWkYXt/jbhKr3hp/EnY7qNfyz8juh47nk4x0lHdvggjybrNCpCVq1W
         LSrpggpfzzweHR4+Bn9YV8PnP4UY39sbBx6wo/nbdnAZg8RDbmr86OO6k9wf+rqFen1X
         +hKW6l9bQCRQmuT4PeS9ewvyUZHM1gVeu4vvxYsJNaJ2uiOTm5BSYw5WigjOtm/wSRxQ
         4hdV2lpecr+BkGMk8I6pObud2U4eJUW+vUbU7FM2kHy2udN4W6QqXfpL4axNBkHztBn1
         fmIcxX8uFDsYHHzrxkq9UY/wk9a1qKZ/5DxrzevPesd5e1NhyWssBKzFW+UwAoBixWGI
         JYzw==
X-Forwarded-Encrypted: i=1; AHgh+RqICOXWtPUZKVbUxwSSqW0iGR1OGwWgk0ceHkmJ5MGUcVHWbxjOMd0CWBMkWKcK+R5HDcP08BRCh+0=@vger.kernel.org
X-Gm-Message-State: AOJu0YzW6EAJB23qDDzcuRAgaDP8MiecALfTT1nFdE8imbs6vTtx9oiG
	J9jRWPWgQpzN0toHupF/YI+kMsoAQYiny0GSzsjduC14Z05H6zsYPvykFv/y+TgPfxwCgiXXfTo
	CGA1iDbVr7f9Dwcoyn66klo9stoX5jIrQOT5PBhA4
X-Gm-Gg: AR+sD12Z9gjEJLvDOdplR8MZBySDvgzKB6P1qz4/F3oSbOw9e9cInxBnfXUYZitTwe3
	ED6AdITUC/pAqKahKSZ6myVRL7vBlBr8lCOdORRSwZ8DnUhI1Zmh2k6aFNI4DTMp9Spil1M3Ozq
	Bqx01elH4QJl0f88M6k3IrmEzTM2v42gDyFifbmGqGdR8GYLvqrZgREDD+P4eJkUeo/NdDkJVYG
	88vz6zcNgHfY9s5sP7oTzr3bMxivMSQevJH2wQ9eA6Q1GTzAvC68eU/5ZYMMXDwLSuXavnC
X-Received: by 2002:a17:90b:5443:b0:384:5dbc:cba5 with SMTP id
 98e67ed59e1d1-38f2961134amr5446040a91.26.1785090719086; Sun, 26 Jul 2026
 11:31:59 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20250428195022.24587-2-stephen.smalley.work@gmail.com>
 <20260725200958.4471-1-cel@kernel.org> <CAHC9VhSGn6UQ1__HtqjKWD1KgyMOhHYYKny5HnVuPAuvqZR9aw@mail.gmail.com>
In-Reply-To: <CAHC9VhSGn6UQ1__HtqjKWD1KgyMOhHYYKny5HnVuPAuvqZR9aw@mail.gmail.com>
From: Paul Moore <paul@paul-moore.com>
Date: Sun, 26 Jul 2026 14:31:47 -0400
X-Gm-Features: AUfX_mz4s5ELv8nSMCfCIDeYTuebpIuEr3Rnq7Fv6nbadAxzkUffEPG3Vn49cbc
Message-ID: <CAHC9VhSh=fXCcDG88m0Qbt61aKajx=cHGQXX7DbyiQtkJRtKYQ@mail.gmail.com>
Subject: Re: [PATCH v2] security,fs,nfs,net: update security_inode_listsecurity()
 interface
To: Chuck Lever <cel@kernel.org>
Cc: Stephen Smalley <stephen.smalley.work@gmail.com>, Anna Schumaker <anna@kernel.org>, 
	Achilles Gaikwad <achillesgaikwad@gmail.com>, Trond Myklebust <trondmy@kernel.org>, 
	Casey Schaufler <casey@schaufler-ca.com>, Christian Brauner <brauner@kernel.org>, linux-nfs@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Jul 26, 2026 at 11:03=E2=80=AFAM Paul Moore <paul@paul-moore.com> w=
rote:
>
> While I don't suspect it will be very interesting, I just started
> building a test kernel with Achilles's patch that I'll run through the
> normal selinux-testsuite automated testing.

Not that I was expecting this to be a good test, but FWIW, the
selinux-testsuite (and audit-testsuite for that matter) ran clean with
Achilles's patch.

--=20
paul-moore.com
