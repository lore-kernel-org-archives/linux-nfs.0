From: seth vidal <skvidal@phy.duke.edu>
Subject: troubling interaction with quotas and nfs
Date: 09 Apr 2002 00:19:07 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1018325948.2639.67.camel@milo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-3rbW8aLOTPSqBT21LU7o"
Received: from mail.phy.duke.edu ([152.3.182.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16unAA-0000WV-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 21:23:22 -0700
Received: from user-152-16-65-47.adsl.duke.edu (user-152-16-65-47.adsl.duke.edu [152.16.65.47])
	by mail.phy.duke.edu (Postfix) with ESMTP id 80C8E303A8
	for <nfs@lists.sourceforge.net>; Tue,  9 Apr 2002 00:23:19 -0400 (EDT)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--=-3rbW8aLOTPSqBT21LU7o
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi all,
 I'm running red hat 7.2 with the 2.4.9-31 kernel.
Its an ext3 file system, exported for nfsv3 udp and nfsv2 clients.

nothing fancy at all.

I have quotas set for my users. If a user hits their hard quota and the
process continues to attempt to write to a file in their  quota'd space
- the process load on the server shoots through the roof.=20

I can reliably recreate this by setting a hard quota, having the system
hit the hard quota and continue to attempt to write to that file - the
server becomes terribly unhappy.

I never saw this problem on older 2.2.X servers and I'm not sure why I'm
seeing it now.

Any places I should be looking first?

thanks
-sv

--=20
GPG Public Key: http://www.phy.duke.edu/~skvidal/skvidal.gpg

--=-3rbW8aLOTPSqBT21LU7o
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA8smu71Aj3x2mIbMcRAlnQAJoDgUaqKcdmPwHfDl3gITJQhWMpsQCfZ7nv
tNuj5t+qGYtnefauIOjbOD0=
=H7Dr
-----END PGP SIGNATURE-----

--=-3rbW8aLOTPSqBT21LU7o--


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
