From: Garrick Staples <garrick@usc.edu>
Subject: Re: nfsd threads locked, 2.6.7 & ia64
Date: Sun, 27 Jun 2004 19:09:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040628020944.GY10560@polop.usc.edu>
References: <20040627051129.GS10560@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="yrEcvySKR+fOA8iz"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Belab-00037a-GV
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 19:09:45 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1Belab-0001sz-7R
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 19:09:45 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id i5S29iGF006698
	for <nfs@lists.sourceforge.net>; Sun, 27 Jun 2004 19:09:44 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id i5S29iZm006696
	for nfs@lists.sourceforge.net; Sun, 27 Jun 2004 19:09:44 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040627051129.GS10560@polop.usc.edu>
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


--yrEcvySKR+fOA8iz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 26, 2004 at 10:11:29PM -0700, Garrick Staples alleged:
> Well here's something I've not seen yet.  All 512 nfsd threads are stuck =
in IO
> wait (state D in ps).  All clients are hung on that mount.  The actual
> filesystem on the server seems fine.

I just ran a few 'find's through the 4TB filesystem and 1 of them got stuck=
=2E  I
guess the filesystem hosed itself.  Guess I'll go back to reiser.

*sigh*  I just found this patch for random data corruption over NFS.
http://linus.bkbits.net:8080/linux-2.5/cset@40d263bcB5wLHA2ALqKxBm1mzuGiFw?=
nav=3Dindex.html|tags|ChangeSet@1.1722.149.18..

But it doesn't mention anything about getting stuck in IO wait.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--yrEcvySKR+fOA8iz
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFA333o0SBUxJbm9HMRApgcAKCSutkWpgKWn/XGzaOx/f2OHdhyugCgtqQo
wWhZNnvcQtF2iqkl/EFWjYc=
=Lh7T
-----END PGP SIGNATURE-----

--yrEcvySKR+fOA8iz--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
