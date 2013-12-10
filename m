Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54079 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722Ab3LJG2H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Dec 2013 01:28:07 -0500
Date: Tue, 10 Dec 2013 17:27:50 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trondmy@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Lever Charles Edward <chuck.lever@oracle.com>,
        Jim Rees <rees@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        An?bal Monsalve Salazar <anibal@debian.org>,
        "Steinar H. Gunderson" <sesse@debian.org>
Subject: Re: librpcsecgss: FTBFS on GNU/kFreeBSD
Message-ID: <20131210172750.02d5809f@notabene.brown>
In-Reply-To: <274DEB30-A80C-49C2-9487-BAD980C86F63@gmail.com>
References: <20090703133142.14887.33854.reportbug@localhost.localdomain>
	<20131124051904.GA16651@master.debian.org>
	<20131124090924.GA29659@infradead.org>
	<20131124130753.GA15178@umich.edu>
	<20131204131317.GA7776@infradead.org>
	<108D7BCB-5869-45BB-A287-C6593257F193@oracle.com>
	<1021B36D-17B9-477F-A8AE-86D6A7750B80@gmail.com>
	<09856BCA-A255-4975-8144-D38775DC44A8@oracle.com>
	<20131205132341.GA3381@infradead.org>
	<274DEB30-A80C-49C2-9487-BAD980C86F63@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/eTac6hM5AZ.hlWxH3d1DSJv"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/eTac6hM5AZ.hlWxH3d1DSJv
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 5 Dec 2013 08:41:27 -0500 Trond Myklebust <trondmy@gmail.com> wrote:

>=20
> On Dec 5, 2013, at 8:23, Christoph Hellwig <hch@infradead.org> wrote:
>=20
> > [adding back Anibal, and adding Steinar as tirpc maintainer for Debian]
> >=20
> > On Wed, Dec 04, 2013 at 01:14:47PM -0500, Chuck Lever wrote:
> >> But I'm looking at tirpc/rpc/auth_gss.h.  Both libraries provide rough=
ly
> >> the same API.  And I'm able to build a working GSS-enabled version of
> >> rpc.fedfsd and clients.  "git log" tells me src/auth_gss.c and
> >> tirpc/rpc/auth_gss.h have been in libtirpc since at least 0.1.7.
> >>=20
> >> libtirpc applications currently have to link explicitly with
> >> libgssapi_krb5 (provided by MIT Kerberos), AFAICT, to get GSS support.
> >=20
> >=20
> >> MIT Kerberos provides libgssapi_krb5.
> >>=20
> >> libtirpc provides the RPCSEC APIs based on the Kerberos v5 mechanism p=
rovided in libgssapi_krb5.
> >>=20
> >> librpcsecgss provides RPCSEC APIs based on the GSSAPI Kerberos v5 mech=
anism provided in libgssglue, which is deprecated.
> >=20
> > So what's actually still using librpcsecgss and libgssglue?
> >=20
> > There is no rdepends for librpcsecgss on my Debian -stable system,
> > and I couldn't find any obvious user for unstable either.  For
> > libgssglue1 -stable has a few consumers:
> >=20
> > nfs-common
> > libtirpc1
> > librpcsecgss3
> > libgssglue-dev
> > libgssapi-krb5-2
> >=20
> > libgssapi-krb5-2 seems to have dropped the libgssglue dependency in
> > unstable, but the others still seem to be be around.
>=20
> I thought that Debian installs the Heimdal kerberos libraries by default.=
 Does it have the gssapi hooks?
>=20
> > How does the situation look for Fedora and SuSE?
>=20
> Fedora=E2=80=99s nfs-utils RPM lists a dependency on =E2=80=98libgssapi_k=
rb5.so.2()(64bit)' and 'libgssapi_krb5.so.2(gssapi_krb5_2_MIT)(64bit)', so =
it uses the gssapi from the MIT kerberos libraries.
>=20
> Not sure about SuSE, but I believe they use MIT kerberos too. Neil Brown =
would know.

openSUSE is actually a bit of a mess right now as we have libtirpc compiled
with libgssglue support and that just doesn't work with a modern krb5. I'm
glad to see that support is being removed!!  (I'm working on getting this
fixed, but there are "issues" ;-( ).

But while we still seem to package librpcsecgss, nfs-utils doesn't bind
against it.  It uses libgssapi_krb5 just like Fedora.

NeilBrown

--Sig_/eTac6hM5AZ.hlWxH3d1DSJv
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUqa0Zjnsnt1WYoG5AQIUnRAAmWxYax/Xm4PtOiQdp+N/uwqeHvO7g9Of
IB6YEG4f+/M04xc6M0qrGskystITm/diya0HcTdP6zA3dTvBlfWaUwmoLc1flM61
zBxCvDtTde5SmTbdmWzLI9BFeinMhWGYUO527FrR2DMnW+AZFXCoWPSe5pbQSYpz
KcIcATlhycardPkEdzmR/sGPNDA8WENOGUr06iWzo4Odbha6yItuWV8DZtuyHUT2
yPw0QnQwcNT4GhmMO771Dkytil8hX2OegbQ8cABJdugb8knRB/5SF87tqvQMIRZH
Q1MdRVlZxH4UOKC0VPttBfeeXCmZRG4sxw1vY16Ybth4djjY5xFcDh9yBRdg40HD
8FMN7FUYeShccCbM7+YZLmkwSdFCqL99iAm3MKhe7whec0aVP8zXrTOOFD+9aTJf
BRa5FpFl2y11FD1k0jGq0SvAbe0Futikhbr9vJJWVsO5VhA1pJl9Kf46dF+jZrqd
Xa80DUOffpqqmZHT3OrJv47tNKG8lWk1DoyQdT+KZQ/F2uaUae4Q9sJNPltreB38
ecmNZSEhwjWlKO2V7BbcE7oeiJ6VUKwNZchrgtM6PO6Z9zlbSb3xDS7cfyWI0Q4S
dVS6/XaFG0vuTtfqeSziJETOqQARnoerxY6ubHTpf9U1HShvN8XUe7cabt8o9mKj
PFIn3MNHDis=
=DPrb
-----END PGP SIGNATURE-----

--Sig_/eTac6hM5AZ.hlWxH3d1DSJv--
