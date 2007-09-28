From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: A unresponsive file system can hang all I/O in the system on
	linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 10:40:00 +0200
Message-ID: <1190968800.31636.26.camel@twins>
References: <92cbf19b0709272332s25684643odaade0e98cb3a1f4@mail.gmail.com>
	 <20070927235034.ae7bd73d.akpm@linux-foundation.org>
	 <1190962752.31636.15.camel@twins>
	 <92cbf19b0709280127yba48b60wfe58e532944894ca@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-98CyLSruF/tUWguf6VGj"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-pm <linux-pm@lists.linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net
To: Chakri n <chakriin5@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760377AbXI1IkX@vger.kernel.org>
In-Reply-To: <92cbf19b0709280127yba48b60wfe58e532944894ca@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--=-98CyLSruF/tUWguf6VGj
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

[ please don't top-post! ]

On Fri, 2007-09-28 at 01:27 -0700, Chakri n wrote:

> On 9/27/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > On Thu, 2007-09-27 at 23:50 -0700, Andrew Morton wrote:
> >
> > > What we _don't_ want to happen is for other processes which are writi=
ng to
> > > other, non-dead devices to get collaterally blocked.  We have patches=
 which
> > > might fix that queued for 2.6.24.  Peter?
> >
> > Nasty problem, don't do that :-)
> >
> > But yeah, with per BDI dirty limits we get stuck at whatever ratio that
> > NFS server/mount (?) has - which could be 100%. Other processes will
> > then work almost synchronously against their BDIs but it should work.
> >
> > [ They will lower the NFS-BDI's ratio, but some fancy clipping code wil=
l
> >   limit the other BDIs their dirty limit to not exceed the total limit.
> >   And with all these NFS pages stuck, that will still be nothing. ]
> >
> Thanks.
>=20
> The BDI dirty limits sounds like a good idea.
>=20
> Is there already a patch for this, which I could try?

v2.6.23-rc8-mm2

> I believe it works like this,
>=20
> Each BDI, will have a limit. If the dirty_thresh exceeds the limit,
> all the I/O on the block device will be synchronous.
>=20
> so, if I have sda & a NFS mount, the dirty limit can be different for
> each of them.
>=20
> I can set dirty limit for
>  -  sda to be 90% and
>  -  NFS mount to be 50%.
>=20
> So, if the dirty limit is greater than 50%, NFS does synchronously,
> but sda can work asynchronously, till dirty limit reaches 90%.

Not quite, the system determines the limit itself in an adaptive
fashion.

  bdi_limit =3D total_limit * p_bdi

Where p is a faction [0,1], and is determined by the relative writeout
speed of the current BDI vs all other BDIs.

So if you were to have 3 BDIs (sda, sdb and 1 nfs mount), and sda is
idle, and the nfs mount gets twice as much traffic as sdb, the ratios
will look like:

 p_sda: 0
 p_sdb: 1/3
 p_nfs: 2/3

Once the traffic exceeds the write speed of the device we build up a
backlog and stuff gets throttled, so these proportions converge to the
relative write speed of the BDIs when saturated with data.

So what can happen in your case is that the NFS mount is the only one
with traffic is will get a fraction of 1. If it then disconnects like in
your case, it will still have all of the dirty limit pinned for NFS.

However other devices will at that moment try to maintain a limit of 0,
which ends up being similar to a sync mount.

So they'll not get stuck, but they will be slow.

--=-98CyLSruF/tUWguf6VGj
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBG/L3gXA2jU0ANEf4RAv6QAJ0WZr7ulCPKZjhmsRzkD7+cMz8UPACePVGF
6RB+u9eyKXyOfSXonT0FiEo=
=6rv/
-----END PGP SIGNATURE-----

--=-98CyLSruF/tUWguf6VGj--
