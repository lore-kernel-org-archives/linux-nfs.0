Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38370 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750775Ab3FCDBN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 2 Jun 2013 23:01:13 -0400
Date: Mon, 3 Jun 2013 13:01:01 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential
 issue.
Message-ID: <20130603130101.4acfe706@notabene.brown>
In-Reply-To: <0016A272-E433-4020-91FE-45A5EE494296@oracle.com>
References: <20130603005219.20080.1927.stgit@notabene.brown>
	<A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com>
	<20130603122319.47f4e0dd@notabene.brown>
	<0016A272-E433-4020-91FE-45A5EE494296@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/1/eYRaDFj7=tuf7aP5bGVhl"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/1/eYRaDFj7=tuf7aP5bGVhl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 2 Jun 2013 22:45:16 -0400 Chuck Lever <chuck.lever@oracle.com> wrot=
e:

>=20
> On Jun 2, 2013, at 10:23 PM, NeilBrown <neilb@suse.de> wrote:
>=20
> > On Sun, 2 Jun 2013 22:01:50 -0400 Chuck Lever <chuck.lever@oracle.com> =
wrote:
> >=20
> >>=20
> >> On Jun 2, 2013, at 9:00 PM, Neil Brown <neilb@suse.de> wrote:
> >>=20
> >>> As you probably know, since 3.7 (I think) Linux NFS has explicitly
> >>> asked for machine credentials for certain requests rather than asking
> >>> for root credentials as is previously did.
> >>> This causes a regression for people who don't have any machine
> >>> credentials configured and use "gssd -n".
> >>>=20
> >>> I gather this was discussed on the mailing list earlier this year but
> >>> not resolved.
> >>=20
> >> It's resolved in 3.10-rc.
> >>=20
> >> The kernel will attempt to use krb5i for lease management operations. =
 If that fails because there is no keytab available, it falls back to using=
 AUTH_SYS.
> >=20
> > And if the server refuses to accept AUTH_SYS?
> >=20
> > I guess this is commit 79d852bf5e7691dc7 ??
>=20
> That's one of the subsequent bug fixes.  The initial change is commit 4ed=
aa308.
>=20
> > It seems to say that the server should always accept AUTH_SYS ... is th=
at right?
>=20
> If we ever find a server implementation that does not support either Kerb=
eros or AUTH_SYS, we can add another step to the negotiation.
>=20
> So far, despite RFC 3530 not requiring AUTH_SYS support on NFSv4 servers,=
 I haven't found an implementation that does not support AUTH_SYS.  We have=
 found one (FreeBSD) that does not support AUTH_NONE.  We do know that some=
 servers allow administrators to control what security flavors are allowed =
for lease management.
>=20
> > That commit isn't tagged for -stable.
> > So do we still need to make it work for 3.7,3.8,3.9 users?
>=20
> There are several commits that would need to be back-ported, starting wit=
h commit 4edaa308.  I am not certain they would apply cleanly to 3.[789], b=
ut a backport should not be difficult.
>=20
> This change also requires that now gssd must be running on the client.  O=
therwise without gssd a sec=3Dsys mount hangs for a bit waiting for the upc=
all to time out (since the client will attempt to use krb5i for lease manag=
ement operations).  Trond and Bruce have been discussing a change to addres=
s that.

Thanks for the explanation.  That all looks rather painful to back-port
though, especially as some of it isn't even written yet :-)
I think I'll stick with my "-N" option for openSUSE for now.

Do you think that supporting -N (or similar) so that the admin can ask for
root credentials to be used for SETCLIENTID requests is reasonable? i.e. wh=
at
do you think of my patch going in to nfs-utils anyway?

Thanks,
NeilBrown

--Sig_/1/eYRaDFj7=tuf7aP5bGVhl
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUawG7Tnsnt1WYoG5AQJm4w//YOLJXUQIdsoa4yBwaHoqkk0FSaiYwFzY
ScTedtvVvqZpbdNTNrbadSzeRC3Misvq0dBZ4FQp+HXT3omljoewdF3Ln8ixazgK
Qq0npw9/9p3SRpSI164es+IspMmf7yMgrHtt4suFWJlxibTq1jCSPtzbZBvXILJ+
Ec/rWyCSMLcU5fPrYy6NcrfG4QpeJum05gD6v6tRRqBLJLZUHjlpZT6JbSZz8vtF
TVud+mu6+izTdyqaCzlR9ybevg95i1t3n+Ja0TFsQXL/RDNF6+kvZxVsmLxtMYtn
/Cy6YWfanU962uoHhXXyiHLSVMmihJwiDOHHF3354jhG/J+YvuKIOepS59uQ4XgH
im2AbEziDEfnMxOpHyi5YvCpY0rtqJt9deXDSo/og/0PRP45+m64fmVfeo5uPT1D
iS4vf5Gi4X7DsiMtGb+dYaMDVvficdY6oO822uyyEsosNMdDnqorW8Emap+ccf0T
Xa1nhucut61JPYGPvwsY6xJ7+hxBljHGRM8VF/iIzi0VapgcjBp+KBW4McfaM9gQ
gITnzyMn45cn5aZ6J3DnZoYP7XzNZpriY8W26PtImOomYjjlalKwjz38K/3IqfpT
1Y0VrEHbtV3sPiwA4Tc5zvu8Ib2YM1Hs6QH3bALmeFK2EzpUbWYFTSDSr+zwkGYW
MOSXxAbrLQw=
=aSbB
-----END PGP SIGNATURE-----

--Sig_/1/eYRaDFj7=tuf7aP5bGVhl--
