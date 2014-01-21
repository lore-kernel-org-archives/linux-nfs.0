Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:36691 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751136AbaAUDp3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jan 2014 22:45:29 -0500
Date: Tue, 21 Jan 2014 14:45:17 +1100
From: NeilBrown <neilb@suse.de>
To: chuck.lever@oracle.com, varekova@redhat.com
Cc: sysstat@orange.fr, linux-nfs@vger.kernel.org
Subject: Re: Too many programs calls nfsiostat.
Message-ID: <20140121144517.5f549347@notabene.brown>
In-Reply-To: <20130410094639.5debfc90@notabene.brown>
References: <20130410094639.5debfc90@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/gqnOl6cbKWstuEEpyxSYRkj"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/gqnOl6cbKWstuEEpyxSYRkj
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


(This time without the typo in Chuck's address - sorry).

Not quite a year ago I wrote:

On Wed, 10 Apr 2013 09:46:39 +1000 NeilBrown <neilb@suse.de> wrote:

>=20
> Hi all,
>  it seems that in 2010, a program called nfsiostat was added to the sysst=
at
>  package (http://sebastien.godard.pagesperso-orange.fr/)
>=20
>  This is unfortunate because in 2008 a program called nfsiostat was added=
 to
>  the nfs-utils package.
>     (https://www.kernel.org/pub/linux/utils/nfs-utils/1.2.7/)
>=20
>  The default install locations seem to be different (/usr/bin vs /usr/sbi=
n),
>  so packagers would not immediately notice.
>=20
>  This seems like something that should be "fixed".
>=20
>  Any suggestions what a good "fix" should look like?
>=20
> NeilBrown


No suggestions were forthcoming.
So I have a suggestion.
I propose we rename the "nfsiostat" in the "sysstat" package to
"nfsio-sysstat" and the "nfsiostat" in "nfs-utils" to
"nfs-utils-iostat".

Does anyone object?  If not I'll send off patches shortly :-)

NeilBrown

--Sig_/gqnOl6cbKWstuEEpyxSYRkj
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUt3tTTnsnt1WYoG5AQLd8A//X+6c49JlpWTFqc4XcQg2RM/YeBjN9g47
MwcBgv9wtYw6sgvk0IrWMmV7ceasR3IBGo9FsHTcxsUp4xo2JQ0GevwmZDblp4ur
+yUjGFIBa6Ngw0F9QE2FGhQFAOJvAAgdIap2wKLCHzQ5Gizja4L7n/L6CgfDQKZu
lsxWQ48BqrJ+cc9iaDGgPOiWjW61yChh9KDZMRpC6BnGf1JaxDiPgeKUAkxIDDKz
1x/C8g/kCJ+nmLCB38Uh1MaytHaFQElUThN+m/sZ0yv5Tju3bn6nsOPJJ9g3UzJv
yb7DKcrLxxFOiFAHUWkaZTJs/episzMCPOVqLkk2jD6gjBWh3cxonbd0XgZX1hP0
bp/nIU/vuC9gav86unebGf+kHNo1uJXIXnR5JhZ4W1rCmeG+nq5IPsTtKwTmhS4P
b8pZ3IPgk7pjG6o/pt3feru6oo2/23GUPUCS5bDQELXAVYQ8e+dQRFbotzPJph4c
WP6m9u1Do9UKByK9aZWmKUHrMvMmgFPWcTJ6bpzJv/qCnV0zPXm5MowrItsm6zXU
aL3D8YmBaQbHCPoBwYfaxXBsxZDkS1vfDI7QZw/ldrtV7bqdISRhjQoEtIvTypC0
ldZHMhKJp6Vebst3JBs7wZjB6dfUBm1e/FXSuwO8x7uaKaHFAaUuW8ZQVNDJbjoE
NKQW7lv/PoE=
=v+hJ
-----END PGP SIGNATURE-----

--Sig_/gqnOl6cbKWstuEEpyxSYRkj--
