Received: from mail-ed2-f35.google.com (mail-ed2-f35.google.com [74.125.228.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CBCA3472795
	for <linux-nfs@vger.kernel.org>; Sat, 19 Sep 2026 11:28:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.228.99
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789817315; cv=pass; b=JLOCY8ukdv5TsTwdsGPAtiEmVzfIHS6li26ZM3YeV1pJMWLGYKJfLfMSqSAt4cmqvLEUVgjkKg/WhScuBdRjIx4Z/S7blUKKLRnADEDVrYpmiv04H0uR/PPVAWsjWNCYuZsvzHgEkt8JS1ASjepaReKtjLA9ZPZhVmQsBdM3918=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789817315; c=relaxed/simple;
	bh=6v8vmWs1HYwx7Z91CjMFT1MOwsXTsGupNzvuGSf2/SE=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Content-Type; b=hN5FY0TCtn8gr/HKWD+WmsCfWmZydxryAnGkPCIPselNuPqD/uIIjhVEGgpTkRxVOrHyANcYnHRHJWLue2Tl+SenAozHN9TmNfnDx/L6sVjVjfE4tr1HLvyn0VMyyTUDkKGZafuTgFC+aDG0E8AC+p0XI0sDqNa+0lPUecEsgGA=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=p/SYZcmC; arc=pass smtp.client-ip=74.125.228.99
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="p/SYZcmC"
Received: by mail-ed2-f35.google.com with SMTP id 4fb4d7f45d1cf-6a99c5de614so2077139a12.2
        for <linux-nfs@vger.kernel.org>; Sat, 19 Sep 2026 04:28:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789817312; cv=none;
        d=google.com; s=arc-20260327;
        b=Hf15+YKy+y2xT6qP/UmZgz3j0zzP7jX7ME0nh+2YX9c8Kt2DyCzRIFbn/H6e69cA4l
         4dZMyBOzvRjMrjT3NDUJZGbItZi2srkVJRJP/VhxHpOw9wB2UnwzrTsufWsYRk1xZExr
         ytqEIoyeOh0Jui3UdwJA7Ut1xZImYrmUISRaXRUM0LkZVremjZB+6AD1QYOPhH72rjLo
         5VdnVIsaI9ues3UXLIOfgvyK12neNEUZgImYsDZ/j/3bAoR5U9HqZbRdf+9TAzRgrlIW
         N0hxuQ2xPbdmGIATw/u1hekVfXUu8icjNhFt+OBgz5qsbid2gDTBay2upAi5Y1MCboBa
         BAXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=YYw0hXLxjAvI0p9m2JnGIwsgy5CaaFrL4W8vXURAxKo=;
        fh=YRwTr2AjnzfvXHTa7+zJoAqCeXeC2OzfNtKNRJEz3Fg=;
        b=jaHPcO6pEGYoLoCOZr5m+wn7ojSZ4d42vHWoSwxN4FpyuZkRsWHkWCF80IMAyknJIs
         jbIAhapsWVHgV+kI1K0FmCR7lfyiZ6SjgNMFosMh+EYwQmmZBIzY1xKarj02Dbav5Nlj
         OEyHn95f2t+5Qe4vZss1lmUWKujXYWmrCJHGvBS2WXsWlBVOMXiZPlRNrbXfqTxJZB+h
         PhB6umrEZsN5tFFj3x6KfVIWJtifE75nRQCq68UjYoYiAfy1RtCrZbdcKx87porVTEc1
         6rKApgvLfTzFT4gPw7t49nIyVIwrhLsG6uF0KJajSnO1x2yZ6TfCa+h4/9f8M2mKh/4Q
         TiZA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789817312; x=1790422112; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=YYw0hXLxjAvI0p9m2JnGIwsgy5CaaFrL4W8vXURAxKo=;
        b=p/SYZcmCgWT21iT/GYzZyFv6zDD/59cb8hwlgfAEkpU4+OIoXBXWaWivj14E0toEEe
         vja6F7CjnQKaJMzUosTA6sRtIh3wx3YExOIzL3KeG0xPHqVlWYfAeaP0cE/jFPRxLKLV
         63ASZGc3SzNizHet1GnOaCvRPTvO79jhl+JYRUtFM6N03R9uDVzZ63+wx3cB3GkOOKdU
         K+naj+MlHGjD1ZoUC+K2gWHRWp3MNoxSH6yEr+VQgVDgiLx5sLCZZcAmFTksPkafpuJy
         2Hu4FkcmBx5kkPcuC1q2zu+9KPOLVfA1CezsFKluwAovEt2vOdxohb+TSeTbZDQ/uCb4
         dIyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789817312; x=1790422112;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=YYw0hXLxjAvI0p9m2JnGIwsgy5CaaFrL4W8vXURAxKo=;
        b=QyGrIlvnR4G+7KUOQjHEscIGvmWggW3WjGBnDU1V1lyggVB4EKnEninICgi+lUWQr9
         UvEj2VD48ZUl2by0Cm73eaqXQB3d0+vbSYtOctLcWSch22TDoCV4JAdIAuyJSSy1cx0k
         9h5fejStnF8Pr9G4k9k6n8blzBuuu6oLfUNfiZwsuhFpMZXFjsREuj8I2OcZzayo0kOA
         eYk/CsiRWTGI0vmhxKg3HvgHwilFCcrUGi3lb7XGK+a8rwBijr8bpilS9j43HwgIY5PJ
         q/jcz7ycDSXlILR8z7jR4IAbXxqHDZxFiLBVFjS8G7W8q5eB92MGxF5/P5ejzQ/VHTT1
         7zHQ==
X-Forwarded-Encrypted: i=1; AKwUvBya+g6p6R/mBZmT9UjYXWhK5MMZCkB7DauxA6wYFLiSqOHJl82bRvBRBbV4y8H6mZkOCAaIBEcZhyQ=@vger.kernel.org
X-Gm-Message-State: AFuF++mmccp6gqwfZ+Ft/0ZNXgFed/Iz8mfQIrPVZ1qdm0daSwCs7R2A
	l98MX8Kw+iPSB4iX5AJygQJohIh+Zcr+m23lL6zlc8JaslRMuuPqIyxNLEQ1yD5/9jRxeVGHjJE
	Lx8qovYODLeLerM9xDsSC7/lZ+revMdT/KmBU
X-Gm-Gg: AYBFou0bPJphJwyz7bdFqjS4o9BUm41cz+Grni52gjPVKaI06oeVboXd4FfJuwHYJIo
	3mew9Z2mlAH8z6pap88l0bfDm2W9DObEZ1w0KF40EdJUKYkaj14xJA3xYXUoLBIWgNuDXQV2sQu
	4aGLKkTEu6o6FsXxyrXMkDDGr6+wU9vEnA0uokQ0nWOrcbXA1Onc1x0VwZeO9h0EYkwMiemHADv
	gPlwpfXHQZVcqMvxl7J7NFUYq9/07edTMxa6oq3cx+ZG8sCFGUFOt0kl45paEmje41kICykbguo
	2Y66bCA8QNh90rtMIfdxOpr8mg95j9nQfJjMtW2KB4t3gMG2EhfEoRc=
X-Received: by 2002:a17:907:94d6:b0:c29:c531:7525 with SMTP id
 a640c23a62f3a-c2a15699fb5mr432643666b.7.1789817311797; Sat, 19 Sep 2026
 04:28:31 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAKAoaQnTria60yM=zYQAe+dZti0ZvCfja0V+Y0F=Qu1h+hXGAA@mail.gmail.com>
 <ea3ec60c-18a1-4643-ade0-c4a004cb2ac3@app.fastmail.com>
In-Reply-To: <ea3ec60c-18a1-4643-ade0-c4a004cb2ac3@app.fastmail.com>
From: Lionel Cons <lionelcons1972@gmail.com>
Date: Sat, 19 Sep 2026 13:27:55 +0200
X-Gm-Features: AcwNN1Wh_x6ED5d9U8TUtwLNg3mnOoOo3DUDL0ujwi5Ljn0HGlXMlDc5kag73dc
Message-ID: <CAPJSo4Uvi2_+fn29tgt1fi4E=R6MKBKXq69uh7U+Rm3Rh=QF_A@mail.gmail.com>
Subject: Re: [Ms-nfs41-client-devel] Need NFSv4.1 "WANT_DELEGATION" op ...
To: "ms-nfs41-client-devel@lists.sourceforge.net" <ms-nfs41-client-devel@lists.sourceforge.net>, 
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Thu, 17 Sept 2026 at 15:50, Chuck Lever via Ms-nfs41-client-devel
<ms-nfs41-client-devel@lists.sourceforge.net> wrote:
>
>
>
> On Wed, Sep 16, 2026, at 7:57 PM, Roland Mainz wrote:
> > Hi!
> >
> > ----
> >
> > We're experimenting with a delegation-driven client-side
> > consitency+caching model for the ms-nfs41-client Windows NFSV4.2
> > client a while now.
> >
> > The original idea was to have two modes:
> > - Mode 1: Get delegations (read delegations for accessing data
> > read-only, write delegations for accessing data [a]) at OPEN time, and
> > return the delegation when the file handle gets closed ([b]). The
> > client only does buffering+caching if it has a delegation.
> > - Model 2:  Do not request a delegation at file open/creation, instead
> > translate Win32 oplocks into WANT_DELEGATION+DELEGRETURN. The client
> > only does buffering+caching if it has a delegation. Server-side
> > revocation of the delegation triggers an oplock break, releasing the
> > oplock from the Win32 side just returns the delegation. This is
> > basically how Win32 oplocks work on the SMB level.
> >
> > But in real life there are problems:
> > - "Mode 1" only worked for small testcases. Real Windows applications
> > typically change filehandle attributes or change ACLs after creating a
> > file, which results in server-side delegation recall triggered by a
> > NFS SETATTR, and after that we do not have a delegation. And there is
> > no WANT_DELEGATION op support in Linux+FreeBSD nfsd to get a
> > delegation back. Which typically means write delegations not being
> > enabled and therefore no client-side buffering/caching.
> > - "Mode 2" does not work because Linux+FreeBSD nfsd does not implement
> > WANT_DELEGATION to implement this "on-demand delegation" model.
> >
> > Or short: For "mode 1" or "mode 2" to work we need the NFSV4.1
> > operation "WANT_DELEGATION" to work, at least in syncronous mode (e.g.
> > no CB_PUSH_DELEG support needed for now [c]).
> >
> > @Chuck Lever What do you think ?
>
> Roland, thanks for raising the question here.
>
> Playing devil's advocate for a moment. Since 2010, when RFC 5661
> was published, no other client implementer has requested a server
> implementation of the WANT_DELEGATION operation.

Steve French (Linux ksmb) pointed out that problem (and it is one)
many years ago: "... The NFS client and server implementations are all
patterned after SUN's awful NFSv1 implementation, and never evolved.
Windows did evolve by introducing oplocks with Windows NT3.1, got the
superior oplock based caching model with Windows 7, and put that into
SMB. ... The UNIX (and by extension Linux) model did not evolve beyond
NFSv1. ..."
Not my words - I am not trying to insult or start a riot in a Linux
list, just quoting. Steve citing "NFSv1" (not v2) was likely some
intentional locking/exaggeration.

But Steve is right: NFSv4 was intentionally designed not only with
POSIX clients in mind, but also to cover IBM's mainframe needs, IBM
DFS-like caching needs, Windows NT needs, VMS network filesystem
needs, and so on.
If you go beyond the Linux point-of-view you see that other operating
systems do it a bit differently. CITI had the ambition to explore a
delegation-based caching model, but never got to that when the funding
ran out.

> That suggests:
>
> - POSIX clients might have a hard time making use of it

This is an issue with how the Linux and UNIX NFS clients work under
the hood. They are designed for FATTR4_CHANGE based caching model, and
delegation are handled like some minor unimportant trailing optional
detail. Otherwise people would've already stumbled over the issues
that delegations get recalled when setting file attributes. Which is a
problem for real world usage on shared files opened for a long time,
but only for big things like compiling clang on a NFS share. The
average userland script kiddle would not even notice.

Lionel
