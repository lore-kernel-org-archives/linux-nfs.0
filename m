Received: from mail-ej1-f45.google.com (mail-ej1-f45.google.com [209.85.218.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 755973AFAEA
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 18:00:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.45
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784829628; cv=pass; b=DOBqi1Qcg0s5FAEBCSxbBnt5YUVLmpn/3XW7MHXTpvt2+NoySQbkyBw07w2gCRbW1sSLxFolkcJ9GK7T+V4aTYxppc37g7mnUNbl6zE4jEwJI+1CgQ4LJxW1Vs26wxnWkApVdoR4efWfx5MZwalTyqHQlvuqGiJ/XrnyuL4fg7Y=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784829628; c=relaxed/simple;
	bh=c/2oV26oR0Zhc712J9EbXiUDflLKQWGDFSkFD8w27aE=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=DJ3Zyn4AAmHL8Cfcc+y4K0WWfadimxwXQjaCc7bESHT2hVTMQ1Q1E9HWS1PHTauzAR5GJD4FmPSskHtULyNwXgZPcdvjIdchrv/TDNcrixNjDIKrQ6HmzRshSJy+0veqS6pXGutGYyFH9eqiRbn9RwMT2hBtxBnR8Ix++yO5WlA=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=M0yhF502; arc=pass smtp.client-ip=209.85.218.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M0yhF502"
Received: by mail-ej1-f45.google.com with SMTP id a640c23a62f3a-c15e03c2763so140205866b.0
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 11:00:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1784829622; cv=none;
        d=google.com; s=arc-20260327;
        b=OftX/j4cvSA/jy2r4tJbsosg38wbe7O0Nks2ASWiJD/n6r56xc/x9NLnblZKcCa2Ue
         ie3AvC3qoEAuswm5Cmc5xTQLWcSA2tGnh9k7nJrnOZENp+cRE2HZTA9eJtbPbNsbIZi4
         cYB2i5PgNeU6jMetjGFoJs/Wg8TaFaxcycSCCp/dqRyfUxKn/tM3kJ3lkIeJHEH8qsVE
         /zvEcdQhkhqrbn8Qk/RGaXDl1RnGKGEMExVliaXfdVxJHDXvzbFs+0hPUcG3hiGQdZsk
         DycPVLUEtpa3LCI1BOvtgbctiaYrgx2VjrtdKO+n5cHybxWCtINX0GHxlaISkcSXv4FY
         0jTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=MUxCdbGeWaQGh+LoYEwItBt1n3zOg3U69kYn+XJ9Jdk=;
        fh=xX6CI2TKgxg4FcfDPw4I37onVjDGnpLdByyPDIdWFYI=;
        b=DtE9XgDUE/slgXGA4hh5m0dlrflXMWNFvdbgwTelOxOxbt9ywkIjg0mseU8j4yVPQa
         xRnzCbGtPgWYWP0cuon3pInUJhPnbVa7d+v0kbLGXJ48Pbzz7LOBLWste+epTd7RiSWG
         nvkrNuMh2429eEuRFk43NvPG6gVIzVrhkF0R355IkKQeDySfyn2hwbZZQ68+ruJ4OJB/
         +NoLR3wuWK2vaX/y5/aKeT7c3LXnZ4HHGsg5CumjWOXdUIwrOX0Fz+MSzbQ5zxT+dImV
         PjellRjf4KZ84Z8xbctnz4iQ5YeNa19f62VymP7ppwjGLvjWEE+IAHXAJa+jm+/h6DqQ
         I9UQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1784829622; x=1785434422; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=MUxCdbGeWaQGh+LoYEwItBt1n3zOg3U69kYn+XJ9Jdk=;
        b=M0yhF502p6ESg1y9tKRE57J1HflZeKuilWuRPSeqou6UZN1zxY/hoRHo8ew17QdUQW
         DGj4SMGzAeAjuDW4XRy4nHBu5Pprtq31udzSw/DGOH8nMK3dNYJ6MDXiIGBDHXT8tglT
         bLmO3T49Z26Df8wkCR23cuNqM4eZC3gYyuzo7Q2TA2PZ5ebEtYWOmT/aELQ1wDbWoVc1
         vcniFXKvCFsBDkHooOziGnuNoWDxUCn8NxO5QSvfhUcBFaTI5OEQ0n5t0enXlCdTFOnD
         VsaIRGPJ+dDYZbSwTZDeSz1dxL2g32vewTRRi19XpJjXsV3YvQSNNUphkkIiigAAFpj1
         UWdQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784829622; x=1785434422;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=MUxCdbGeWaQGh+LoYEwItBt1n3zOg3U69kYn+XJ9Jdk=;
        b=p94lqSsaFuinO+1SJGigpS5Dl8M9lM5i1JcQkyjVpVw8C7skdmZMxf/UfiyAXfCbn6
         Dj95rSRPB/ztKFKnslrhlu1VideyL9YYiPohuQ3KASVeqe9OpORJopvqrLAsPTI9BQrt
         7xKBEXi+JBmDTQ5CXDYioIcn5ur6Q8pTcSgt6akhaZe0lYMI7j5p5XQLoy+8ZRdmgJvl
         sHZXmRdiuPpBK/+uU9kVp7qCLM9yshGOCF9GlFj156BVuK7CiAzS07MuuUILqA8bZBAf
         8MODLyIM1PoAbssNu4zh20hEJbkUbA0Nq5De/jq+xGxIC34etzA5hBeCDnLm5VG0hl5g
         BJPQ==
X-Forwarded-Encrypted: i=1; AHgh+RqP+GljXEPAGivp7ApRF2k/E78F2vizVSez+0FNi6FNqteZjdKyWNMF40tzAQpOzB3Ji4SSSykO07I=@vger.kernel.org
X-Gm-Message-State: AOJu0YwgbCRlWPWfDOmXYu5fg0bqcIuF8IlGIXQEKp42y/3bntKDTlqA
	E+cUVasnyntPhzq3DO6gUCFPoJcBmZC+q0aaDPC5+9iEpNCKM1PNuyiZqbSgSaiYmP0belvIoiz
	YdZIVYVT+d+1z0+kIkBOob96DIFZ+QvgUcmb9zji/Dg==
X-Gm-Gg: AR+sD13l7e2aK6va/G8M8M4RRNuAvpCxFCLApRT3sdrG0YHwX7n9gkl3ESbS2xywC+8
	F51AAXAv1zs+DPIgimZWmLrQxAWOCoHIrRyh6V6IpVDNH1zywD/tlgFbXpgLKJzH8OmsyN69a3E
	Qg6hk1Y3W/7E0adOWYHFGrt+xbZr6+otbyD3lRYeHDelQLxehULaDGOYyXni/vhccslIcgwtlGr
	VS5t4yQHlOj4I7GUT5tut9qYR9rwAhvKIvjWNoBUsdh1oTDCBOQVCLAPiUBiuaxATR26ycmcIgd
	ssmUj4uTfOHQBAQ1F8E=
X-Received: by 2002:a17:907:9619:b0:c19:891c:e1a6 with SMTP id
 a640c23a62f3a-c1c536c8d6emr180399366b.12.1784829621600; Thu, 23 Jul 2026
 11:00:21 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260722130615.3163560-1-hch@lst.de> <20260722130615.3163560-2-hch@lst.de>
In-Reply-To: <20260722130615.3163560-2-hch@lst.de>
From: Kairui Song <ryncsn@gmail.com>
Date: Fri, 24 Jul 2026 01:59:44 +0800
X-Gm-Features: AUfX_mwYG6fMwqod_7vhQphcNSi4VFizKHSgiYv7Hwr5KRsNZH6h97bbms1Vw_s
Message-ID: <CAMgjq7ArsgdKf-uZ_drQ9Kqtq4i_MMZ+dP+tjNzPrsrR0YPBWQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/swap: revert to single-folio writes for
 synchronous swap devices
To: Christoph Hellwig <hch@lst.de>
Cc: baoquan.he@linux.dev, akpm@linux-foundation.org, chrisl@kernel.org, 
	usama.arif@linux.dev, nphamcs@gmail.com, shikemeng@huaweicloud.com, 
	youngjun.park@lge.com, trondmy@kernel.org, anna@kernel.org, sfrench@samba.org, 
	linux-mm@kvack.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 22, 2026 at 9:06=E2=80=AFPM Christoph Hellwig <hch@lst.de> wrot=
e:
>
> Kairui Song reported that zram benefits from submitting each folio
> directly instead of batching up I/O because the classic LRU scanning
> benefits from clearing the folio writeback bit in the scan loop.
>
> Accommodate that by kicking off reads for synchronous devices for
> each iteration.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  mm/page_io.c | 11 ++++++++++-
>  1 file changed, 10 insertions(+), 1 deletion(-)
>
> diff --git a/mm/page_io.c b/mm/page_io.c
> index e4fa7ffffe8b..c984a4023a65 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -358,7 +358,16 @@ static void swap_add_folio(struct swap_io_ctx *ctx, =
struct folio *folio, int rw)
>         }
>         bvec_set_folio(&sio->bvecs[sio->nr_bvecs], folio, folio_size(foli=
o), 0);
>         sio->len +=3D folio_size(folio);
> -       if (++sio->nr_bvecs =3D=3D ARRAY_SIZE(sio->bvecs)) {
> +
> +       /*
> +        * Write out the iocb if we filled it, or if the device is synchr=
onous.
> +        *
> +        * The latter is to work around expectations in the classic LRU c=
ode
> +        * which make synchronous clearing of the folio writeback flag in=
 the
> +        * reclaim path beneficial.
> +        */
> +       if (++sio->nr_bvecs =3D=3D ARRAY_SIZE(sio->bvecs) ||
> +           (rw =3D=3D WRITE && (sis->flags & SWP_SYNCHRONOUS_IO))) {
>                 if (rw =3D=3D WRITE)
>                         swap_write_submit(ctx);
>                 else
> --
> 2.53.0
>

Looks good, thanks!

Acked-by: Kairui Song <kasong@tencent.com>
