Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48505 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755100Ab3GAV5E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 17:57:04 -0400
Date: Tue, 2 Jul 2013 07:56:50 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/3] krb5_util: don't give up on machine credential if
 hostname not available.
Message-ID: <20130702075650.63f72ca9@notabene.brown>
In-Reply-To: <51D1ACBE.7030608@RedHat.com>
References: <20130603005219.20080.1927.stgit@notabene.brown>
	<20130603010021.20080.11239.stgit@notabene.brown>
	<51D1ACBE.7030608@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/o569xC8w12KrvfZjOXDPQmV"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/o569xC8w12KrvfZjOXDPQmV
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 01 Jul 2013 12:22:22 -0400 Steve Dickson <SteveD@redhat.com> wrote:

> Sorry for getting into so late... I did an extraordinary amount
> of travailing in June....=20
>=20
> On 02/06/13 21:00, Neil Brown wrote:
> > krb5_util tries various different credential names in order to find
> > the machine credential, not all of them use the full host name of the
> > current host.
> >=20
> > So if getting the full host name fails, don't give up completely,
> > still try the other options.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  utils/gssd/krb5_util.c |    8 ++++++--
> >  1 file changed, 6 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
> > index 9ef80f0..5e84481 100644
> > --- a/utils/gssd/krb5_util.c
> > +++ b/utils/gssd/krb5_util.c
> > @@ -825,8 +825,10 @@ find_keytab_entry(krb5_context context, krb5_keyta=
b kt, const char *tgtname,
> >  	myhostad[i+1] =3D 0;
> > =20
> >  	retval =3D get_full_hostname(myhostname, myhostname, sizeof(myhostnam=
e));
> > -	if (retval)
> > -		goto out;
> > +	if (retval) {
> > +		/* Don't use myhostname */
> > +		myhostname[0] =3D 0;
> > +	}
> > =20
> >  	code =3D krb5_get_default_realm(context, &default_realm);
> >  	if (code) {
> > @@ -883,6 +885,8 @@ find_keytab_entry(krb5_context context, krb5_keytab=
 kt, const char *tgtname,
> >  								myhostad,
> >  								NULL);
> >  			} else {
> > +				if (!myhostname[0])
> > +					continue;
> >  				snprintf(spn, sizeof(spn), "%s/%s@%s",
> >  					 svcnames[j], myhostname, realm);
> >  				code =3D krb5_build_principal_ext(context, &princ,
> >=20
> >=20
> At the end of day... This patch allows the machine cred to be used when
> there is no DNS or /etc/hosts is empty (aka getaddrinfo() fails via=20
> the get_full_hostname() call).
>=20
> I'm thinking this is a good idea, but I'm a gnawing feeling this would
> be open some type of security hole by using machine creds when they
> should not be or they were not expected to be used...
>=20
> Am I being too paranoid???

Probably, but it is a good default position nonetheless.

This patch will only allow a machine credential to be used in the absence of
an easily detected "full hostname" if a wild card machine credential is
available.  And if such is available, it seems wrong not to use it.

If wildcard machine credentials were no expected to be used, it we seem
strange to have them included in the keytab file.

So I cannot see any hole.

Thanks,
NeilBrown


--Sig_/o569xC8w12KrvfZjOXDPQmV
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUdH7Ijnsnt1WYoG5AQKiQRAAijxrkORy6CCaJfzkk8ATtgnmZoxhT8tA
lawPun7mSJu10Zvy7JlwGXRfrZMK0UKQqLNVgs2UXvnd35beIbLj017oHyYmxLCp
C/6RzecZgBYuvb9ih0e3y8IZi7HpES8fbZlJ3EqcMT5t0O6DAQanjeQ2iHJu9OIx
3BG/re7SgorfG4KZ8AxtpxgknDvE7ZALRztyinHKTJKjI8JIN7/KUKwmDZigWD0v
i+UJeCTUr7q9mGJ9AoA0MBTA86i1JSA5o66gBb1RtdTXeUCEB/zcmbp2GxO+tNRC
Noxz1IE9U9v4caFaiEQRHbAXkGjCeJcjNQ2rl1G/6Q0WcZ0TNrpdT7NuF4ZQC73+
AoN7wZNQrjLyd9c6POudnbaP0WaWKi7GgwKifhRlbSIoFIOTYHfH6b8KruGvXaqo
whiE3fnPQNjqPVx8etu70YStJqFAXilbmEmoHrsweStU0IklqkWmpgzRUWQfCS9q
Sh39QEucM26N7sVK0Rd+pn5iNtDE8ebxUsh5Nthr96MgCKkYjyOTvyfxqa9k3WcO
DiFlEgujKO2UVt/5ETh6RZHxPHnhfdlKVpfkwKL9R1lWRnbEp0o3Nf/RG+dtf9H+
t5tFrE5UPHO5D0XmRRJxI5NB0xcRobj5FTerGK3rY8a+3abPEiO8UwBeu+uhLgDf
hWYIZ5ZzhcE=
=4WHS
-----END PGP SIGNATURE-----

--Sig_/o569xC8w12KrvfZjOXDPQmV--
