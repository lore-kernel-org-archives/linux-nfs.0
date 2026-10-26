Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.128.174
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1793021957;
	b=Qvbh2zLnXf/o3fV/1tOhLkTuPUa+ZyXWtJNMQyeGtcg8/RjQDMTn4qtKtYMZdHNq1lOj
	 c72qd1alhFLBVhG+ckb7C7x4a3Nek+44lJhQG5cOYCIBJy+wElPUuNSitJ+bh9be0xTY1
	 DaJqRaUgtrcNonXk4X0krygchCuI+ENvLty4Tlp1f29Eiqp4FLYZGQTQiAbyff3iU32uY
	 YJTCM6wLMxKy3At0tB7Kh/d3LupjcIDm2dFZGZgMf8bpdyBWVE8Z/9FoSoJScP+I73AY/
	 ch4JdoF8gT0kVp37TWwswrzrK0zHY3zEHC/TZhCZU1JtxmuQ+zolCDaHvJ9dSdi4G7A==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793021957;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 MIME-Version:References:In-Reply-To:From:Date:X-Gm-Features:
	 Message-ID:Subject:To:Cc:Content-Type:Content-Transfer-Encoding;
	bh=2yqlTYuFGrgIfnrJfnVffYVg9swbHOJ+x9GDLU1mUkY=;
	b=4WXRCibJXNaQ6K/vrooyIq10cfYUqZM+zM697PncTL+e+hxYoy5/P7JA5VfXAPBYSf8d
	 aepOiq/d/vlirdPjszYSCCdvzVL2VqwWR8R+2yXdm90KyzUhHjWUX5v8VlPqAS7kXiE1n
	 crf+XKEEpg9kAR+RIY/TvVhd9/bUNVMNzro5rhoKSN9TOUPX3QNMHGr6PTHtNY3Q1ulik
	 KeTuJwcL8JQstKKAx6C6PecIwKC/hux7TpuzPOdcHFFxMBik9fTBF8Ol3J1izIEdM4tmF
	 NA0q5xDl4sz5njcb9Nebyveykty9fXFuj11kxe5Hj+71l2c1J3138Kv++CMPuSrbUzw==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b="qOcRk0/I";
	arc=pass header.oldest-pass=0 smtp.remote-ip=209.85.128.174
Received: from mail-yw1-f174.google.com (mail-yw1-f174.google.com [209.85.128.174])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E51B3606A32D
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 13:39:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E51B3606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=qOcRk0/I
Received: by mail-yw1-f174.google.com with SMTP id 00721157ae682-8ab3d3c5761so24765777b3.1
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 06:39:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1793021956; cv=none;
        d=google.com; s=arc-20260327;
        b=B8PXufLwEDgY17GqpnXxZg/AKeMdrWlM/AMB7gmXRzmXgOS21rfTzF3XWKmBqzTbSN
         QaisAHdOb/olbSP5oNQZCRqRTK3ARc41II7+ZxOZLRQ9VL3sw8Se2/K47TZ9z1D4MKhb
         Jdd/gWFt8fKBVvwIFlq20pFuQCJq4D7jXEY0tX4WjrWEFZMROr1WkPgEYHc9tiikUE4y
         C7O1Y6xbJdGCqcMzFMtS8/YbgaxDDiUfpeENT6hexUD3ygK7WAuSlq5ZsS76IKZVY+wv
         AepCUq08tMnv1AOatbXuyJ2nKwPCVwxta04VeNxwPbxPciMMFl9mxL7tjss/f8O+eW9e
         4K6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=2yqlTYuFGrgIfnrJfnVffYVg9swbHOJ+x9GDLU1mUkY=;
        fh=2g10VumDH1cOBVzqAiWAdxFxqsuT+5I6xu2gWOyQ9Gc=;
        b=IgCqK+UtVWNP6SfWOw5PySP9BIotIQ0TTTKLWOV3nNUH3Wd73UEs8bxpE4/ocNN833
         cDaoamocHUk2FTAVqvfBWsiSUXRnYiSm2Hcgl+saRVrAPuiy8pYii0dNjFTHnTNoZUny
         epZ95Hrw+AYd0q4iPp5LFWBRnaIiyVPwI/hzBwjX6TyTJVNVHeYNegUpaY0T98+KMtLw
         tsUcNllzp15R5L7FH6TpJsVbowWzT1nuNG1TXhSSKtvNvjCNmvqtxL5C9JNKktQHDqyS
         253dL5Nky5lH/Uei4ZwoIlaHNvkpHweda71Ty79zEnpggarXMq3qgwYimFZcZbPP5enB
         SWbg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1793021956; x=1793626756; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=2yqlTYuFGrgIfnrJfnVffYVg9swbHOJ+x9GDLU1mUkY=;
        b=qOcRk0/I9m9lQQN/ftbyf18Com52ILCo1x3lCK8/P8Wenye5ZAQIX8AfKfb7X/gmKX
         vCW+mS/MgQuBXnFqas1wZITchhbQAmlEkHsw9VuHhD6Tmh5RccOLVJxCIuYE9Dx/JZiU
         TfDWa07bdhW4N1WtajKHxf4ecBZ0PDWgyaNWQO1gVzW3hSXVsIHPdYI8QmrnXm7ax5k+
         g0RC2VL6/XcosXvzV/2237y/7TpO5SkkCPDJpiUP4yqSp74AHvpSArR+S0jdszHse6tQ
         cquK7B77KeCeyFGs/Xgd0CXNwJmxq2WGRw6VqByd8VAeVwUd8Dpp34BYnmjaRfvOc+Ii
         3yrQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793021956; x=1793626756;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=2yqlTYuFGrgIfnrJfnVffYVg9swbHOJ+x9GDLU1mUkY=;
        b=R3bEHuxd1XUvtfYc7WVHpOTcVaQtYo+ag3JBgd5WGQC+0L0g2McOS5BeYBiVAfAsDW
         zIaQODog0s9BnRIkFfdceZRTk5aESAiKuQ/DU8PrGqqm3+9jaC55DYvPEAe1chuv7HJ7
         dh9kzfX48QfLJAKxu4yyGoS9jW0vN4HNK1wkMQSfa46WrzU8AJrKK7HLv8JJfQCD8n/9
         usdh4Hba7nG3HTO7a1r90Hu4GFI/UZB93L8E3s3PkFVbHAL9nIjcJjcPYGXL3j4VRPui
         xGFCN7LeNxwp7kONiTWy3yRAisvDUZZUvcIIXu1htmGpG8x0wP1s2aGK+3IfA0mEvdrZ
         ONrA==
