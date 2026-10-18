Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CF7B35F5E3
	for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 20:45:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792356356; cv=none; b=aAwWNkzyMPEtDgHszZ9vjWPuiEZugm4qf96a/74VEqYwXSj6/mErfGOJoGwrOdiRKGq62jH4e/yDHsv82xROXzMLvn/l2ZQVo5gc56RzPGlRJiKdR1UaeBt2WrpilwnYMZTSOqoXGQythx2B+TtNwuwqk4ohrMwXea2aedD6arg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792356356; c=relaxed/simple;
	bh=jOBMEOP/PAlTzGnhvm9r/bDO0egyALjQ8pLUTu4xduU=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=r9gRk39iYEafNC7LwYK6G7QN0YyMDCcH+S3c8gNpnVNfg4OYLNp/dvxIhICmPYsR7Z79Ydgc9vaK42dY9/Pd83PpLOMV1WiO9hJ2s9GEy7sQ/NbMShj9gM/5N4r+PDnYh+queaMI8cM7Yl3ejgV0SMff0a59aPKNO1iH2LQIesY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=izFlRjmP; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=UNnSYy9z; arc=none smtp.client-ip=202.12.124.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="izFlRjmP";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="UNnSYy9z"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 734557A0142
	for <linux-nfs@vger.kernel.org>; Sun, 18 Oct 2026 16:45:52 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Sun, 18 Oct 2026 16:45:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1792356352; x=1792442752; bh=CL051/IwMBR8epOZ3ipeSU8+br7sH5TRShd
	AfH3s3vs=; b=izFlRjmPfoURfKnc2mlhIO4jB2R+k6UmqcrGQogzaPWQUNQDlWs
	fy7IfMFSGggUPTkLXYtR+C33t97KC8lMWyaNRHTxzs45wLTOt+Ro4XN8xeZwp6x7
	5jm+QfXZ48FpqokpHBZ2xFcXew/Xr6TPB8NlH6YIukPminh31b3FCtSpj2db5JTw
	w6vYYlOwrYeNZ/sOM4+uyFs0w0pbCMadgerIqrb7h2dS6usptDuABT6mOKH7EhHy
	h9mkkq/FlKHTU9KQFA9wBjIY6BKKEllPU7omqkwrmJ4oIoVfWykCQewqJOSruPMS
	arhytNCwlPpcQsOA92MMHiZ4GfV9eYCiYmQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1792356352; x=
	1792442752; bh=CL051/IwMBR8epOZ3ipeSU8+br7sH5TRShdAfH3s3vs=; b=U
	NnSYy9zN2nkYfHEtzQntyy//xounkGzBd0i/IIuj5FMZ/nrFYzz/nguddhun1kCl
	s4vem7YIo8KbmHUYjIJPhh+yd/h6UcaqJlUPFqQczbh78JFkwJyw4/smPYRDIF2n
	wMhkVuHaD7Z7ewB+GWHnl9/fwwpPwCZS2zZBgxj2x9vnCRUq4Bw6455PHr1W5oIQ
	IWNuMKNaJt0//eZc2FvhptT2NMf6/g73fumSRdHlyIT8cEYyVaOup+AJ2qtk0ZHt
	7x5cabtZTJNjzYQ10aPPrStJbjn4At/RW27A7o+0BPMzSPTRN2BliEHDR2kofbXJ
	psCtCq65BuUhYoc/xy0Dw==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-06;
	repo=github.com/dkim2wg/interop; date=2026-10-08; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792356352; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:TZNicQb3yI0GL5c9ukh0wCrWA9PmzHPzbbvvnLg60dkuezz
	Hdh85bm/r0nmIB/TOCMIEYE+DTQQZPIMGqdifZ9ENs4sChGWCaet6k0FZQZUzHEm
	Obd207tXAMnPOJHN25zS+vaZj4N767GQ5RD+UCzyRDT+oEtwBBRJv0oEaCKQ3mNC
	sXjKj3PFP6xkHfLn3I6n/679IKAbEJQ63773xOd+GwWahwuU3OmBiqGk3I169BL/
	ss414i7eLFaXh82o/NoOjMbX8bIDpmnhMU6DPmIqOuNcxiFyCVjh41DyyEEZJOlK
	5+NB46waoEfgpanyqZA6Ydt0Pf1Du1/Jyzey3Xg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-06;
	repo=github.com/dkim2wg/interop; date=2026-10-08; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:m/zaef+hacF4bhoJieFwitJT++vqpv09fahZnb2symk=:jOBMEOP/PAlTzGnhvm9r/bDO0egyALjQ8pLUTu4xduU=;
