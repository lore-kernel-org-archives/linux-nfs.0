From: Garrick Staples <garrick@usc.edu>
Subject: Re: mountd segfault on itanium2
Date: Mon, 3 May 2004 17:17:18 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040504001718.GZ23287@polop.usc.edu>
References: <20040430212414.GF22498@polop.usc.edu> <20040430234327.GM22498@polop.usc.edu> <20040501030730.GE23287@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="McORcswOES2gGXLb"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKneO-0007b6-UW
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 17:19:08 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BKndt-0000EO-JI
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 17:18:37 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i440HIlv013357
	for <nfs@lists.sourceforge.net>; Mon, 3 May 2004 17:17:18 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i440HI56013355
	for nfs@lists.sourceforge.net; Mon, 3 May 2004 17:17:18 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040501030730.GE23287@polop.usc.edu>
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


--McORcswOES2gGXLb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 30, 2004 at 08:07:30PM -0700, Garrick Staples alleged:
> On Fri, Apr 30, 2004 at 04:43:27PM -0700, Garrick Staples alleged:
> > I just spotted a pattern.  After collecting several strace samples, it =
always
> > segfaults after read() or write() to fd 5.  And fd 5 is always:
> >=20
> >    open("/proc/net/rpc/nfsd.fh/channel", O_RDWR) =3D 5
>=20
> I have an ugly work-around that seems to be working.  It seems that 2.6 h=
as a
> new nfs interface for userspace.  By forcing mountd to use the older 2.4
> interface, it doesn't segfault anymore.  So something in the new code pat=
hs is
> broken.

I'm slowly starting to wrap my brain around how these RPC calls work.  I've
found something that I can't make sense of.  In my_svc_run(), it packs fds =
3,
4, 5, 6, and 7 into select().  3, 4, and 5 are 3 files in /proc/net/rpc.  f=
d 6
 and 7 are udp and tcp sockets.  During my umount/mount tests, fd 6 is the
only set bit after the select(), and is then passed to svc_getreqset().

But just before the segfault, select() sets fd 5, which is
/proc/net/rpc/nfsd.fh/channel.  The thing that I don't understand is that f=
d 5
is being passed to svc_getreqset().  Shouldn't svc_getreqset() be only for =
fds
of sockets that have pending rpc calls?  Should fd 5 be cleared from the fd=
set
before calling svc_getreqset()?

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--McORcswOES2gGXLb
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAluEO0SBUxJbm9HMRAlIbAJwPTaX7Qg7fmmTRICovkC2vLriYTwCfRCBh
hkjs/3vBi4dI3Lf8N39lyM8=
=MX3R
-----END PGP SIGNATURE-----

--McORcswOES2gGXLb--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