X-Forwarded-Encrypted: i=1; AKwUvBxIQZ7U2uZteP2ocW+8JltwMEDeRgXfkz6BBm1H4U2/ubUpXQxBLOIOXtjlUBXo3DvB7Fo2q1fVL18=@vger.kernel.org
X-Gm-Message-State: AFq9FYLGeFVeTbrX8TCfru8swxF/VT2PCOfr0B6G5i8ofGN+UIVFeKMC
	J47ipy1dcXiQdwGG4AMjFQ0WGc/qcpZ42bMglL669JfkVYOpHINinpLQ2QXKNQR2pgX8oAKfgmG
	jz4Fbonj7saBd1eXRwtNLbDBGNZy4TLE=
X-Gm-Gg: AYBFou2Sbl8hEPVzfHmTXMb3zeW5/MTWaSRN4X5grBu/dT/J/Slhs/QcYZP6ZveHO5D
	ZkaPOiHD//vSMXCJxIhuTv4yCZOOR3bfqosFS/VdPrsaX9guUrexJG/K2gz/25qaaL1plK837Ti
	qQR7TrwNiuaDRKT4tYmpOmJUq+v1GYSyM9oKaJNpSkBjDbr60jOrgvPetx9z7UVTBDZ3bLnXLKC
	RqlwPhVQ7cCcPTQZavYboiCfQJRqLvCLUsB8BgDlfAElF+HPAswyJ2OjKmK4/yspaFUPFvyRfJY
	G4xTCQuFsin42wvh9jK/FgEZeFOgJtG5tMoU4YL6BV8dQBnNhwYvKc7hp6NWx5ARabCHBKuidgv
	/PQVN9yZ1uairVwOjkxQwcGY0tLC0Lx6c2KGH3RoXgZ6CIfkT3Yg6mu/YlXe8o19enf/KlCk=
X-Received: by 2002:a05:690c:79b:b0:8a8:8456:a96a with SMTP id
 00721157ae682-8b166c1b380mr51343767b3.28.1793021955912; Mon, 26 Oct 2026
 06:39:15 -0700 (PDT)
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
References: <20261022205357.3239985-1-cel@kernel.org> <CAD37_9jTO0jvrroWzbNWOk0eOj8Otw6rCWE7Ap1kb13OsP+0Wg@mail.gmail.com>
 <68c4df1e-385f-47f7-a387-7176855ab24e@app.fastmail.com>
In-Reply-To: <68c4df1e-385f-47f7-a387-7176855ab24e@app.fastmail.com>
From: Mohammed <mohammed.saad.alquraini@gmail.com>
Date: Mon, 26 Oct 2026 16:39:04 +0300
X-Gm-Features: AclHuK8p0RHg04D9c21GDQTh8D7CNZevBXQp_PnSATTun6qYNGF_e6yf_H_AovY
Message-ID: <CAD37_9iEGXxQJk4WRCLueF1ttY1BW57M9qiUG=oqeEXK3p_J8g@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix use-after-free in svc_age_temp_xprts_now()
To: Chuck Lever <cel@kernel.org>
Cc: NeilBrown <neilb@ownmail.net>, Jeff Layton <jlayton@kernel.org>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Sure thing.

