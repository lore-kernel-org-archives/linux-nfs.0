Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.174
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794332474;
	b=iYi3QEsSc2aKBAk221GBYqxhLy2wscTd3KyFrtyMaPOeR8TBzyTlPxTWAVOBfmCGt5c0
	 j1lei7Kzr2mRYKP/85d13Y7Ibkk5A7XrSo4dEo5xDbdyMt2wcxAVbpu7I5INJx2gW2l8I
	 fBZ+/7t+hgXyEkB/EZkeyMbb46OmwAhdUzycV48o9JCdYQt/Me72zHymWb4gjIMzUb7st
	 eTPDyE3sUIkyLOqg0rUErKgwjvlwgfSMHf2+OKmMclRrkAoucd6UFDeZWqOS8AiB6TsJV
	 h441wXgZgG52OOnrWfF17XrZyFI4vPxvva39N8clmyuBJoxnTUVmPImIde/2GndBdng==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332474;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:References:
	 In-Reply-To:From:Date:X-Gm-Features:Message-ID:Subject:To:Cc:
	 Content-Type:Content-Transfer-Encoding;
	bh=wCfuXsU+jGX9D3S+uWIcLeSkVcle/hWcfEI/8sFir7k=;
	b=XO0rvMmt9QJmESvtGGR73/IvjQqcwo6pmxSoyfHGspqWPME7JIfy6D3Z9XfnwmlX2Lnp
	 KEEwxCtFuTio899e3XP2YCEOL8+bgymobDvXiQq0/vsmsFMcoh9iMYMTA0tkAF1nxhKLy
	 VDDwrkzHwswJ0uWuusMsHtoq6hMT3K2ZU0Ss0/jxWNAxOpqVFoUv3JMPel3YhE3Gq7Uqz
	 e7im5lqC+fMOhJ+sX0IfjWAbtVVbI39VPb7HvpsPyKtmVdmbohHnTx8tTIKv96qQJTh/F
	 yCbBaRAkFLDrq9JSrG5G6fJCPTV7D+uqJggu2v+VkjBjlGfkAr71L25KjQOI+piMyHQ==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=tqyUJ9mD;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.208.174
