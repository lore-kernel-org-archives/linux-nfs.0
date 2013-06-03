Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:37554 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756893Ab3FCCXa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 2 Jun 2013 22:23:30 -0400
Date: Mon, 3 Jun 2013 12:23:19 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential
 issue.
Message-ID: <20130603122319.47f4e0dd@notabene.brown>
In-Reply-To: <A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com>
References: <20130603005219.20080.1927.stgit@notabene.brown>
	<A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/iccD9rKnO9FLhyNFzgb9sta"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/iccD9rKnO9FLhyNFzgb9sta
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 2 Jun 2013 22:01:50 -0400 Chuck Lever <chuck.lever@oracle.com> wrot=
e:

>=20
> On Jun 2, 2013, at 9:00 PM, Neil Brown <neilb@suse.de> wrote:
>=20
> > As you probably know, since 3.7 (I think) Linux NFS has explicitly
> > asked for machine credentials for certain requests rather than asking
> > for root credentials as is previously did.
> > This causes a regression for people who don't have any machine
> > credentials configured and use "gssd -n".
> >=20
> > I gather this was discussed on the mailing list earlier this year but
> > not resolved.
>=20
> It's resolved in 3.10-rc.
>=20
> The kernel will attempt to use krb5i for lease management operations.  If=
 that fails because there is no keytab available, it falls back to using AU=
TH_SYS.

And if the server refuses to accept AUTH_SYS?

I guess this is commit 79d852bf5e7691dc7 ??  It seems to say that the server
should always accept AUTH_SYS ... is that right?

That commit isn't tagged for -stable.
So do we still need to make it work for 3.7,3.8,3.9 users?

Thanks,
NeilBrown

>=20
>=20
> > I would like to re-awaken the issue and offer a resolution (which has
> > been tested and found effective by a customer).
> >=20
> > Hence these three patches.  The first two are minor issues that I
> > stumbled over while trying to understand the problem and are not
> > critical but probably should be fixed.
> >=20
> > The third addresses the above mentioned issue.  It introduces a
> > variable "machine_uses_root_credentials" which is similar to the
> > current "root_uses_machine_credentials".  It also adds a "-N" flag to
> > set this variable.
> >=20
> > I'm not certain what the defaults should be.  For backward
> > compatibility it would be best if '-n' set the this new variable as
> > well as clearing the old one, but then I'm not sure what exactly -N
> > should do.
> >=20
> > Comments welcome.
> >=20
> > Thanks,
> > NeilBrown
> >=20
> >=20
> >=20
> > ---
> >=20
> > Neil Brown (3):
> >      krb5_utils: remove redundant array size.
> >      krb5_util: don't give up on machine credential if hostname not ava=
ilable.
> >      gssd: add -N option to use root credentials as machine credentials.
> >=20
> >=20
> > utils/gssd/gssd.c      |    9 ++++++---
> > utils/gssd/gssd.h      |    1 +
> > utils/gssd/gssd.man    |   13 ++++++++++++-
> > utils/gssd/gssd_proc.c |   12 +++++++-----
> > utils/gssd/krb5_util.c |   10 +++++++---
> > 5 files changed, 33 insertions(+), 12 deletions(-)
> >=20
> > --=20
> > Signature
> >=20
>=20


--Sig_/iccD9rKnO9FLhyNFzgb9sta
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUav+Fznsnt1WYoG5AQKbcQ/+Mpwd0vDOQyI/tRQUL2q1YPlqzWD1v30k
t1dlY5wlrL9QB3TaKjUjCvKK3Cm6QqHYKlu7ILElTxKEXDAXeT9k3ue0R35kxUzQ
UyDJsiMkPZS1Jd92GLwRgHZXi/w55YrFqCQ1iDMfqQM9FHUwXciNhcmrJFEttgjr
74W3COeDUt54gENTs23v7Y4lARPqBQbJV6fTlaRHwYXVr5EUtghJkLWUaciPnW+0
og6eqCsUhdcUinyrhG+74V0Afe29NouiZASncVs6ao2rDfzZyGZkN37PVOGfxrjv
lBhvMvZcPbu/Q3wrBSSbCdBZO4wl28iBwCSxaZvjes0rFkpDPgvsaPqCloASBMOT
0Jby0VK3GKwR5OebN/XKzlBa9oZkHVOMJFsyCWYLQuBceThuZNm4EEg26tXBhbck
xLLWPLkbn/AXxPOo+3q3y58gUcGIGQldFHEz5sItTgkSPV14uv8+uhawaGIxREAE
cqv75DEHdcaJxPv4dYbYHIzB/yb5JY1gHG9UpOHf4ARhdQOennptOPAo58zMrhkC
UdBTzKc6YJZaOP/cXAI6Gs3rqwGpQLVkPJZNW0g0yvP9e1Q2lkzdPe3TDpQnIABT
ulSWEB0CiGR7BK5GkVjWrrenu3tuLZQL7Fy3EOcDw2ThPMpdswOfAhhsJvMRmkko
5b6YMxzYLgM=
=PnUA
-----END PGP SIGNATURE-----

--Sig_/iccD9rKnO9FLhyNFzgb9sta--
