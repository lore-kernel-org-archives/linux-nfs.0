From: Garrick Staples <garrick@usc.edu>
Subject: Re: possible client stale filehandle bug?
Date: Tue, 25 Jan 2005 22:35:47 -0800
Message-ID: <20050126063547.GS12269@polop.usc.edu>
References: <20050125173945.GU12269@polop.usc.edu> <1106719587.10014.4.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5iQfWP9hwu8WkYTt"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtgmN-0002bv-7N
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 22:35:51 -0800
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CtgmL-0000Vw-Qe
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 22:35:51 -0800
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id j0Q6ZlfF005815
	for <nfs@lists.sourceforge.net>; Tue, 25 Jan 2005 22:35:47 -0800
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id j0Q6Zl3E005813
	for nfs@lists.sourceforge.net; Tue, 25 Jan 2005 22:35:47 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <1106719587.10014.4.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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


--5iQfWP9hwu8WkYTt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 25, 2005 at 10:06:27PM -0800, Trond Myklebust alleged:
> ty den 25.01.2005 Klokka 09:39 (-0800) skreiv Garrick Staples:
> > Hi all,
> >    I have lots of storage in a large Solaris samfs environment that is =
NFS
> > shared to a large number of Solaris and RHEL3 clients.  Under some cond=
itions,
> > linux apps have been getting stale filehandles during the normal course=
 of
> > their activity.  Various file handling syscalls like read() or open() m=
ight
> > error.  Lots of renames and setattrs calls seem to trigger the problem.=
 =20
> > 'ci' and 'cvs commit' are particularly good at this.
>=20
> ESTALE is usually a sign that someone is deleting a file on the server
> that is in use by the client. It is a sign that you are doing something
> that violates the caching rules of NFS.

Nothing of the kind is happening here.  I've tested this a thousand times o=
ver
the last few days trying to find a solution.  In this case, Sun's samfs
filesystem is definitely at fault and doing the wrong thing.  Backline
engineers at Sun confirm this and are working on a fix. =20

The reason for _this_ email isn't because of the ESTALEs, it's regarding the
handling of the ESTALEs.  Right now I need the Solaris client behaviour to
deal with this particular buggy server.

Incidentally, 2.6.10 never has a problem.  It's behaviour never creates EST=
ALEs in
the first place.

=20
> > It seems that the Solaris clients never report any such errors, only th=
e Linux
> > clients.  However, watching 'snoop' on the Solaris NFS server, I see th=
at it IS
> > returning stale file handles to both OSes, but Solaris clients seem to =
retry
> > the request several times; and the Linux clients immediately pass the e=
rror up
> > to the application.
> >=20
> > Is there some condition that the 2.4 kernel is handling incorrectly?
>=20
> I do not believe that Solaris redrives ESTALE on read, but they may do
> it on open(). Linux does not redrive either case. See the many
> discussions in the NFS list archives for why.

Did you look at the 'snoop' bits in the previous email?  During that time, =
the
process on the Solaris client is hanging in a write() call.

I'd be very happy to see any patches lieing around that might do this
behaviour.  It would get me through the short term until Sun fixes this bug=
 in
samfs.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--5iQfWP9hwu8WkYTt
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFB9zpD0SBUxJbm9HMRAgmtAJsH29LSrd/2jnlAfXD7CdMiAdkA6wCgxCvX
uRxMQjJHKL8viCmFF9WC57E=
=7TCq
-----END PGP SIGNATURE-----

--5iQfWP9hwu8WkYTt--


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
