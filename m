From: Arjan van de Ven <arjanv@redhat.com>
Subject: Re: [PATCH] lockd
Date: Mon, 04 Oct 2004 20:13:28 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <1096913608.2788.19.camel@laptop.fenrus.com>
References: <41617958.2020406@RedHat.com>
	 <1096912891.22446.67.camel@lade.trondhjem.org>
Reply-To: arjanv@redhat.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-bbUERD0b7L0KH8XJiI75"
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267571AbUJDSOn@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1096912891.22446.67.camel@lade.trondhjem.org>
List-ID: <nfs.lists.sourceforge.net>


--=-bbUERD0b7L0KH8XJiI75
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, 2004-10-04 at 20:01, Trond Myklebust wrote:
> P=C3=A5 m=C3=A5 , 04/10/2004 klokka 18:24, skreiv Steve Dickson:
> > Hey Neil,
> >=20
> > Attached is a patch that fixes some potential SMP races
> > in the lockd code that were identified by the SLEEP_ON_BKLCHECK
> > that was (at one time) in the -mm tree...
>=20
> Just for the record: the "SMP race condition" argument given here is
> completely bogus. sleep_on_* is quite safe to use when the SMP races are
> being handled using the BKL, as is the case here.

actually this triggered because there was NO bkl... if you hold the bkl
the warning doesn't trigger.....



--=-bbUERD0b7L0KH8XJiI75
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBYZLHxULwo51rQBIRApCtAJ9N3iZwDE7HI4iqIijxjY01li+vmQCgn/MP
tcTIP1w2TxyZ1D+k2f8P1P4=
=Dk1d
-----END PGP SIGNATURE-----

--=-bbUERD0b7L0KH8XJiI75--
