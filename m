From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Thu, 6 May 2004 12:13:52 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040506191351.GP23287@polop.usc.edu>
References: <20040506185603.GM23287@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cNJ0mG4Q6+QCvBh5"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLoNA-0000FV-CR
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 12:17:32 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BLoNA-0001CO-5X
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 12:17:32 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i46JDqlv026812
	for <nfs@lists.sourceforge.net>; Thu, 6 May 2004 12:13:52 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i46JDqUO026810
	for nfs@lists.sourceforge.net; Thu, 6 May 2004 12:13:52 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040506185603.GM23287@polop.usc.edu>
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


--cNJ0mG4Q6+QCvBh5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 06, 2004 at 11:56:03AM -0700, Garrick Staples alleged:
> I'm trying to get a pair of NFS failover servers working correctly.  I've=
 got
> all heartbeat scripts worked out, the common storage, IP takeover, etc.  =
The
> only problem I have now is random stale filehandles after a failover.
> Sometimes it works, sometimes it doesn't.
>=20
> I was originally trying to doctor up rmtab and carry over the mount info =
to the
> second server, but according to recent docs, rmtab is no longer used and =
NFS
> requests should simply always work, as long as the filesystem is exported=
 to
> the client hosts.

Btw, I'm using linux 2.6.5, glibc 2.3.2, and nfs-utils 1.0.6.


--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--cNJ0mG4Q6+QCvBh5
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAmo5v0SBUxJbm9HMRAuMbAJ4wyICynoGPqroDwZ7br1+Yyw2akgCgoKfn
8j3vLFhDRSnaWap+xPaE4kw=
=Kkjc
-----END PGP SIGNATURE-----

--cNJ0mG4Q6+QCvBh5--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
