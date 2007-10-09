From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: Re: proc/sys/sunrpc/max_resvport
Date: Tue, 09 Oct 2007 17:26:48 -0400
Message-ID: <1191965208.3697.5.camel@pc.ilinx>
References: <1191949933.30724.56.camel@pc.ilinx>
	<1191963460.7052.1.camel@heimdal.trondhjem.org>
	<1191963718.3697.2.camel@pc.ilinx>
	<1191964149.7052.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1994138116=="
To: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfMbC-00021c-7A
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 14:26:42 -0700
Received: from server.klug.on.ca ([205.189.48.131])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfMbG-00022J-9U
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 14:26:47 -0700
Received: from linux.interlinx.bc.ca (d38-139-100.home1.cgocable.net
	[72.38.139.100])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id E7F002803
	for <nfs@lists.sourceforge.net>; Tue,  9 Oct 2007 17:26:44 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 5720386F8
	for <nfs@lists.sourceforge.net>; Tue,  9 Oct 2007 17:25:34 -0400 (EDT)
In-Reply-To: <1191964149.7052.4.camel@heimdal.trondhjem.org>
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


--===============1994138116==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-/5Y/SS6XVqlyaugWuR2n"


--=-/5Y/SS6XVqlyaugWuR2n
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-10-09 at 17:09 -0400, Trond Myklebust wrote:
>=20
> The client processes only. IOW: the nfs client, lockd client and the
> posix acl client.

I'm sure I'm missing something obvious here, but isn't it the server
that (chooses and) binds to a port?  What effect does a "max port" have
on a client when it has to bind to the port the server chose/was given?

> Not as far as I know.

Pity.

b.

--=20
My other computer is your Microsoft Windows server.

Brian J. Murrell

--=-/5Y/SS6XVqlyaugWuR2n
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHC/IYl3EQlGLyuXARAts2AJ97+HSv1LY5QMiXh9YJ6rR80hlhdQCfaNIN
FVhZcmuPqmI7HMEe80kyGXY=
=GmoJ
-----END PGP SIGNATURE-----

--=-/5Y/SS6XVqlyaugWuR2n--



--===============1994138116==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1994138116==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1994138116==--
