From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: overlapping/conflicting entries in
 /proc/net/rpc/nfsd.export/content
Date: Tue, 29 Nov 2005 09:10:40 -0500
Message-ID: <1133273443.25136.66.camel@pc.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-S6OgKVWDdL+wCIn7b5ME"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eh6C6-0002hz-6w
	for nfs@lists.sourceforge.net; Tue, 29 Nov 2005 06:10:54 -0800
Received: from linux.interlinx.bc.ca ([66.11.173.224])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Eh6C4-0007Yo-Gi
	for nfs@lists.sourceforge.net; Tue, 29 Nov 2005 06:10:54 -0800
Received: from pc.ilinx (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 0735CC36DB
	for <nfs@lists.sourceforge.net>; Tue, 29 Nov 2005 09:10:45 -0500 (EST)
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


--=-S6OgKVWDdL+wCIn7b5ME
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I have what seem to be overlapping/conflicting entries
in /proc/net/rpc/nfsd.export/content.  The two entries that seem to
conflict each other are:

/home   10.75.22.0/24,pc.ilinx(rw,no_root_squash,sync,wdelay)
/home   pc.ilinx(rw,no_root_squash,sync,wdelay)

I believe these are the cause of the following messages littering my
syslog:

12:53:27 rpc.mountd /home exported to both 10.75.22.0/24 and pc.ilinx in 10=
.75.22.0/24,pc.ilinx

How do I clean up that /proc/net/rpc/nfsd.export/content?

Thanx,
b.

--=20
My other computer is your Microsoft Windows server.

Brian J. Murrell

--=-S6OgKVWDdL+wCIn7b5ME
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBDjGFgl3EQlGLyuXARAm3rAKDbEQDFICRk5hfreEAXSsctf0QFWwCg2M1f
N7uBa/PXLSUNQdmdV2VEPmk=
=+1HI
-----END PGP SIGNATURE-----

--=-S6OgKVWDdL+wCIn7b5ME--



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
