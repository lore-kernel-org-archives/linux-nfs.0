Received: from mail-vk1-f175.google.com (mail-vk1-f175.google.com [209.85.221.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B2C5A3E1208
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 20:51:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.221.175
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786999922; cv=pass; b=IUnlGXFQPoqs7hahfxN9unbrO1jgpQS7b1xv/rgbeWEpR90ny+7ztwsx6pQGMEQaAY8cMhj5rtYW+u8kVvcW04XWUs2VBRwch7R8n1+6sYTLr6CmCoTqADD8MVFlxIM1Hh8XGqQ6UElwDrE0FQYmKk795m5CfcBF0fJ0ja1vOyc=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786999922; c=relaxed/simple;
	bh=6WuzAbspB1ExSogF8kqjQzSwSHTkgCAcgZZwabnez2Q=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=lggAYTGp/is8hEWPU6MgpQrwolBOdSpFlCgVFVlXzljzb9Jqnb+FuwM80wt6GIMDiu6IlZHojbwwg7qNUhxc4CPRD6KWWvqR0qGdIgl9LswbBDU6zcFkEUZkNvWsDTyvG/Q2y9iCDNWFh1hKUZF9LMO0RPj8vxFnTdVRIbZO0S8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=PhOHFZ3g; arc=pass smtp.client-ip=209.85.221.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PhOHFZ3g"
Received: by mail-vk1-f175.google.com with SMTP id 71dfb90a1353d-5bf95ade656so1435213e0c.1
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 13:51:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786999918; cv=none;
        d=google.com; s=arc-20260327;
        b=qHoSY+kxiFz7aia3AKQf/SAgeOzxyUWJTqn3yCvw5LhMMQxE3LJwODpF+Ofr+Urrw7
         5E/AZk+vJy0IQi3LkVJCGGBMkcVHUr9rsYIiFyIH6z5TW6x1GL3T7mgAR32HQJFgQR3f
         5XSG/P6Lq+fZmtxhvl1krIDAw4oBbJZxHnAwnPAbVbrFlJ/4MPTPEYNx9MMvt0GhvFJx
         nwB3lu9xy8eSAJJFgrfL1ep6oHZwXlPsJBJFFVQICq5wKxFJSuXEfYvy8xGDKzcmcLcR
         OAHugqmR7h45/pKJXGV6Uj0NRRr/NTNfGyEpS9g559lfJy1Cqrq+lwhsQBavH7brNb2n
         ah3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=eF1JE8DesWnKgF2u3tRIF8wb7IKv2IB08SAz4bl5DYk=;
        fh=SZQRNNBEmgSWYaqVqcE5EBr/cLOUAC+r8YIw22qT/6k=;
        b=NLjFidIKTQy3IAc+fEnZAvFCick5htWKUk357h+caTJKYJP9jrKBKSveJrZvHaAtsP
         jye0d6jUChAdLeESPjxG8lMBl5n4KSuSfB2MR/tydOYYfK3k2U8ue4+RJN3bDDa6Yleh
         I/eYWJ03OG62sbMhNePwkLyeG8VZWGjzo9Xl0KKLaCwtHDXjan0tsJlVEJykkqoxiVsp
         60MwGhFQm1oSysASwk0JsSX9HyVAqtowDFh20ZaqYGrcmk1GHEtth651MIBly7g227eY
         7u/qWCBXeaPxosscdD+O6ana7+1Nt67YxETIpNa9S0wpvTpGvgJpEM6CFi5K9czq5Wb6
         Tkrg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1786999918; x=1787604718; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=eF1JE8DesWnKgF2u3tRIF8wb7IKv2IB08SAz4bl5DYk=;
        b=PhOHFZ3gQ1FZ+GWctd96IbMbpV5YEaOZSE+jYQtO6tlA4KD2uopyvtbH75bpkgLMOV
         89mGyZOoAZsEeG5p/wWUipMMoIPpGakqtboWTJ8YOOIqg6Vh73XJYVj5HR+Aa9JGQlMe
         A/9tXHSmLfUALEuEaNwrIgy7J6n6mRQ8yJvE0bkqfIVofeLzoJlQofntO1xbCDUOhHRh
         wE39K1ggOhGYAe6mhJqnBW/ETZgKAk9OTwEaRpNt+4WG6tATYwAASem42VClIvsskmXR
         o/XWQeYzC00vOItTMLVPnoeFdCBFFWuM5oNLU1JDITwwtgbL0nhRZrlenC35EUbj2pSC
         Z6hg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786999918; x=1787604718;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=eF1JE8DesWnKgF2u3tRIF8wb7IKv2IB08SAz4bl5DYk=;
        b=almTVT84hY2uBQYNzTLl3j0dsnx/54nuxEr2127qa6wEitmVkR38I60vt1KNu/3TaD
         V8n3bliKY+VVEj0W0ZAbH+hKOs5MQ+1R8Lk5hl0SAztsleIDgtjkusJ6fpu1yBiiZtFF
         xNNwslsM8I6/P3+lR0KpJ85SOxUUDtP+UWzG1QAG7IBSqUfwZhv/B2jijOdo08Dmvrck
         TYtwlb+sJutFXCjQ0PJ5PFQl8q+192qlmlWQ2SnB7RtfiCDJ14NQrNhW8HCYtwJ/uXiU
         sqGN86mofEgtM25WRzyP+cfusk5zGQ3fGOQPItLbUcMArBUkvHSVRAq2Rq0xIJJaTx4a
         abbA==
X-Forwarded-Encrypted: i=1; AHgh+RqMFuQgFRe/OBvPKYBpJqWXm4zI6MBye/TXB8lsfr9ki/CGXPHMieUDK9KrBJkE3g+FqDUpAB0njyg=@vger.kernel.org
X-Gm-Message-State: AOJu0YzBHMUnuwOhlD+YgUjT9pyBHenkCdwfWjhmOGZW+liOZiL2q86+
	x7VYo8KCwiW5JTRe84O/O4P+XjUPrf4qJoG10IyATvR2tFf4hL3H6f9KuHlFKvLeHOAkvKseeLM
	ViAOjmJe4WTN0r4bYzwuzQurfpg1+SEkxmS6zuQU=
X-Gm-Gg: AR+sD12sFVEzxcu6UQwsHlTWN0OdEs4QqYmXPm2VjTRymN1kI1HygyB9BhE9XzwQ0DR
	9L4fD1Rhv+5YMC3xGp2azjxryTTbWOCHebEcmB3Ii7THV5Z55H7n1D22eLI5pWctlm4XDmQ5XPO
	9JskAhAMtC7NmNYq+/M61SKIJao1YTQPeid6W0KbLVWYxKK9s73yTI/I4n8TcFKelIZvUR204kn
	3XDUbabZhMNwSGkT77iWteud9bmTAkuxzvNyxS3Cbx7ROfkOo5kXPJoMegOPwc/lg0rz6w4J0Va
	VNOW75RzaYQiqMpPDQIyv/aY0BJy0TKpIJQv8ct8/775oKdQj6W8qVf18ge4x6x5HullClT2r+y
	hsKygVrh5itpZXhB2xSWAru/hLPj/1nYftxVQJjpXjQ==
X-Received: by 2002:a05:6122:1d8e:b0:5bf:7f98:9657 with SMTP id
 71dfb90a1353d-5c591d1e4b3mr5206909e0c.6.1786999917761; Mon, 17 Aug 2026
 13:51:57 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com>
 <aoNuOD6CLopCgxtU@google.com>
In-Reply-To: <aoNuOD6CLopCgxtU@google.com>
From: Bill Wendling <morbo@google.com>
Date: Mon, 17 Aug 2026 13:51:41 -0700
X-Gm-Features: AcwNN1UiSchRXIblAc0RIrxdgm7oeFqezFJfw_ciVQw3x4wTmpuPp3ASi6kdEAY
Message-ID: <CAGG=3QXu=kioXx3dRB2GO=qGQ+SqSuenbqMrrLEFz8KcRbn35A@mail.gmail.com>
Subject: Re: [PATCH] NFS: nfsroot: replace strlcat() with snprintf()
To: Justin Stitt <justinstitt@google.com>
Cc: Mariia Nikitash <mariianikitash@google.com>, trondmy@kernel.org, anna@kernel.org, 
	keescook@google.com, linux-hardening@vger.kernel.org, 
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	nikitash.mariiaw@gmail.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 17, 2026 at 1:33=E2=80=AFPM Justin Stitt <justinstitt@google.co=
m> wrote:
>
> Hi,
>
> On Fri, Aug 14, 2026 at 12:28:45AM -0700, Mariia Nikitash wrote:
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
>
>
> Reviewed-by: Justin Stitt <justinstitt@google.com>
>
Acked-by: Bill Wendling <morbo@google.com>

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
> >       return 0;
> >  }
> > --
> > 2.55.0.679.g6767b8d81c-goog
> >
> >
>
> Thanks
> Justin
>
