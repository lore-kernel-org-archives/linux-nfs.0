From: Garrick Staples <garrick@usc.edu>
Subject: Re: Converting open filehandles to pathnames
Date: Sun, 9 May 2004 20:00:30 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040510030029.GL30964@polop.usc.edu>
References: <1084059203.714.13.camel@omikron> <20040509072418.GB18762@sgi.com> <1084063428.714.40.camel@omikron> <1084148814.29382.32.camel@binkley>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OY4z34RctfP64Hws"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BN13h-00016A-7y
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 20:02:25 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BN13g-0003QI-43
	for nfs@lists.sourceforge.net; Sun, 09 May 2004 20:02:24 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i4A30Ulv017179
	for <nfs@lists.sourceforge.net>; Sun, 9 May 2004 20:00:30 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i4A30UWU017177
	for nfs@lists.sourceforge.net; Sun, 9 May 2004 20:00:30 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1084148814.29382.32.camel@binkley>
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


--OY4z34RctfP64Hws
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, May 09, 2004 at 08:26:54PM -0400, seth vidal alleged:
>=20
> > Now if someone just had as good an answer to the "what is a client?"
> > question....  You might imagine my interest in that is more than
> > academic, with 100's of *long*-duration filehandles in the GB+ range
> > each, yet over only a few physical client machines.
> >=20
>=20
> Any thoughts to making this program available anywhere? I'd be
> interested to get some mappings to find out who my most abusive users
> are.
>=20
> I've run into some performance problems recently and I'd love to know if
> I've got some specific users who are being abusive or if the machine is
> just underpowered.

Come to think of it, I've found myself in the same situation... wondering w=
ho
is beating up my NFS servers.  This would be a great tool to have.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--OY4z34RctfP64Hws
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAnvBN0SBUxJbm9HMRAuO3AJ42gXeLn0LjBASzKmddbWWibU+2kQCfecrv
99HjhiahMDwik6f6ITyiB7Y=
=lGng
-----END PGP SIGNATURE-----

--OY4z34RctfP64Hws--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
