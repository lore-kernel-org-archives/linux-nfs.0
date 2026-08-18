Received: from mail-vs1-f45.google.com (mail-vs1-f45.google.com [209.85.217.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 922642E7BD3
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 21:05:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.217.45
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787087157; cv=pass; b=Pr9y1eVpBZ7uwuPPgAn2iGfqdP+4Z9/8NiQ0gL7OI8H9H1dRJMjXWtxxXGyWAgO+OHhMFB4zgAUNy9WBv+P6TUgnuYEZssoxzVOf3A/aG3ZEpkVvwAWvRr9PTPcmODY4qtPt+ACGkvEGgcFXOOhEGhHabA6DFCDrKlqFWoCmIuA=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787087157; c=relaxed/simple;
	bh=eaiZGhTFkGSfUcIl89fwxJ6hO6jgRXyP3XW1j8eLIR0=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=T31qx79k8txYSDIm7lHD2b65ZHmU7qh7e3kvSI5iWXsFWx7o100ZA+/2+q23P0OZh2tCXHdUdVn3ToAOas9s31JLlbd9mcsJdf29sRwvzrKncasGqmOBGyH3cvWCmqfkr7ef4T3+wujDEZ7y49ni1BO6WGG2KsIGbm8aTZcjp3Y=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=XqBe7Rb2; arc=pass smtp.client-ip=209.85.217.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XqBe7Rb2"
Received: by mail-vs1-f45.google.com with SMTP id ada2fe7eead31-74ac3ea9c60so124357137.1
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 14:05:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787087154; cv=none;
        d=google.com; s=arc-20260327;
        b=NPJOg7V9Wh4mX5YJBCmBMRtfLZO7i/0vtrE+/mWsv06fAfsdyl8+QOIW8idyYXOYuG
         0DFqO3J2vDHWDudBtVzTemgCYiZfmiHvNxAFPG57c1omvBN1/zvzmVCK9kSWXNq9eZR0
         q8i4/gPTpM2s1cn7EgGYJUjQhe1Nw9Z0JHOGQwMdmKRWp9n3XrZySDuLLLadb8HCI8n0
         W56TdScjh3lgbFeEYgYjUVJrAQrI9HhQR9LPidaLjbVLnFqG/0MBK+Pi+wXMXRTse8FP
         Mysv1l+A+XQLrTlEhpbCh60BvIeHuvD6SX50KUPy62UWUImyqERZFNVH7z2r58yGw1PS
         U3ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=w65RnozkjZAQaQTG29xDabJ4i5pwIahs9WVifSWjt2I=;
        fh=KmYRNc+4A8EZe9W7vEJpTAFLola8BSA2ciJKyloWeAo=;
        b=j4f8QQ7J/thMssVvsCmUTKDM2sDZ5Xc2YeUqKSJa9JryPxEaQmHgDYQpFR7PcStieI
         m/nUjFfCxxnHrDc4R6f10b2kON0tOoYAWhFgPynwGJmjMcvfPgk7d2V6xrNIznKqZXn1
         JKXMG42gGfIjPrKuxvSPISCrp5UZ2DGCU53jBfWh2vWNF3KKKpszgAah6Pf8nRRqxSG0
         y/c5GIS8/+knSyGPDDHuaKrXE5lNXDSmMSzGraOGlzyKz/ENB3zOjp1KEJPf1XL+r4qy
         5bSxnlmijH39Za+Xnp+ALX/reyeqoVz3AcPA3cnvB8hY1M9G1IY+VON5V30G6nlMige6
         GpwA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1787087154; x=1787691954; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=w65RnozkjZAQaQTG29xDabJ4i5pwIahs9WVifSWjt2I=;
        b=XqBe7Rb2aXIrL58QzBetFbB5cR1YFxWXXq/WWMxz5NoohtoHLMZJP8qYZ16w3yQ9zy
         KKTCrWmbXDdp+uJMwFlV3QJB7eLindLwo/kzCTCDQfanziC0XbIlm1qYw/gg1KjJfY9f
         IdEFXGbTjVnNNjB+/DY9F5yK4n6RabUnfq6kCJewMLMgElpVDh56XNRg2qpH8JM9W1vj
         4NjkP0hyj/oFro4jvIOWibvbLxyb0972jrDugXtfCKHV/BvKBQJV7EO3CSrooRn0NsZI
         CgU2BhlX0YauBwyW2vjh7KXXE+4BA8mW0wTlJ6p6vKV5YmW0tomIbH0d7fn9XBdufYMd
         pnQw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787087154; x=1787691954;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=w65RnozkjZAQaQTG29xDabJ4i5pwIahs9WVifSWjt2I=;
        b=B8Qjc9g381mHSYchwGZOKlD3foHD+lIjKnKlfTeHae3cyp3zeYZpU6JkKiyuppgrZg
         /UaF7qjl3K6LO5y2AqHazAUbKInjm5yik/TubJEEPrYokZusfgXBC7WB4ZM43lHMEc6B
         ltSSbZsVr2ex3ssU+jny2E72OBeKNVrmyRCEIoWJyRaTlJaYl00iQfB2TjAgoNUqVxhp
         FJRqWgxRZD92QmnkkBUXpGhRqmTqxU0n1we8n4y8BsAlfdzNXzAxRZQiqm+UvmNCMfmT
         /g3T3jJhhkhTvHzbxXvXh50VUojwRxcFpBgFLhLdngPHbmhfUDbx7lnXP7FL9SPmFy63
         lrkg==
X-Forwarded-Encrypted: i=1; AHgh+RplsMXWeG2HIh2N84qfqzUyfMPAAVU8SzCyVPF7e/WtPhkkIlMUl4oD0qNw6iJfTnI1IjgL6D5jUEE=@vger.kernel.org
X-Gm-Message-State: AOJu0Yx8SOaHxvbszzfkHFn7wxBPRlSwz/WRVvKSUInUuP4/gW5CUMkn
	LA3abQ7g5zobHywt78K9QcrDs3KBdsevirrh/ke7x8qwAfKTVfMzNLQB2eFmzpi4HIWsMw0GkLQ
	YtURUx6zBpuDV4ceaRXbBT3Pjd92+O2jH3L2Ew8o/6LZI+2+VjtJAcg6C
X-Gm-Gg: AR+sD12ZB060PXkt5SjULTDf44/w8Q4/jJPwc78zCheirEjCtteY9H675f5d/aKXqVC
	IHuUQF1qIldN/x/qWS3qNfDwvrhtfngmKIcvT8v8k9Nygm76CMuQ73e0gH/3DBoVQy3SY5Jc4Ht
	HMuQ784VfgNkvw4qRDBwDUNZRmziDpTiXB8W+qqbYoVhc3R+0YO/gbWir0jmcsdm+zfrC91SJs0
	bb8Z/f9EoxS1i/Q+Zqg+HKiBw3vMVQB6e0qZBR1Tgv2/860rVvXH3Fl2NQBcBe7tmtp7EaORZAz
	J2fFWOx0dmt1vQfTfv6eBvqsBCNXdCikGkNGPAjatA1lls9/DIZu9ZaHRbvw9WzM3YGrY35Uh0I
	L0g==
X-Received: by 2002:a05:6102:5087:b0:772:94c0:fa4 with SMTP id
 ada2fe7eead31-777b8becdd3mr326722137.12.1787087153716; Tue, 18 Aug 2026
 14:05:53 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com>
 <20260818095548.27e0edb2@pumpkin>
In-Reply-To: <20260818095548.27e0edb2@pumpkin>
From: Justin Stitt <justinstitt@google.com>
Date: Tue, 18 Aug 2026 14:05:41 -0700
X-Gm-Features: AcwNN1XPdoRn06Kbjdp5yMNEHfNd_fxF4aqaUzMomekFpCZQpXJpbK6mr3zZqTE
Message-ID: <CAFhGd8rGren7EwjASppcx2WW8d-ky-T7k6mTxK-MpHfZmFTtbg@mail.gmail.com>
Subject: Re: [PATCH] NFS: nfsroot: replace strlcat() with snprintf()
To: David Laight <david.laight.linux@gmail.com>
Cc: Mariia Nikitash <mariianikitash@google.com>, trondmy@kernel.org, anna@kernel.org, 
	keescook@google.com, linux-hardening@vger.kernel.org, 
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	nikitash.mariiaw@gmail.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Aug 18, 2026 at 1:55=E2=80=AFAM David Laight
<david.laight.linux@gmail.com> wrote:
>
> On Fri, 14 Aug 2026 00:28:45 -0700
> Mariia Nikitash <mariianikitash@google.com> wrote:
>
> > In preparation for removing the deprecated strlcat() API[1], replace it=
s
> > uses in root_nfs_cat() with snprintf().
> >
> > Build the separator and source string in a single call using the
> > remaining space in the destination buffer. snprintf() returns the lengt=
h
> > it would have written excluding the terminating NUL, so comparing the
> > return value against the remaining buffer space preserves the existing
> > truncation check.
> >
> > Link: https://github.com/KSPP/linux/issues/370 [1]
> > Signed-off-by: Mariia Nikitash <mariianikitash@google.com>
> > ---
> >  fs/nfs/nfsroot.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> >
> > diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
> > index 432612d22437..e951fe731679 100644
> > --- a/fs/nfs/nfsroot.c
> > +++ b/fs/nfs/nfsroot.c
> > @@ -173,12 +173,12 @@ static int __init root_nfs_cat(char *dest, const =
char *src,
> >                              const size_t destlen)
> >  {
> >       size_t len =3D strlen(dest);
> > +     size_t remaining =3D destlen - len;
> > +     const char *sep =3D "";
> >
> >       if (len && dest[len - 1] !=3D ',')
> > -             if (strlcat(dest, ",", destlen) >=3D destlen)
> > -                     return -1;
> > -
> > -     if (strlcat(dest, src, destlen) >=3D destlen)
> > +             sep =3D ",";
> > +     if (snprintf(dest + len, remaining, "%s%s", sep, src) >=3D remain=
ing)
> >               return -1;
>
> I think I'd have gone for:
>         size_t len =3D strlen(dest);
>         if (len && dest[len - 1] !=3D ',' && ++len < destlen)
>                 dest[len - 1] =3D ',';
>         if (strscpy(dest + len, src, destlen - len) < 0)
>                 return -1;

Can we run into underflow issues if `len =3D=3D destlen` during the
increment. imagine @len is 10 and @destlen is also 10. We end up
incrementing len and our strscpy receives `10 - 11` wrapping to
SIZE_MAX.

Maybe this isn't reachable as @destlen may always be larger than what
`strlen()` can give us but that increment looks suspicious.

>
> Although it would be better as an 'add_option()' function.
> I suspect the it used to be just strcat().
> (similarly for root_nfs_copy() which is a pointless wrapper on strscpy())=
.
>
> Much more worth while would be fixing the sprintf() for NFS_ROOT.
>
> David
>
> >       return 0;
> >  }
>

Justin
