From: Garrick Staples <garrick@usc.edu>
Subject: Re: force unmount not working 2.4.22
Date: Sat, 9 Oct 2004 14:41:56 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041009214156.GV7742@polop.usc.edu>
References: <Pine.LNX.4.58.0410091031520.1370@donald.themaw.net> <20041009212231.78436.qmail@web20524.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="I0JUXUhnehxKnLt4"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CGOzJ-0005f0-8u
	for nfs@lists.sourceforge.net; Sat, 09 Oct 2004 14:42:49 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CGOzC-0002Yv-2t
	for nfs@lists.sourceforge.net; Sat, 09 Oct 2004 14:42:49 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i99LfuGK031480
	for <nfs@lists.sourceforge.net>; Sat, 9 Oct 2004 14:41:56 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i99Lfuqr031478
	for nfs@lists.sourceforge.net; Sat, 9 Oct 2004 14:41:56 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20041009212231.78436.qmail@web20524.mail.yahoo.com>
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


--I0JUXUhnehxKnLt4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Oct 09, 2004 at 02:22:31PM -0700, Goutham Kurra alleged:
>=20
> Force unmount simply isn't working on a standard linux
> 2.4.22 kernel. Isn't it supposed to unmount NFS
> filesystems no matter what?
>=20
> In my case, the backend server is still up and
> working, I have a "tail -f /mnt/nfs/foo" of some file
> on the mount, and "umount -f" fails with "device or
> resource is busy"

I don't believe force is useful in this case, what you want is -l.

   -f     Force unmount (in case of an unreachable NFS system).  (Requires
          kernel 2.1.116 or later.)

   -l     Lazy unmount. Detach the filesystem from the filesystem  hierar-
          chy now, and cleanup all references to the filesystem as soon as
          it is not busy anymore.  (Requires kernel 2.4.11 or later.)

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--I0JUXUhnehxKnLt4
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFBaFsk0SBUxJbm9HMRAur2AKCZn0UoO/i6DLu6oJ15uH8izErH4QCgobpK
OkZmHtsWIJI3bigHjORAAkU=
=KyrA
-----END PGP SIGNATURE-----

--I0JUXUhnehxKnLt4--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
