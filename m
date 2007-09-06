From: Mike Frysinger <vapier@gentoo.org>
Subject: librpcsecgss-0.15 still uses GSSAPI_CFLAGS
Date: Thu, 6 Sep 2007 13:17:21 -0400
Message-ID: <200709061317.22165.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0352497080=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITKxe-0005xx-3l
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 10:16:10 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ITKxh-0003Er-Jf
	for nfs@lists.sourceforge.net; Thu, 06 Sep 2007 10:16:14 -0700
Received: from localhost (localhost [127.0.0.1])
	by smtp.gentoo.org (Postfix) with ESMTP id 9468664D5D
	for <nfs@lists.sourceforge.net>; Thu,  6 Sep 2007 17:16:11 +0000 (UTC)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0352497080==
Content-Type: multipart/signed; boundary="nextPart10345900.DeBTF8FoPT";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart10345900.DeBTF8FoPT
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

looks like src/Makefile.am needs a quick fixup to use GSSGLUE_CFLAGS rather=
=20
than GSSAPI_CFLAGS ... i'd check cvs to see if this were already done, but =
i=20
have no idea where these projects are kept as they dont seem to be on sf.net
=2Dmike

--nextPart10345900.DeBTF8FoPT
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.6 (GNU/Linux)

iQIVAwUARuA2IkFjO5/oN/WBAQLm4w/+KUoG2e1Aodre38l9IaSZp2x/rAdCiqU8
Np0doOeNvL9J2b9qAgHXjmMevXD83k2g3+UYlyvlqLgxcDOaX9ZWkgpo/67b38li
LTFNA0qFgkKrlgTNwret0iOg5P7hINfp3yxZJC5XxPtCGQhY4RBXC30J/5q4NaFe
p45PgJOmfdaO+aXqhlSgldcaOnE8hD0KsvZFEqd0PGA8Ou0TO9wP+YqvsThFJgGN
pp5o2mp67gxBLEqZN8y0yTeM/xNBupuYJ+1ztgIMW5MX/T4Hg3QUg0UCnrSVPPdD
p34dJrqoO9Trn6a3pxhY+HYIAS3Aq2RRkhperdzBEnxcjXxFx2vmqarQNxht3GmC
zgmKvt4965An33wgGo/1xasJ57RssqkYOcViGKDi9Gg8MfcKJVLxoodmqeSxhOhT
4aZlD6pMtgrMwheL++a98Q+53jRitHCy5SM3cizI0lku0QjLG+TJMtCuusFj4Hv5
wx+U0mVNtOEUFBX/gSEimtpVia1T3xqsn5noEv3NQvbLdQS5oQjrMkU7kyKY9aiS
HwYevmqd1Vq5+NWPyeveMxh4sCw8DPSaijsqrgUAQgc3CzYVSAGtWOSUZCPBNdhH
gSLvFOa8Qci7Z+dUSWiuBLA6x+NapxrtfzEtNPZruxHGYfv5E6sIqEXcSkSiR+su
UkaSUSMsPWQ=
=nZbl
-----END PGP SIGNATURE-----

--nextPart10345900.DeBTF8FoPT--


--===============0352497080==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============0352497080==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0352497080==--