On Mon, Oct 26, 2026 at 4:05=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
>
>
> On Mon, Oct 26, 2026, at 6:30 AM, Mohammed wrote:
> > Hi Chuck,
> >
> > This patch fixes the issue.
> >
> > Thanks for the quick response and fix!
>
> May I add:
>
> Tested-by: Mohammed <mohammed.saad.alquraini@gmail.com>
>
> ?
>
> > Best,
> > Mohammed
> >
> > On Thu, Oct 22, 2026 at 11:54=E2=80=AFPM Chuck Lever <cel@kernel.org> w=
rote:
> >>
> >> svc_age_temp_xprts_now() moves each matching temporary transport
> >> onto a local list under sv_lock, then drops the lock and walks the
> >> local list without holding a reference on any of them. In the
> >> meantime svc_delete_xprt() can take sv_lock, unlink the same
> >> xpt_list node, and drop the transport's last reference. An idle
> >> temporary transport holds only that one reference, so a peer FIN
> >> that arrives between the two loops frees the svc_sock out from under
> >> the second loop. The notifier then sets XPT_CLOSE in freed memory,
> >> and svc_xprt_enqueue() reads xpt_flags and xpt_server from the freed
> >> object and queues that object on a pool for an nfsd thread. KASAN
> >> reports a slab-use-after-free in svc_xprt_enqueue() under
> >> nfsd_inetaddr_event(), with the object freed by svc_sock_free() on
> >> an nfsd thread.
> >>
> >> The two-phase walk dates from when the second loop called into the
> >> socket layer and could sleep. Commit 546125d16142 ("sunrpc: don't
> >> call sleeping functions from the notifier block callbacks") moved
> >> that work to the nfsd threads, so nothing left in the second loop
> >> needs sv_lock dropped. Mark and enqueue each matching transport
> >> under sv_lock in a single pass, as svc_age_temp_xprts() already
> >> does, so that svc_delete_xprt() cannot unlink and free a transport
> >> the notifier is still touching.
> >>
> >> Fixes: c3d4879e01be ("sunrpc: Add a function to close temporary transp=
orts immediately")
> >> Reported-by: Mohammed Alquraini <mohammed.saad.alquraini@gmail.com>
> >> Signed-off-by: Chuck Lever <cel@kernel.org>
> >> ---
> >>  net/sunrpc/svc_xprt.c | 16 ++++------------
> >>  1 file changed, 4 insertions(+), 12 deletions(-)
> >>
> >> Mohammed, thanks for the report. Please test and report your results.
> >>
> >> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> >> index 5db42e53be62..076c624fe675 100644
> >> --- a/net/sunrpc/svc_xprt.c
> >> +++ b/net/sunrpc/svc_xprt.c
> >> @@ -1075,29 +1075,21 @@ void svc_age_temp_xprts_now(struct svc_serv *s=
erv, struct sockaddr *server_addr)
> >>  {
> >>         struct svc_xprt *xprt;
> >>         struct list_head *le, *next;
> >> -       LIST_HEAD(to_be_closed);
> >>
> >>         spin_lock_bh(&serv->sv_lock);
> >>         list_for_each_safe(le, next, &serv->sv_tempsocks) {
> >>                 xprt =3D list_entry(le, struct svc_xprt, xpt_list);
> >> -               if (rpc_cmp_addr(server_addr, (struct sockaddr *)
> >> -                               &xprt->xpt_local)) {
> >> -                       dprintk("svc_age_temp_xprts_now: found %p\n", =
xprt);
> >> -                       list_move(le, &to_be_closed);
> >> -               }
> >> -       }
> >> -       spin_unlock_bh(&serv->sv_lock);
> >> -
> >> -       while (!list_empty(&to_be_closed)) {
> >> -               le =3D to_be_closed.next;
> >> +               if (!rpc_cmp_addr(server_addr, (struct sockaddr *)
> >> +                               &xprt->xpt_local))
> >> +                       continue;
> >>                 list_del_init(le);
> >> -               xprt =3D list_entry(le, struct svc_xprt, xpt_list);
> >>                 set_bit(XPT_CLOSE, &xprt->xpt_flags);
> >>                 set_bit(XPT_KILL_TEMP, &xprt->xpt_flags);
> >>                 dprintk("svc_age_temp_xprts_now: queuing xprt %p for c=
losing\n",
> >>                                 xprt);
> >>                 svc_xprt_enqueue(xprt);
> >>         }
> >> +       spin_unlock_bh(&serv->sv_lock);
> >>  }
> >>  EXPORT_SYMBOL_GPL(svc_age_temp_xprts_now);
> >>
> >> --
> >> 2.54.0
> >>
>
> --
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
