Received: from mail-ed2-f43.google.com (mail-ed2-f43.google.com [74.125.228.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86AB4385D97
	for <linux-nfs@vger.kernel.org>; Sat, 19 Sep 2026 19:22:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.228.107
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789845745; cv=pass; b=GemHgisO4nQCN9S2rW7get4ov2tRPRMdFWEMG87vORravB+82c7xS42HcDVwh6Z4FWRS37uSeOX3SE+uvFK5pC0ESg3rrflI4bUns/Ns+MvibHAZgB8UciE/+efHLwyDJXIqmSHjw/+jqcatLO1SiAipp01kDT+1PRoVKRmqtO8=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789845745; c=relaxed/simple;
	bh=gN1WI+qphepzDCwKaABqp7qf4bf0o02kweBq2l/Y9Jo=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=L2QDE4XKgHM1Ux8wAkJjUqVqwDnaeGfx/IleKC2TS2wRO45aFA64uBaky73EGcN0+77Iz014R8jcZas+7xk1UfcP5Kj6jMeDPthWiF1HoR9x2cVJo7KMbiciK7Ul6stGP4BYrF5BCQaO7VF87+JivkCB1CScsI2I0NpQTXxrvs0=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=OEGMHAsA; arc=pass smtp.client-ip=74.125.228.107
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OEGMHAsA"
Received: by mail-ed2-f43.google.com with SMTP id 4fb4d7f45d1cf-6a9ba73bee8so1304932a12.0
        for <linux-nfs@vger.kernel.org>; Sat, 19 Sep 2026 12:22:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789845741; cv=none;
        d=google.com; s=arc-20260327;
        b=X4ueqyUWfnZ1imr9RaZI8RjeBLNoy7yCNnMCoup+SFJ2TRwfEejYV+/DziYlg38YSY
         y6PgINx2XATyxkCNny9niwFIewODMHstD0gGnj/+V6oV43nCU/vnKnpA07fAf3TNXVn6
         uC1mwlNOY99xxCLxFwoftjqgQdov37pR3CFNk5SigaW2vgzlAs+qh4jbktZR+AdWnJ7o
         k12fqaK6JNhD1Zb6M/cgIMsEHc1R7eeZoqOyxQ1QgfvpYeCyVmIpGCdk0NTtrYjTBMYn
         QOnhWjBSnajvoxSAtnxAVS/hW6ZsCpwaMQsXTEttK1KN7AiveKjM2D6qRTRb4TrxYB17
         1ZuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=gN1WI+qphepzDCwKaABqp7qf4bf0o02kweBq2l/Y9Jo=;
        fh=Ngy2BDM21RuctHycH6E44Q+cl6monNjBRO5pKPjAchc=;
        b=IFQkFz2/yDStHs9TSO+x4FgVDkfNqzfPOdtWITflhWTVmhVADOHJBflthn0N8DNbWH
         vVtbs1i+OSJBazIIW2DDB4lnD95JbxXjBMRG7isQ7xt4pkGdlMdQ1H15dxAML45e9ZSS
         YyRl4X4L6m0b1FOqBEinZn8t5NFTWvvB9OyMffnMQcShue5w1vhdjcwLcZm4u6gyErj/
         k7g2DaXVWwcvFuNJroWAXRZKX005S5plpV6wZiaBpXR7QlRbtCaAKYzwCKdsyeetxcIU
         5+DBoJ9n7ALNa10ZPP2YNCrHwledGyYYL5j0QaBXUIyNJcVIvfsgzRYmFidiNFhuYIO4
         cMTg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789845741; x=1790450541; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=gN1WI+qphepzDCwKaABqp7qf4bf0o02kweBq2l/Y9Jo=;
        b=OEGMHAsAgb3AywaF/LGcd+J8UzENG46PfnFcjqwWErxCPyJbK4fEPUABlPOknYCvuE
         FgEAk0uYlhWNVo/KHnJ6wFSMfqQMDoSW0TeQXB7+133CBZdFH5+4hY62XlxmR0W7TGHa
         u/9hsputA5PVHX/bCHm/1/8ctYrHHUmq93SSBfKc5fKOO2JB7QBQrbrYwsD1L20xHZC3
         9OI6mN2Z/+7wynqmy2MilaaSXj9IYPNu8dRzbNySjYulk+uTS69hE22pK+ahpyocv5qE
         RmaE0/WMlSgv+DQgaIPbfMrxZfYCJBJguUiIv7Iz2Rs3xCXn220hz83osD4mXerfdPSp
         SQ8g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789845741; x=1790450541;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gN1WI+qphepzDCwKaABqp7qf4bf0o02kweBq2l/Y9Jo=;
        b=f2kfgcVs9VOVGP5lTspCkdzobdzE49HrXqXvoh6vigEyeHqjztFrzCeW6yhTzq9UNI
         j8hlzg7FD/cToX1HJFH6k1yja7owFw//ExWUSUR+kBzPi4QxCcVgtRtxqIaagItyTlPM
         ysq6y4LxWs/DQT4BxdjvgQLv+fcBAbHvrDxhLdxbpuKiEhty3iXqEoriZyCd7DWW88C3
         uXXMlbJsQrqyYPETsqPE/dIEuWm55jey3YQiPEdZKcbe25f4+E7m5tLyZUqIPcGPK40w
         VuubvOSycUmlJUuuBrInvdUS2E3RlqnDmB8IMvu+GMGPg2BHyEdciz9EiT7NZRSYVhhl
         m02g==
X-Forwarded-Encrypted: i=1; AKwUvBzIHXThaRh3DxxReGCis0GXbqkTVtkc16JFuCZLHjD+Nq5aG/+AUYJhF0Z7eaMJvXkV2EQ99gTX8DI=@vger.kernel.org
X-Gm-Message-State: AFuF++n3WaQNM6trrICYqAVoD9ElDWDl6m6wmfRjRNt/Z5YbvD9qHxpR
	FTAzHUojYth9P/TUG1XFuGgUGflCrHr5dw3difMpn3ITuGp9VF+X09n71zF/6ToYSd7Ukfadu83
	KL7EBk6yTVu9ROoSIXeH+FnFfDi9jrQ==
X-Gm-Gg: AYBFou09xpOML5f1wYGlxrTV4F3DgGfnJiw5zwgQEl2nlGV54wZouWonVi6+RCceat5
	ID3MK10NyZhvkIljN+B8QNjGZEqmAaKh6OuImsvDzHvLvX2iDx45yksWUcNE1j0j9I9WNZ0EnI2
	eYdhgKWoPhzTS52Z4Rf+apneqAROmaTh2gfrFF5lNhJkFV9tPKrMu0a2MTkDBD9t6JpI4BGn8SU
	lxeNgMx0Sru5L4sz4+gkw/vxylAOH6G1FkDvtu/C+fpMCsChB1bO9rA6ASUMS11QpytQHKD5LIp
	xXL6iaPGdorf/wPyravkgffQEoruf/aAboourmZRK12YkD9kyIsHD8gs7deqHLinKjl6xu16M7R
	wOoNoXWKHsp4=
X-Received: by 2002:a05:6402:360a:b0:6aa:12f0:166e with SMTP id
 4fb4d7f45d1cf-6aa4fe77112mr5015991a12.16.1789845740503; Sat, 19 Sep 2026
 12:22:20 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAKAoaQnTria60yM=zYQAe+dZti0ZvCfja0V+Y0F=Qu1h+hXGAA@mail.gmail.com>
 <ea3ec60c-18a1-4643-ade0-c4a004cb2ac3@app.fastmail.com> <CAPJSo4XZcAvXE6gP1vXFSfGZnjiQ8BwgeqO02obd_nWc-boR_Q@mail.gmail.com>
In-Reply-To: <CAPJSo4XZcAvXE6gP1vXFSfGZnjiQ8BwgeqO02obd_nWc-boR_Q@mail.gmail.com>
From: Rick Macklem <rick.macklem@gmail.com>
Date: Sat, 19 Sep 2026 12:22:09 -0700
X-Gm-Features: AcwNN1We1oDonn0gAwlDlHzH4jpOtceOwQ9122EHBH3x8kDKy0sc26VY-G-wFOQ
Message-ID: <CAM5tNy4Jm=Mu4Tu1QUQV4JjMj0iabFJ1NqnytWioWtu6bDYUuQ@mail.gmail.com>
Subject: Re: [Ms-nfs41-client-devel] Need NFSv4.1 "WANT_DELEGATION" op ...
To: Lionel Cons <lionelcons1972@gmail.com>
Cc: "ms-nfs41-client-devel@lists.sourceforge.net" <ms-nfs41-client-devel@lists.sourceforge.net>, 
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 19, 2026 at 4:43=E2=80=AFAM Lionel Cons <lionelcons1972@gmail.c=
om> wrote:
>
> CAUTION: This email originated from outside of the University of Guelph. =
Do not click links or open attachments unless you recognize the sender and =
know the content is safe. If you are unsure, forward the message to ITHelp@=
uoguelph.ca for review.
>
>
> On Thu, 17 Sept 2026 at 15:50, Chuck Lever via Ms-nfs41-client-devel
> <ms-nfs41-client-devel@lists.sourceforge.net> wrote:
> > The RFC treats the absence of WANT_DELEGATION as a normal case
> > with a fallback. Section 10.2.1 notes that "since the server is
> > not required to support this operation," a client reclaiming a
> > delegation with no associated open can instead use a dummy OPEN
> > with CLAIM_PREVIOUS and then CLOSE it (rfc8881.txt:9596).
>
> I had to refer to a colleague for this one. The answer:
> "... CLAIM_PREVIOUS is only valid during reclaim. Outside the server's
> grace/recovery period, a compliant server must reject it. ..."
Yes, the above does refer to reclaim during grace.

However, I do not see why a client cannot do an OPEN/CLAIM_FH
for a file where the client already has an OPEN for the same file
for the same owner.
This is normally done to upgrade from OPEN4_SHARE_ACCESS_READ
to OPEN4_SHARE_ACCESS_BOTH, but all the RFC says is that the
access bits are or'd together. (It does not say that the new bits must be
different than what is already done for the OPEN.)
At least for the FreeBSD server, it appears to allow this for "same access =
bits"
and will issue the delegation based on the OPEN4_SHARE_ACCESS_WANT_xxx_DELE=
G
bit, using the same rules as an OPEN where file is not yet OPEN'd and the s=
ame
rules that a WANT_DELEGATION would apply if it were implemented.

I'd suggest that you explore using the above, since you are only doing
it for an "experimental caching model" at this time.

rick

>
> I think that is why WANT_DELEGATION was added to RFC 5661
>
> Lionel
>
