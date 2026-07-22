Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E88C43FB05A
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 16:57:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784739467; cv=none; b=Eh83GEQ+7x8F4fi+T1CrPqIksPRezvN/b9ZFg0OpevoRE6Xjj4Y04hqeMR0VQNDc26F90f0+R9kD8mekbDWkVs7BnasQyjYiIniS7Hh10FE36pASpWLk3KEoevytHGHhajk6olyBPGWFK5FEMZobSNepSojuRMQzqqbKxJJLLhA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784739467; c=relaxed/simple;
	bh=e1FkolQyDltw5pfWJiQXzOw3WvZiHAK9iH/NrYvqCBM=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=qng85k99sbE+Cvu44puHkAiiWLqYs4pD1ROYB6hkIHmBo/q41KHjCxxkT5NX/SgdsBHNYodKNUApvgEPXB0OH61ZhwTDAlfcirWyWIaYlZ2O4m20DDXgpc/tUcTtS7iDrx+xFZ5tL0z1cnEQDHzyd1xLv/nT8ZbB9VphCzopWY4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eJF49rsb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eJF49rsb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 906E51F00A3D
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 16:57:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784739465;
	bh=LPcOdVZMMcgm6b/T5m22MfHqQlIHIR7KE5HKHozKnrE=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc;
	b=eJF49rsbPUgdwajk0xWnb6M2zudQlpD3V/DNHkpcp8xNh/IU23Jhr465Xm2FjO9hb
	 exFnAFhv2KmIEZLQKjctijnli42zAkwCMgLHhyRwWyTF2iSp/K3GjfkY7q4ULeEtyV
	 OK8CpTPpyRfedwyJ3Hhy8W4I4NL3j4ObQsi360MJdQk5/e0d5uyr/1yg9d8QrS3hyW
	 F5MGl4gprg6tzTDBygD7dhFndBKtMLV0lrKy1UcFiYPoGk7yBJLYU0eA11XLOQ/zvx
	 KoARYNt10m0v7Gu2q9jPsB2Don9kSK14cDI3c3b5XyQtusx694lP1LQwGBY7h3TEVZ
	 NbnI0x8HrYh1Q==
Received: by mail-yw1-f170.google.com with SMTP id 00721157ae682-81f36179d72so10994317b3.2
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 09:57:45 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AHgh+RppNw40BWq1svaVKhHtOijnqhJIGBZ/lRqCSei+XnCYi7Vf/a16dyqVwuQJJFQAGQ5kesnvYDJ33Yo=@vger.kernel.org
X-Gm-Message-State: AOJu0YwECD5b28ME467zTgCq2OMXd5HcoY6U85+912yznZKx0cChU8Dq
	habZ1+V40f+13appRf+E8O63BW0M9Hirq0imbS09A+tqKu+/5mUzNPAoak+j3DDW16rS0atQ1Gm
	3ohF7Cz6xkKJ2f2qoJK1rmTBqSq4ThUFuOHC5+S7d6Q==
X-Received: by 2002:a05:690c:e3e4:b0:80e:1ad2:afc3 with SMTP id
 00721157ae682-81ef22ef457mr71652027b3.15.1784739464993; Wed, 22 Jul 2026
 09:57:44 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260722130615.3163560-1-hch@lst.de> <20260722130615.3163560-2-hch@lst.de>
In-Reply-To: <20260722130615.3163560-2-hch@lst.de>
From: Chris Li <chrisl@kernel.org>
Date: Wed, 22 Jul 2026 09:57:34 -0700
X-Gmail-Original-Message-ID: <CACePvbWpxJ-5kzvkFwNRcpxqxsKNowsKkWLC6BtzuabyNZv4oA@mail.gmail.com>
X-Gm-Features: AUfX_mxaUX8OlbXL4sZ1zJoB_AVHbNO17lVhNRIYu9y_lmljMjecn4zlQmCtqew
Message-ID: <CACePvbWpxJ-5kzvkFwNRcpxqxsKNowsKkWLC6BtzuabyNZv4oA@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm/swap: revert to single-folio writes for
 synchronous swap devices
To: Christoph Hellwig <hch@lst.de>
Cc: baoquan.he@linux.dev, akpm@linux-foundation.org, usama.arif@linux.dev, 
	kasong@tencent.com, nphamcs@gmail.com, shikemeng@huaweicloud.com, 
	youngjun.park@lge.com, ryncsn@gmail.com, trondmy@kernel.org, anna@kernel.org, 
	sfrench@samba.org, linux-mm@kvack.org, linux-cifs@vger.kernel.org, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 22, 2026 at 6:06=E2=80=AFAM Christoph Hellwig <hch@lst.de> wrot=
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

Acked-by: Chris Li <chrisl@kernel.org>

Chris

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
