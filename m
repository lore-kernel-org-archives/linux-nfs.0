From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: intermittent EPERM
Date: Wed, 04 Oct 2006 07:36:41 -0400
Message-ID: <1159961801.9991.11.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2083913738=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GV53S-0004jZ-B4
	for nfs@lists.sourceforge.net; Wed, 04 Oct 2006 04:36:50 -0700
Received: from linux.interlinx.bc.ca ([66.11.173.224])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GV53Q-0000WS-S3
	for nfs@lists.sourceforge.net; Wed, 04 Oct 2006 04:36:51 -0700
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 28989EC338
	for <nfs@lists.sourceforge.net>; Wed,  4 Oct 2006 07:36:42 -0400 (EDT)
To: nfs@lists.sourceforge.net
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


--===============2083913738==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-C1Ov5TmJYhSxLAYY2m1B"


--=-C1Ov5TmJYhSxLAYY2m1B
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Since having upgraded my Ubuntu (edgy) kernel I have noticed the last
few revs of it cause intermittent EPERM errors on NFS clients.  For
example:

brian@pc:~$ sudo mount pc:/home/brian /mnt/test
brian@pc:~$ cd /mnt/test
brian@pc:/mnt/test$ cat .bash_profile
cat: .bash_profile: Permission denied
brian@pc:/mnt/test$ cat .bash_profile
cat: .bash_profile: Permission denied
brian@pc:/mnt/test$ cat .bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

It took three attempts at reading that file to not get an EPERM.

Is this a known issue of any sort?

Thanx,
b.

--=20
My other computer is your Microsoft Windows server.

Brian J. Murrell

--=-C1Ov5TmJYhSxLAYY2m1B
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQBFI5zJl3EQlGLyuXARApaCAJ9Z1foH03AmChf3WeH2gRgXlFknvwCg+uc1
ftpXeKGl7gF7L6EMO4EvuVc=
=yCOj
-----END PGP SIGNATURE-----

--=-C1Ov5TmJYhSxLAYY2m1B--



--===============2083913738==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============2083913738==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============2083913738==--
