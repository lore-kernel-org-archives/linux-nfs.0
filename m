From: Garrick Staples <garrick@usc.edu>
Subject: Re: [PATCH] NFS: Zeroing NFS and kNFSD stats
Date: Tue, 13 Jul 2004 14:09:50 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040713210950.GB22659@polop.usc.edu>
References: <40F3D483.8020507@RedHat.com> <20040713143044.GA3023@fieldses.org> <40F3FAD8.7090707@RedHat.com> <20040713151759.GC3023@fieldses.org> <20040713180108.GF3023@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yXyGAOZGgonRe4uu"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BkUXu-0004y3-8f
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 14:10:38 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BkUXt-0007Kc-Vo
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 14:10:38 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i6DL9o66013223
	for <nfs@lists.sourceforge.net>; Tue, 13 Jul 2004 14:09:50 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i6DL9oiK013221
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 14:09:50 -0700
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
In-Reply-To: <20040713180108.GF3023@fieldses.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--yXyGAOZGgonRe4uu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 13, 2004 at 02:01:08PM -0400, J. Bruce Fields alleged:
> On Tue, Jul 13, 2004 at 11:17:59AM -0400, J. Bruce Fields wrote:
> > On Tue, Jul 13, 2004 at 11:08:08AM -0400, Steve Dickson wrote:
> > > Starting up a test run, zeroing out the stats give you a very clear
> > > picture of what exactly is going on...
> >=20
> > But you could exactly the same thing by recording the values at the
> > beginning of the test run and then subtracting.  In practice this is
> > likely to be annoying, so you'd want to write utilities that did this
> > for you, like say
> >=20
> > checkpoint_stats stats.txt
> > display_stats --since stats.txt
> >=20
> > That'd do what you want, right?
>=20
> The problem I have, by the way, is that zeroing is going to cause
> confusing problems whenever there are two simultaneous attempts to
> collect statistics.
>=20
> For example, imagine that your NFS server has a persistent
> performance-monitoring daemon that checks the statistics every now and
> then and emails the adminstrator a summary once a week.

It's about choice, isn't it?  Some sites may want to maintain the same numb=
ers
over time, other sites might want to zero them.

If someone zeros the numbers and messes up something else, that's the admin=
's
perogative to break things.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--yXyGAOZGgonRe4uu
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFA9E+d0SBUxJbm9HMRAuROAKCcNd5vhrhP0Epguf+c/noiWjs8swCfRiE4
fpnE4pSE/lobBQHkz/N+yC4=
=/8OV
-----END PGP SIGNATURE-----

--yXyGAOZGgonRe4uu--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
