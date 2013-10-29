Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:41272 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab3J2GmQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 02:42:16 -0400
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx2.suse.de (Postfix) with ESMTP id E28FAA585B
	for <linux-nfs@vger.kernel.org>; Tue, 29 Oct 2013 07:42:14 +0100 (CET)
Date: Tue, 29 Oct 2013 17:42:04 +1100
From: NeilBrown <neilb@suse.de>
To: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH/RFC] - hard-to-hit race in xprtsock.
Message-ID: <20131029174204.7f6578d4@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/AoOFjZ0RtK/ksxfsqOU3Zop"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/AoOFjZ0RtK/ksxfsqOU3Zop
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


We have a customer who hit a rare race in sunrpc (in a 3.0 based kernel,
but the relevant code doesn't seem to have changed much).

The thread that crashed was in=20
  xs_tcp_setup_socket -> inet_stream_connect -> lock_sock_nested.

'sock' in this last function is NULL.

The only way I can imagine this happening is if some other thread called

 xs_close -> xs_reset_transport -> sock_release -> inet_release

in a very small window a moment earlier.

As far as I can tell, xs_close is only called with XPRT_LOCKED set.

xs_tcp_setup_socket is mostly scheduled with XPRT_LOCKED set to which would
exclude them from running at the same time.


However xs_tcp_schedule_linger_timeout can schedule the thread which runs
xs_tcp_setup_socket without first claiming XPRT_LOCKED.
So I assume that is what is happening.

I imagine some race between the client closing the socket, and getting
TCP_FIN_WAIT1 from the server and somehow the two threads racing.

I wonder if it might make sense to always abort 'connect_worker' in
xs_close()?
I think the connect_worker really mustn't be running or queued at this poin=
t,
so cancelling it is either a no-op, or vitally important.

So: does the following patch seem reasonable?  If so I'll submit it properly
with a coherent description etc.

Thanks,
NeilBrown



diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ee03d35..b19ba53 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -835,6 +835,8 @@ static void xs_close(struct rpc_xprt *xprt)
=20
 	dprintk("RPC:       xs_close xprt %p\n", xprt);
=20
+	cancel_delayed_work_sync(&transport->connect_worker);
+
 	xs_reset_transport(transport);
 	xprt->reestablish_timeout =3D 0;
=20
@@ -869,12 +871,8 @@ static void xs_local_destroy(struct rpc_xprt *xprt)
  */
 static void xs_destroy(struct rpc_xprt *xprt)
 {
-	struct sock_xprt *transport =3D container_of(xprt, struct sock_xprt, xprt=
);
-
 	dprintk("RPC:       xs_destroy xprt %p\n", xprt);
=20
-	cancel_delayed_work_sync(&transport->connect_worker);
-
 	xs_local_destroy(xprt);
 }
=20


--Sig_/AoOFjZ0RtK/ksxfsqOU3Zop
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUm9YvDnsnt1WYoG5AQLmOhAAsC3yKnQUvct4gcmOUz0ttCkfxt5aSJtB
CNEzmWZXorE6SwBKgFY0GvaufTzyp0FeIlAm7QXV5Ugcpy3BgEprsy1vN1na00pS
Xf6zx7CNSpKNUfYcMIPCVIGZFyQmbwjUocZxKJR1Tr2lbUlYBu01F3rjL31rDTGu
jx7wJnJYYmg2B8BxvBjlKJNa0fFe4jfPg72bDGvxycCIyUjqu8/I8jSWGkL+Kb9c
knC+qRVtNbu6sllF1gQ6ke0qlQRypWA02X7aLJtpjAj/PoJxCmv+y70vuFz+mtXU
gZcMsP6x2ufUzdc9wwCNYE8fH5Z/IUjQ1Rsu0k7X/0dElOBqs6KHClHzWCCQRsRB
PYVV5+FE+9Kf9/fEPBJZq8DmKJWgj1Z0kTHr1TZAUKt5GA9K2xkeqT++bTLf01Ij
xs+T9s66XBV5mJYDvQqU+2GcUKCeLJYXaeVIlVz6C96F9L6iqcKFwENVCDDt4FhB
W/X5Sb0aUXaLWbe0DdwrgXWZHVi+xPttDI9P7o9XU8VsuboMrhfmeGKd0taR1u3y
VTC0YvPf5DzGgUqElnNEbT2OxJ70EGW9GvHNyqjwo0QEPi6MKp+pEqARZ+DqwGG5
SFtYRQtyO4hftqH5yUkTBXAacyX31C4fGnB23I6O4t5BzXVtJB5m+XsEVEq9I56P
ub/ojwMkf/g=
=+6Uz
-----END PGP SIGNATURE-----

--Sig_/AoOFjZ0RtK/ksxfsqOU3Zop--
