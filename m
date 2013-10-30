Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:34170 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994Ab3J3GDE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Oct 2013 02:03:04 -0400
Date: Wed, 30 Oct 2013 17:02:50 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] - hard-to-hit race in xprtsock.
Message-ID: <20131030170250.702da2c3@notabene.brown>
In-Reply-To: <1383058955.7805.2.camel@leira.trondhjem.org>
References: <20131029174204.7f6578d4@notabene.brown>
	<1383058955.7805.2.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/bDMwxvuzssfzXW//ESUa=AJ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/bDMwxvuzssfzXW//ESUa=AJ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 29 Oct 2013 15:02:36 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-10-29 at 17:42 +1100, NeilBrown wrote:
> > We have a customer who hit a rare race in sunrpc (in a 3.0 based kernel,
> > but the relevant code doesn't seem to have changed much).
> >=20
> > The thread that crashed was in=20
> >   xs_tcp_setup_socket -> inet_stream_connect -> lock_sock_nested.
> >=20
> > 'sock' in this last function is NULL.
> >=20
> > The only way I can imagine this happening is if some other thread called
> >=20
> >  xs_close -> xs_reset_transport -> sock_release -> inet_release
> >=20
> > in a very small window a moment earlier.
> >=20
> > As far as I can tell, xs_close is only called with XPRT_LOCKED set.
> >=20
> > xs_tcp_setup_socket is mostly scheduled with XPRT_LOCKED set to which w=
ould
> > exclude them from running at the same time.
> >=20
> >=20
> > However xs_tcp_schedule_linger_timeout can schedule the thread which ru=
ns
> > xs_tcp_setup_socket without first claiming XPRT_LOCKED.
> > So I assume that is what is happening.
> >=20
> > I imagine some race between the client closing the socket, and getting
> > TCP_FIN_WAIT1 from the server and somehow the two threads racing.
> >=20
> > I wonder if it might make sense to always abort 'connect_worker' in
> > xs_close()?
> > I think the connect_worker really mustn't be running or queued at this =
point,
> > so cancelling it is either a no-op, or vitally important.
> >=20
> > So: does the following patch seem reasonable?  If so I'll submit it pro=
perly
> > with a coherent description etc.
>=20
> Hi Neil,
>=20
> Will that do the right thing if the connect_worker and close are running
> on the same rpciod thread? I think it should, but I never manage to keep
> 100% up to date with the ever changing semantics of
> cancel_delayed_work_sync() and friends...
>=20
> Cheers,
>   Trond

Thanks for asking that!  I had the exact same concern when I first conceived
the patch.

I managed to convince my self that there wasn't a problem as long as
xs_tcp_setup_socket never called into xs_close.
Otherwise the worst case is that one thread running xs_close could block
while some other thread runs xs_{tcp,udp}_setup_socket.

Thanks,
NeilBrown

--Sig_/bDMwxvuzssfzXW//ESUa=AJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUnChCjnsnt1WYoG5AQJa+Q/+KBgpREcsVdM2/76sCWFXDwKq+1Vs72TM
RJITXM89LhW9ouTTOFBL2ielEek7jutgJi769wfLpqNJj8jM8j2xDlwTrhCMcO3/
yikAcZ2DCXF2Mslul5hq9zVL6LLbVNqHSxRVWd0iJAA19SkHktcDriyIcCUGtCHF
OJ+gDWN3yZaRrkyIDztm9X11PSgcAuNVtAdu58/HsUESnv5MqRn6ledfz/5lOTp5
To9cawXXWVPfM2I/WYKs6D8aWbri7BVod9jclTKd5DwioaswqUKertr/iA3+0qQ8
4LVIPP/7cg7KILPYrLQ3DlkC9j54H3EdX2OSlxxcu/K+Bkflaq3LOyEurAKPHUNL
760S7ZVKy5scO8X7/AtVUUG3JtPrJVnfyApx5AdNWg/1wDHZLKAfI40roG/3RP0E
JXg9qNIwHhRbGy9/nmekBe6Aj/oOD2LDT8SeG914bLsFCyKWGAfDh4jmzZd9WqcR
joFA3szM6aoboSBKLJ+a+OH2dL2vz80AbVfaxbguAVQqWCn/AJI7tWsoWXPdh1ai
RqEokzc/0ttIUtBaUtr+h4n+lhYorFYxO9/9nj9PZFSRToaIcKuO+6g2Nplo6Yv2
sBOpJMRwBKyGcK2n1O+rzez0JZ6EjjZ5t4gQ6NZpeMkM5L3ssHx0iB+EnY9Q7aak
ps2caP1in+k=
=wVEK
-----END PGP SIGNATURE-----

--Sig_/bDMwxvuzssfzXW//ESUa=AJ--
