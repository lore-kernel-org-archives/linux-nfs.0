From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: Re: proc/sys/sunrpc/max_resvport
Date: Thu, 11 Oct 2007 09:53:48 -0400
Message-ID: <1192110828.31407.82.camel@pc.ilinx>
References: <1191949933.30724.56.camel@pc.ilinx>
	<1191963460.7052.1.camel@heimdal.trondhjem.org>
	<1191963718.3697.2.camel@pc.ilinx>
	<1191964149.7052.4.camel@heimdal.trondhjem.org>
	<1191965208.3697.5.camel@pc.ilinx>
	<1191973408.7418.18.camel@heimdal.trondhjem.org>
	<1192029030.31407.35.camel@pc.ilinx>
	<1192110296.8556.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0212546534=="
To: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfyTy-0005U0-WA
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 06:53:47 -0700
Received: from server.klug.on.ca ([205.189.48.131])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfyU4-0002Lm-4L
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 06:53:52 -0700
Received: from linux.interlinx.bc.ca (d38-139-100.home1.cgocable.net
	[72.38.139.100])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id EC26F2803
	for <nfs@lists.sourceforge.net>; Thu, 11 Oct 2007 09:53:44 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 083FB86F8
	for <nfs@lists.sourceforge.net>; Thu, 11 Oct 2007 09:52:27 -0400 (EDT)
In-Reply-To: <1192110296.8556.6.camel@heimdal.trondhjem.org>
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


--===============0212546534==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-PqToxlUXqjA6ZZxnhEv7"


--=-PqToxlUXqjA6ZZxnhEv7
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2007-10-11 at 09:44 -0400, Trond Myklebust wrote:
>=20
> Nope. The job of the portmapper is only to _publish_ those port numbers
> once the server has selected them.

Ahhhh.  I see now.

> That way an rpc client needs only to know the server IP address, the
> port number on which rpc.portmap is running (port number 111), and the
> RPC program number (see /etc/rpc) for the service it is trying to use.

Indeed, this I understood.  I just misunderstood who selected the ports
for the server.

Thanx for all the info!

b.

--=20
My other computer is your Microsoft Windows server.

Brian J. Murrell

--=-PqToxlUXqjA6ZZxnhEv7
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHDirsl3EQlGLyuXARAhx2AJ9vhoa4nqFSFJfLp8deOMp6j8OeiACeK8G6
tYV3UP76R7UOfmBYi+0tKY4=
=5yaj
-----END PGP SIGNATURE-----

--=-PqToxlUXqjA6ZZxnhEv7--



--===============0212546534==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============0212546534==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0212546534==--
