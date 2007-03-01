From: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
Subject: nfs-client 2.6.20 bizarre ro-mount
Date: Thu, 1 Mar 2007 16:25:48 +0100
Message-ID: <200703011625.51457.ulrich.gemkow@ikr.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0548344012=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMnBD-0004Fq-8c
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 07:26:51 -0800
Received: from wall.ikr.uni-stuttgart.de ([129.69.170.1])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HMnBA-0000w3-Ll
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 07:26:50 -0800
Received: from netsrv1.ikr.uni-stuttgart.de (netsrv1-c [10.11.12.12])
	by wall.ikr.uni-stuttgart.de (Postfix) with ESMTP id 1BA8156CC2
	for <nfs@lists.sourceforge.net>; Thu,  1 Mar 2007 16:25:52 +0100 (CET)
Received: from ikr.uni-stuttgart.de (pc150 [10.21.21.150])
	by netsrv1.ikr.uni-stuttgart.de (Postfix) with SMTP id 8BDBBBC07E
	for <nfs@lists.sourceforge.net>; Thu,  1 Mar 2007 16:25:51 +0100 (CET)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0548344012==
Content-Type: multipart/signed; boundary="nextPart3502686.maRbv4Y0o3";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart3502686.maRbv4Y0o3
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello,

I have a rather bizare problems with the nfs-client in
Linux 2.6.20, the previously used kernel 2.6.17 worked fine:

=46or one specific filesystem, which is exported rw, the client
mounts the filesystem (according to /proc/mounts) as ro=20
despite the fact that the mount-command asks to mount
it rw.

When doing a "mount -o remount,rw ..." after the first mount
the filesystem is writable and all is fine (and /proc/mounts
shows the mountpoint as "rw").

To make things more interesting, when doing a second mount
after the rw-remount, the mount is writable. So it seems=20
that the _first_ mount for the mountpoint fails.

The mountpoint is located in a ramdisc.

The problem does not happen with client kernel 2.6.17. The=20
configuration besides the kernel is unchanged. It only happens
with one filesystem, other filesystems from the same server
are mounted rw as requested. For us it is always reproducible
for all our clients. I found nothing special for this problematic
filesystem.

Server kernel is Linux vanilla 2.6.17 (unchanged), distribution
is Fedora Core 6 for client and server.

I checked really careful that nothing else besides the kernel
changes in the systems and that there is no obvious "user error".

Has anyone a glue? The workaround is simple (remount) but I=20
do not understand the changed behaviour.

Thanks in advance

=2DUlrich

=2D-=20
|-----------------------------------------------------------------------
| Ulrich Gemkow
| University of Stuttgart
| Institute of Communication Networks and Computer Engineering (IKR)
|-----------------------------------------------------------------------

--nextPart3502686.maRbv4Y0o3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBF5vB/7bxSwnjsAMgRAgnAAKCW3OWtInYrVV4UzSTZNhBSwm/4KwCgvWLJ
dcLYLHlbyHYk4l/f6d5p+7c=
=Q+aK
-----END PGP SIGNATURE-----

--nextPart3502686.maRbv4Y0o3--


--===============0548344012==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0548344012==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0548344012==--