X-ME-Sender: <xms:_y_Vap1JeXj-3w6cXGFihAl92ecv093TfI8611L0FiAaJXuEd_slEQ>
    <xme:_y_Var84aD3uyFWOOBAjcjs6Wt8wgfGZgf3ANdxjirLfM1v7RFT5lL2I99xeB1Auu
    YjzHiWs4DMOn8vEL9rcQjd_-91dn2f-1UxRN7hwu9hixd1O7g>
X-ME-Received: <xmr:_y_Vam7eOoosoSu5oSE4c9Wug_xLmvpcN3_f41WEbd_yzQbwF-RDgT8-REE2ETfibqWxVm_PrTzPC4qTW4KIbJjtXFrcPmg>
X-ME-Proxy-Cause: dmFkZTFECpY9M9UWM0stSSHWUlcugPteC7xF1kHuUOu15yqKQpxIQPQWsChTppyCXsGHNp
    RaQ3cVmcOkV+F16/VwJXpOuD6HDEIdGAakWA9w8tSsBT+NqWuVYR6zZFtv5ZiRJ4qyHme1
    AukhphtAl2lTKGfWr7iSZkdyo0lH8gnCbyjyDm5uYLiwn+jWvULabGO++gEZRn8K6tQg0T
    S5zLGLzluA7AJ/xnYn7K4ZOE3w4aDwvNtU/XKni3l6QMc6kjh1tLcy+QDp1VIVZn7DieHh
    NmQm5NzRR/TQr81Nojl5X5kUIXwEfQ7nVYLFlt5RcAtE5+B5/4fU/WtsPqdmbS4htOjMS5
    q8bJf+FFwf3MI4FMs7E4HJ8PjATHIgkd2Lp23IRiadlxBUO9zq8+ciSvoAHodeJFAcaV+J
    zroFLZjMMaotejok6ddzJq9YK1w6uNLo1qBOnBqc8oo3JjpBByfDzRNmAlWFUn7Q1tW7OB
    ytbTKImsYpdQXEmgfbCFuUoUgWxoy52jFHAvaCGlr/vM/J6tVqrS/Uo5k+AEjeWJv+JnPU
    VmsmRFVEpc5krPTeKZqvV+5jIld7luzTUWF0oSASmuIjQwRLP4yvkkVZSFdA0BSCsuPCzP
    zBbqu3B1paTxqC6KbtFTQJD0EVEB8W7uMPFum1d7JrjoHQ1mo9Rkd9oky5Yg
X-ME-Proxy: <xmx:_y_VarvzgO0OHWC1fPr34DwaQux7r5LbYDNJWjmB8s0Ppr-parqAyg>
    <xmx:_y_Vag0Cl53HW2sJhGX3KA0AFU4aRRGOTmNpkMk9hturEvN7WLgavQ>
    <xmx:_y_VasrKzSHTx1T4878Ue2X3z0yC20jKgKpVwX0rUMEZ-NXicA-HOg>
    <xmx:_y_VaoJqk61-DPjV7NAQ381zQ4561MkJAfG27jyODMqs63upbgC5Sw>
    <xmx:ADDVakHEkl6IS8hQXbgOeQmzmEIf62eY0fYKWet7yhfSBcQ0MM9K4Zsp>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 18 Oct 2026 16:45:48 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Deepanshu Kartikey" <kartikey406@gmail.com>, cel@kernel.org,
 okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com, bfields@fieldses.org,
 skinsbursky@parallels.com, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org,
 syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
Subject: Re: [PATCH] nfsd: fix out-of-bounds read of sv_permsocks when
 starting a thread
In-reply-to: <c19a047cc3abde3ee342cf4188620e70ab51b429.camel@kernel.org>
References: <20261018113312.10455-1-kartikey406@gmail.com>
  <c19a047cc3abde3ee342cf4188620e70ab51b429.camel@kernel.org>