Received: from mail-lj1-f174.google.com (mail-lj1-f174.google.com [209.85.208.174])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF002606A323
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:41:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CF002606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=tqyUJ9mD
Received: by mail-lj1-f174.google.com with SMTP id 38308e7fff4ca-3ace304021eso20309631fa.2
        for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 09:41:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794332472; cv=none;
        d=google.com; s=arc-20260327;
        b=pwozXUgOxi8tmMyFSecBbYfrrCpFkUX1gweSp+cFMAyeR/xmCLjQ2+B350RQsoka5b
         tOIG0d0meUqqNc4nIPmDHxqKP/Waep+8iUZZt1rXUrXwxQGFn3jAFqTG6RWiU2MYBWkw
         4RNdK4tfzzkYPT621ATshm6gBykAJWVXN1l/Td9XvPdRBzXOQ1MbOBoYhrP2KW+gWPB7
         iux62/yugwNCwQG7RcamQLBnvE4lmQG8LNq4baERdmhItR7KBcOo1zIEaA8DsErTypIV
         IKI8fM3otntIR9zFtb8CqlClNNdqZlVgmnlmI9ZKSmNanMSIqAz0o0WbsC7w1ab8ftb6
         6g+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=wCfuXsU+jGX9D3S+uWIcLeSkVcle/hWcfEI/8sFir7k=;
        fh=+EkHVdStwtii5wkzgUNAZeXPjCx95tlIXWplKyPL+Wc=;
        b=OUb/GrfAYWxT4DYyqdWKKYt1dbceHCO4CQbnxwpFbsDFrBQaEh2aCcZr5BztMUUpWx
         PtbYUwE9eWaJg0+LhozkCfsKn4iLwEYVsUXut7oKb/CFHAMcKalCnmOWyXqYnuspYe1q
         JHwWuKDxCDgjyXNudG6L24vctWiD9Dtb1Lvcj8t3Bc5RMVGNTEjDmOJvHa6Jyjp5RIzX
         MlORlag7X16CZKykNfjnnImYJFfALBRMEZGCFdLgW8XpF5h/8eRAVZnySx/xvAWuBbEW
         NmbrRkh0jq+qXvBxiVdWTYRh111AbS0A+/3bHA7Xk1FV/Xq70n+YipBT6xNtpNkq4iDS
         +Y0Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794332472; x=1794937272; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=wCfuXsU+jGX9D3S+uWIcLeSkVcle/hWcfEI/8sFir7k=;
        b=tqyUJ9mDV57DDUQ4jmGKqHQ5P9unPBh/usQ9PY6yFQZDjdjmmqfCJikNQjrf7Nwvz6
         Ccc0XeVJnKc+HU7HQ3lwalkVZfe2xi+KzqOzBEBZ86s/40P9Ugq75oB6AcGJNY6UPOTY
         xgCMDRojnOqDubf00+ZoE2WaobSCWpBueO6xnpWSeCW7QcjzI02bbQ7w52lRpUWlQiqG
         IZzYekkTvg1MH7xYrYy9ptFo6L/nvKzx9Q+c0pEFO4wRC94lIUhSezF3SxBcQqaIqVtu
         2NNOfA+ExFtYU3Ip5fZuP3kBpEkETCezfSOpB6mpY7habrogPr9ToKoCgpU+6HudT0Xv
         oiWw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794332472; x=1794937272;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=wCfuXsU+jGX9D3S+uWIcLeSkVcle/hWcfEI/8sFir7k=;
        b=HG8IZlApjrG90+5+LR7hO0AKpjZwHYYlXL38SIVW47Khq4+6nYSuPzseDff8jHmh1a
         CBr2V6P4721GL294H4PIlX9K9xKT2opDBJ9VylrTC8SSht6oOadO7LsCgRbHeE7YXBY7
         vLXR9semaTAbhjNkODYA9qoqF59VL6Vu8JimnFbQUniNfYjttECcG+fw/+gHnC7OcxbJ
         DfqqXEL+hxxEXhlFI9lbuDx2bzf7KEdj82BEvY3tcLWGc8lR1cLpkjNBXuHQQel4CN/L
         gIuJLImtST94O4OEF81kx4UbNMNjjgVvnYpATSUhp4Tprz+VyP8sP1bbpYsFDngLqG5V
         JnFw==
X-Gm-Message-State: APuU4Z9SW8YJRa170MQgSV7tE2Mbtj43rMAoy+FGiM4LBsRkMekENeA0
	02sqEofeNZhndlsbH9hqh4kXjFSR+9t1B9T/1PsFlbQqBNf7ZlS4Bgqgr2hj2LeQaDzb1yPWHnv
	NpV+d/nWdLwBsFyWDbItaUoPEOV3yfx4aEg==
X-Gm-Gg: AYBFou0hqHHmZXHkXYVIMevOd3g0PsmGzLf3ZEIlrCGb+gVuDkkgucIanfzXJN+9153
	9/BldehIPC65WHpx59sEJajNP1qGz3uXw3HcV0zUxSrnSA9cIrwdLFA/vFrjwwEZm0eNX4jqrzL
	LPgkYHL/YP4szLYkP5b1q/sKwvK36gQ+v/cZDgRkaWQasTBAo0CBA4uOm6XuT7WGpmGXtJWRkRN
	0aN6Gmk1azxulaknmBPWgm9Xvz8Tl3ZeRR7KpHm/L7hXfTu/A6fXaeeEn2TY3Q7PZX97Uz+Cp5/
	16Y/vVfyRUnzvPdgY0VcOvp1EIWRDFH+7mL1t59YvISLTDHPhGRHsTfTlMhd65x5TP7HjvyW+5T
	eYGIgOzEQJ03cNQl4W1wxi/3KrkGSHbgezQOAgA==
