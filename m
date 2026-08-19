Received: from mail-wr1-f43.google.com (mail-wr1-f43.google.com [209.85.221.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C8A344B692
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 10:22:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787134980; cv=none; b=ldroFrVUo8lUWPvpu3qPxXr5WU1Jy6mS9ZjCH0W7DFeHpItudrJYZXnNAPVokFNi9vPvw0s0YQ5UDjixDHeR3cC/675CnG9kDgKk5WURoULF2DO0N0FOWV7yhociI5B9WhmfT6HDVHpR1DaCb6VFaoC1mjJvNvrqRn7P3ft3Rwk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787134980; c=relaxed/simple;
	bh=rW/e1CxWcba8RMrjEjk+asvAa8OSuX3JiGrYAp/zjkI=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=PGVJ0n/9uIM6bqIywjmwmiXRrw4o7xR+ahEpdkfOqkUthe5HXUf4FyYaYHF4gUXbVUg9y0mgNydSXO7/FOW+N86tNp62pHqJPz4miyiF9wi5LAtLbVJok7dDkAw3cMPx74TPBiw9EKJGJWbFVm5CDu5XOGxFZxy1vAFlXJ79JMQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=eeqKIxDU; arc=none smtp.client-ip=209.85.221.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eeqKIxDU"
Received: by mail-wr1-f43.google.com with SMTP id ffacd0b85a97d-47fd4531020so475958f8f.3
        for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 03:22:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787134977; x=1787739777; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=F2O1QeWpjEXp0I6ZiHe6QrGIN+8dZKSNTYFq4Xm0R9g=;
        b=eeqKIxDUvL5ihSUwqNwVM6Y8DVGi37Ciihh5Avf6tagYZ429UIAdFKgttI++upjPn2
         ryRyoIHAVSNJptUtC4cED/akCPqJrBw+YNyVTOvVXVNP59phoeATCyFwbTxBeyxzkCAN
         9nkvCa/e8Jv9RMUbV8hNmxTHXomyARsc3eB6Epw7m41rnk2zaFVCpXgGBvMYoiTeNDPF
         XLTIVZZxSVLlip2YaO0N/WAWL/Ey16JrjF5kGBONQRLlph0mPDNJlf5BqkY8JdoJ7JWl
         jDjfaCrZhXc8ABzP56pcJh8WPHKaNPfeXl7GUdkfBlb32XRfj1MZ6xgQ0qk1gvjCVhFB
         7ODw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787134977; x=1787739777;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=F2O1QeWpjEXp0I6ZiHe6QrGIN+8dZKSNTYFq4Xm0R9g=;
        b=LA2UjeU27eu8a/ASVxanHzZVfWrO5iKo5vLzQoilYCRoUvzSQOEraCqU0OV+GXOsd2
         K1TbpIxD3eAiCoMDY1rvLrYubC/CIixrSdpcRbLYZWzxVjM2UEBCXaLo+Ak8x72T27Hn
         8ZEBuDarH8iU0mx5zl2oW5cz7DZDHTmq1iuLx5Fi1amUfZ7o/sTFjqXHW9uKOX9CTGN/
         Latwg92Ywi55ICCSDFChCZV3zC6uuo3LLiHs9Cu/TtwrvS5UCtbkuEAs5H1GFj0d8Mg4
         ITNyXIWVSm4/h6knHqRfYf88KCYEtAWgkznaU+Ia8DL+91xgZg7ykTPK9Hf1+FYo7mRF
         /KLw==
X-Forwarded-Encrypted: i=1; AHgh+RrCet/UX4BoYGswPrzyaH/rZ+Zc62UxclpqPYKA0IwOgEeZ/F5V6e0ogRxV3E/62UuK1lKpFGHxST0=@vger.kernel.org
X-Gm-Message-State: AFuF++k5/VY3dKrAvwZt2D9icMjTELN1FoKqu16X3dmWhN3EIp38Qrr6
	5vRHId4VeyW0MDrVGcZq8tTyCL3g1Onp9LoUV7w3h1rtZVL3E8fj1nD5
X-Gm-Gg: AR+sD12RCXB59j76oA2MLvP3sLGNLS//5vnWa7yk3e/P0QN/CqQKygtDCy8VgrKZ7dh
	Yyn/292MB4rkxLVLTNVL9KI+Y7sxNZDnRLREXYngi59L7uXYsEH8stfAJUnCn4YHUkcsDbMhagR
	9Wy5rKki28d3dR01j4Z+GSv7XREeAGNG5MvfQm0kFvrxe3reNF86vuQzychmFAz1Fv2GIRVYLHo
	xCLW/PkIUhgUxYsTuEB3Lj4CVVvDLSmg9Vk5Fd7l6LZrAganEog7Ec0StKINYQ9mAtlxHxCdxxE
	pzTvovbYc+A6V/cmJhYRkcuKkk30drkIX8115DNRNQwIdFIydqHRTM6BNjHGaX865qDBHk3Dg5F
	HMSsRAR/xBKDj+bfpTmVsb0KgWH4rqMUGInvYJpIbyvM3LuqPD7/iObh06AiMvXYOOZcY+PZQni
	DqwITj43mU0pBgydfG4PE9/jg4HOc/9S9mywYaQdoQXztaPWsgE3IkwvwVkF3NRa1Zx7mzois04
	X3Eog0094nbBCRSbjlvafJ74b9dZrtn3p06
X-Received: by 2002:a05:6000:401e:b0:482:a610:7a27 with SMTP id ffacd0b85a97d-482b1ff2808mr5345072f8f.20.1787134976552;
        Wed, 19 Aug 2026 03:22:56 -0700 (PDT)
Received: from pumpkin (82-69-66-36.dsl.in-addr.zen.co.uk. [82.69.66.36])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-482b14c338dsm4051137f8f.25.2026.08.19.03.22.55
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 19 Aug 2026 03:22:55 -0700 (PDT)
Date: Wed, 19 Aug 2026 11:22:54 +0100
From: David Laight <david.laight.linux@gmail.com>
To: Justin Stitt <justinstitt@google.com>
Cc: Mariia Nikitash <mariianikitash@google.com>, trondmy@kernel.org,
 anna@kernel.org, keescook@google.com, linux-hardening@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 nikitash.mariiaw@gmail.com
Subject: Re: [PATCH] NFS: nfsroot: replace strlcat() with snprintf()
Message-ID: <20260819112254.3e7d2b9c@pumpkin>
In-Reply-To: <CAFhGd8rGren7EwjASppcx2WW8d-ky-T7k6mTxK-MpHfZmFTtbg@mail.gmail.com>
References: <27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com>
	<20260818095548.27e0edb2@pumpkin>
	<CAFhGd8rGren7EwjASppcx2WW8d-ky-T7k6mTxK-MpHfZmFTtbg@mail.gmail.com>
X-Mailer: Claws Mail 4.1.1 (GTK 3.24.38; arm-unknown-linux-gnueabihf)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Aug 2026 14:05:41 -0700
Justin Stitt <justinstitt@google.com> wrote:

> Hi,
>=20
> On Tue, Aug 18, 2026 at 1:55=E2=80=AFAM David Laight
> <david.laight.linux@gmail.com> wrote:
> >
> > On Fri, 14 Aug 2026 00:28:45 -0700
> > Mariia Nikitash <mariianikitash@google.com> wrote:
> > =20
> > > In preparation for removing the deprecated strlcat() API[1], replace =
its
> > > uses in root_nfs_cat() with snprintf().
> > >
> > > Build the separator and source string in a single call using the
> > > remaining space in the destination buffer. snprintf() returns the len=
gth
> > > it would have written excluding the terminating NUL, so comparing the
> > > return value against the remaining buffer space preserves the existing
> > > truncation check.
> > >
> > > Link: https://github.com/KSPP/linux/issues/370 [1]
> > > Signed-off-by: Mariia Nikitash <mariianikitash@google.com>
> > > ---
> > >  fs/nfs/nfsroot.c | 8 ++++----
> > >  1 file changed, 4 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
> > > index 432612d22437..e951fe731679 100644
> > > --- a/fs/nfs/nfsroot.c
> > > +++ b/fs/nfs/nfsroot.c
> > > @@ -173,12 +173,12 @@ static int __init root_nfs_cat(char *dest, cons=
t char *src,
> > >                              const size_t destlen)
> > >  {
> > >       size_t len =3D strlen(dest);
> > > +     size_t remaining =3D destlen - len;
> > > +     const char *sep =3D "";
> > >
> > >       if (len && dest[len - 1] !=3D ',')
> > > -             if (strlcat(dest, ",", destlen) >=3D destlen)
> > > -                     return -1;
> > > -
> > > -     if (strlcat(dest, src, destlen) >=3D destlen)
> > > +             sep =3D ",";
> > > +     if (snprintf(dest + len, remaining, "%s%s", sep, src) >=3D rema=
ining)
> > >               return -1; =20
> >
> > I think I'd have gone for:
> >         size_t len =3D strlen(dest);
> >         if (len && dest[len - 1] !=3D ',' && ++len < destlen)
> >                 dest[len - 1] =3D ',';
> >         if (strscpy(dest + len, src, destlen - len) < 0)
> >                 return -1; =20
>=20
> Can we run into underflow issues if `len =3D=3D destlen` during the
> increment. imagine @len is 10 and @destlen is also 10. We end up
> incrementing len and our strscpy receives `10 - 11` wrapping to
> SIZE_MAX.

len can only be less than destlen, so strscpy() can only see a zero
length - which is fine,

This whole code could be rewritten to avoid the strlen().
The function is only used twice to append data to a single static string.
Tweaking the initialisation would allow sizeof() be used to set
the initial length.
The initialisation also means that the ',' is always needed.

The second call appends data from an snprintf() into a temporary buffer.
It wouldn't be hard to directly add the data to the actual buffer.

David

>=20
> Maybe this isn't reachable as @destlen may always be larger than what
> `strlen()` can give us but that increment looks suspicious.
>=20
> >
> > Although it would be better as an 'add_option()' function.
> > I suspect the it used to be just strcat().
> > (similarly for root_nfs_copy() which is a pointless wrapper on strscpy(=
)).
> >
> > Much more worth while would be fixing the sprintf() for NFS_ROOT.
> >
> > David
> > =20
> > >       return 0;
> > >  } =20
> > =20
>=20
> Justin

