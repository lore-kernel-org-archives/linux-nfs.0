Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:33514 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbbGJPTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 11:19:03 -0400
Received: by ykeo3 with SMTP id o3so145013530yke.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 08:19:03 -0700 (PDT)
Date: Fri, 10 Jul 2015 11:18:52 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: William Dauchy <william@gandi.net>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>, jloup@gandi.net,
        Jean Spector <jean@primarydata.com>
Subject: Re: extra reference to fl->fl_file, possible regression
Message-ID: <20150710111852.7f666ba1@tlielax.poochiereds.net>
In-Reply-To: <20150710150659.GP15144@gandi.net>
References: <20150710092910.GI15144@gandi.net>
	<20150710072438.08b3417a@tlielax.poochiereds.net>
	<20150710125444.GL15144@gandi.net>
	<20150710103914.78189580@tlielax.poochiereds.net>
	<20150710150659.GP15144@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/P3ha9kDaVRA_gIck2qmHJ=v"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/P3ha9kDaVRA_gIck2qmHJ=v
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 10 Jul 2015 17:06:59 +0200
William Dauchy <william@gandi.net> wrote:

> On Jul10 10:39, Jeff Layton wrote:
> > So if a file happened to have some flock locks on it, then we could
> > be taking a new reference to a file that has already had its refcount
> > go to zero.
>=20
> do you have any test case which may confirm that?

Not right offhand, at least not with a stock kernel.

I was planning to turn that get_file call into an
atomic_long_inc_return and then test the return value and WARN if it
was 1. Then, set a flock lock on a file, and close it without
explicitly unlocking. I suspect that would make the WARN pop.

> in the commit messages, you also were refering to some tests; I wonder
> if you could share it.

Jean? Are those tests something you could share?

--=20
Jeff Layton <jlayton@poochiereds.net>

--Sig_/P3ha9kDaVRA_gIck2qmHJ=v
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVn+JcAAoJEAAOaEEZVoIVUrAP/R7DqBOQ3kRmlORlVMJqE2hz
qkIebEY7QeN1O+9Beb8BFJV+Yi9CyOArOv5P83JPK5PpKIMvIJ0l5wooTVdnFpZw
zeeEzWVJM0sGfH6EYFi4SgofbvhlCW7qp7esS7R/rxQfDLFzF/Q9/15l+OnG4ppZ
m39YknXdhJOWBIn6f27Qz+e7cVLkwYU1lC6jmZOJBsFWpe5qMSVmRCSXGZZLGhHP
PJ6sTCUn/2WaMeetLFrLzl2DX8tjZuqXTgy+oAztxXGFddWCF2j1r8XlwcsvbkeH
WmCUQ6qTzjmqR7YOecgorPO+MwSpTqn7oiT9yYamHmNWFVqyXryujEEQ9ikBU000
gt/NBxiTAorpzgMjFw4fxEEbWLsJ4kJg1QAP7DELmjDCCqaqcSMVslPgl9pk1U+N
o4lWCP5R2t6cVU/ItCP5yyOlHCdTJBrjZn3qMf1wJV2Us3Jd0fu6dnBz++sp8Zm+
zgx397+7Qy0Ekq1TuM/fxIPNrdgNlO6dt43nV8u3zhP9si47xJaV/4cPwE8im3QB
bN70DBFXm9x9rAF6aw8z3NbJBEToxDxea9PkDm5frybnpvsv8zyEopecFlQPnO4C
7lpi79M3xOAqzpbioCKPISxu7KcmhwaRrni0xBsIorBe3GOdMvsA9msPobMyeOFu
AK2yj6aRhR0cpouXBbbB
=H4rR
-----END PGP SIGNATURE-----

--Sig_/P3ha9kDaVRA_gIck2qmHJ=v--
