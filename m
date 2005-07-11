From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: umount trick for NFS timeouts
Date: Mon, 11 Jul 2005 13:45:46 -0700
Message-ID: <1121114746.10126.38.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-tbaiisMb5ij787X4XUzQ"
Cc: strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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


--=-tbaiisMb5ij787X4XUzQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


This may not be 100% on topic for linux, since contemporary versions
have forced and lazy umounts, but I came up with a way of making it
easier to umount a filesystem on an AIX box, when the NFS server was
gone forever, and we didn't want to reboot the AIX box.

The trick was to create a virtual interface with the same IP address as
the server that was gone forever.  It then became far easier to umount
-f the filesystem.  :)

Only thing is, the DNS resolution on the AIX box got semi-screwy due to
that virtual interface somehow, so it was important to destroy the
virtual interface after the umount had succeeded.

HTH's someone.


--=-tbaiisMb5ij787X4XUzQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBC0tp6o0feVm00f/8RAv+8AJ9cyLMRoQgfOHpEUnRxh8nTXxJX/gCeNpg6
VW2MioV/7+ZPNJ4iMC3BTlg=
=I7L3
-----END PGP SIGNATURE-----

--=-tbaiisMb5ij787X4XUzQ--



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
