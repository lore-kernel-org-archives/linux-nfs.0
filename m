Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=74.125.224.51
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793010655;
	b=GBP8K5Tyv1JfunlIaVfJmIogHoRq3kZnCJxDw7O0ASmwSL2n0zJ+s4qrY6qsOvGU7X5T
	 TB13VjFuMixbV/JDVUSWQqqCVJul6FbOakJ8L7NkwGswV2OOd48kUhtscdM3LCaFD9+LZ
	 F+8PXGXVpu2RGDio+XSMgKrqZRibDRxzc/m0d4n+uhbn23Q2GSe1Zu/8t++iyty0Bzkfx
	 jyE3aSGDFS9yLjMzwtKjYFZ79z2K6EI2phhVsCcLDufa5B7/uz6jpf1t4DJlcyk3HLcU6
	 HJqx2tvdsjcCWVrfs5vXy61ZZIgiiNu2a6de5FgKsRUoqce8dJT30N9VhHGOv0mi/hQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793010655;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=W/Xl1hqO2gfiOUxTSJouFQmc0SxZFTjKJorh5/Tizus=;
	b=LV9veJT/AVrADLXp/pR/YAKxfmtGcb8lE6U8MirikWl+RFQqiOSB75BD2HHAfGM7jWrh
	 61oov2l/tE8FzKfL7vtmv3C19iU6JSeGH9s8ulITuWabMwkz5Tw5Ap5X3beuFjfLmFlvK
	 0d6YB63Ob0BR14lumb5Mafus4JD3RT2vOHOMVZYtDO6AcG6e5UirpVHOB5jizIVQK9aPo
	 jUiWTC0uIHBt3ZKVRKVl+w1U1fdpeYpQa/bngEtXxj+WH5/+nzkoLxJN+1J2XxfCudyGz
	 MHrCxSX2rlj63X4/owXhgJW2JEbwJ/fJihPyu5a9n+K+yPpcCmXSQ5tETTZsCa4UIzw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=n+DzWzqY;
	arc=pass header.oldest-pass=0 smtp.remote-ip=74.125.224.51
Received: from mail-yx1-f51.google.com (mail-yx1-f51.google.com [74.125.224.51])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B70F606A31E
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 10:30:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 9B70F606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=n+DzWzqY
Received: by mail-yx1-f51.google.com with SMTP id 956f58d0204a3-677dbe051d4so2298864d50.0
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 03:30:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1793010653; cv=none;
        d=google.com; s=arc-20260327;
        b=mmkhJAv57yq40XCdbL6Dqm/xcOEz1kZFRVr/LqKT5lnICbQv4zI4/vt7+otpQvvy8o
         YTuCAMEKSYENT1mDzRDGlUJemkWkpiHUSyztHlshNwybqDK/D+J38NWM7sukxdS0RfXB
         c4Kcq/NRdAtEhtWGeo8qv5A/XfTC7pGJ1IrGIjTi/i2Y3xbQo/nduGxvcqElNn/OKTif
         dLB0En9+a79cd7tnMlto2ujmNDzmxNvpwPz0WoYMMm0B/F92bDT7ms9nz93ge/Yyz/Co
         XtE3vMDIjsWNDpSHO4c62QGp11JmY+PWFncWtW4epkNWFabPjlD/qfhjqoOERnEZQ9+w
         Ivvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=W/Xl1hqO2gfiOUxTSJouFQmc0SxZFTjKJorh5/Tizus=;
        fh=BW2Bz4NFsEwVdfW8PPR4FsvAnYI3vdwLoyBHoATtxBs=;
        b=MdDLUgxfd6vT389oxa1TDhsIghbv9GAqSX+DTaEyZVN4maP6F1JT5sy4WxpIZXsKZ4
         rhLEjXxXz7y4zH3ZgklFfuXASG8pzXD3DJ9Rv63I0RKHuEPL4utiW7Efejke+DQdoNVl
         xpJs/YD18qHiqQLVpWdGWbRSMTRGZv9lGgVN5UT3eg408tQ1IBIrCluupmeSkuQWE8h0
         Fll+s7h1xorvblGo8lXEb0sTm8MMpJdJUk2VRXZ0EUi7IZJoPu8O0nBnwMniTqVfX5rA
         zuaiWnT7Pb+iBgTueK4ESL3Eh8wZgIIF94bhHD0xn7LMWCKNNJ5ReiKqug363iEsT3hc
         DYMQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1793010653; x=1793615453; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=W/Xl1hqO2gfiOUxTSJouFQmc0SxZFTjKJorh5/Tizus=;
        b=n+DzWzqY5phGFw+Sl5wCn3oMpAxu0loahwui28ewAQrIkchz1qx4X4T3E7J9vCjgIr
         dAcpjdHhrPXOBZtmlJk04bWJ+60xFXm5WOy7yLFWShBSiWpw2mpnGMYaH0Z533yhdDG5
         qB3zrZgcaVb4jHno0IeyB5RqRWlY1Doi43abCZxUFFH3IujVq5kItgxYpPqHUUUyZwYj
         he/Y5UZ7nKEEzEeL612xG7c/sdY0MImxMb9GWfp7M6rjfNapozUVjxUN3faecUFxLrFu
         CKtHkjyTFJsWBqb9WsG26PW0oaJHQJkAzyYtuzvTNd6rf4g6TeV07MMI6CWlMKPslUac
         FbaQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793010653; x=1793615453;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=W/Xl1hqO2gfiOUxTSJouFQmc0SxZFTjKJorh5/Tizus=;
        b=I6VSHoFeZirV7QmtSdf596JR3rDVrps6IsRozj1CVSXRfNl70OYlLaQdby5oY5KsRx
         sqSFKX55XG+jvZ7zjHH10+IA1wltVjR+PsbO45otkp3YEZgmOxIdGjBZh6Ll6iZEriXy
         eQPDtNoWWlgMWQAcnybOg2ifu9twO99kzGSAOIdSbK1gsQJyYAV+mIbZKbChT9QzUA+z
         E3sPLn+1Pnjh+a8SF8/WF3vUirolfsqXZELaJIkrYNMssNvPNSqUfJkvVLw2AwVZ5zIX
         d6z4aCx2EHoUlg6cGi3Q5RulC1OA654WdAu9sCrM08QUtgj2pBFJVpahW6fQHPFRQZi+
         Uijg==
