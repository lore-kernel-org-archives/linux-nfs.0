From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Thu, 6 May 2004 16:00:55 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040506230055.GC26968@polop.usc.edu>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="w7PDEPdKQumQfZlR"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BLrsk-0007f2-2h
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 16:02:22 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BLrsj-0000yb-De
	for nfs@lists.sourceforge.net; Thu, 06 May 2004 16:02:21 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i46N0tlv027071
	for <nfs@lists.sourceforge.net>; Thu, 6 May 2004 16:00:55 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i46N0t8t027069
	for nfs@lists.sourceforge.net; Thu, 6 May 2004 16:00:55 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040506222455.GP18964@fieldses.org>
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


--w7PDEPdKQumQfZlR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 06, 2004 at 06:24:55PM -0400, J. Bruce Fields alleged:
> On Thu, May 06, 2004 at 02:53:11PM -0700, Garrick Staples wrote:
> > I'm at a total loss.  Everything I'm reading tells me that all I need t=
o ensure
> > is that fs device names are the same on both servers so that the genera=
ted
> > filehandles are the same, and that I need to move all lines matching
> > ":$mountpoint:" in rmtab to the new server.  The former is done since I=
'm using
> > persistant device numbers with lvm.  The latter shouldn't be needed bec=
ause I'm
> > using the "new" proc interface with 2.6.5.
> >=20
> > rmtab definitly doesn't do any noticable difference.  I can add random =
text
> > and blank it out with no noticable difference on the clients.
> >=20
> > Is this a client problem?  The clients are all 2.4.24 and 2.4.26.
> >=20
> > All clients and servers are using vanilla kernels.
> Hmm, also, could you try recompiling mountd with the following patch
> applied?

No effect.  All I did was kill mountd, run the patched mountd, and try to '=
ls'
on the client.

Watching an strace of mountd, it doesn't seem that mountd is ever contacted.
The client reports stale filehandle pretty much immediately, and mountd doe=
sn't
do anything.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--w7PDEPdKQumQfZlR
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAmsOn0SBUxJbm9HMRAtsQAJ9C4rdfkI9Tl6+8nhtOrysFonlTTQCfeP6W
VtR71t7S2uqeZkYtLPXlkoY=
=e3Vp
-----END PGP SIGNATURE-----

--w7PDEPdKQumQfZlR--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
