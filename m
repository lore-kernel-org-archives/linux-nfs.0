From: Garrick Staples <garrick@usc.edu>
Subject: Re: mountd segfault on itanium2
Date: Mon, 3 May 2004 18:52:53 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040504015253.GB23287@polop.usc.edu>
References: <20040430212414.GF22498@polop.usc.edu> <20040430234327.GM22498@polop.usc.edu> <20040501030730.GE23287@polop.usc.edu> <20040504001718.GZ23287@polop.usc.edu> <20040504010158.GD3636@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SHFFXbs3XlGSDX14"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKp8s-0004IQ-Us
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 18:54:42 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BKp8O-0006et-P4
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 18:54:12 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i441qslv013533
	for <nfs@lists.sourceforge.net>; Mon, 3 May 2004 18:52:54 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i441qrTN013531
	for nfs@lists.sourceforge.net; Mon, 3 May 2004 18:52:53 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040504010158.GD3636@fieldses.org>
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


--SHFFXbs3XlGSDX14
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 03, 2004 at 09:01:58PM -0400, J. Bruce Fields alleged:
> On Mon, May 03, 2004 at 05:17:18PM -0700, Garrick Staples wrote:
> > I'm slowly starting to wrap my brain around how these RPC calls work.  =
I've
> > found something that I can't make sense of.  In my_svc_run(), it packs =
fds 3,
> > 4, 5, 6, and 7 into select().  3, 4, and 5 are 3 files in /proc/net/rpc=
=2E  fd 6
> >  and 7 are udp and tcp sockets.  During my umount/mount tests, fd 6 is =
the
> > only set bit after the select(), and is then passed to svc_getreqset().
> >=20
> > But just before the segfault, select() sets fd 5, which is
> > /proc/net/rpc/nfsd.fh/channel.  The thing that I don't understand is th=
at fd 5
> > is being passed to svc_getreqset().  Shouldn't svc_getreqset() be only =
for fds
> > of sockets that have pending rpc calls?  Should fd 5 be cleared from th=
e fdset
> > before calling svc_getreqset()?
>=20
> Cool, good detective work, I think that must be it.  Other people
> weren't seeing it because you have to be using the new interface (have
> nfsd mounted), and have to get an rpc call and a kernel upcall at the
> same time.  Does clearing the bit end the segfaults?

I just got this, for some reason mail from sourceforge seems to be lagging =
by
several hours today.

Yes, that seems to fix the problem.  Isn't this a significant DOS attack?
Anyone on the net could generate lots of mount/umount requests to mountd
running on any 2.6 machine and segfault mountd.

Is there a deeper problem in glibc's rpc code that shouldn't be segfaulting?

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--SHFFXbs3XlGSDX14
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAlvd10SBUxJbm9HMRAvq0AJ4zv9D7LfWWltKmOeYdF8bxMQJ8oACgnSQ2
YE4OvFAm94rSYpjIY6wXrNM=
=3im6
-----END PGP SIGNATURE-----

--SHFFXbs3XlGSDX14--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
