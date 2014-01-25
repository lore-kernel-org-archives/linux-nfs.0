Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41896 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413AbaAYUqS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 25 Jan 2014 15:46:18 -0500
Date: Sun, 26 Jan 2014 07:45:57 +1100
From: NeilBrown <neilb@suse.de>
To: Sebastien Godard <sysstat@orange.fr>
Cc: Steve Dickson <SteveD@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        varekova@redhat.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Too many programs called nfsiostat.
Message-ID: <20140126074557.6baf15c8@notabene.brown>
In-Reply-To: <52E3DC2C.1050400@orange.fr>
References: <20130410094639.5debfc90@notabene.brown>
	<20140121144517.5f549347@notabene.brown>
	<A5BFEC5C-7AF2-4A7E-856F-D62F35BCEFC0@oracle.com>
	<20140122112436.574f0e29@notabene.brown>
	<52DFC3C3.7080506@RedHat.com>
	<20140123085226.72ebaf85@notabene.brown>
	<52E15495.3050103@RedHat.com>
	<52E17790.4090903@orange.fr>
	<52E3CC9F.5060102@RedHat.com>
	<52E3DC2C.1050400@orange.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/eRSfIE_dUOY84qoAlbRnE90"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/eRSfIE_dUOY84qoAlbRnE90
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 25 Jan 2014 16:45:48 +0100 Sebastien Godard <sysstat@orange.fr> wro=
te:

> On 01/25/2014 03:39 PM, Steve Dickson wrote:
> >
> > On 23/01/14 15:12, Sebastien Godard wrote:
> >> On 01/23/2014 06:42 PM, Steve Dickson wrote:
> >>> On 22/01/14 16:52, NeilBrown wrote:
> >>>> On Wed, 22 Jan 2014 08:12:35 -0500 Steve Dickson <SteveD@redhat.com>=
 wrote:
> >>>>
> >>>>> On 21/01/14 19:24, NeilBrown wrote:
> >>>>> Is this version still actively being maintain?
> >>>> Last change was 5 days ago.
> >>>>
> >>>> https://github.com/sysstat/sysstat/commits/master/nfsiostat.c
> >>> I guess the question now is do they want to continue maintaining
> >>> it or just merge the functionality into the nfs-utils version...
> >>>
> >> This is no longer a question as I already answered it. Please *read* m=
y previous mail.
> > I did... but thought Neil's mail was pointing out that some type of
> > maintenance was happening... But if you say it's "no longer actively be=
ing maintained"
> > I'll believe you... :-)
> >
> > So what is the next step to deprecate the nfsiostat in sysstat?
> >
>=20
> In fact, the various patches applied to nfsiostat over the last few=20
> years were mainly cosmetic ones (changes in sysstat APIs, etc.)
> So I propose now to simply remove nfsiostat code from sysstat: Next=20
> sysstat version will rename nfsiostat (eg. to nfsiostat-sysstat) and the=
=20
> man page will indicate it is now obsolete and point to the version from=20
> nfs-utils. Then nfsiostat will be definitively removed sometime before=20
> the end of this year.
>=20
> Regards,
>=20

Fantastic - a nice clear resolution, just what I was hoping for.
Thanks a lot!

NeilBrown

--Sig_/eRSfIE_dUOY84qoAlbRnE90
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUuQiiznsnt1WYoG5AQL0FA//Xu5rVSxmlOCvzN4Y8qI7oGc+esylFxee
8pQ8H0EoGijCDnYwmf804mysFHYZuGwy+8Hbyil863IKbfIemiJcVNC6t3ZIXxMR
Wu4wJytRtWvzI4LKynZ0qDWUlmQ+MXG6wIOU5M8sEF90HsfQHyLo1FqwFb0j3tro
829pNSIzZqkuTvjynBsTYoy43limCmtGWqRJ4sKZ061BSQDTZeNGlyJ03jWuJot0
R2n4dIsL2PCWwtDQT1eRCNf1PJFojgmeXxvRuYCmPf/9gQiMKf06BnMn99XMGHzM
Zy2LdyIEXiv3oZgJakcX66WjW8asRYOpHfEb23Ufko4sQ2iaiZ81fizVvjwjZZsd
r4xH3jE6ooDKHfxnhu1+neiutTS0Z5BCeXpWYMBjgZPHWjHp795WYEzJaCQRgpvo
GtPhMcMPjiCuNqQgQDn7KZk4TWaKYog6JONaPYSwmbaiEQ+8V9LjgyfqfKckr2PJ
fBDfhgD7D7mJeMQLgqPois+07cdQJBBkEpYkUKbq4xL04qdbliKCD7uW8AJGwshL
sRlm3RuJLY8jn2Uk2mjfBkV8NPqdKGWzx7SAAX5zqkSic7+gHB/ODAZW8a1XusV4
6+q2U/vBiDZB1ZcbD1ChZPtRJVmnds5DDoa6EoPNzqiFi4evR8+LZxwRo3Qw5QJg
3omNaGl5eI4=
=mycy
-----END PGP SIGNATURE-----

--Sig_/eRSfIE_dUOY84qoAlbRnE90--