X-Received: by 2002:a2e:bccc:0:b0:3a9:d9db:61b0 with SMTP id
 38308e7fff4ca-3ae0969b9a4mr7013331fa.24.1794332471806; Tue, 10 Nov 2026
 09:41:11 -0800 (PST)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <CAHnbEGLHGX2rMnf=S6CasoNyc939DTe-whcsjt9WhSWG920OoA@mail.gmail.com>
 <434f6474-b960-4383-8d61-0705632b4c33@oracle.com> <CAHnbEGJq-w4CMS1dg8UBraV+6kLMkmC-hO4Dq7f4z8Af6maitA@mail.gmail.com>
 <41e9ed40-311d-42ee-9fe2-5af3ecda67d4@oracle.com> <CAHnbEGLuYq6vYqq9M3w+W0iR-r0OOeCfSD3cEV-yekAbo-yAQw@mail.gmail.com>
In-Reply-To: <CAHnbEGLuYq6vYqq9M3w+W0iR-r0OOeCfSD3cEV-yekAbo-yAQw@mail.gmail.com>
From: Sebastian Feld <sebastian.n.feld@gmail.com>
Date: Tue, 10 Nov 2026 18:40:34 +0100
X-Gm-Features: AclHuK9oBNYvTMxhqSPOa2z3Dz-d_QvBWMj-KqyAMHtDJLmXCt35I1DZU94hoZs
Message-ID: <CAHnbEG+qCwHRptvTGYDY_PeCN+61DVQRf+UcGDnhB+m6H9Np1g@mail.gmail.com>
Subject: Re: fattr4_hidden and fattr4_system r/w attributes in Linux NFSD?
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: open list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Yearly reminder that this is still not fixed.

Sebi

On Tue, Jun 17, 2025 at 9:59=E2=80=AFAM Sebastian Feld
<sebastian.n.feld@gmail.com> wrote:
>
> On Tue, Apr 29, 2025 at 3:45=E2=80=AFPM Chuck Lever <chuck.lever@oracle.c=
om> wrote:
> >
> > On 4/29/25 9:10 AM, Sebastian Feld wrote:
> > > On Mon, Apr 28, 2025 at 4:15=E2=80=AFPM Chuck Lever <chuck.lever@orac=
le.com> wrote:
> > >>
> > >> Hi Sebastian -
> > >>
> > >> On 4/28/25 7:06 AM, Sebastian Feld wrote:
> > >>> I've been debating with Opentext support about their Windows NFS4.0
> > >>> client about a problem that the Windows attributes HIDDEN and SYSTE=
M
> > >>> work with a Solaris NFSD, but not with a Linux NFSD.
> > >>>
> > >>> Their support said it's a known bug in LInux NFSD that "fattr4_hidd=
en
> > >>> and fattr4_system, specified in RFC 3530, are broken in Linux NFSD"=
.
> > >>
> > >> RFC 7530 updates and replaces RFC 3530.
> > >>
> > >> Section 5.7 lists "hidden" and "system" as RECOMMENDED attributes,
> > >> meaning that NFSv4 servers are not required to implement them.
> > >>
> > >> So that tells me that both the Solaris NFS server and the Linux NFS
> > >> server are spec compliant in this regard. This is NOTABUG, but rathe=
r it
> > >> is a server implementation choice that is permitted by RFC.
> > >>
> > >> It is more correct to say that the Linux NFS server does not current=
ly
> > >> implement either of these attributes. The reason is that native Linu=
x
> > >> file systems do not support these attributes, and I believe that nei=
ther
> > >> does the Linux VFS. So there is nowhere to store these, and no way t=
o
> > >> access them in filesystems (such as the Linux port of NTFS) that do
> > >> implement them.
> > >>
> > >> We want to have a facility that can be used by native applications
> > >> (such as Wine), Samba, and NFSD. So implementing side-car storage
> > >> for such attributes that only NFSD can see and use is not really
> > >> desirable.
> > >
> > > I did a bit of digging, that debate started in 2002.
> > >
> > > 23 years later, nothing happened. No Solution.
> > > Very depressing.
> >
> > It's a hard problem.
> >
> > Focus on the recent work. It appears to be promising and there have
> > been few objections to it.
>
> Do you have any reference to that work? Are there status updates?
>
> Sebi
> --
> Sebastian Feld - IT security consultant



--=20
Sebi
--=20
Sebastian Feld - IT security consultant
