Received: from mail-ed1-f47.google.com (mail-ed1-f47.google.com [209.85.208.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B526943BDB8
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 09:35:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.47
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788946554; cv=pass; b=cUVZ0NzsX8d6WDt/16bxFH4459nhFeGMzW4SHPgovfWto6U82pkD30SSNWWeoqSfMM5rBzNWa8WqbjgFNimBdm847iVAbZ8ElMdG7m8FN0tbv1BKuPcQqPqg51Zrvii2adgle13MeATKOh4XDk8WC58xHnxXNEDxE9G/8oh0wGY=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788946554; c=relaxed/simple;
	bh=29MUHrGaHyPL+Y0iVPPzvmOfz5y95o8akYNmcTLdfEw=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=MFo10bDBrdFWvxK5nFuqCsLbLnpehQE/AaHhqLskyCSEAJdPOP0Q6H489m+vAiuc6wC7UBLQ9ufLQ7woUTKIyIDcTh09qojhSOAr+QfXeQKG2mJdXXWAqSscEtWh3m7pmmzFJA+wJ7CaoWnd522S7JAlv16jMZ6kZ7fhBraNK1Y=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=mWzRV343; arc=pass smtp.client-ip=209.85.208.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mWzRV343"
Received: by mail-ed1-f47.google.com with SMTP id 4fb4d7f45d1cf-6a0de062db5so8136341a12.1
        for <linux-nfs@vger.kernel.org>; Wed, 09 Sep 2026 02:35:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1788946543; cv=none;
        d=google.com; s=arc-20260327;
        b=sR/1hSHZGnbIlHW0UPVG1UZa4HHOqs+r2jGYUPBz4Ycu7eCjZLTDasusI4PLpzwlBq
         tNt3nmeEQpK1Gj9YhZPybCO355vfCCyfnU9VwMx5XVi7Ivha4bHLCHwrH7v25yc3qqgx
         DzTV8TwBgzimnaY3kdndAUTQfQjzrUDKsK4SuQA/2SurRK+Fg6/IotLI7rDs6kSI1SXR
         Q+JbHsBP/l90MqwaSzEiIYakIq3FQO1OilAEeB1j9TfRDoe50vptAPFYvihxW1jzyBgz
         SjIePdXiXe2SvOihmYNCE7eDsRZwh4M2ktQIl+nBp7LKZuoQyBRneCroY7Qh/SHEqY9D
         UzJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=29MUHrGaHyPL+Y0iVPPzvmOfz5y95o8akYNmcTLdfEw=;
        fh=aamp+i0+ZvrLpgw7WQ3vvhS1MirpCwH62Y/7GUFdvKc=;
        b=VhDvorZEYo1ITh9vsimkN/W03u6oBzQZnMjKiV+pDytY/NWNAz6IixEEpxKitm4+JM
         XzCcHaGSAKMFR5XtK5vd3LYTPCRh3N1jklYj8scdyc0YboKjWVY9WjrFk5fzYMvpZ9K7
         U6GeDbj5aNtKAZ6cP1dv6d0Oifm4ravdejt83TwUaOhWU9YiaPcXPf4WxMo9O4Ace0ti
         X3V8nY5Hf9DWGkyDoOImF0JvHLhqjrCvOfXQeN+PReuQiyATzHbxHvbALdiiVv91qHnc
         spLq7SRYieOksJk/WJT8VmvhEKQ3VY3nHwVvgq2OQVkYHn5d0gCzpdrRx204bdSVjcAn
         6mRA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788946543; x=1789551343; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=29MUHrGaHyPL+Y0iVPPzvmOfz5y95o8akYNmcTLdfEw=;
        b=mWzRV343fQIvsY+v1+fg62BmLBC7FiTn2d0RZT+DHCOXAJ3OfBcpDM0NmWRCcAHDf1
         a3Wn2iMQhmjPeyqMJMYT2EXg/SJqqgRnV5zoB3dgmyZQYC264da638pIDkbohxjWOPK/
         l07aUFrNErdn+s2pOtDPKOpk1Rdh6C7TbfmUqxNGBa3jNSR6fwzwv2yp9typNlsdrJJu
         El38P/LkeuABPnWrAJ1ANLszZozdo73neo1qHhWOqRGammNK4j7LBs34vb+o6+sky7J8
         eK4o1tBSRyxDRu103Bg284RITTcWoWrNfOQ3yqUKjWVWdl+5zcNfqryhcwDsMRsKgQDb
         i7Qg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788946543; x=1789551343;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=29MUHrGaHyPL+Y0iVPPzvmOfz5y95o8akYNmcTLdfEw=;
        b=cWiOazWwRPWZZAqI/MjIxZTzL6yt+3TAjO7dFY8JF0z/8A3J2RyUfHPIeCe8vR+XL4
         IWjOiBb1n2ThpNyzriOf/lkcHgdrca8HoXXIu2tVAEBZ4PbCAee7fKd21h4rjwIeRmjV
         tbXc7Dxxbxc+t2RVjRT6DCqCdGh77WFr/07oZvBWiZJO4ySyJIH/juMOmJ2T8tvvrwZC
         Mns5z7gYwPini3hjTXi2CRAUlOhBVYVhWMdJxzn0WAvfWz6P0I6UOH9B1aWWCS+bD/Xa
         HReYJjSyDkFUrRFYb9fc00ox1WelDlOU4IgmWE0Qg/XCZ8TIqxC6VB0hc6XSuC7OaJEI
         h8bw==
X-Gm-Message-State: AFuF++mHSEZ7UEmGx1E4axXYlPYwjlGHQpoTvoRWqrUieP5wZdGN9ru6
	eiF7nmb8J7MqAkQKRXw1c+Tb22bqQfWFyV+D07727YL19ZYcz60R3H70OHOMJD8ABiqTklVcbUs
	XNsTDQfxy2tjpxJJHcwdDcODchiEPIHk=
X-Gm-Gg: AYBFou2/fJRQ6bpyMN7W0Yk+S6qSVzZyiJ64xfkQNYTTS6GEyz5+2crECqBkpjwBc9x
	2Hk1QSnMOM4NyfX0RxoG/LBzO+O1ye3ZzzDOkwNuOwFhqVcTJOVDqjzJl+wnMtPaBO4Sd+WjGDq
	U10GAHuPsZtIQrxs0njSWn4+BzAm1UBwaERerTzpjBwQ8nIeH4hKe611fqTfx2wzY9xsDoxJqzS
	sQ2NjWor/8mUumpztK8QQEC20cGzGLY0MPlIjEj4yhE2rN/hC1Jt5xsMHa4wBtJG85JNYLCEGQL
	4Y9U+NppbszgKDtq1iY4fTpMTGearShkpQK5Ll/Gba9JF9ekix7gvA==
X-Received: by 2002:a05:6402:3509:b0:6a9:93cf:2367 with SMTP id
 4fb4d7f45d1cf-6a993cf25ccmr1017392a12.41.1788946543182; Wed, 09 Sep 2026
 02:35:43 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CANT5p=rb=HJsFPrD0swPi8D8LzaodTvKK=M6xwR0SvtK_YaLRA@mail.gmail.com>
 <c4a59806a92d2afdeceed1da3190e232f1beb7b4.camel@kernel.org>
In-Reply-To: <c4a59806a92d2afdeceed1da3190e232f1beb7b4.camel@kernel.org>
From: Shyam Prasad N <nspmangalore@gmail.com>
Date: Wed, 9 Sep 2026 15:05:31 +0530
X-Gm-Features: AcwNN1V63iUPxsMWW6y06YIbFpWz7qtvlN2rCEYJtxkpOUEbXKtiSWcX5b4K2pI
Message-ID: <CANT5p=q_1y0yMXyDu-kYpi5zitnL0M+h2ixq2ve6UEbHrfOmPA@mail.gmail.com>
Subject: Re: NFS strategy for large number of file opens
To: Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 8, 2026 at 3:24=E2=80=AFPM Jeff Layton <jlayton@kernel.org> wro=
te:
>
> On Mon, 2026-09-07 at 17:23 +0530, Shyam Prasad N wrote:
> > Hi all,
> >
> > I'm starting this email thread to understand how NFS deals (or plans
> > to deal with) workloads that serially do open/close calls to a large
> > number of files in a directory? Think about a use case of tar of Linux
> > kernel source code on NFS shares.
> >
> > AFAIK, local filesystems fare well for this workload compared to
> > network filesystems, as file opens are local, and file state is
> > maintained locally. For network filesystems, each open needs to go
> > over the wire to the server.
> >
> > Has there been any proposals to improve perf for such workloads?
> > Could there be possible extensions to directory delegations, that
> > could allow the client to make opens async and batch them together to
> > the server in the background? IMO, the challenge is that such open
> > calls can fail. But can the clients be enabled to do many of these
> > failure checks (for example, the client could be allocated quota for
> > how many files it can create, be allowed to cache file permissions by
> > delegating them etc.)?
> >
> > Looking forward to the responses. Thanks in advance.
>
> You should resend this and cc linux-nfs@vger.kernel.org.

Hi Jeff,

linux-cifs mailing list is already in the cc. :)

>
> The big problem for untar workloads is that they are serialized at the
> VFS layer on the client. Neil Brown has been working on changing that.

Has this been discussed in the mailing list? Could you point me to
that discussion?

> --
> Jeff Layton <jlayton@kernel.org>



--=20
Regards,
Shyam
