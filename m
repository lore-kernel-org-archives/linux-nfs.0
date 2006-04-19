From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: slow performance -- how to diagnose
Date: Wed, 19 Apr 2006 16:14:05 -0400
Message-ID: <1145477646.12854.152.camel@pc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-w5hXIUOQYty4rFCPf6KU"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FWJ43-00022d-VH
	for nfs@lists.sourceforge.net; Wed, 19 Apr 2006 13:14:15 -0700
Received: from linux.interlinx.bc.ca ([66.11.173.224])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FWJ42-0001PD-7u
	for nfs@lists.sourceforge.net; Wed, 19 Apr 2006 13:14:15 -0700
Received: from pc.interlinx.bc.ca (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 9E657D8D78
	for <nfs@lists.sourceforge.net>; Wed, 19 Apr 2006 16:14:06 -0400 (EDT)
To: nfs@lists.sourceforge.net
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


--=-w5hXIUOQYty4rFCPf6KU
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I'm experiencing some slow performance that I have done some initial
diagnosis as per http://nfs.sourceforge.net/nfs-howto/performance.html
but not sure where to go from here.

I have tried both UDP and TCP and in fact UDP performance seems to be
slightly worse.

The connection between a client and the server is gige and seems to
perform pretty close to such using ttcp:

ttcp-t: 819200000 bytes in 7.368 real seconds =3D 848.299 Mbit/sec +++
ttcp-t: 819200000 bytes in 7.01 real seconds =3D 891.19 Mbit/sec +++

The first is from client to server and the second server to client.
Both seem reasonable.

The speed of the disk on the server using a simple dd test:

# time dd if=3D/dev/zero of=3Dfile bs=3D1M count=3D4000
4000+0 records in
4000+0 records out

real    2m28.756s
user    0m0.024s
sys     0m17.141s

(1024*1024*4000)/148.7/(1024*1024)*8 =3D=3D 26.899 MB/sec =3D=3D 215.192Mbi=
t/s

But from an NFS client...

# rsh client5 "(cd $(pwd);time dd if=3D/dev/zero of=3Dfile bs=3D1M count=3D=
1000)"
1000+0 records in
1000+0 records out

real    1m21.036s
user    0m0.006s
sys     0m1.982s

(1024*1024*1000)/81.036/(1024*1024) =3D=3D 12.340 MB/sec

Any ideas where to look?

b.

--=20
My other computer is your Microsoft Windows server.

Brian J. Murrell

--=-w5hXIUOQYty4rFCPf6KU
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQBERpoNl3EQlGLyuXARAneEAJwJ1+/lXB9Me6RzeGEyhpAEZGsSagCcDTGf
nXVy6OF10gGsqCvb989nC/k=
=9fyQ
-----END PGP SIGNATURE-----

--=-w5hXIUOQYty4rFCPf6KU--



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
