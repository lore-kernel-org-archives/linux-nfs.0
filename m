From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Thu, 6 May 2004 14:53:11 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040506215311.GA26968@polop.usc.edu>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ibTvN161/egqYuK8"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLqpB-0001j4-4D
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 14:54:37 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BLqpA-0002I2-RL
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 14:54:36 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i46LrBlv026982
	for <nfs@lists.sourceforge.net>; Thu, 6 May 2004 14:53:11 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i46LrBHV026980
	for nfs@lists.sourceforge.net; Thu, 6 May 2004 14:53:11 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040506191351.GP23287@polop.usc.edu>
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


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 06, 2004 at 12:13:52PM -0700, Garrick Staples alleged:
> On Thu, May 06, 2004 at 11:56:03AM -0700, Garrick Staples alleged:
> > I'm trying to get a pair of NFS failover servers working correctly.  I'=
ve got
> > all heartbeat scripts worked out, the common storage, IP takeover, etc.=
  The
> > only problem I have now is random stale filehandles after a failover.
> > Sometimes it works, sometimes it doesn't.
> >=20
> > I was originally trying to doctor up rmtab and carry over the mount inf=
o to the
> > second server, but according to recent docs, rmtab is no longer used an=
d NFS
> > requests should simply always work, as long as the filesystem is export=
ed to
> > the client hosts.
>=20
> Btw, I'm using linux 2.6.5, glibc 2.3.2, and nfs-utils 1.0.6.

I'm at a total loss.  Everything I'm reading tells me that all I need to en=
sure
is that fs device names are the same on both servers so that the generated
filehandles are the same, and that I need to move all lines matching
":$mountpoint:" in rmtab to the new server.  The former is done since I'm u=
sing
persistant device numbers with lvm.  The latter shouldn't be needed because=
 I'm
using the "new" proc interface with 2.6.5.

rmtab definitly doesn't do any noticable difference.  I can add random text
and blank it out with no noticable difference on the clients.

Is this a client problem?  The clients are all 2.4.24 and 2.4.26.

All clients and servers are using vanilla kernels.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--ibTvN161/egqYuK8
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAmrPH0SBUxJbm9HMRAhbGAJ9tiYVe9mWJYHkst/h7jouc4m1d0gCfcoHt
7yKZizs8naiHTodP+v2HpjM=
=iHqJ
-----END PGP SIGNATURE-----

--ibTvN161/egqYuK8--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
