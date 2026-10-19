Received: from mail-yw1-f179.google.com (mail-yw1-f179.google.com [209.85.128.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0057225DB0D
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 00:40:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.128.179
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792370435; cv=pass; b=Af5TFwBzEsGDCLWyq9J84szfPtvKazn079Bq/hZGy1RjEp4DKTqrjoHafRFYvbpTPUpOVxcKUUbgl4HYxS4pkMPnQ5qwZ0KJl2SuzsvlsjoyHJC6HSKHbSy+MUmKSgMthiTgxIsdLmjtvExx5rS8uFClOwQe5iAUGY3lQJlL88o=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792370435; c=relaxed/simple;
	bh=4mT1f/FkgEWZvx3hboa1SfVZRjzrNNR4fyTa9aEM4sI=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=IIPQH0vVF737vBqtUCbN6SS0jpkohQTLX/qLmYHzTH1MNZwr1xxZ9qd/8WoDwCYWkbBKLvGAlUimV/2nUG9Cjb36MAk18oLzxQXcuhtrRT9oG/aq+TXLMohWH0Jo4t1ELHss9uea5YJxrGpZF1sHnhGWvWnnwqgsB2gGTWO3uDw=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=OYJKSytx; arc=pass smtp.client-ip=209.85.128.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OYJKSytx"
Received: by mail-yw1-f179.google.com with SMTP id 00721157ae682-8ab38a051aaso11672447b3.3
        for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 17:40:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1792370433; cv=none;
        d=google.com; s=arc-20260327;
        b=RkojO9LNFLBCVeqvZ3bdMEDUAPv8hUtoE0/3Nh84aP7mBoXSmySIYg5a/TkUEg4WtE
         OKfxmE+04Y3MUkANeEXTHdmv5KrVd2Kdwua6ATWZde0IEcdB+wA7xJWirdyr/sW8ypMN
         veD4cE1lWgTexXpNDvzu/Kdp4E+4pT6FwEGxcAl26gfYzULaj/p92dKrDUjLjmpf1wLN
         rW9ezs/OATu599vqrsXW1oaVbziHFWPp2BIj/DQBJdQz1lYPGWtKVP5yQh9S4ozhj2Zc
         9ev1cy+sxFfCJ1Jsr4zq/CmRgiPIsLv2cca3cTBxnAoBcW3Wd0mOoceZ9FIfehDDN9HU
         GDPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=hWed0IDwBI9tkyg2fqDRId8vpQroFOJCTY18+5ctqrw=;
        fh=l3xp59NS9dyi34k1icKHNYF8EwOKBsNP7WjMtCHDUzw=;
        b=C/g+PMJitHcjVhIbL9bFvSjg8i4YSLvJtbTVtiPgxCEZ6HKybeRKGOjbGw39SjqrKF
         LEDfQ+14RVvB6/6e+fGoqr09z8zGst7UOSneMOkE8f6QXhOMtlBKSusMbrOjX00JSXWz
         nUoHIBz7oQvJYyycznuSkiYXFpCO9LnqMA8fDW9aEJ6E2acRkvBwT0vtxKEt5JYE3KF0
         d5ocZ87j5tp3HZexLaF6P6Db7VAlhg1aBkIYG1fGB5Cu2pGeqBCrU9FJWeaunNaQqjp2
         c8ON5J/aFD4/j3QzYmoNSP51ciibxqko2WifL+SlbYq5lvPTu9W2uLY49dTBYfV3LYEs
         Iv0A==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792370433; x=1792975233; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=hWed0IDwBI9tkyg2fqDRId8vpQroFOJCTY18+5ctqrw=;
        b=OYJKSytx6PpRGJajfOHJjiBvryNaJZL7vmQfIoEUGjrEKY//JOXcA7g2nm20q/yQ0q
         L/iTKkfJT8cC9FZafiMKGhi6uPU5nzRDP92mSgGjhzQaf+cwwH+kLbA5aFXYlz7SBUtr
         hgbWTKlX+DzlJ5aD/5op9qxlckif9czwaKGwR9/e3cM1gaBHpa6KQxM/wablbxZ2Eeh4
         jK+nLHV9EnLxk9IEz/uWycPq4iU+1WsOnOr6DLHJ7XUxZeGIPcZc+E3Lf8XT3OJU32gf
         aSXXQbn34UMOwVUJHx8todlBpaQBcwcIFPw1d8nyJPnJ3RcKbGj/ss9iZdT7kXWlLUT0
         IE+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792370433; x=1792975233;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=hWed0IDwBI9tkyg2fqDRId8vpQroFOJCTY18+5ctqrw=;
        b=wIXe2NMTUTLD8PqOZs+tB4SyPskdAy3uIyOnDXQKBg9uZCmGXldgpGJquMxt5Vhg+c
         BgTW11gnWmKLBfSBl4e4pBohqiwwqRxn4B13HGYyxm5FQEMxSBIB887Fl1sxSIeOdSHQ
         5m9bYbaPeRprw2zhdhanC4Kq6lPP17oN4/V34N9EOtzfD84t0YXyq4IKa9kY4ivI/prZ
         8fvaZsBGq2x6obbujPaYxYFgo+NScYZfuz0FulbHkNYQXkt81W8sCo7bbauxdyL5Bc0W
         MFPemg1B2ZRAeFTbviWQB68cAsH+GQuxw6krEWmmMNxwa99vp54/Zz53GBQcGatd6jq7
         vCBw==
X-Forwarded-Encrypted: i=1; AKwUvByhzJywfqFqaOlE/eHF2vrfBeop/umj+R4daDbsyaWzV3Bb3dRUXVoIbGMfJUovwQwHV74YsykWKEE=@vger.kernel.org
X-Gm-Message-State: AFq9FYKuLdyrQUlZaSC3SmEjfmwKWTadXtKeeMGsKMfcPSoQknAUtHHK
	lDet19F6jBWJj+uJ4hkaT8UjIbEM/1E29iNSNtIVoZJuxhz+AXO7JGDzNOz9M61+PoyTxNDmL3b
	Iqf8sUC82WHw/N8s4d7056WUzQXO+sik=
X-Gm-Gg: AYBFou3PqVtZ1nOlhMjh1+hDjZNZeX6i3Sxgg3hhGNAn44VD7I42ERkayJf9vOWFCjh
	LXNOSexx8xi3OPPIzK7r3VkgBTS5Nn5mWJ72a2arBggMIbk0fabAxh3lTwfJDBA9akxci0OcxBA
	BRsy5i8b8W1GUOTZ8juhtL1h8ZAyzKR33nfo1NeULAQBzlfWCIk58WEJ2n1L5bU/dx4qg9Z7Wlc
	q26fsEzthxAZk+fSbvf5OueWylFeOf5rW6scRzmGDU/jSZfBqLzrSMDr0xeCwdzrs1l5Twzth1u
	jN4gm2FhHUS4GKLcZRqvGgJYYcEHmwV1EevvlH9t2Vu2Du2tn7lMn520L9w6UCD6b/g8asnHDQz
	C5W5EKTkZpusdn4N7eFpIJd3YGMeMNHPL8baTL7jldozv
X-Received: by 2002:a05:690c:47ca:b0:8b0:cc24:f7b8 with SMTP id
 00721157ae682-8b0f2245744mr13155427b3.69.1792370432796; Sun, 18 Oct 2026
 17:40:32 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20261018113312.10455-1-kartikey406@gmail.com> <c19a047cc3abde3ee342cf4188620e70ab51b429.camel@kernel.org>
 <179235634403.1724252.2120669689990867061@noble.neil.brown.name>
In-Reply-To: <179235634403.1724252.2120669689990867061@noble.neil.brown.name>
From: Deepanshu Kartikey <kartikey406@gmail.com>
Date: Mon, 19 Oct 2026 06:10:20 +0530
X-Gm-Features: AclHuK-k7bBUnVWcQDeP4Fon2Hb1aX5pEUZH9n4MT7krgkcfy_LsGVwYyWucUSo
Message-ID: <CADhLXY4Gv6tt5xXsGZt=h1gyRwxcsAy3G50=_9=vbk4GrkJafg@mail.gmail.com>
Subject: Re: [PATCH] nfsd: fix out-of-bounds read of sv_permsocks when
 starting a thread
To: NeilBrown <neil@brown.name>
Cc: Jeff Layton <jlayton@kernel.org>, cel@kernel.org, okorniev@redhat.com, 
	Dai.Ngo@oracle.com, tom@talpey.com, bfields@fieldses.org, 
	skinsbursky@parallels.com, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, 
	syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 19, 2026 at 2:15=E2=80=AFAM NeilBrown <neilb@ownmail.net> wrote=
:
>
> On Sun, 18 Oct 2026, Jeff Layton wrote:
> > On Sun, 2026-10-18 at 17:03 +0530, Deepanshu Kartikey wrote:
> > > nfsd() derives its struct net from the first entry of
> > > serv->sv_permsocks using list_entry() without checking that the list
> > > is non-empty. If the list is empty, list_entry() returns a bogus
> > > svc_xprt computed from the list head embedded in struct svc_serv, and
> > > the following perm_sock->xpt_net load reads far past the end of the
> > > svc_serv allocation:
> > >
> > >   BUG: KASAN: slab-out-of-bounds in nfsd+0x118/0xbc0 fs/nfsd/nfssvc.c=
:894
> > >   Read of size 8 at addr ffff88802d423f50 by task nfsd/5988
> > >
> > > The list can be empty because nothing guarantees that a permanent
> > > listener exists while a thread starts. With dynamic thread spawning, =
a
> > > thread can begin running after the last listener has been closed and
> > > removed.
> > >
> > > Take sv_lock, which protects sv_permsocks, and check for an empty lis=
t
> > > and read xpt_net in the same critical section. If there is no
> > > permanent socket, report -ENOTCONN through svc_thread_init_status(),
> > > which wakes the creator and exits the thread, instead of dereferencin=
g
> > > a bogus pointer.
> > >
> > > Fixes: 88c476661719 ("nfsd: pass proper net to nfsd_destroy() from NF=
Sd kthreads")
> > > Reported-by: syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
> > > Closes: https://syzkaller.appspot.com/bug?extid=3D561b859d032c8bf2fb5=
3
> > > Tested-by: syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
> > > Signed-off-by: Deepanshu Kartikey <kartikey406@gmail.com>
> > > ---
> > >  fs/nfsd/nfssvc.c | 22 ++++++++++++++++++----
> > >  1 file changed, 18 insertions(+), 4 deletions(-)
> > >
> > > diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> > > index 2edf716ea022..da6fce79efae 100644
> > > --- a/fs/nfsd/nfssvc.c
> > > +++ b/fs/nfsd/nfssvc.c
> > > @@ -890,17 +890,31 @@ nfsd(void *vrqstp)
> > >  {
> > >     struct svc_rqst *rqstp =3D (struct svc_rqst *) vrqstp;
> > >     struct svc_pool *pool =3D rqstp->rq_pool;
> > > -   struct svc_xprt *perm_sock =3D list_entry(rqstp->rq_server->sv_pe=
rmsocks.next, typeof(struct svc_xprt), xpt_list);
> > > -   struct net *net =3D perm_sock->xpt_net;
> > > -   struct nfsd_net *nn =3D net_generic(net, nfsd_net_id);
> > > +   struct svc_serv *serv =3D rqstp->rq_server;
> > > +   struct svc_xprt *perm_sock;
> > > +   struct net *net =3D NULL;
> > > +   struct nfsd_net *nn =3D NULL;
> > >     struct nfsd_thread_local_info ntli =3D { };
> > >     bool have_mutex =3D false;
> > > +   int err =3D 0;
> > > +
> > > +   spin_lock_bh(&serv->sv_lock);
> > > +   if (list_empty(&serv->sv_permsocks)) {
> > > +           err =3D -ENOTCONN;
> > > +   } else {
> > > +           perm_sock =3D list_first_entry(&serv->sv_permsocks,
> > > +                                        struct svc_xprt, xpt_list);
> > > +           net =3D perm_sock->xpt_net;
> > > +   }
> > > +   spin_unlock_bh(&serv->sv_lock);
> > >
> > >
> >
> > There is another way to get to the nfsd_net here. It turns out that the
> > sv_stats field for nfsd always points to the one embedded in nfsd_net,
> > so we could avoid the socket lists altogether by just doing something
> > like:
> >
> >   struct nfsd_net *nn =3D container_of(rqstp->rq_server->sv_stats,
> >                                    struct nfsd_net, nfsd_svcstats);
> >
> > That avoids the extra locking, but it seems a little weird to depend on
> > the sv_stats field. Maybe we could wrap that in a little helper or
> > something to make it less ugly?
> >
> > An alternative would be to add a serv->sv_net field, but most services
> > are not per-net. nfsd is the exception so it's the only one that would
> > use it.
>
> Most services don't use svc_create_pooled() either - only nfsd.
> I would add a 'struct net*' arg to svc_create_pooled() and
> store it in serv->sv_net as you suggest.
>
> Thanks,
> NeilBrown
>
> >
> > >
> > > +   if (!err)
> > > +           nn =3D net_generic(net, nfsd_net_id);
> > >     /* At this point, the thread shares current->fs
> > >      * with the init process. We need to create files with the
> > >      * umask as defined by the client instead of init's umask.
> > >      */
> > > -   svc_thread_init_status(rqstp, unshare_fs_struct());
> > > +   svc_thread_init_status(rqstp, err ?: unshare_fs_struct());
> > >
> > >     current->fs->umask =3D 0;
> > >
> >
> > --
> > Jeff Layton <jlayton@kernel.org>
> >
> >
>


Thanks Jeff and Neil, for the review. I will make the changes and
submit patch v2 shortly.

Thanks

Deepanshu
