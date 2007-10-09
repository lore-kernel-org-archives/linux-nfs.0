From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: proc/sys/sunrpc/max_resvport
Date: Tue, 09 Oct 2007 13:12:13 -0400
Message-ID: <1191949933.30724.56.camel@pc.ilinx>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1908163460=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfIcq-0000WX-FR
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 10:12:08 -0700
Received: from server.klug.on.ca ([205.189.48.131])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfIcu-0001pW-GM
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 10:12:13 -0700
Received: from linux.interlinx.bc.ca (d38-139-100.home1.cgocable.net
	[72.38.139.100])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 7D3B52803
	for <nfs@lists.sourceforge.net>; Tue,  9 Oct 2007 13:12:09 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 305C486F8
	for <nfs@lists.sourceforge.net>; Tue,  9 Oct 2007 13:11:00 -0400 (EDT)
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


--===============1908163460==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-iRfwz7ZGHWQ65eG78ikO"


--=-iRfwz7ZGHWQ65eG78ikO
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I've been trying to link /proc/sys/sunrpc/max_resvport to the process
the portmapper uses to allocate ports from but have not found it.  So
perhaps somebody here can answer what I hope is a simple question.

Can /proc/sys/sunrpc/max_resvport be used to limit (the upper bound of)
the port range that the portmapper will allocate for all RPC servcies?
If I set it to, say, 900, I can be guaranteed that no RPC servers will
get bound to ports > 900?

Thanx,
b.

--=20
My other computer is your Microsoft Windows server.

Brian J. Murrell

--=-iRfwz7ZGHWQ65eG78ikO
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHC7Ztl3EQlGLyuXARAgNpAJ9A2ZN74OQU9mNiPtlDQ+9AEaDAKwCdGXA6
0CWIWboIkjigbWxStWf5E0w=
=4l73
-----END PGP SIGNATURE-----

--=-iRfwz7ZGHWQ65eG78ikO--



--===============1908163460==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1908163460==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1908163460==--
