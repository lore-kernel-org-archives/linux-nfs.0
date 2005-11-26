From: Nico Golde <nico@ngolde.de>
Subject: NFS mounted but errors occur
Date: Sat, 26 Nov 2005 18:48:11 +0100
Message-ID: <20051126174811.GA19128@ngolde.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gBBFr7Ir9EOA20Yy"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eg4W6-0002q1-Bw
	for nfs@lists.sourceforge.net; Sat, 26 Nov 2005 10:11:18 -0800
Received: from natfrord.rzone.de ([81.169.145.161])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Eg4W0-0000xA-1w
	for nfs@lists.sourceforge.net; Sat, 26 Nov 2005 10:11:18 -0800
Received: from ngolde.de (e178113209.adsl.alicedsl.de [85.178.113.209])
	by post.webmailer.de (8.13.1/8.13.1) with ESMTP id jAQIB5Z3008887
	for <nfs@lists.sourceforge.net>; Sat, 26 Nov 2005 19:11:05 +0100 (MET)
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


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,
I have compiled in v2 and v3 support. I mount an nfs share=20
and it works (it shows the shared directories). If i try to=20
do an ls command in a share with some files the whole thing=20
breaks and ls hangs.

/var/log/syslog says:
Nov 14 00:30:55 noname kernel: nfs: server 192.168.0.4 not=20
responding, still trying

This is somehow strange. ls in share, which has got many=20
files in the root will fail immediatly.
I made a tcpdump, you can find it at:=20
http://nion.modprobe.de/nfs.dump

I found noone who can help me and nfsd and portmap are=20
running correclty. The NFS worked until ome day :(
I use nfs kernel server but the problem is independent from=20
the used kernel.
Regards Nico
P.S. Please CC me I am not subscribed.

--=20
Nico Golde - JAB: nion@jabber.ccc.de | GPG: 0x73647CFF
http://www.ngolde.de | http://www.muttng.org | http://grml.org
Forget about that mouse with 3/4/5 buttons -
gimme a keyboard with 103/104/105 keys!

--gBBFr7Ir9EOA20Yy
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFDiJ/bHYflSXNkfP8RAlnkAJ0dQ7vIDFyAU2FOBi7PsaYyLxCrmwCfZHJU
aVlGJDcdfZHFOldnycTbtqQ=
=MMbo
-----END PGP SIGNATURE-----

--gBBFr7Ir9EOA20Yy--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
