From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: Re: proc/sys/sunrpc/max_resvport
Date: Wed, 10 Oct 2007 11:10:30 -0400
Message-ID: <1192029030.31407.35.camel@pc.ilinx>
References: <1191949933.30724.56.camel@pc.ilinx>
	<1191963460.7052.1.camel@heimdal.trondhjem.org>
	<1191963718.3697.2.camel@pc.ilinx>
	<1191964149.7052.4.camel@heimdal.trondhjem.org>
	<1191965208.3697.5.camel@pc.ilinx>
	<1191973408.7418.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1141202300=="
To: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfdCc-0003Pq-Ht
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 08:10:26 -0700
Received: from server.klug.on.ca ([205.189.48.131])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfdCf-0002r1-Eh
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 08:10:31 -0700
Received: from linux.interlinx.bc.ca (d38-139-100.home1.cgocable.net
	[72.38.139.100])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id 172F52803
	for <nfs@lists.sourceforge.net>; Wed, 10 Oct 2007 11:10:26 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 4E7758705
	for <nfs@lists.sourceforge.net>; Wed, 10 Oct 2007 11:09:13 -0400 (EDT)
In-Reply-To: <1191973408.7418.18.camel@heimdal.trondhjem.org>
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


--===============1141202300==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-oWKXCn3zXWt0nhT5t/jw"


--=-oWKXCn3zXWt0nhT5t/jw
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-10-09 at 19:43 -0400, Trond Myklebust wrote:
>=20
> There are two ports involved in an IP connection: one source port (i.e.
> the client) and one destination port (i.e. the server). If bind() is run
> on a socket that was set up by the client, it will set the source port
> for the connection.

I see where this is going.  I had not considered that one might want to
set a range of ports that the client uses.

> The reason why an RPC client would want to select a particular port
> number is that for most *NIX setups, the ports with number < 1024 will
> usually require root privileges to bind() to.

Indeed.  The insecurity of putting (even a tiny amount of) trust in a
remote application using a port < 1024 aside.  :-)

> By requiring that RPC
> calls must originate from such a 'privileged port', an NFS server can
> therefore make it slightly harder for an unprivileged process on that
> machine to spoof NFS requests.

Sure.

> See the 'secure' and 'insecure' export options on 'man 5 exports'.

Yeah.  I'm familiar with them.  I had just not drawn the link from that
to this sysctl being for limiting the client bind address.

> Not really. portmap doesn't choose the port numbers: the server
> processes themselves choose that number, and so they are the ones that
> you need to fix up.

Hrm?  Really?  I thought the process of registering an RPC server with
the port mapper involved the port mapper finding an available port for
it to run on.  I thought that was whole point of the port mapper -- to
allocate ports out of a "limited" pool of available ports for services
that wanted to be available -- rather than the more traditional
"officially assigned port"-from-IANA method of getting a port number.

b.

--=20
My other computer is your Microsoft Windows server.

Brian J. Murrell

--=-oWKXCn3zXWt0nhT5t/jw
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHDOtml3EQlGLyuXARApxiAJ4tSI7yeDlQ0AQlkGoajxpfw+NRiQCg0Tsb
AHd0bwADqFymRLBIhEQTAtI=
=sMR2
-----END PGP SIGNATURE-----

--=-oWKXCn3zXWt0nhT5t/jw--



--===============1141202300==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1141202300==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1141202300==--
