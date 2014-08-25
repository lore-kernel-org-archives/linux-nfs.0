Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:33824 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020AbaHYGPb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2014 02:15:31 -0400
Date: Mon, 25 Aug 2014 16:15:22 +1000
From: NeilBrown <neilb@suse.de>
To: Junxiao Bi <junxiao.bi@oracle.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: rpciod deadlock issue
Message-ID: <20140825161522.3cb91100@notabene.brown>
In-Reply-To: <20140825160501.433b3e9e@notabene.brown>
References: <53F6F772.6020708@oracle.com>
	<20140825160501.433b3e9e@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/VspU=2Y_M5MkdtFfX1ya75n"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/VspU=2Y_M5MkdtFfX1ya75n
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 25 Aug 2014 16:05:01 +1000 NeilBrown <neilb@suse.de> wrote:

> On Fri, 22 Aug 2014 15:55:30 +0800 Junxiao Bi <junxiao.bi@oracle.com> wro=
te:
>=20
> > Hi All,
> >=20
> > I got an nfs hung issue, looks like "rpciod" run into deadlock. Bug is
> > reported on 2.6.32, but seems mainline also suffers this bug from the
> > source code.
> >=20
> > See the following rpciod trace. rpciod allocated memory using GFP_KERNEL
> > in xs_setup_xprt(). That triggered direct reclaim when available memory
> > was not enough, where it waited an write-back page done, but that page
> > was a nfs page, and it depended on rpciod to write back. So this caused
> > a deadlock.
> >=20
> > I am not sure how to fix this issue. Replace GFP_KERNEL with GFP_NOFS in
> > xs_setup_xprt() can fix this trace, but there are other place allocating
> > memory with GFP_KERNEL in rpciod, like
> > xs_tcp_setup_socket()->xs_create_sock()->__sock_create()->sock_alloc(),
> > there is no way to pass GFP_NOFS to network command code. Also mainline
> > has changed to not care ___GFP_FS before waiting page write back done.
> > Upstream commit 5cf02d0 (nfs: skip commit in releasepage if we're
> > freeing memory for fs-related reasons) uses PF_FSTRANS to avoid another
> > deadlock when direct reclaim, i am thinking whether we can check
> > PF_FSTRANS flag in shrink_page_list(), if this flag is set, it will not
> > wait any page write back done? I saw this flag is also used by xfs, not
> > sure whether this will affect xfs.
> >=20
> > Any advices is appreciated.
>=20
> This problem shouldn't affect mainline.
>=20
> Since Linux 3.2, "direct reclaim" never wait for writeback - that is left=
 for
> kswapd to do. (See "A pivotal patch" in https://lwn.net/Articles/595652/)
> So this deadlock cannot happen.

Sorry, that might not quite be right.  That change meant that direct reclaim
would never *initiate* writeout.  It can sometimes wait for it.
Sorry.

NeilBrown

>=20
> Probably the simplest fix for your deadlock would be:
> - in shrink_page_list, clear may_enter_fs if PF_FSTRANS is set.
> - in rpc_async_schedule, set PF_FSTRANS before calling __rpc_execute, and
>   clear it again afterwards.
>=20
> NeilBrown
>=20

--Sig_/VspU=2Y_M5MkdtFfX1ya75n
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU/rUejnsnt1WYoG5AQJjAw/9G51uGxB98lBJgZLDzYwdhr8boZZESxF1
dqh6+pfDoJYZDgbbbdSiGlZUg0rWPDttA2ILInRwVcMNEaNk4zB4dykQL6TcgWtw
27pV3DKVBEMMQSubWrw8v2HitC3mGmKyshvonNL0Z+H+6CvLme1HTIvOb+Nr/1mq
LwF7hYXTWBJkeYqUtkuLRCJFSGj2PtAxAY3gr+JBhsFSV3QYFVMwaYfIBcBur7e2
sAKA3ceqeKJk8MbkIk595HmHgm3UXnr/J/nu8IsZzuEmL3h4lqO5gTiEPUVvwStU
aQXzpTGJHxz4r1Zib93wZTvbYb7uRvJ2Qfr4TjU7UthW1toslQX8gGlIeIErBoUr
nu97HfaFtidxb3El75IzF/uU/VHiobWd9N1MLr9mVDB19R06+409KU5S/Dq72xUb
ndbXT4USItyFfI8+7zlooz19vQxlH72/Yw1g3/ZZLUOKyF+aESqo1LOo3ieawfCC
I3+2leL0gC9apDcpuRA27ykWF5P2t7S7I/rUxFe7W2mM1gQfBzYkqWm2OQjuQucA
YRE292P2aGaZzEM0kxIzu9U0Iu5cebKRk5+7zmcVSwqb5X3y4Tq+0Bf6dOatx41n
vBCiZpTDQpcgED4K19HO/tDDioonmxxLrRVGjIrbo4ZOdOLplNYNoUyqqGslnJPK
ukhZfQPZEIg=
=QhTl
-----END PGP SIGNATURE-----

--Sig_/VspU=2Y_M5MkdtFfX1ya75n--
