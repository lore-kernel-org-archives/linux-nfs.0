Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52139 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866AbaCUXJx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Mar 2014 19:09:53 -0400
Date: Sat, 22 Mar 2014 10:09:43 +1100
From: NeilBrown <neilb@suse.de>
To: Chris Friesen <chris.friesen@windriver.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: race-free exportfs and unmount?
Message-ID: <20140322100943.710d2f83@notabene.brown>
In-Reply-To: <532CC3FF.700@windriver.com>
References: <532C9E49.2030007@windriver.com>
	<20140321202040.GC26831@fieldses.org>
	<532CC3FF.700@windriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/P/4DNhXfTtXySJfX5/4W5Tt"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/P/4DNhXfTtXySJfX5/4W5Tt
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Fri, 21 Mar 2014 16:58:07 -0600 Chris Friesen
<chris.friesen@windriver.com> wrote:

> On 03/21/2014 02:20 PM, J. Bruce Fields wrote:
> > On Fri, Mar 21, 2014 at 02:17:13PM -0600, Chris Friesen wrote:
> >>
> >> Hi,
> >>
> >> There was a linux-nfs thread in July 2012 with the subject "Linux
> >> NFS and cached properties".  It discussed the fact that you can't
> >> reliably do
> >>
> >> exportfs -u 192.168.1.11:/mnt
> >> umount /mnt
> >>
> >> since there could be rpc users still running when exportfs returns,
> >> so the umount fails thinking the filesystem is busy.
> >
> > There could also be clients holding opens, locks, or delegations on the
> > export.
> >
> >> I'm running into this on a production system.
> >>
> >> Was anything ever done to resolve this issue?
> >> If not are there any workarounds?
> >
> > You can shut down the server completely, unmount, and restart.
>=20
>=20
> What is different with shutting down the server completely vs unexporting?
>=20
> Does shutting down the server somehow wait for in-flight operations to=20
> complete whereas the unexport doesn't?  I'm assuming that it can't just=20
> cancel in-progress disk I/O and as long as that's happening then we=20
> won't be able to unmount the filesystem.

Shutting down the server waits for all nfsd threads to complete what they a=
re
currently doing.
I think you can simply:

 exportfs -u the filesystem
 N=3D`cat /proc/fs/nfsd/thread`
 echo 0 > /proc/fs/nfsd/threads
 echo $N > /proc/fs/nfsd/threads
 umount the filesystem

to reliably unmount a filesystem used by nfsd.
NFS service will be stopped for a moment but clients shouldn't notice beyond
slight delay and the need to re-establish a connection.

If this doesn't work for some reason, we should probably fix it.

NeilBrown

>=20
> Thanks,
> Chris


--Sig_/P/4DNhXfTtXySJfX5/4W5Tt
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUyzGtznsnt1WYoG5AQJF9BAAgaxw3tp8chFg28ZtAk/mXZ82uYUurrEj
8nGc6M4oDdS4gMXW/H6Q26nP5fNIJIqqD0bCZC0chm3Eg4gYGiiLve08Wm5cWZM0
hcMpKRxAzeVGEImxtQ7YwhkUqjwWlJh7tVwU7r6rF4J2iby6BlIecNWFc1eyPHYU
CGMS8YHmkM9xIens1YPzrGRBoJwR40OCKqikH0DqgKn7dchnC6YkosiY3eHalZZQ
XmRUMa5qdlYkOc5+qIJaVK7O3o31ripgnGgiahd16mZiqdoN6g8nu/QrHaEfvfjy
F7/x3fNOIyHA34oaalG69LCnub7qJzlmamdBsbkL75uj+DR4zNrZ0RuoJboFi4Em
DTcSWXY+6KjJl6rmKj4xI6TsczGnDBP/ECsUceYEDMDmjpChVj7mRxzRf6lMc5O+
x5Hp71UaBZ1bbbynzAV/6yKetcG51mCwdYxqVA9CeAV2dvEcoPjcqUQZutzt14RZ
KufOj0tk8jR7Ag3OS6e3AccICa3oQQWNkzRdb11xo1NBxHYtGwXxquWXQzIR5f4t
XVo8XfIbXBlRt3aFE6A2o/2HFspExe/bJjIBBrSINWwxTJzzMVJ9GcUh2Lfr2CkZ
FuHn8OQA1V+pGOLgC3zMDDVGnquR3vW693RdwGoTKqoct7oSWXzQB7SsUpVOtGrl
idjnNotbjnk=
=Tv6f
-----END PGP SIGNATURE-----

--Sig_/P/4DNhXfTtXySJfX5/4W5Tt--
