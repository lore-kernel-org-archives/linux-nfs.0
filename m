Received: from mail-ed2-f12.google.com (mail-ed2-f12.google.com [74.125.228.76])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B40932D9ECB
	for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2026 17:32:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.228.76
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789925558; cv=pass; b=VxTuK3GKq+vQpCdqDsitBGZstTv+1euWnjoNcX0AZoFoYmisdCpTQ7Kq6og3MK/NRrpSxlQhmWvVCgmjQfCFv4YW/jOmoA/8cnQqvMXQvVM7vPRL1vjWyFs0QXSSJ9W0BE03trXhR8XN/x3Czk2hCVDcQXdom8FUr7fyQ8xli3k=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789925558; c=relaxed/simple;
	bh=NKA9IU/siaGutO1lqGCz7C/kGpzRSmKDM/zWbvIfBUw=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=nuovVdx75Q4gEXi708p5UHo4NJRU30R6rBLoK3ru5uR5v1vIGOw6ICU2IIGJ6m/Vz0gtAGdTA14XaGA6WKd2DxHURR2ny9KT6+o2MJyHNcdbObAzPrR8CbcKtfLGObb29a9XyJBYRwoEVVA6rZ+jP2dNGSfM3RgGZq8abgKAJ1o=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=UXVJdJ0Y; arc=pass smtp.client-ip=74.125.228.76
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UXVJdJ0Y"
Received: by mail-ed2-f12.google.com with SMTP id 4fb4d7f45d1cf-6a99cd5115bso3415485a12.3
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2026 10:32:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789925555; cv=none;
        d=google.com; s=arc-20260327;
        b=NB6Oxi/OzS77jo9GoZ4i0Ez3K2v2WQ2+b7RKDDW0YB9Vb3DbUxTTtoBHqTzUFOHaxc
         vrpwbA05WzGZ7lxIFgjsXhlegcUN54qIF3KC9KXU/w/kBPDNxmK7YB1JLIS2+Is81CKu
         t5oeDsvSErkfFg5uG+fdN1LFyZyPML6XsnEOEa9vV3G8SPwQ9fY01UkG0uyraK7Cttnl
         rHQ7zIbKUD+yuN3Ca4E8WOvEKD/Tt5t0U39zdpT4Ch0sEZ3IYO9yWNC5Jb4pvHgBc65F
         v7KLQToa/8SBpWnxx0X0TmQImVm7OVjm9yiANmzfCNdpw1UDjtediY7V3pW7/K9H0AQi
         AZBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=NKA9IU/siaGutO1lqGCz7C/kGpzRSmKDM/zWbvIfBUw=;
        fh=el6r7sq6ZqQujOZnP3X9Hxr+KeOQ7m8JIgdU+uu77Z4=;
        b=JQ9gC6VKaTWYzNz+0fEjYfyrwBeiFXrM7VIq3edDcsNAaZFnrBvLMDGj8zBFMV7SdG
         +uWyNXy7EhkeMKK7TIbfiJhwl0FnpJSco8+MtJQxhyLWm8S7YPgcDNOzT5ZDrXpXdRL9
         7WyF+2p2SjFV6gae8M9GPOKt5KjFgUei9MSeNlsKaORnPfnIEDH38sHwlgzGIrAcS7cg
         6oifPFUyDfdzwU3puGGwoidH+SHhSPHQ8g4cAyVTvMQsotGp/nAwABLm9qk62wL/MJMv
         pJ1tOiwxwhWm9/sZVR5VRNZNQwpb/26Oo3bVyaimnSLB9i7a9Qrq3apuhRSnyJtHi7Ok
         gzYg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789925555; x=1790530355; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=NKA9IU/siaGutO1lqGCz7C/kGpzRSmKDM/zWbvIfBUw=;
        b=UXVJdJ0YB0IqwOQvEYXiRdc9+E9kQCofReK6l8wx7/2FJGMLOMgFeI3YYwrSp2Ukxv
         pJGR9ifvmtmdPoV+iu0Pv0+Oynayuiohik1vM7elj/5catrLrmNZX2sj/FQS4l1rSgC1
         Z8DZd8aSJYcfM9m8km6jlmZvXvJtJ9R06Juw8DqKflMUu9730wikTmXdWBb7gI/f94A1
         Ql9V2DJPYLldLRH6m3ACyUMm3R131QZyTnt+X0sWMYStqV1/X0SmloB2CRlmPVjI8LvT
         +7FhHwdE4C7kErvXK1qEJT6rnvm9ZXoOf/lmf/G86wxrVecr/lrXf3AZ9Z67IUEU/IGP
         Ggjw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789925555; x=1790530355;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=NKA9IU/siaGutO1lqGCz7C/kGpzRSmKDM/zWbvIfBUw=;
        b=OO+9mnfr46l0g7fjcNACt/dpDeQ7j/8f7NiiUMHrBWH961li/nRbu/3a1uL6Dq5GPF
         Sm6BZuyCNF3HBRbTsq82Fv/h8ZK7Fm1HD/OYy/o7sOLOXTk36lD4R/582ZJsDUoIvTLT
         UJ9A3XqMiWrn+l12jLbo1b1Iew+ApcbmSEeQ7cD1YqtLuWNCGG7nLSEKhLvlLRG5vWZw
         tmgTE4KJ4OTF/rOwRUHDLkmSVlZ00v/mv0G4+n206Ka6ZU1YykKJtgAd3n92/TRmGU6r
         KYObrzS1Uy9uHrJyRHZZrogio9di3nAheawCCvmg3dQQPHCeQ0GG4ISZkFPsuW4s7d3L
         HTTg==