Date: Mon, 19 Oct 2026 07:45:44 +1100
Message-id: <179235634403.1724252.2120669689990867061@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sun, 18 Oct 2026, Jeff Layton wrote:
> On Sun, 2026-10-18 at 17:03 +0530, Deepanshu Kartikey wrote:
> > nfsd() derives its struct net from the first entry of
> > serv->sv_permsocks using list_entry() without checking that the list
> > is non-empty. If the list is empty, list_entry() returns a bogus
> > svc_xprt computed from the list head embedded in struct svc_serv, and
> > the following perm_sock->xpt_net load reads far past the end of the
> > svc_serv allocation:
> >=20
> >   BUG: KASAN: slab-out-of-bounds in nfsd+0x118/0xbc0 fs/nfsd/nfssvc.c:894
> >   Read of size 8 at addr ffff88802d423f50 by task nfsd/5988
> >=20
> > The list can be empty because nothing guarantees that a permanent
> > listener exists while a thread starts. With dynamic thread spawning, a
> > thread can begin running after the last listener has been closed and
> > removed.
> >=20
> > Take sv_lock, which protects sv_permsocks, and check for an empty list
> > and read xpt_net in the same critical section. If there is no
> > permanent socket, report -ENOTCONN through svc_thread_init_status(),
> > which wakes the creator and exits the thread, instead of dereferencing
> > a bogus pointer.
> >=20
> > Fixes: 88c476661719 ("nfsd: pass proper net to nfsd_destroy() from NFSd k=
threads")
> > Reported-by: syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
> > Closes: https://syzkaller.appspot.com/bug?extid=3D561b859d032c8bf2fb53
> > Tested-by: syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com
> > Signed-off-by: Deepanshu Kartikey <kartikey406@gmail.com>
> > ---
> >  fs/nfsd/nfssvc.c | 22 ++++++++++++++++++----
> >  1 file changed, 18 insertions(+), 4 deletions(-)
> >=20
> > diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> > index 2edf716ea022..da6fce79efae 100644
> > --- a/fs/nfsd/nfssvc.c
> > +++ b/fs/nfsd/nfssvc.c
> > @@ -890,17 +890,31 @@ nfsd(void *vrqstp)
> >  {
> >  	struct svc_rqst *rqstp =3D (struct svc_rqst *) vrqstp;
> >  	struct svc_pool *pool =3D rqstp->rq_pool;
> > -	struct svc_xprt *perm_sock =3D list_entry(rqstp->rq_server->sv_permsock=
s.next, typeof(struct svc_xprt), xpt_list);
> > -	struct net *net =3D perm_sock->xpt_net;
> > -	struct nfsd_net *nn =3D net_generic(net, nfsd_net_id);
> > +	struct svc_serv *serv =3D rqstp->rq_server;
> > +	struct svc_xprt *perm_sock;
> > +	struct net *net =3D NULL;
> > +	struct nfsd_net *nn =3D NULL;
> >  	struct nfsd_thread_local_info ntli =3D { };
> >  	bool have_mutex =3D false;
> > +	int err =3D 0;
> > +
> > +	spin_lock_bh(&serv->sv_lock);
> > +	if (list_empty(&serv->sv_permsocks)) {
> > +		err =3D -ENOTCONN;
> > +	} else {
> > +		perm_sock =3D list_first_entry(&serv->sv_permsocks,
> > +					     struct svc_xprt, xpt_list);
> > +		net =3D perm_sock->xpt_net;
> > +	}
> > +	spin_unlock_bh(&serv->sv_lock);
> >=20
> >=20
>=20
> There is another way to get to the nfsd_net here. It turns out that the
> sv_stats field for nfsd always points to the one embedded in nfsd_net,
> so we could avoid the socket lists altogether by just doing something
> like:
>=20
>   struct nfsd_net *nn =3D container_of(rqstp->rq_server->sv_stats,
>                                    struct nfsd_net, nfsd_svcstats);
>=20
> That avoids the extra locking, but it seems a little weird to depend on
> the sv_stats field. Maybe we could wrap that in a little helper or
> something to make it less ugly?
>=20
> An alternative would be to add a serv->sv_net field, but most services
> are not per-net. nfsd is the exception so it's the only one that would
> use it.

Most services don't use svc_create_pooled() either - only nfsd.
I would add a 'struct net*' arg to svc_create_pooled() and
store it in serv->sv_net as you suggest.

Thanks,
NeilBrown

>=20
> > =20
> > +	if (!err)
> > +		nn =3D net_generic(net, nfsd_net_id);
> >  	/* At this point, the thread shares current->fs
> >  	 * with the init process. We need to create files with the
> >  	 * umask as defined by the client instead of init's umask.
> >  	 */
> > -	svc_thread_init_status(rqstp, unshare_fs_struct());
> > +	svc_thread_init_status(rqstp, err ?: unshare_fs_struct());
> > =20
> >  	current->fs->umask =3D 0;
> > =20
>=20
> --=20
> Jeff Layton <jlayton@kernel.org>
>=20
>=20

