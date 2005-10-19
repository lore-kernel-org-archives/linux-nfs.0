From: Garrick Staples <garrick@usc.edu>
Subject: Re: Accelerating 'mountd'
Date: Wed, 19 Oct 2005 11:36:57 -0700
Message-ID: <20051019183657.GX27890@polop.usc.edu>
References: <dj5r3h$rqm$1@osprey.mgras.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="35kA0bP2/aOd7joH"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESIoD-0003Vd-4o
	for nfs@lists.sourceforge.net; Wed, 19 Oct 2005 11:37:05 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ESIoC-0003RL-11
	for nfs@lists.sourceforge.net; Wed, 19 Oct 2005 11:37:05 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.11/8.12.11) with ESMTP id j9JIav1e017692
	for <nfs@lists.sourceforge.net>; Wed, 19 Oct 2005 11:36:57 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.11/8.12.11/Submit) id j9JIav75017690
	for nfs@lists.sourceforge.net; Wed, 19 Oct 2005 11:36:57 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <dj5r3h$rqm$1@osprey.mgras.de>
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


--35kA0bP2/aOd7joH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 19, 2005 at 04:09:21PM +0000, Martin Spott alleged:
> 2.) Are there typical environments that degrade the performance of the
>     'mountd' where I should have a closer look at ?

I'm far from an NFS expert, but I've always seen slow mounts come from
slow or missing DNS resolution.  Simply adding the clients to the
server's /etc/hosts and running nscd can often make a huge difference.

--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--35kA0bP2/aOd7joH
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFDVpJJ0SBUxJbm9HMRAhjDAJ9znJF9k1DgF66vO7R2LtN6YQsVdwCdFoai
uBqCWMUTzKRerK5eSrO3tfI=
=+qHo
-----END PGP SIGNATURE-----

--35kA0bP2/aOd7joH--


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
