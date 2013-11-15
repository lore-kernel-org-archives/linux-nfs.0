Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55068 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751472Ab3KOGjA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Nov 2013 01:39:00 -0500
Date: Fri, 15 Nov 2013 17:38:45 +1100
From: NeilBrown <neilb@suse.de>
To: Harshula Jayasuriya <harshula@redhat.com>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        "J.Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH] exportfs: modify can_test() to use LONG_MAX when
 appropriate
Message-ID: <20131115173845.5ff064cd@notabene.brown>
In-Reply-To: <1384496133.14391.112.camel@serendib>
References: <1376588800.17754.14.camel@serendib>
	<20130815175258.GS17781@fieldses.org>
	<1384154434.16759.39.camel@serendib>
	<20131111185356.6e0fd0a9@notabene.brown>
	<1384168843.16759.50.camel@serendib>
	<1384496133.14391.112.camel@serendib>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/2+9YCbVc.V=fkrt91=QnFJ0"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/2+9YCbVc.V=fkrt91=QnFJ0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 15 Nov 2013 17:15:33 +1100 Harshula Jayasuriya <harshula@redhat.com>
wrote:

> On Mon, 2013-11-11 at 22:20 +1100, Harshula Jayasuriya wrote:
> > On Mon, 2013-11-11 at 18:53 +1100, NeilBrown wrote:
> > > On Mon, 11 Nov 2013 18:20:34 +1100 Harshula Jayasuriya <harshula@redh=
at.com>
> > > wrote:
> > >=20
> > > > This patch is the nfs-utils patch corresponding to the kernel patch=
=20
> > > > commit 2f74f972d4cc7d83408ea0c32d424edcb44887bf "sunrpc: prepare NF=
S=20
> > > > for 2038": "The kernel sunrpc code needs to handle seconds since ep=
och=20
> > > > greater than 2147483647. This means functions that parse time as an=
=20
> > > > int need to handle it as time_t."
> > > >=20
> > > > When appropriate exportfs should use LONG_MAX in can_test() instead=
 of
> > > > INT_MAX.
> > > >=20
> > > > kernel INT_MAX + exportfs INT_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > >=20
> > > > exportfs: /mnt/export does not support NFS export:
> > > > ------------------------------------------------------------
> > > >  # cat /proc/net/rpc/auth.unix.ip/content
> > > >  #class IP domain
> > > > ------------------------------------------------------------
> > > >=20
> > > > + mount fail:
> > > > ------------------------------------------------------------
> > > >  # cat /proc/net/rpc/auth.unix.ip/content
> > > >  #class IP domain
> > > >  # expiry=3D2147483768 refcnt=3D2 flags=3D4
> > > >  # nfsd 192.168.1.6 -no-domain-
> > > > ------------------------------------------------------------
> > > >=20
> > > > kernel LONG_MAX + exportfs INT_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > >=20
> > > > "exportfs: /mnt/export does not support NFS export":
> > > > ------------------------------------------------------------
> > > >  # cat /proc/net/rpc/auth.unix.ip/content
> > > >  #class IP domain
> > > > ------------------------------------------------------------
> > > >=20
> > > > + mount success:
> > > > ------------------------------------------------------------
> > > >  # cat /proc/net/rpc/auth.unix.ip/content
> > > >  #class IP domain
> > > >  # expiry=3D2147485448 refcnt=3D2 flags=3D1
> > > >  nfsd 192.168.1.6 *
> > > > ------------------------------------------------------------
> > > >=20
> > > > kernel LONG_MAX + exportfs LONG_MAX: "Tue Jan 19 03:14:08 UTC 2038"
> > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > > >=20
> > > > exportfs:
> > > > ------------------------------------------------------------
> > > >  # cat /proc/net/rpc/auth.unix.ip/content
> > > >  #class IP domain
> > > >  # expiry=3D9223372036854775807 refcnt=3D1 flags=3D1
> > > >  nfsd 0.0.0.0 -test-client-
> > > > ------------------------------------------------------------
> > > >=20
> > > > + mount success:
> > > > ------------------------------------------------------------
> > > >  # cat /proc/net/rpc/auth.unix.ip/content
> > > >  #class IP domain
> > > >  # expiry=3D2147485448 refcnt=3D2 flags=3D1
> > > >  nfsd 192.168.1.6 *
> > > >  # expiry=3D9223372036854775807 refcnt=3D1 flags=3D1
> > > >  nfsd 0.0.0.0 -test-client-
> > > > ------------------------------------------------------------
> > > >=20
> > > > Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
> > > > ---
> > > >  utils/exportfs/exportfs.c | 20 ++++++++++++++++----
> > > >  1 file changed, 16 insertions(+), 4 deletions(-)
> > > >=20
> > > > diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> > > > index da5fe21..bccbed5 100644
> > > > --- a/utils/exportfs/exportfs.c
> > > > +++ b/utils/exportfs/exportfs.c
> > > > @@ -27,6 +27,8 @@
> > > >  #include <netdb.h>
> > > >  #include <errno.h>
> > > >  #include <dirent.h>
> > > > +#include <limits.h>
> > > > +#include <time.h>
> > > > =20
> > > >  #include "sockaddr.h"
> > > >  #include "misc.h"
> > > > @@ -406,17 +408,27 @@ unexportfs(char *arg, int verbose)
> > > > =20
> > > >  static int can_test(void)
> > > >  {
> > > > +	char buf[1024];
> > > >  	int fd;
> > > >  	int n;
> > > > -	char *setup =3D "nfsd 0.0.0.0 2147483647 -test-client-\n";
> > > > +
> > > >  	fd =3D open("/proc/net/rpc/auth.unix.ip/channel", O_WRONLY);
> > > > -	if ( fd < 0) return 0;
> > > > -	n =3D write(fd, setup, strlen(setup));
> > > > +	if (fd < 0)
> > > > +		return 0;
> > > > +
> > > > +	if (time(NULL) > INT_MAX)
> > > > +		sprintf(buf, "nfsd 0.0.0.0 %ld -test-client-\n", LONG_MAX);
> > > > +	else
> > > > +		sprintf(buf, "nfsd 0.0.0.0 %d -test-client-\n", INT_MAX);
> > >=20
> > > This generally makes sense, but I think the cut-off is a bit too fine.
> > > If time(NULL) is exactly INT_MAX, then this might not do what is requ=
ired.
> > > How about
> > >    if (time(NULL) > INT_MAX - (24*3600))
> > > ??
> >=20
> > Good point. Mount attempts seem to fail not because of when exportfs is
> > run, but when the first mount request is made.
>=20
> Clarification, what I said above is only true when the kernel does *not*
> have commit 2f74f972d4cc7d83408ea0c32d424edcb44887bf.
>=20
> I did a few more tests with kernel commit
> 2f74f972d4cc7d83408ea0c32d424edcb44887bf and found:
>=20
> 1) When the mount attempt arrives before the expiry time, set in
> can_test(), is reached, /proc/net/rpc/auth.unix.ip/content will contain
> the entry for the real mount attempt and test_export()'s "-test-client-"
> entry. If the mount attempt arrives after the expiry time, only the
> entry for the real mount attempt will appear. In both cases the mount
> attempt succeeds.
>=20
> 2) If the expiry time, set in can_test(), is older than the time when
> exportfs is run, then test_export() will fail (write
> to /proc/net/rpc/nfsd.export/channel fails) and validate_export() will
> print the following error "exportfs: /mnt/export does not support NFS
> export". However, the mount attempt still succeeds.
>=20
> Neil, have I missed something here? It looks like we don't need to add
> the tolerance to the time check.

