From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Fri, 7 May 2004 15:17:01 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040507221701.GN30964@polop.usc.edu>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org> <20040506230055.GC26968@polop.usc.edu> <20040507182543.GA27341@fieldses.org> <20040507213811.GL30964@polop.usc.edu> <Pine.LNX.4.58.0405071651080.11315@illuminati.stderr.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="20XocjIeMTCm4X0r"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BMDfp-0003Xl-Fa
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 15:18:29 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BMDfp-00056E-9S
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 15:18:29 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i47MH1lv031443
	for <nfs@lists.sourceforge.net>; Fri, 7 May 2004 15:17:01 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i47MH1cn031441
	for nfs@lists.sourceforge.net; Fri, 7 May 2004 15:17:01 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.58.0405071651080.11315@illuminati.stderr.org>
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


--20XocjIeMTCm4X0r
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, May 07, 2004 at 04:52:02PM -0500, elijah wright alleged:
>=20
> > [root@hpc-fs3 root]# mount /dev/vgtest/lvtest /mnt/test
> > [root@hpc-fs3 root]# exportfs -o rw,no_subtree_check,no_root_squash,asy=
nc 10.125.0.0/16:/mnt/test
> > [root@hpc-fs3 root]# exportfs -u 10.125.0.0/16:/mnt/test
>=20
> those sure are some weird IP addresses ( .0.0? ) ...

10.125.0.0/16 is network notation.  It means all IPs from 10.125.0.0 through
10.125.255.255.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--20XocjIeMTCm4X0r
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAnArd0SBUxJbm9HMRAgj4AKC76Rp6DKMNJvIIebup2mGylCb6qwCfX43x
Dfz1thteMGsOhevXgRhLQLU=
=Iuag
-----END PGP SIGNATURE-----

--20XocjIeMTCm4X0r--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
