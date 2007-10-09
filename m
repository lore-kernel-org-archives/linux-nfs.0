From: "Brian J. Murrell" <brian@interlinx.bc.ca>
Subject: Re: proc/sys/sunrpc/max_resvport
Date: Tue, 09 Oct 2007 17:01:58 -0400
Message-ID: <1191963718.3697.2.camel@pc.ilinx>
References: <1191949933.30724.56.camel@pc.ilinx>
	<1191963460.7052.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1149383459=="
To: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfMDE-00084x-TE
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 14:01:56 -0700
Received: from server.klug.on.ca ([205.189.48.131])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfMDH-0001xj-Q4
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 14:02:02 -0700
Received: from linux.interlinx.bc.ca (d38-139-100.home1.cgocable.net
	[72.38.139.100])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by server.klug.on.ca (Postfix) with ESMTP id F22D72803
	for <nfs@lists.sourceforge.net>; Tue,  9 Oct 2007 17:01:54 -0400 (EDT)
Received: from [10.75.22.1] (pc.ilinx [10.75.22.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by linux.interlinx.bc.ca (Postfix) with ESMTP id 4C22F86F8
	for <nfs@lists.sourceforge.net>; Tue,  9 Oct 2007 17:00:45 -0400 (EDT)
In-Reply-To: <1191963460.7052.1.camel@heimdal.trondhjem.org>
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


--===============1149383459==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-lg/afu8GWRYPaPqBQat1"


--=-lg/afu8GWRYPaPqBQat1
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-10-09 at 16:57 -0400, Trond Myklebust wrote:
>=20
> No. The portmapper is a userland process and has nothing to do
> with /proc/sys/sunrpc/max_resvport.

No wonder I couldn't find the linkage.  :-)

> The latter controls the kernel's sunrpc client port usage _only_.

Hrm.  So that would mean only kernel space rpc services, like nfsd?

I guess there is no way to limit the userspace portmapper the way
max_resvport does for the kernel rpc services then?

b.

--=20
My other computer is your Microsoft Windows server.

Brian J. Murrell

--=-lg/afu8GWRYPaPqBQat1
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHC+xGl3EQlGLyuXARAvexAKDN6+zZeYE4MZCgMbo1qjjfvBYqkgCePpmo
pNSjAYN4ouR9Gscz0iboOpU=
=1izb
-----END PGP SIGNATURE-----

--=-lg/afu8GWRYPaPqBQat1--



--===============1149383459==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1149383459==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1149383459==--
