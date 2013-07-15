Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:51058 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753707Ab3GOFCk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jul 2013 01:02:40 -0400
Date: Mon, 15 Jul 2013 15:02:29 +1000
From: NeilBrown <neilb@suse.de>
To: Jim Rees <rees@umich.edu>
Cc: "J.Bruce Fields" <bfields@citi.umich.edu>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130715150229.06ff8464@notabene.brown>
In-Reply-To: <20130715012620.GC7429@umich.edu>
References: <20130710092255.0240a36d@notabene.brown>
	<20130710022735.GI8281@fieldses.org>
	<20130715012620.GC7429@umich.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/=Pdre+4TxcP.rUD+UmUTqHX"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/=Pdre+4TxcP.rUD+UmUTqHX
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 14 Jul 2013 21:26:20 -0400 Jim Rees <rees@umich.edu> wrote:

> J.Bruce Fields wrote:
>=20
>   On Wed, Jul 10, 2013 at 09:22:55AM +1000, NeilBrown wrote:
>   >=20
>   > Hi,
>   >  I just noticed this commit:
>   >=20
>   > commit 9660439861aa8dbd5e2b8087f33e20760c2c9afc
>   > Author: Olga Kornievskaia <aglo@citi.umich.edu>
>   > Date:   Tue Oct 21 14:13:47 2008 -0400
>   >=20
>   >     svcrpc: take advantage of tcp autotuning
>   >=20
>   >=20
>   > which I must confess surprised me.  I wonder if the full implications=
 of
>   > removing that functionality were understood.
>   >=20
>   > Previously nfsd would set the transmit buffer space for a connection =
to
>   > ensure there is plenty to hold all replies.  Now it doesn't.
>   >=20
>   > nfsd refuses to accept a request if there isn't enough space in the t=
ransmit
>   > buffer to send a reply.  This is important to ensure that each reply =
gets
>   > sent atomically without blocking and there is no risk of replies gett=
ing
>   > interleaved.
>   >=20
>   > The server starts out with a large estimate of the reply space (1M) a=
nd for
>   > NFSv3 and v2 it quickly adjusts this down to something realistic.  Fo=
r NFSv4
>   > it is much harder to estimate the space needed so it just assumes eve=
ry
>   > reply will require 1M of space.
>   >=20
>   > This means that with NFSv4, as soon as you have enough concurrent req=
uests
>   > such that 1M each reserves all of whatever window size was auto-tuned=
, new
>   > requests on that connection will be ignored.
>   >
>   > This could significantly limit the amount of parallelism that can be =
achieved
>   > for a single TCP connection (and given that the Linux client strongly=
 prefers
>   > a single connection now, this could become more of an issue).
>  =20
>   Worse, I believe it can deadlock completely if the transmit buffer
>   shrinks too far, and people really have run into this:
>=20
> It's been a few years since I looked at this, but are you sure autotuning
> reduces the buffer space available on the sending socket? That doesn't so=
und
> like correct behavior to me. I know we thought about this at the time.

Autotuning is enabled when SOCK_SNDBUF_LOCK is not set in sk_userlocks.

One of the main effects of this flag is to disable:

static inline void sk_stream_moderate_sndbuf(struct sock *sk)
{
	if (!(sk->sk_userlocks & SOCK_SNDBUF_LOCK)) {
		sk->sk_sndbuf =3D min(sk->sk_sndbuf, sk->sk_wmem_queued >> 1);
		sk->sk_sndbuf =3D max(sk->sk_sndbuf, SOCK_MIN_SNDBUF);
	}
}


which will reduce sk_sndbuf to half the queued writes. As sk_wmem_queued
cannot grow above sk_sndbuf, the definitely reduces sk_sndbuf (though never
below SOCK_MIN_SNDBUF which is 2K.

This seems to happen under memory pressure (sk_stream_alloc_skb).

So yes: memory pressure can reduce the sndbuf size when autotuning is enabl=
ed, and it
can get as low as 2K.
(An API to set this minimum to e.g. 2M for nfsd connections would be an alt=
ernate
fix for the deadlock, as Bruce has already mentioned).

>=20
> It does seem like a bug that we don't multiply the needed send buffer spa=
ce
> by the number of threads. I think that's because we don't know how many
> threads there are going to be in svc_setup_socket()?

We used to, but it turned out to be too small in practice!  As it auto-grow=
s,
the "4 * serv->sv_max_mesg" setting is big enough ... if only it wouldn't
shrink below that.

NeilBrown

--Sig_/=Pdre+4TxcP.rUD+UmUTqHX
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUeOCZTnsnt1WYoG5AQIQkg/8CxXZefc72De8gXhFjUkoG44KTER1vJkt
Jg91d0CPO8kfNcirgHdx8Y048vesLCC1bgYblsO9gGh96EftGk+icXVKUtT6VGTG
lE0D/dAl5loexfXDS8epAC6UHA9t/rRYwF8Q4tbBIh4xbZXtYyyxVixlQR6KlEGy
aMTAtsSkbnFyjJIm8zlBmZlSQ9i9pF3Qqam9fH7+aBONhIp6USoS0DhfRqemMFOw
n9UVUY5Fscq34Ww/fTSO5kyfjaFNaLDarLHPq/wYS+SOb1kDNWvuBlIVUsffbO0I
V0mfb9FBzA2tDRfK/6aJ8hVgbNXYp7rZekb2x0k47qqiSdGNt8Elyv6DMNubGLGj
HsifzTeZTuSljZLvCLWGAyn47LE2wbz9J9a59u2XjyyJvDnBWvbknxDXxgwI5pop
v5jA3jxaQ4sQcym+oYWaZQVHYOmWmBR0gITDvJD94wNueUqjx24ZrwpTk+VW6jzt
RPZiA2omAEl5L/ffR2/7zBJecDEeJ2N2WT21R/pWbgW2FpDBcyecCDMDZcit058a
TFgJeBVNgKmewFf2l27cWvv4aTzIqNNZjHsFNJkHj2zJE0gOO5iQ5Gz7zgSN43SW
HcHgtUTM+APDsUkIXDPwI9P5shvQP7geGTemsJZqk2+jpPMXL5nVA5feRwtLW5AO
E4T937wFHZM=
=DFza
-----END PGP SIGNATURE-----

--Sig_/=Pdre+4TxcP.rUD+UmUTqHX--
