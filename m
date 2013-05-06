Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35598 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752438Ab3EFEo1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 May 2013 00:44:27 -0400
Date: Mon, 6 May 2013 14:44:13 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mountd: Fix is_subdirectory again.
Message-ID: <20130506144413.46b6f37b@notabene.brown>
In-Reply-To: <20130502151634.GE15728@fieldses.org>
References: <20130502170511.646e2717@notabene.brown>
	<20130502151634.GE15728@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/RkJWcDiQ=TBIM05gp7mOek8"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/RkJWcDiQ=TBIM05gp7mOek8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 2 May 2013 11:16:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, May 02, 2013 at 05:05:11PM +1000, NeilBrown wrote:
> >=20
> >=20
> > Hi Steve,
> >  I just noticed
> >=20
> > commit ebe2826ca571a3959c3b5c8e29686c621f2775cf
> > Author: Steve Dickson <steved@redhat.com>
> > Date:   Sat Mar 23 10:30:17 2013 -0400
> >=20
> >     mountd: regression in crossmounts
> >=20
> > Sorry I missed the email you presumably sent me to let me know
> > that I had caused a regression.
>=20
> Yup.  The strategy around here is to bury people in email and trust they
> have industrial-strength filtering.
>=20
> And I could have added Neil on the cc: too and forgot, oops:
>=20
> 	http://marc.info/?l=3Dlinux-nfs&m=3D136404930104976&w=3D2
>=20
> > Here is the proper fix.
>=20
> I'm dense.  I still had to scratch my head a while:
>=20
> So: in a case like the one steved gives:
>=20
> 	/home *(rw,fsid=3D0,crossmnt)
> 	/home/fs1 *(rw,crossmnt)
> 	/home/fs1/fs2/fs3 *(rw,nohide)
>=20
> where nfsd_fh is asked to look for an export with fsid=3D0, it gets a
> match on the export of /home.  But that loop there keeps going in case
> it finds some better match.  In particular it considers any mountpoints
> under /home as candidates, since /home has "crossmnt".  And they all
> match too.  So it considers in sequence the possibilities:
>=20
> 	(found=3D/export of /home, found_path=3D/home)
> 	(found=3D/export of /home, found_path=3D/home/fs1)
> 	(found=3D/export of /home, found_path=3D/home/fs1/fs2/fs3)
>=20
> The subexport() test--designed to favor crossmnt exports which are
> "closer" to the target filesystem--passes in each case, so we end up
> taking the last.
>=20
> So we pass down the longest path to the kernel, it does an export upcall
> for that path, the hilarity ensues.
>=20
> Anyway:
>=20
> 	Acked-by: J. Bruce Fields <bfields@redhat.com>

Thanks.

>=20
> But this all still gives me a mild headache:
>=20
> 	- it only works if we iterate through the submounts in the
> 	  correct order?

Does it?  nfsd_fh() is trying to find the export for a given file handle.
  For every export it tries that filesystem and (if CROSSMOUNT) ever
  filesystem mounted below there.
  It only considers filesystem for which the fsid matches.
  Of those, it chooses the exp which is 'lowest' in the hierarchy.

I don't think the result of that can be dependant on order.

> 	- should fsid=3D be inherited by crossmnt anyway?

No...
If you have an export with fsid=3DN,crossmnt and a filehandle arrives for
fsid=3DN, then when we first look at that export match_fsid() will report a
match and 'found' will be set.
nfsd_fh() will loop around and try again for the next entry in /etc/mtab
which is under that same filesystem.  It will get a match_fsid() as well but
as subexport() will report "no" (as it is the same export), no change will =
be
made to found.  It also will not report that "X and Y have same file handle
for Z, using first" as the e_paths will match.

So it works as is.  Maybe the code could be made clearer though.


> 	- nfsd_fh() is too long, and the logic (with those extra loop
> 	  control variables declared static inside the CROSSMOUNT case)
> 	  could be more straightforward.

You have a history of taking my too-long functions and breaking them up into
manageable bits (kernel commit 3211af1119174fbe8b).  Maybe you could try
again :-)

NeilBrown

--Sig_/RkJWcDiQ=TBIM05gp7mOek8
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUYc1HTnsnt1WYoG5AQLEqA/+KQT6pw2ETG/6kqQPXU+KSIiw3taEIcCj
dKgAYc/Xp9w7JXeoGCXUz00s90WnI796dLuruCE6bgW1RnURC67ql4po2VcJzJJc
igsTpaneK/tW0JTdkEC9DppiH8kyRLB9+xjYI8cBbS0Gwy4h75ggq0THlewVFpc7
laaKJZ605BceNL2+Yao9JGLaeqYCHFOuqur6y2lZjiavT8C3ji0KqqFuF/znOYvx
h3wSZ7rjSKcWpHGuYZa9SIw1dLa8zDPhB5m348yPrefiUb5uQxduRfdcATgCdEij
Kkp9vwW2KKHIvzMjjNIQfruRF5G0a8pe3+Tb9c/fO0V3XKQ2N66FBcqoxtiSHB9B
JyzzqtyB6fUm6cVdITPtB9MPb3k24vjdMpHmcZamcbz59ArPzqugHtal77AT8ERk
ES7DTj5yj9CwQKySNKVgMpNUIndGmJME9o7zqFXipC8449CqhMzHAAx1ecGDJnpS
oaCkC4AT5eoWxswtecni855UBDrsZjqTcng8gIvglkSWum5FRGwknX0oY7kWLSib
7KnDb11e3t+r9x6C2yvIkL3mSzzvU/5e4Mt/5Vz9IlaRcyh+W74l17+cFcJkLIR4
R9U3QRwY3Dv9Ka5tvH4H35Hf70VCrFCf8eRVTUGr1l9CKlZwhsG8UcJUoVa7kpri
ZjjwqI9bOKE=
=aLvQ
-----END PGP SIGNATURE-----

--Sig_/RkJWcDiQ=TBIM05gp7mOek8--
