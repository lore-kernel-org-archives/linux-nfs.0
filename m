Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.44
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1794483667;
	b=g3XUcItLoEdA/ngwoZag/wO8CuuB7BwPUnc8BsKteEXcCkHBtbSEo+edMQTEpJzv0IYd
	 kG03Q2ujC6ePE8Z09KJs+8aRr6+K0qAUd1hFDNxhe+UvfXWsI8Z7I6OSKQ4JuyjCGCcnH
	 QgdrRaJkYDdFjDSeeH9Rlsut+oHFZhBKxkUgwoWEpEPTk7GYzSmUyY6YiNQjJZg33ODRp
	 uoBfjbCLSznVy16+XRdShmrE8bdpvynrUI5sDKYSp4DEMPYF8Ncya7vPOzE/bECbFeSEe
	 essJPSxEyCZZhEjpk7658CAEKfzq6ngnRPPyndigA1+4ajJ7Z3gW/+C4SMMVJksVxag==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794483667;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:MIME-Version:References:
	 In-Reply-To:From:Date:X-Gm-Features:Message-ID:Subject:To:Cc:
	 Content-Type:Content-Transfer-Encoding;
	bh=nXI7xYZgxnpfLKHFm8ZvAIfm4pFkD5dHlOX1GBrtPmA=;
	b=ydDiiYMDGk3gpSVE2Vxu4OEnFthmQzq/+1Puwms8FXo06bIKqRe1Ke974vbcmdv3FQHk
	 895Ux4FV5tcajbxjV7toh1Y4TY/APwKRUiDXopEBz9P0k1eeaYsUtNgvWo6oyeS4UaFJT
	 Fe/yIfFxW2SxHekxH0xAqDETgvD+WpS2GcMmeVrrt5gP5P2qsoRnc7EROoeltT/8Hj44T
	 dAhLi5Ht8JJNoA+Tb9UThc0USvRG85EvG4tJrfeVqwscD1hYJAEGbgsr8qefcgDqiP0kD
	 sPSiLpb3OxD3qt6uVwDJmNzy+NKLUNa3Wos7XAqz4LeXGNld+7js/OgdXc/IQktjmug==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=ihANWpv4;
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.167.44
Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com [209.85.167.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C0BE606A327
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 11:41:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8C0BE606A327
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=ihANWpv4
Received: by mail-lf1-f44.google.com with SMTP id 2adb3069b0e04-5c14f7768acso3072896e87.3
        for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 03:41:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1794483666; cv=none;
        d=google.com; s=arc-20260327;
        b=H9CQSrj7BI5wg3UmAZZfxhC99xeApB/Np3MpOYq+cDABZW5cjSWR6pz50Prua/h9+Q
         sOo6UtXUFGzhmVL7XcBdFeLyvqXHOdhCTundSf9wzOPQRnQgcFbX5nix1yRd5pLfWIfW
         JcMszx0tmjRBvnmpppzlIbNwVBF6u1uPdBcFBDZQxwexQSZAWXqUFbEz4D0Cnw0OfLqZ
         9mlb+F5RQmgaM1DTIuQBHrHkh87+GdgPPgrYFzq+lhQHueyrhfMaR5/XeYW4Me9hmT5E
         sVsKfetNnQ122cjl2xxGohHBOF6jzlbEjr087IOUmBcjrLrYWWtEXXXqZm+06BqW6p7l
         daxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=nXI7xYZgxnpfLKHFm8ZvAIfm4pFkD5dHlOX1GBrtPmA=;
        fh=+EkHVdStwtii5wkzgUNAZeXPjCx95tlIXWplKyPL+Wc=;
        b=mDPJ0ejFt1+QFXEVyN8MG1cuMHZ3AdwI+wphJFgVQDlK7VcD7GO/NiHgV0No9pwCyO
         FwHOpKnLCpxsnt43dwZlsGBhIuLPaKzQkxzHDNmyEdy7RhBaUz3EXEqHankSXWgrRaFr
         59HOaly0NX72OxYrjvZjRruWZ75aXeDZQAC+Hr5je3uMWdRZk1j2tvHj7eclzFkSds1K
         DJZOcYd6IFNJdhNQuiy+jpG4b3yo6iQolScBU4CsnmGNuct2Y86wJGrt7mrRSiAE1Mmf
         kLbDXcEVajddCXfVUaOtHgfQSW1xZnzQar1jlkrOxvc5qKWslaeFgSO7fZ+bYMlHy4ja
         D8tA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794483666; x=1795088466; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=nXI7xYZgxnpfLKHFm8ZvAIfm4pFkD5dHlOX1GBrtPmA=;
        b=ihANWpv4YvOF7GeQaUYSLUviFOALE7/UOOuxTnBtBcjp9uXbckjgxo8U9pFNwLvLHf
         RNCRINQwXl9qXHglhb9SVKerNn5MgRTLxUqv+a0klzHJOsEaXDlck+NvIiZEiO+E4mZF
         47somZb75K2oFTVz/uopuy4lk0tsfoZLEou/+pUxWpHKMyt5Eti55qIcALn1ZoU+asoi
         38au4Cby0BfrbsGZcVoDzfW5ziDCHgbtvxUSX5I3j5Fv61QJuv12qnkq85UgFzvnUsb8
         nn50imcTCxcyP+LZktDJjNgrJwoiQbIYsNxQ61vVmrCxogUiMbTAi2CRNEx3C7x1thN2
         IIWQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794483666; x=1795088466;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=nXI7xYZgxnpfLKHFm8ZvAIfm4pFkD5dHlOX1GBrtPmA=;
        b=NhjYseC8ZNGdotdZthLT6GtTEF9ILPyAxNHU77KNzLjfIuB9Tvd6uc3q7YqsnmtLd7
         gIrtyk/WhIvzLBeyRNnWowbT9IQ2IELwUTlfWwIXs8T6sl7FREkMC+xJLUc54ASWgacM
         bImb//0D4pd9HeS8NghuDvV6Qz7xQVkvjBp3W7Cx0j7Wbux+P9ULIIIOx6xBm8K5evx1
         k7o4tN5/duN1VQlWGveUgHr79md2TrTi99h7oz2NndiDhpG1CU7U2MpnMkUYO7CLKiXB
         N1D9gsyZqWtVWPXiLVfKArLrJxIEp5YAusLIKF5KpMVSUte8FoGlV07gIJaFu02Bs/uN
         hbZg==
X-Gm-Message-State: APuU4Z/6vAJ57BFm05xAQJle3GiNuJZFLikoI5obSo43jylVCgJqoWYU
	u7gd0VDmtyCnYEdRpIZM2GSIgwTSfmtA7z/UnCcB2pMmwP0WrMmEOD9hPqe7NUmfz1kWhPvtryi
	04V990o+VT51lxe0swzZF/Mim2ijRXRjGhA==
X-Gm-Gg: AYBFou1iu/onI6SavalKyjVwUQKOZXrFGStNZEup9UfxPLala8g8anaKESD+EiUTIQP
	6le7X4BgypNH7KAxXnlDljsEljt0K1gvaJ7S1go5LoxvFRG0A/dArNpxbZzODtxlXtAju8RRVYX
	bIkTXfoBT2+MyarplQRWw/rmZfoeiCZsEXEMvdNNBcolTuvCKSncnfRqv678x3txvab8BPHTeZu
	HF33rX92NWyqrI4KcyjReSNvzFUl/fDqUA4Su6ubmpKJaCMHL2KQpylKAOg+AvSoBoJ+ngVvwdA
	LEyjH/4T2YZiJ0bDBc2PKcngUaEHqpjWZQGgKzFqhLxThYnNQzKaAFYyShJABaRMCPE7c9Jlpqv
	oRp0EDGGhFhs6rgxhCf5QU9OBXnSDkTJNTgxd5Q==
X-Received: by 2002:a05:6512:3a8c:b0:5c0:b5c:4052 with SMTP id
 2adb3069b0e04-5c15d58a6eemr1875176e87.2.1794483665562; Thu, 12 Nov 2026
 03:41:05 -0800 (PST)
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
 <CAHnbEG+qCwHRptvTGYDY_PeCN+61DVQRf+UcGDnhB+m6H9Np1g@mail.gmail.com>
In-Reply-To: <CAHnbEG+qCwHRptvTGYDY_PeCN+61DVQRf+UcGDnhB+m6H9Np1g@mail.gmail.com>
From: Sebastian Feld <sebastian.n.feld@gmail.com>
Date: Thu, 12 Nov 2026 12:40:27 +0100
X-Gm-Features: AclHuK-I-9jbTBeQqqpElHlN3AqN0JJHznUWSYtQAmwQIlS15cJfT8Fsf5XfmSA
Message-ID: <CAHnbEG+HGsubEYwa6b2zmTgiJJYCeWqAaekZiG0iFDtaf1Xm9Q@mail.gmail.com>
Subject: Re: fattr4_hidden and fattr4_system r/w attributes in Linux NFSD?
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: open list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Somehow my email did not get through to the list, so again...

Sebi

On Tue, Nov 10, 2026 at 6:40=E2=80=AFPM Sebastian Feld
<sebastian.n.feld@gmail.com> wrote:
>
> Yearly reminder that this is still not fixed.
>
> Sebi
>
> On Tue, Jun 17, 2025 at 9:59=E2=80=AFAM Sebastian Feld
> <sebastian.n.feld@gmail.com> wrote:
> >
> > On Tue, Apr 29, 2025 at 3:45=E2=80=AFPM Chuck Lever <chuck.lever@oracle=
.com> wrote:
> > >
> > > On 4/29/25 9:10 AM, Sebastian Feld wrote:
> > > > On Mon, Apr 28, 2025 at 4:15=E2=80=AFPM Chuck Lever <chuck.lever@or=
acle.com> wrote:
> > > >>
> > > >> Hi Sebastian -
> > > >>
> > > >> On 4/28/25 7:06 AM, Sebastian Feld wrote:
> > > >>> I've been debating with Opentext support about their Windows NFS4=
.0
> > > >>> client about a problem that the Windows attributes HIDDEN and SYS=
TEM
> > > >>> work with a Solaris NFSD, but not with a Linux NFSD.
> > > >>>
> > > >>> Their support said it's a known bug in LInux NFSD that "fattr4_hi=
dden
> > > >>> and fattr4_system, specified in RFC 3530, are broken in Linux NFS=
D".
> > > >>
> > > >> RFC 7530 updates and replaces RFC 3530.
> > > >>
> > > >> Section 5.7 lists "hidden" and "system" as RECOMMENDED attributes,
> > > >> meaning that NFSv4 servers are not required to implement them.
> > > >>
> > > >> So that tells me that both the Solaris NFS server and the Linux NF=
S
> > > >> server are spec compliant in this regard. This is NOTABUG, but rat=
her it
> > > >> is a server implementation choice that is permitted by RFC.
> > > >>
> > > >> It is more correct to say that the Linux NFS server does not curre=
ntly
> > > >> implement either of these attributes. The reason is that native Li=
nux
> > > >> file systems do not support these attributes, and I believe that n=
either
> > > >> does the Linux VFS. So there is nowhere to store these, and no way=
 to
> > > >> access them in filesystems (such as the Linux port of NTFS) that d=
o
> > > >> implement them.
> > > >>
> > > >> We want to have a facility that can be used by native applications
> > > >> (such as Wine), Samba, and NFSD. So implementing side-car storage
> > > >> for such attributes that only NFSD can see and use is not really
> > > >> desirable.
> > > >
> > > > I did a bit of digging, that debate started in 2002.
> > > >
> > > > 23 years later, nothing happened. No Solution.
> > > > Very depressing.
> > >
> > > It's a hard problem.
> > >
> > > Focus on the recent work. It appears to be promising and there have
> > > been few objections to it.
> >
> > Do you have any reference to that work? Are there status updates?
> >
> > Sebi
> > --
> > Sebastian Feld - IT security consultant
>
>
>
> --
> Sebi
> --
> Sebastian Feld - IT security consultant



--=20
Sebi
--=20
Sebastian Feld - IT security consultant
