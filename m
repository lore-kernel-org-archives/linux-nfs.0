Received: from mail-ed1-f51.google.com (mail-ed1-f51.google.com [209.85.208.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 22CA84FECC3
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 13:30:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.51
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791898231; cv=pass; b=aH1gfp8AtrHnr75dnJcjtqVFA6bsv3b0PLDH7tYK+AajB7fyEe6u3E6Nrpgkqcuk8mRVLZiaB43U4HV3cuboOxGnuqYgqY68xnZzkCZPeMAdfJd/FzUSZ7sThqoJiQ7a2w6Y556pellMNuQpAXun6uPF89ZjV0m9U2xBpOgON+Y=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791898231; c=relaxed/simple;
	bh=5qhYf43Muz9D0siyZVmewVTjJme/DDq/hXostKmYpv4=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Content-Type; b=NFE5vzLnBZiK4j3eM8I0wCA1rzXzl4Y0F6I2YGHZbygGabU+WIpxyeUqTjjTsW3pqwZmtwogDcCvaelZdkLcSJaARIczrJdFjGmt40jD5McgJ5wrfwz0BIDv2hPgJh/qDgJPqr3ynhj4D4I41LE9ibDqhuLYFDybQyBv+KAsuJ8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=oDNBuxTi; arc=pass smtp.client-ip=209.85.208.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oDNBuxTi"
Received: by mail-ed1-f51.google.com with SMTP id 4fb4d7f45d1cf-6af8620a7d2so3574163a12.0
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 06:30:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1791898228; cv=none;
        d=google.com; s=arc-20260327;
        b=iZb1M3Bz5ucztjUa9JgyULCAgIj4wPcf4900hE28Bgwy2kHsZJ9P38ZwfDfWV4TJWn
         0d8QwuAGD6RlHtuRAoJ8M4/1q80Mx5Ew/uzh/yO9Wz9dYywLeHA1HZB8ZznXwSp+7jPz
         H5L3Oq0h6+xLym0dgbX5Xn6Vw8DWrRvL2FRz6FOtW3Xr97abCTo4ibRMGdmcJaYmvON1
         Gr2nM9/KUhp5jifIjHQdIfXpsPKCAs+xJ0YgJQkYG97kh15V43cvAy2+CYAs+0p4RGI5
         AgBgtJGwHHW9PB+12HPYakIBT5kB5JgB3eYs9El4LR5hpRVKXTOWy3ILVh9DB94GuqtK
         vTBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=5qhYf43Muz9D0siyZVmewVTjJme/DDq/hXostKmYpv4=;
        fh=Mys3y4MwsHRytUQMpdfGBn3oGRYLcLloxNwkFYMYMmg=;
        b=QXjQhcIUl9FlqB+71qzA5e6zol4uLF6DN2vp5/eas7CdHBTTI2NMi5h/Dp0V2olQPi
         8+Xp68vOq9HTshZvZCkrMVYYNoKXO1HKzjnZLP+qwgu076FyqLzNkvrRUfdCK7k/d95j
         jdLALPR/LJRW18nIbFgLASr6MShXdCRbPG8gdJoc/KsXwCAZpvJ5mGR7iJ3ntnRCcZUu
         H/sutIW4BaE5kU84x++QT2TwuDAjHL0E5Ey7pHs5pUitGQrv7lmhSbwNreFJUjGaJovr
         Z67XD94qEtIPPrrxgb1Tei7bLcdGgmd0OosJxz3Og7XRALyJSGfvunL+T3lqpgIhsjf9
         S2UQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791898228; x=1792503028; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=5qhYf43Muz9D0siyZVmewVTjJme/DDq/hXostKmYpv4=;
        b=oDNBuxTikPFqvMUm9hZZmrEi1HZEKzVrdh8dwl4IgO8ROqQKnyo1Sh9Da6pDfXgdX3
         YALmuZbP7PCnqxcgfihthcBJexxjvI1yweS4+CKnNgs1ybLJWas5/2Wp+ZnFOPMBS+MA
         Z4oHCYPwUjQ2I8ItsEY1klerT4tWjE+ysHA8NkvM+OYTXgvmrKwX8gm/FmXQy2jhkwle
         3+QeXsrkyL7Hd1AYrzdwTGbX2qkOb6XL7KUF83SocqcSH60QsgeaoHU5djX4s9jRdBK8
         rRfhENvDOap7+oK+f8mhHy1OIRAbPQQhhpaWpQrBIevr5UxwYtwdb2JVouNlv1Kka9mr
         qZzw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791898228; x=1792503028;
        h=content-transfer-encoding:content-type:to:subject:message-id:date
         :from:in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=5qhYf43Muz9D0siyZVmewVTjJme/DDq/hXostKmYpv4=;
        b=FpkrR3IXETkLKgjDxnrs5/foAoue0MESDfcEP4IWKQu+yLwFJnCIVUrLRSBZRnaucq
         wLkDHRxFXX5OCtY4Koje5Zjhvw3kklAvocTWlKjFDV+hp6polQTtGw/0CbNSzglVv+UB
         GyD0esarqwEosxEuZUJgRm2hRGhcyH+NOXh3PF/aqVpbaETEYfx7L63zywn1k/p5xNcs
         MHmugJLDpQxpgbN/iNft2LHR/0YkN1CZMBjqre8CzGd/DV0/vm0i0z3CMc0ZltQP6WP5
         7rxYMBKpNUm+UsXfu0jJgkc+NB2Zv4p1Lb0Iynj5eH0vhgVWcDHkgnHUOCPSJ+dxum8Q
         tL3w==
X-Gm-Message-State: AFq9FYJKv409snAXoiDATn9JsFAu0FNZX+P0F94vJdVKBTuS61+ZiGnb
	PoeDKoggUCmGibKtkEb6LpAo1cwLPuHDsUvMN6Mwy57Z9YcWOQSAFfmNUtwtJM7UB2XHjQcrcC+
	2fyXULhsAS0n4fFcnXWWnwphEQolSCWpZPeCt
X-Gm-Gg: AYBFou0Qfx5177CaG2CMbxHap/wAYZBTY7ic3X9vMELZhmXW4H9QClYXAxcHIULL8Li
	lIAWK8+s1xy8q6KlBKC7rRJtSNvAIVdPcye47VdDmc70Cxa/j6tEcB7akuAbIAb4LFxqp4VoPzn
	2WXjui1icoV3HagojuyVxE8+OJdZSyn43GZZnCW8AEgRW3QEbuuqU5gCJn+AWlL3aHctjAI0kPF
	uqmYe/px85CzEHT32fdwxpRr+KWGTQM8qufhIiqlzq7Sd5y/2/yH3CUOpR0oFuGQZf3SYy7odxh
	HoF/Rm1dzAL4PuucS3jVrFmCndifL5KsUv/ngoFxWu+W5QggKHFK74m0EOViMg2RJR9rUbsm4tV
	rtvicRvqLQ0xVGQ==
X-Received: by 2002:a05:6402:27cb:b0:6ac:6318:ab1e with SMTP id
 4fb4d7f45d1cf-6b17c2a384amr10700800a12.24.1791898228095; Tue, 13 Oct 2026
 06:30:28 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org>
 <20261009-acl-mode-v3-8-ba487c5e66e0@kernel.org> <CA+1jF5pyuVULzoAjbfCLDjwwOwHQP7sG29G-dkG9ZSOdVShHWg@mail.gmail.com>
 <dc1342d1-3c6f-4ebe-a093-2c2f876d32dc@app.fastmail.com>
In-Reply-To: <dc1342d1-3c6f-4ebe-a093-2c2f876d32dc@app.fastmail.com>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Tue, 13 Oct 2026 15:29:51 +0200
X-Gm-Features: AclHuK9Dv04wSY3LvPOWm2sJ7PyaklqzF-vRi2HJAGe8wXMcnMIMaIVuEBbOeaU
Message-ID: <CA+1jF5rfRgf6T312L0Ziwubx=8NXSUqrscQEkD2rY7mdve3RKg@mail.gmail.com>
Subject: Re: [PATCH pynfs v3 8/9] Add tests for SETATTR with MODE and ACL
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Oct 11, 2026 at 6:37=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
>
>
> On Sun, Oct 11, 2026, at 5:40 AM, Aur=C3=A9lien Couderc wrote:
> > What about testing FATTR4_MODE_SET_MASKED too? IMO this is a better
> > way to set the mode, because it is atomic and might fit better with
> > ACLs because it only sets intended mode bits.
>
> So, this thread is a repost of last year's pynfs ACL+MODE tests. I was
> trying to include only fixes and clean-ups.
>
> To be clear, are you asking for an additional pynfs test, or for
> additional logic in the Linux in-kernel NFS server? Or both?

First I was thinking only about a pynfs test for
FATTR4_MODE_SET_MASKED, but then I found out that Linux does not
support it. IMO the answer is therefore "BOTH". But first the test,
because we need to test this in ganesha too.

Aur=C3=A9lien
--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
