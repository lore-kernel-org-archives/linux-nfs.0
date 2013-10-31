Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48654 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750783Ab3JaFOu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Oct 2013 01:14:50 -0400
Date: Thu, 31 Oct 2013 16:14:36 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: close a rare race in xs_tcp_setup_socket.
Message-ID: <20131031161436.22969327@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/v5oIjJMgyGddUWh40TBzT6A"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/v5oIjJMgyGddUWh40TBzT6A
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



We have one report of a crash in xs_tcp_setup_socket.
The call path to the crash is:

  xs_tcp_setup_socket -> inet_stream_connect -> lock_sock_nested.

The 'sock' passed to that last function is NULL.

The only way I can see this happening is a concurrent call to
xs_close:

  xs_close -> xs_reset_transport -> sock_release -> inet_release

inet_release sets:
   sock->sk =3D NULL;
inet_stream_connect calls
   lock_sock(sock->sk);
which gets NULL.

All calls to xs_close are protected by XPRT_LOCKED as are most
activations of the workqueue which runs xs_tcp_setup_socket.
The exception is xs_tcp_schedule_linger_timeout.

So presumably the timeout queued by the later fires exactly when some
other code runs xs_close().

To protect against this we can move the cancel_delayed_work_sync()
call from xs_destory() to xs_close().

As xs_close is never called from the worker scheduled on
->connect_worker, this can never deadlock.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ee03d35677d9..b19ba535ae1a 100644
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

--Sig_/v5oIjJMgyGddUWh40TBzT6A
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUnHnPDnsnt1WYoG5AQIpSRAAoy91/TqqmfFL6L3ZbtOXlfTQeo2b5zyB
oGAGuGUGZj8ILG63AYRgiGUBbrfsyuEQNWmAaKEMKqQCqdlnygoCgknOZ6I9QcM5
fjXRYqFSQvRnsvzVYKTLZwli0+eVPLgtG3iuGru7X7tPsSVVCQo2N2X3qfHrgaSD
6MpQM5XQo/syL7aEgTx81hMxcbQ5y8t7XNM/4i1dGeXXvoRjZa7NfYodp7kKmyXU
37otMBQGUc6OCXcyb1hX0J0tUZhARvw8yNz7szzV4m6isM2THcBOOt0ExDQIyNPm
5MzTS5sYPZujA4Pvt8FSggFfDUF25hV77kex3WNHd1Vc69Ma5uzVT+2of+yzcF5q
7zyZ1NevczsbutD1irz1d59KBRO07eDGSgvTvvFHnD/ntqe1faiOzhLgSuTFn8Yi
C35gVudJaAgUyOs5b3yk4qv6T9jYEK/HQNysx6XZ+Cx91ld6QDSfaSWazpDJfhZ4
k5oq60RU34JSh+Bucgukxyl1+tPkfx6xoqMlLR1/BxdPvlXMaFUxLZVsC5qkMXGD
iJ84bjAehq9WC7IZqcDafVxiaNdq5C+PLsPJT/OJNr0mGX7/08iTX6GiM0+PjC+a
bxHZ5LN3jclkRpp6PZxV0z8rGqvurxILAx8/uRiglDkZCN6rncM4XtYI3aQz8P5e
8q+/ayLxQVI=
=kGy2
-----END PGP SIGNATURE-----

--Sig_/v5oIjJMgyGddUWh40TBzT6A--