X-Forwarded-Encrypted: i=1; AKwUvByEST3ZVr4J9UWnwD/AkSzce8NtoYm64iF2VfNZ69BbT/Z4GASF3iK1+RTxyczh1J4CCzlox3Rag/M=@vger.kernel.org
X-Gm-Message-State: AFq9FYLxEBB+kdA+zl2ICuHBoyW5Y2uFVRDz/svIy8A+KAneRfvLZBG4
	HNdm/Da6wOS8CqkwhDdQXYrkIas2XMdCSXJCliRDuwyebQep7a+EX4FZsyZZqhr9/3P6Wj9lCWy
	gjd5UADThL6/YL+e5gxENznzMt8V2JzE=
X-Gm-Gg: AYBFou0l6b9gbqkxGOEDdTtTGcqY4Rglj0BVuSO/Yj2ZF4O2NyEIFrEqffAgkTG/62e
	zfFYa4Pga0xt6WX4j5LEaKnG800tz9rjdLn6POiKYU8ET3d/AqFFBWTGms8ZB6HTTbApanEEp4W
	fd7J38WAUhh77fW+2/tGjroyType62lEchNIODVJTu6AZLtaR+4vV+RUNMZTXcy5BMuezW1gUgP
	Ymk7F35enR5SVSqyAFR2I+qV57GR+/LIDJ8zTKnayP8F1XxI0z6eoCqexIV1tvsFCtEiKlfezkN
	GTQxlEq3UP+BS/dHtqdYZ7qBmasKK6JcsTA6zFhYr3/Llk6WbVjAAyhIs5EpXZBWXQ9Po1PNSOK
	dvBBl9jnj3SnERNBElKWzfrzgCkz3Jk4MHwtyihgMDZm4rCq/DKicEA==
X-Received: by 2002:a05:690c:e197:20b0:8b0:d9ff:4f4d with SMTP id
 00721157ae682-8b1669e46f1mr27751547b3.10.1793010653625; Mon, 26 Oct 2026
 03:30:53 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261022205357.3239985-1-cel@kernel.org>
