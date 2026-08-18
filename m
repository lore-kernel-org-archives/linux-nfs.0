Received: from mail-yw1-f182.google.com (mail-yw1-f182.google.com [209.85.128.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EECA53EDAA9
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 18:44:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.128.182
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787078691; cv=pass; b=oofys3kmRGNfqrFyu+gSW6AW3uxyKRUf/ohuKfWg20Yccxl9kP3YkHVjhjt8DuS0bwYzyU+LEvG9E3GujZoy4RwmvUh+yuA8wJTTmJEmQG4tNPo43gUib9QdxWbIWjO8W5j5P43TUUJlD+Pqkvi+DLye2tBgPT8xvKLwK/g2ohA=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787078691; c=relaxed/simple;
	bh=3oW2WhdOYSxmg4pvKp10tBDIqvdQLZRlXXHrFgQdYA0=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=MGDGbU5j9DCKP9OsAErgtMrni1fW2Dy6Y1QIfGgoyp+1Ec0f1GfUi0L8qwllfRjtBvwqs7JQYYW8StMSr72rjFTD+9H49S3ZztGbskA/V/0AEmz89mkP2eKvhFw67BCaH8ldLSLassasQB1U7B0OlV3b6Jtbf5FvbE1A/bMm8o8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=QhgClk3A; arc=pass smtp.client-ip=209.85.128.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="QhgClk3A"
Received: by mail-yw1-f182.google.com with SMTP id 00721157ae682-836c5b01e82so4632757b3.0
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 11:44:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787078689; cv=none;
        d=google.com; s=arc-20260327;
        b=iRfeCLImUbwGYiwlKZCt3AdtgbDIWYE2ZMEKlU7coMTdEs03pp3GVmnFOruSPz4xTL
         Gh3cOEm/imYUJkvh846B+5YA+fGE9MpEMVKE+5ax3kRcOaS6/eGfeyC0CwFjMcl64k+K
         LODCUUono8TSB9WfilppAz6HQ0RwvCFAG6WIgjHUkfh3K4NWi12/f5YwWUPTmExP+EA0
         nMVpibQpswmTIxtvdzN9GrhNwdpFPZPJdvmvLiV0zrlwnpnLX3Uz6xmQFWLh8d8QlbF6
         x7Ozi6Gb2Kj7KMOF4nTHaBfOTX0im+G5O+Jb4xyacNtNx7i73RA+1tZyCzPH4Ag1TYgK
         OjvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=eUWxoyugIoSCCau305C8MjG63CJLkHpqw2M9gsy7wTY=;
        fh=ogoC0uJS//xia+pdsqD+L6IaOh0MQvRzswvoR2DHBMg=;
        b=hmguz4K1jDzzFhZl9Crie4fLGZ6yxsnFsPDNCo6GB/udlRrQDLb8eumcPD+nvdWD9e
         KK15plu7RaMiWrkTPryFcB71xSTQGXqz1r7tYbcL1Xt/nDNKaIdtKfj6mmbzUbCk5qte
         1m1ZRFGzdeK84SUqp6Xdu6Pob0MFSQh3cKszp0lMUB66x14MpDNkCopVcRym1VvucN7I
         Ap4AoweSFGIzvzEueYMSsNVruHKqzh/hj+zqcyYwLwxgFSvqmbH9to3cTMU3a1xJjG6n
         23grslbqbbPi296UWk1pmLQZxf3bu3ikCG8fEmKXMdF6WoQs5RsMgVJ8KdI0d22xso/+
         Uqvw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1787078689; x=1787683489; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=eUWxoyugIoSCCau305C8MjG63CJLkHpqw2M9gsy7wTY=;
        b=QhgClk3ATWr0bK9Ye8Jt/pNvuYBWD1JxyGW1xT90xViOmYw4sFnsC80XBgA5oI4GJ8
         KNBgXtKPBNiDIE8girY6Sg7EhXMUt0abTRqWjgoeeWc248bN3hrhQQ+izZgrqZBKhRzM
         fdcWPh+im0++ZgXfCE0Wt9y1SVtXnVEJBNuGuWpHA35Vc5V9woyqtHJsx8rBEg4Eh5iB
         21T6N99GRL1SjEJO//d1qQJdzjMSAIFFnPcmbyink9lK6oN1/pi/cgoP6cZSbyIS1y8d
         7BXlV/6jkjCTwwGlb05Lpsik8IXM1Mwym8XvsXLci1djepe4d7a+K5VjcriP561jeqUK
         QiSw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787078689; x=1787683489;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=eUWxoyugIoSCCau305C8MjG63CJLkHpqw2M9gsy7wTY=;
        b=bdEfC0zaey2HACGZAlK+yTll5WGJDVNWWp1teXlr+eNLsRip0B4+ezH0u7emwFQJa4
         ocvZEn6Rr//AKBnYIIky7yvcNJTLwTdinhdKevFeabJf5+gmJdIFvheuL7J1SF1LbPS7
         sMMC+5oelUjoVj8OfcXUDc953GIu1cx4rzszu1kGgUZnsRRxsFVQvDVSEdNQLU76cfjL
         /2RYBxlDjBmCeAER3zcDXHJTTeaWhpSZbSj+0ny7XJQv6C46GmJa6b1+09WT+iACQ0ia
         BL6YAr2mQMq0JYIpe7TBp0fA86QokA7YNGtQvDzl743QwlpL/PnaSJ9f2Z+mk++bnCmd
         U/dw==
X-Forwarded-Encrypted: i=1; AHgh+RpDZVxgS/uO+DBp7QALERqAxOcBL/c9AKrMe34kEE3/4EEtp6x1vcoTfH+3ID9wj9zqSMHcSr6TsPU=@vger.kernel.org
X-Gm-Message-State: AOJu0Yy5gaC6rUjM/UGnntvmWwD2iqNSpVEnQF2g1TMvVrWG1Y7Agb4D
	G8hT4kx+auCxxTpULZL7rqYKbDbd8alRC4aogRw31rxgeowuhwxWvlBBZv1kBx2/5csV90gvhEQ
	piAEJWsQ6ZYm0PkM8NRhTNlRXmOc90uf3535Y77Qo
X-Gm-Gg: AR+sD11ekEPSTejsLr+8CWH0p2kCaqNMIssig9gfxgz13eRADQ1iVRMb9eXa4F78MVZ
	ZQ15AQPG9ICbR/qdU1e3JOlS7mRkgB/j3xE9JkQPjANBAyFmkjFjiJy3oeErGTcP+NlgX+0MKB+
	pp4MeA2yOTnIzJTISrXwcDprSyU2B0urjhAhlmwq1yKjbx2sQSYJDObnBYxMDRm2ya3uRJG9X83
	bvFvPPHqzpM8O+7H6l0xSiw9K4zcyMuSF1WBfd/RwnxG6QVY2vLOs7O+2jSSSv5UV9tbrQgcI7H
	qL5CFfgCgCqYanGIQMXqfRGqU59dcRLXXQppeDhcwUfcdmjTfkIo9SZTyO9Fypj7lGCq5whBZIh
	JBLQJ/3ZT
X-Received: by 2002:a05:690c:e1c2:10b0:80c:76fd:f732 with SMTP id
 00721157ae682-841316567a4mr32446497b3.26.1787078688444; Tue, 18 Aug 2026
 11:44:48 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com>
 <20260818095548.27e0edb2@pumpkin> <202608181041.0619C92@keescook>
In-Reply-To: <202608181041.0619C92@keescook>
From: Mariia Nikitash <mariianikitash@google.com>
Date: Tue, 18 Aug 2026 11:44:36 -0700
X-Gm-Features: AcwNN1VpdCirsWcApQO42k7ZgW4GVpZYRhbKLXvlSnwbeWlmgtq1HM7L9WUmBXE
Message-ID: <CAK=BGyKGPf+dvph30b4m=oPhA=cfAYEj2Sq0FY=Qsbpmb2XEQw@mail.gmail.com>
Subject: Re: [PATCH] NFS: nfsroot: replace strlcat() with snprintf()
To: Kees Cook <kees@kernel.org>
Cc: David Laight <david.laight.linux@gmail.com>, trondmy@kernel.org, anna@kernel.org, 
	justinstitt@google.com, linux-hardening@vger.kernel.org, 
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	nikitash.mariiaw@gmail.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi,



On Tue, Aug 18, 2026 at 10:42=E2=80=AFAM Kees Cook <kees@kernel.org> wrote:
>
> On Tue, Aug 18, 2026 at 09:55:48AM +0100, David Laight wrote:
> > On Fri, 14 Aug 2026 00:28:45 -0700
> > Mariia Nikitash <mariianikitash@google.com> wrote:
> >
> > > In preparation for removing the deprecated strlcat() API[1], replace =
its
> > > uses in root_nfs_cat() with snprintf().
> > >
> > > Build the separator and source string in a single call using the
> > > remaining space in the destination buffer. snprintf() returns the len=
gth
> > > it would have written excluding the terminating NUL, so comparing the
> > > return value against the remaining buffer space preserves the existin=
g
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
> > >                            const size_t destlen)
> > >  {
> > >     size_t len =3D strlen(dest);
> > > +   size_t remaining =3D destlen - len;
> > > +   const char *sep =3D "";
> > >
> > >     if (len && dest[len - 1] !=3D ',')
> > > -           if (strlcat(dest, ",", destlen) >=3D destlen)
> > > -                   return -1;
> > > -
> > > -   if (strlcat(dest, src, destlen) >=3D destlen)
> > > +           sep =3D ",";
> > > +   if (snprintf(dest + len, remaining, "%s%s", sep, src) >=3D remain=
ing)
> > >             return -1;
> >
> > I think I'd have gone for:
> >       size_t len =3D strlen(dest);
> >       if (len && dest[len - 1] !=3D ',' && ++len < destlen)
> >               dest[len - 1] =3D ',';
> >       if (strscpy(dest + len, src, destlen - len) < 0)
> >               return -1;
>
> This is valid, but I just feel like %s%s is more readable for what it
> does. You've open-coded the first %s, and the ++len's interaction
> between the logic and the argument to strscpy is subtle. Since this
> isn't fast-path, let's use what Mariia has proposed.

I had also considered similar approach to what David suggested, I am
open to any path forward based on what maintainers want.

>
> >
> > Although it would be better as an 'add_option()' function.
>
> If this were done in more places, I'd agree, but as-is it's pretty
> limited.
>
> Reviewed-by: Kees Cook <kees@kernel.org>

Thanks for the review!

>
>
> --
> Kees Cook


Mariia
