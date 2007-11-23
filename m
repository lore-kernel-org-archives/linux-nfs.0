From: Timo Sirainen <tss@iki.fi>
Subject: [NFS] NFSv4 close-to-open attr cache flushing broken in 2.6.23
Date: Fri, 23 Nov 2007 10:30:51 +0200
Message-ID: <1195806651.5532.12.camel@hurina>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1245478498=="
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IvTw6-0008L2-Pd
	for nfs@lists.sourceforge.net; Fri, 23 Nov 2007 00:30:54 -0800
Received: from dovecot.org ([82.118.211.50])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IvTwC-0003T6-Fo
	for nfs@lists.sourceforge.net; Fri, 23 Nov 2007 00:31:00 -0800
Received: from [192.168.10.2] (82-203-162-146.dsl.gohome.fi [82.203.162.146])
	by dovecot.org (Postfix) with ESMTP id 8533116471E5
	for <nfs@lists.sourceforge.net>; Fri, 23 Nov 2007 10:30:52 +0200 (EET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--===============1245478498==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-p6E26Oh82S64OtTPfeX0"


--=-p6E26Oh82S64OtTPfeX0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

In v2.6.23 (but not in v2.6.22) a file's attribute cache doesn't get
flushed with close()+open() if the file is open in any process on the
same server. Test program below demonstrates it.

BTW. I thought delegations were supposed to fix most of these caching
issues automatically? I don't see any difference in caching behavior
compared to NFSv3 (Linux 2.6.23 as NFS server).

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

int main(void)
{
	int fd =3D open("foo", O_RDWR | O_CREAT, 0600);
	int fd2 =3D open("foo", O_RDWR);
	struct stat st;
	char buf[1024];

	if (fstat(fd2, &st) < 0) perror("fstat()");
	printf("mtime before =3D %ld\n", st.st_mtime);

	printf("now modify the file on server\n");
	fgets(buf, sizeof(buf), stdin);

	close(fd2);
	fd2 =3D open("foo", O_RDWR);
	if (fstat(fd2, &st) < 0) perror("fstat()");
	printf("mtime after =3D %ld\n", st.st_mtime);
	return 0;
}


--=-p6E26Oh82S64OtTPfeX0
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHRo+6yUhSUUBViskRAhSRAJ4ugxxt/300UaJv49oaPgDCknzonQCeO1ml
D25AI3n2cTYKGwsNPeUxST0=
=+hLN
-----END PGP SIGNATURE-----

--=-p6E26Oh82S64OtTPfeX0--



--===============1245478498==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============1245478498==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============1245478498==--