X-Forwarded-Encrypted: i=1; AKwUvByyicfCbo0sxkQFHoII27IHUJu11ydvVOP5Yy6qMVqQBgEdKSuH8J/IGgdYhOYla1EfmEK1Zx01sTQ=@vger.kernel.org
X-Gm-Message-State: AFuF++lNdjTIAVlOK6jY9HvddpMicw0uBEg0TXRSg9qAaS1KsxZvtSXw
	HyYougGw0a6mQgpgo4s23V74HTM+tctrgGxEqH1JMY1zEVNBod9ULtbR+FkeWeEus1oaiLImkwC
	MZEXu2u5RD/xQDz3GybQTzeagcoxfr5E=
X-Gm-Gg: AYBFou0LnU7Tn632YSbkf62lTpDM14VU8zKBriBrnCGDIn4slMtrtDNudYyrNc8IyMe
	NhxRkq5oT1QcK5pHnsZbj259rxw+Sz4XeRC0bmxna5MZLxOezxbWs7BKZ2D95VrC+bgbm3LkLAI
	jH/XJXfF0oDNV95DSPI5LsCSpLLLMN8x+3WtAefH68u66fBa9midWlrLcc7Ql//qSZSr+rIccM4
	DlJ/BYgNV2YqWrHQSyePFviVEzG1VgBx1Is2KNnfFJl8f/TU395siuMplXk3tKYbVGXtS6iHdjb
	dnIUHF2sOYlReAVRdccZUozxnTFJ8ZFRAa0x59rZBDeC+D3+zjRo/rEKsQ==
X-Received: by 2002:a05:6402:438c:b0:6a3:ee60:b13f with SMTP id
 4fb4d7f45d1cf-6aa577f8829mr5598617a12.14.1789925554728; Sun, 20 Sep 2026
 10:32:34 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAKAoaQnTria60yM=zYQAe+dZti0ZvCfja0V+Y0F=Qu1h+hXGAA@mail.gmail.com>
 <ea3ec60c-18a1-4643-ade0-c4a004cb2ac3@app.fastmail.com> <CAPJSo4XZcAvXE6gP1vXFSfGZnjiQ8BwgeqO02obd_nWc-boR_Q@mail.gmail.com>
 <CAM5tNy4Jm=Mu4Tu1QUQV4JjMj0iabFJ1NqnytWioWtu6bDYUuQ@mail.gmail.com>
In-Reply-To: <CAM5tNy4Jm=Mu4Tu1QUQV4JjMj0iabFJ1NqnytWioWtu6bDYUuQ@mail.gmail.com>
From: Lionel Cons <lionelcons1972@gmail.com>
Date: Sun, 20 Sep 2026 19:31:58 +0200
X-Gm-Features: AcwNN1XkKguznbVekAccXucjk0lZuTUG2zSBncSVIby03FPYmv-xTMxUVOR3MjU
Message-ID: <CAPJSo4XuHo7jed5AThjooh2E8uuoxQYDFV+7x+CrBsrKoN3Lkg@mail.gmail.com>
Subject: Re: [Ms-nfs41-client-devel] Need NFSv4.1 "WANT_DELEGATION" op ...
To: Rick Macklem <rick.macklem@gmail.com>
Cc: "ms-nfs41-client-devel@lists.sourceforge.net" <ms-nfs41-client-devel@lists.sourceforge.net>, 
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 19 Sept 2026 at 21:22, Rick Macklem <rick.macklem@gmail.com> wrote:
>
> On Sat, Sep 19, 2026 at 4:43=E2=80=AFAM Lionel Cons <lionelcons1972@gmail=
.com> wrote:
> >
> > CAUTION: This email originated from outside of the University of Guelph=
. Do not click links or open attachments unless you recognize the sender an=
d know the content is safe. If you are unsure, forward the message to ITHel=
p@uoguelph.ca for review.
> >
> >
> > On Thu, 17 Sept 2026 at 15:50, Chuck Lever via Ms-nfs41-client-devel
> > <ms-nfs41-client-devel@lists.sourceforge.net> wrote:
> > > The RFC treats the absence of WANT_DELEGATION as a normal case
> > > with a fallback. Section 10.2.1 notes that "since the server is
> > > not required to support this operation," a client reclaiming a
> > > delegation with no associated open can instead use a dummy OPEN
> > > with CLAIM_PREVIOUS and then CLOSE it (rfc8881.txt:9596).
> >
> > I had to refer to a colleague for this one. The answer:
> > "... CLAIM_PREVIOUS is only valid during reclaim. Outside the server's
> > grace/recovery period, a compliant server must reject it. ..."
> Yes, the above does refer to reclaim during grace.
>
> However, I do not see why a client cannot do an OPEN/CLAIM_FH
> for a file where the client already has an OPEN for the same file
> for the same owner.
> This is normally done to upgrade from OPEN4_SHARE_ACCESS_READ
> to OPEN4_SHARE_ACCESS_BOTH, but all the RFC says is that the
> access bits are or'd together. (It does not say that the new bits must be
> different than what is already done for the OPEN.)
> At least for the FreeBSD server, it appears to allow this for "same acces=
s bits"
> and will issue the delegation based on the OPEN4_SHARE_ACCESS_WANT_xxx_DE=
LEG
> bit, using the same rules as an OPEN where file is not yet OPEN'd and the=
 same
> rules that a WANT_DELEGATION would apply if it were implemented.
>
> I'd suggest that you explore using the above,

At least for MS nfsd and OTAP nfsd this does not work outside the
recovery period.

> since you are only doing
> it for an "experimental caching model" at this time.

Well, it's already in the tree, and slated to be the only caching model.

Lionel
