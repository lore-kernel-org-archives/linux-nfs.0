From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Fri, 7 May 2004 10:18:11 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040507171811.GB30964@polop.usc.edu>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org> <20040506230055.GC26968@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CUfgB8w4ZwR/yMy5"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BM90d-0000oT-KQ
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 10:19:39 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BM90d-000827-86
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 10:19:39 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i47HIBlv031058
	for <nfs@lists.sourceforge.net>; Fri, 7 May 2004 10:18:11 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i47HIBI6031056
	for nfs@lists.sourceforge.net; Fri, 7 May 2004 10:18:11 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040506230055.GC26968@polop.usc.edu>
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


--CUfgB8w4ZwR/yMy5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 06, 2004 at 04:00:55PM -0700, Garrick Staples alleged:
> On Thu, May 06, 2004 at 06:24:55PM -0400, J. Bruce Fields alleged:
> > On Thu, May 06, 2004 at 02:53:11PM -0700, Garrick Staples wrote:
> > > I'm at a total loss.  Everything I'm reading tells me that all I need=
 to ensure
> > > is that fs device names are the same on both servers so that the gene=
rated
> > > filehandles are the same, and that I need to move all lines matching
> > > ":$mountpoint:" in rmtab to the new server.  The former is done since=
 I'm using
> > > persistant device numbers with lvm.  The latter shouldn't be needed b=
ecause I'm
> > > using the "new" proc interface with 2.6.5.
> > >=20
> > > rmtab definitly doesn't do any noticable difference.  I can add rando=
m text
> > > and blank it out with no noticable difference on the clients.
> > >=20
> > > Is this a client problem?  The clients are all 2.4.24 and 2.4.26.
> > >=20
> > > All clients and servers are using vanilla kernels.
> > Hmm, also, could you try recompiling mountd with the following patch
> > applied?
>=20
> No effect.  All I did was kill mountd, run the patched mountd, and try to=
 'ls'
> on the client.
>=20
> Watching an strace of mountd, it doesn't seem that mountd is ever contact=
ed.
> The client reports stale filehandle pretty much immediately, and mountd d=
oesn't
> do anything.

I don't know how to debug this further.  At this point I'm assuming nfsd is
immediately returning the ESTALE, there's something about the filehandle it
doesn't like.  Is there some way to look at the filehandle on the 2.4 client
and see why the 2.6 server is rejecting it?

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--CUfgB8w4ZwR/yMy5
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAm8TT0SBUxJbm9HMRAsCUAJ4iPMDKFCIMvbcF4D1034qgU/keVQCdFqdU
G27z/9UC8zJMgpGVopLIQkY=
=F3ju
-----END PGP SIGNATURE-----

--CUfgB8w4ZwR/yMy5--


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
