From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] Stop recvfrom errors from killing nfsd
Date: Tue, 21 Sep 2004 11:54:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040921095414.GP22254@suse.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-md5;
	protocol="application/pgp-signature"; boundary="/WwmFnJnmDyWGHa4"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C9hLn-0000R4-5x
	for nfs@lists.sourceforge.net; Tue, 21 Sep 2004 02:54:19 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1C9hLl-0004tc-FQ
	for nfs@lists.sourceforge.net; Tue, 21 Sep 2004 02:54:19 -0700
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 023DCC3D477
	for <nfs@lists.sourceforge.net>; Tue, 21 Sep 2004 11:54:14 +0200 (CEST)
To: nfs@lists.sourceforge.net
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


--/WwmFnJnmDyWGHa4
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Content-Disposition: inline


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

I just looked into a customer report about nfsd processes terminating
because svc_recv() returned -107.

This is caused by svc_tcp_recvfrom propagating errors such as ENOTCONN
and ECONNRESET up to svc_recv, which is not equipped to deal with this.
svc_recv expects the return value from svsk->sk_recvfrom to be either
positive (a packet length), 0 (accept call or incomplete record), or
-EAGAIN (no data). Any other error codes are treated just like a packet
length.

The original code in svc_tcp_recvfrom would always kill the socket
when it got an unexpected error, and return EAGAIN. This was changed
some time between 2.4.18 and 2.4.21 - I don't know for what reasons.

The patch below reverts that change.

Alternatively, we could add special case treatment for certain error codes;
e.g. propagating EINTR up to nfsd while making ECONNRESET and ENOTCONN
simply kill the connection.

Cheers,
Olaf
--=20
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+=20

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=sunrpc-svc-recv-errors
Content-Transfer-Encoding: quoted-printable

=46rom: Olaf Kirch <okir@suse.de>

svc_recv is not equipped to deal with error codes other than EAGAIN,
and will propagate anything else (such as ECONNRESET) up to nfsd,
causing it to exit.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: 2.4.21/net/sunrpc/svcsock.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- 2.4.21.orig/net/sunrpc/svcsock.c	2003-06-13 16:51:39.000000000 +0200
+++ 2.4.21/net/sunrpc/svcsock.c	2004-09-20 13:11:53.000000000 +0200
@@ -894,7 +894,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	} else {
 		printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
 					svsk->sk_server->sv_name, -len);
-		svc_sock_received(svsk);
+		goto err_delete;
 	}
=20
 	return len;

--J2SCkAp4GZ/dPZZf--

--/WwmFnJnmDyWGHa4
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: what?

iQCVAwUBQU/6ROFnVHXv40etAQGYSQQAvIkCS21lS76dfdTzuuqY8+ojLyv1i6qB
C5t1N4L8IIuJG/CC7wINQ1/KJj+xx5rJ5TkGfrAxQSjxEtVIRmdoG74+i4iI1/zI
j4hjGrpxwnGvLheBS0alLhRmG5MObp9we8izaHo7WwtLtBwccPHXCmfHL5mdaTCf
jQwevoo2QLc=
=C4mq
-----END PGP SIGNATURE-----

--/WwmFnJnmDyWGHa4--


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