In-Reply-To: <20261022205357.3239985-1-cel@kernel.org>
From: Mohammed <mohammed.saad.alquraini@gmail.com>
Date: Mon, 26 Oct 2026 13:30:42 +0300
X-Gm-Features: AclHuK-mYnNsWNBUK8TGInr1zujsRmY0IzVN5iR-wD5j86Y7UeesPbIZrm7pnmU
Message-ID: <CAD37_9jTO0jvrroWzbNWOk0eOj8Otw6rCWE7Ap1kb13OsP+0Wg@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix use-after-free in svc_age_temp_xprts_now()
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neilb@ownmail.net>, Jeff Layton <jlayton@kernel.org>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Chuck,

This patch fixes the issue.

Thanks for the quick response and fix!

Best,
Mohammed

On Thu, Oct 22, 2026 at 11:54=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote=
:
>
> svc_age_temp_xprts_now() moves each matching temporary transport
> onto a local list under sv_lock, then drops the lock and walks the
> local list without holding a reference on any of them. In the
> meantime svc_delete_xprt() can take sv_lock, unlink the same
> xpt_list node, and drop the transport's last reference. An idle
> temporary transport holds only that one reference, so a peer FIN
> that arrives between the two loops frees the svc_sock out from under
> the second loop. The notifier then sets XPT_CLOSE in freed memory,
> and svc_xprt_enqueue() reads xpt_flags and xpt_server from the freed
> object and queues that object on a pool for an nfsd thread. KASAN
> reports a slab-use-after-free in svc_xprt_enqueue() under
> nfsd_inetaddr_event(), with the object freed by svc_sock_free() on
> an nfsd thread.
>
> The two-phase walk dates from when the second loop called into the
> socket layer and could sleep. Commit 546125d16142 ("sunrpc: don't
> call sleeping functions from the notifier block callbacks") moved
> that work to the nfsd threads, so nothing left in the second loop
> needs sv_lock dropped. Mark and enqueue each matching transport
> under sv_lock in a single pass, as svc_age_temp_xprts() already
> does, so that svc_delete_xprt() cannot unlink and free a transport
> the notifier is still touching.
>
> Fixes: c3d4879e01be ("sunrpc: Add a function to close temporary transport=
s immediately")
> Reported-by: Mohammed Alquraini <mohammed.saad.alquraini@gmail.com>
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  net/sunrpc/svc_xprt.c | 16 ++++------------
>  1 file changed, 4 insertions(+), 12 deletions(-)
>
> Mohammed, thanks for the report. Please test and report your results.
>
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 5db42e53be62..076c624fe675 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -1075,29 +1075,21 @@ void svc_age_temp_xprts_now(struct svc_serv *serv=
, struct sockaddr *server_addr)
>  {
>         struct svc_xprt *xprt;
>         struct list_head *le, *next;
> -       LIST_HEAD(to_be_closed);
>
>         spin_lock_bh(&serv->sv_lock);
>         list_for_each_safe(le, next, &serv->sv_tempsocks) {
>                 xprt =3D list_entry(le, struct svc_xprt, xpt_list);
> -               if (rpc_cmp_addr(server_addr, (struct sockaddr *)
> -                               &xprt->xpt_local)) {
> -                       dprintk("svc_age_temp_xprts_now: found %p\n", xpr=
t);
> -                       list_move(le, &to_be_closed);
> -               }
> -       }
> -       spin_unlock_bh(&serv->sv_lock);
> -
> -       while (!list_empty(&to_be_closed)) {
> -               le =3D to_be_closed.next;
> +               if (!rpc_cmp_addr(server_addr, (struct sockaddr *)
> +                               &xprt->xpt_local))
> +                       continue;
>                 list_del_init(le);
> -               xprt =3D list_entry(le, struct svc_xprt, xpt_list);
>                 set_bit(XPT_CLOSE, &xprt->xpt_flags);
>                 set_bit(XPT_KILL_TEMP, &xprt->xpt_flags);
>                 dprintk("svc_age_temp_xprts_now: queuing xprt %p for clos=
ing\n",
>                                 xprt);
>                 svc_xprt_enqueue(xprt);
>         }
> +       spin_unlock_bh(&serv->sv_lock);
>  }
>  EXPORT_SYMBOL_GPL(svc_age_temp_xprts_now);
>
> --
> 2.54.0
>