The problem scenario that I imagine is:

> > > > +	if (time(NULL) > INT_MAX)

happens towards the end ofthe second when time(NULL) =3D=3D INT_MAX.  The t=
est
fails and INT_MAX is stored in 'buf'.

By the time buf gets written to the kernel, time has passed and so the kern=
el
sees that the entry written has passed.
So an already-expired entry gets stored in the cache, which is clearly
pointless and could conceivably result in the in the subsequent
'test_export()' call failing incorrectly.

It is admittedly a tiny window and it may not cause a problem.
It just seems to me that waiting until the very last moment to switch over =
to
used the new max-time value is pointless brinkmanship.
It is obviously correct to use LONG_MAX a day (or even a month) before the
change over.  So just do it and don't worry about trying to prove whether it
is actually necessary or not.

NeilBrown



> cya,
> #
>=20
> > Is 1 day the right amount of tolerance? Or should we just go for a much
> > larger tolerance, on the assumption that the running kernel will have
> > commit 2f74f972d4cc7d83408ea0c32d424edcb44887bf by then? :-)
> >=20
> > cya,
> > #
> >=20
> >=20
> > > > +
> > > > +	n =3D write(fd, buf, strlen(buf));
> > > >  	close(fd);
> > > >  	if (n < 0)
> > > >  		return 0;
> > > > +
> > > >  	fd =3D open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
> > > > -	if ( fd < 0) return 0;
> > > > +	if (fd < 0)
> > > > +		return 0;
> > > >  	close(fd);
> > > >  	return 1;
> > > >  }
> >=20
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


--Sig_/2+9YCbVc.V=fkrt91=QnFJ0
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUoXBdTnsnt1WYoG5AQKqwRAAucDQCXbB5oM9ur15JZpkUp+MGWpWKQ5H
CWoq05X/+FEqF67T5Lc+FCZPgxbuo0A/Ei3p2Z57/0R++p82PS+v0sBuPt7Sxlld
1QGIKlRyPCpzA1+6g0mIN2li/p1nR5J1Fa8BiZpxztUdS1AdsHHc2hBvRSbbFvMa
AM9eocCkb10v43wFsh6oMqqb3KgaWprB9B854y1S5G8iCGl0Tj9q2SZ/GWIuaIab
4tJXKkPN4TADvTn53pmfzkSOLmXAZKtJgubSctdpAUFs86957Fh6jso6NX8IdzWN
kkyOFA/JW3Jb8rv/ZCneZSeY3IKrwQj+WYI91ZkO9bij1dpCfG18NZbnMWZehnsL
3T6cotGWPzCKt/yzro92epTcr8TsPZBub5txAorT6VyP7HAqG22I0rk47a3VbtKz
XzjUBWneohK08ZbMN7wNf3pu+JRL86XZbCnPvz+wMGT7r39rUAPB+UzZQldZ3LkS
VxtEowIUa6XAZZuTjOWhBcl59AsMjDYYQFlAPV2VmJggbNdJEHxn05k8Hi14qYbK
E3HITetbi2R43ktqcrN0YeQw/46FTfo29/FUQJm7hYROB62SuoYaUVu/hKD5uzgF
8rwySmBcogbV4qEEpzpAYe8tU9Ts8DCJagH5PwFF1MOsJDFGwDI4sTE+gevex2g7
aPxiwxAuHBg=
=egxO
-----END PGP SIGNATURE-----

--Sig_/2+9YCbVc.V=fkrt91=QnFJ0--
