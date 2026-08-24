Received: from mail-ed1-f42.google.com (mail-ed1-f42.google.com [209.85.208.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56EEB3AE712
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 09:27:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.42
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787563625; cv=pass; b=b8QyELFJy94EHAGYws+aYurmH72tvaYzAoKxgnqUhNqJh+UGtm2aV/SY3GpAK3hLTLVHBmI0kgAjXJvIrCYpR/vDRYUJo9U8VDHrCj5hLs7+RicPNqFJGQv2ILRM8ncymd1Tqtsh64PcsqnLcfnRIqm9D3f7d1smh/nUAdK+YmY=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787563625; c=relaxed/simple;
	bh=OA04IjLa+28PYYqa4JgI0QmWP8EUE5rmOrjI2n0Gy+s=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=HUIlHhE13ynAyP2B/wrZ9Kjn1E30NONKhad1LKRcNThRUU/n+D/iZQWTGSQWN97+ESJOKBK1lS4m7pbWO5Tv6fblL6Ayt+webJQwmIkGWu5ecbKww350DXrsyCuJ7NNNBr3guxD9NVv6hJLuLnP1VuS5TiA9JsP6B2CoW/KE6nc=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=G+jDk0MJ; arc=pass smtp.client-ip=209.85.208.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="G+jDk0MJ"
Received: by mail-ed1-f42.google.com with SMTP id 4fb4d7f45d1cf-6a3e145e1bfso4209499a12.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 02:27:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787563621; cv=none;
        d=google.com; s=arc-20260327;
        b=dqBRukUHQ6Wff53wF+nchPeKHBdq9+arBdfy5wK1M2XZ5YF+0UKCkFIJN4Y/NPtMHU
         ZMu5JTb5SPwpalJXgeRSTwK0GuADQqDc9eTU85aGCXLiQlCrSoSMgXokGXdiz0VcEOHZ
         8Ob21z+T8iOr8c4X19LOsODiMcCNKGStVvD7Vb2yrB94M/UkFGVuX5N0qUkDlqYJqCO5
         sPPPaFGLxlLlBPOWlmj7dlqE7p3KIPHsjXtXNEiIUp8hdBO3T3i1rus6uCdNEn/XlIqn
         +mmb06Huuu9ibrEwOj1YZ0IQRK1rCnAn+r9DrzTH54Lp/XFBVeweNSrc/qeKFVrAi1QP
         doNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=6bwjgExHYS2/aeZboO9F4uG83NTdpCfevjwOgza4abU=;
        fh=T4jCxyoJYa1gjMmHR3I6ACwlQuNwUuvzIRN8vjGV6m4=;
        b=QEOQx4IixS5HcPDpCm3z7OzOGD7UV34UhBQCKIXUzmYXuOqfVxQAjYcOHME7twDAk1
         7Uy5IULuvz4XfOad7OOlBvnkY91X6fofEqSuNZYBoYSfURT7nfS2IWRpiG41OdymE9QI
         i4Y01HibKv1rVUpO5J5/timfzXjAjZZBt1/i1EKr0lqOs6rZbCFKmsPRz6qQuEdxREWW
         lUcaA8qwW/MbING0Cmz+HI/MaYiOhIpfyzzyY/m88BEMBhGwMhUbvTycAbsZMY/Qxuhk
         SoqF8+wh/43lfhOzYj/ek0aHtbZW7y9SdBrSBz24qZtYC2YJL0YxC5M6pXqIBCtCtXx+
         1YMQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787563621; x=1788168421; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=6bwjgExHYS2/aeZboO9F4uG83NTdpCfevjwOgza4abU=;
        b=G+jDk0MJtLEka+MH0eIbFpAn5RvZUQaB90zqk3z8E2nH9kNb/kLyqWQbMnsZ2YYhee
         HU+KTrM5kYgrT9HjADyk/6vWX0olzo7EXk202Xrw7SNYZq5gBp8qkCdOM9lQzSziwXqD
         abQ+/yQHYFswj9zZLyefhPpOkSM5j81F1lF3z0GQGpz/RWn6JQtFTIQ2eFeX9Tz0PyOF
         Kwdy/uk/ERAGo/FTaQm1inxLaN8mB69uMPE72B4aHgaqPHL0BsEjVVYAp26Kl/cz9GHR
         K0Ks77UJQnTNtFdv30FV3cPyGpaefVTvy6oBXit6Crgz6NQKLmxL5jvtWyQmYQl8iH+H
         wubA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787563621; x=1788168421;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=6bwjgExHYS2/aeZboO9F4uG83NTdpCfevjwOgza4abU=;
        b=O+QMr0NmIQ3Hniby6kuKWsmr/S0n67ggytTEFd4YGTSVhqQt6aUSFaXDwWRXqzbbvN
         +6O4xlDPZqsKhkKaWuHIFJ5saaH44a2JlCm14iv0MuRr1iQxQiNFZy4RJrPGfcz3E/q6
         AhTpfMCNPQM4FRbB4oeA/8rWavIxlIHhsR/c+gMAV3+zLnkIcYw5AlJzylSgYPyDuSIQ
         kh5U7xCI5Q6AgSoJkaM0i8HkiJjOcPBuTiIzQLskpQbxDZ+ectWwASSHJs8oVHohhaTP
         SMfhsTTAJ2Zz773rvk/q0//T/3kU8OghYuA1FZdEB/3XD2q9d0RwtV4BkiJhEPcMDXRW
         uXFg==
X-Forwarded-Encrypted: i=1; AHgh+RoS5X8uTm9uHPs15Arlnuk4Sr/ATdD+Ne864cH+N1kjg6sMBioq/zSLR3sjzJuejCUUebSLu60e+dc=@vger.kernel.org
X-Gm-Message-State: AFuF++ks9O+fjfw1rqrVWgQKN5UDk4VuEDslUNGA1O1bjAqhaX8LZFzK
	1+Pkk4yQRwgMcdCUToKCheCohg9Be04nc+obSj7xZOHQhwtryAjECOc9EptKkOiZ77I5ZoBrX4t
	PelKxEoQzI6Aep6eyjqBsLDVhn+5FzE4=
X-Gm-Gg: AR+sD12GqMntyxQVXygy4LaicfT9xhM463xdMmXlKIBxN3nrsKFTSkldezQk7xnCwtB
	D67u4i+W0OmrqwVuoW2W7izt9kvydp+MOFknTgII6ls2j4nzN6u15Pyx3mjxBZBGdhXYSfhKd+/
	LWaV120vwRZ1sfccbeR/lj3c1eqmkoFhIzjL35Dj6p74NIEPOogos1FGQ9rfB1K9GULDZLNlu8X
	M59q6s7GOkwIhl811N1ufr3g9e1A7+/yFPh+QCeWt5Gx0o8EBg9SypoLH+vevxplyCAqqODHxNQ
	HMm2J5UOTkKmG3r1Ru+2OHOfeHC/BOdRPwEjIL3VUlGq+A==
X-Received: by 2002:a05:6402:505b:b0:698:af31:5a9b with SMTP id
 4fb4d7f45d1cf-6a42f1e08c0mr27512621a12.9.1787563621344; Mon, 24 Aug 2026
 02:27:01 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260818225715.572140-1-ameer.hamza@truenas.com>
 <aoVHBkmPNSRakbYW@infradead.org> <9ad95194-983d-427d-9a07-c9eb0891d1a0@app.fastmail.com>
 <CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCzN2Xz=xm1FyumewHZXg@mail.gmail.com> <aovPSDE_IGKggzyN@infradead.org>
In-Reply-To: <aovPSDE_IGKggzyN@infradead.org>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 24 Aug 2026 11:26:50 +0200
X-Gm-Features: AcwNN1Ww_-DMhoMsd0BRmy2xbNr7HMtb_CXoB5tNe2ML2jWxM6NYnZnZX0RCcds
Message-ID: <CAOQ4uxgok6Yk0yp3DcxfD9Cp0ZoFJ7G6a7KasLyhHn6wGuTRyg@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSD: Fix duplicate fsnotify access events for
 iterator READs
To: Christoph Hellwig <hch@infradead.org>
Cc: Chuck Lever <cel@kernel.org>, Ameer Hamza <ameer.hamza@truenas.com>, 
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, 
	Christian Brauner <brauner@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 24, 2026 at 6:57=E2=80=AFAM Christoph Hellwig <hch@infradead.or=
g> wrote:
>
> On Sat, Aug 22, 2026 at 12:21:12PM +0200, Amir Goldstein wrote:
> > (1) In this series
> > https://lore.kernel.org/linux-fsdevel/20231122122715.2561213-1-amir73il=
@gmail.com/
> > we intentionally moved the permission hook outside
> > of the splice iterators because we wanted to avoid calling them
> > with freeze protection held and also there were some duplicate calls
> > for this work.
>
> This got me into a little rathole of looking into the other
> do_splice_direct_actor callers.  And I still don't understand why
> taking file_start_write outside the main splice machinery is fine
> for splice_file_range callers, but not for do_splice_direct callers,
> and what consideration exists for potential new callers.

Tough question.
If I can retrace my steps:
The main consideration in the "Tidy up file permission hooks"
work was to move permission hooks outside of sb_start_write()
to avoid "first order deadlocks" from pre-content events (and LSMs),
but I think we also tried best effort to avoid holding
file_start_write(out) while
performing read on file in, to avoid "second order deadlocks" with
weird setups like:
https://lore.kernel.org/linux-fsdevel/5lz5jq7gzoejbywmh56ayfkdiuqsjd2s5pl5u=
vlflfxc5lq4rr@thr4hrkw67d2/

For the first order deadlocks, both flavors are fine:
1. permission + file_start_write() in ceph_copy_file_range() +
    splice_file_range()
2. permission + do_splice_direct() in vfs_copy_file_range()

->copy_file_range() are called from vfs_copy_file_range() with
file_start_write() held so ceph_copy_file_range() needs to use
the first flavor.

But at least it's holding file_start_write() on ceph fs while reading
a file from cephfs (maybe not the same sb though).

The use cases of do_splice_direct() from ovl copy up
nfsd/ksmbd copy_file_range (*) have more potential of hitting the
second order deadlocks, so they try to avoid them with more
granular file_start_write().

TBH, I don't think that we proved to what extent this helps avoid
the second order deadlocks because obviously, those deadlocks
are still possible.

(*) In the past copy_file_range(2) across different fs was also
a use case, but we stopped supporting that use case.

Anyway, there could definitely be other reasons for the
do_splice_direct/splice_file_range split which I do not remember,
but hey, at least the kerneldoc for these helpers is pretty clear...

Thanks,
Amir.
