Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:55831 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751796AbeBFAY3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Feb 2018 19:24:29 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "rostedt@goodmis.org" <rostedt@goodmis.org>,
        "hacking@nachtgeist.net" <hacking@nachtgeist.net>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: It's back! (Re: [REGRESSION] NFS is creating a hidden port (left
 over from xs_bind() ))
Date: Tue, 6 Feb 2018 00:24:23 +0000
Message-ID: <1517876654.79669.5.camel@primarydata.com>
References: <57220e1f-f81e-b30b-a4ea-39ad74c7c0d6@nachtgeist.net>
In-Reply-To: <57220e1f-f81e-b30b-a4ea-39ad74c7c0d6@nachtgeist.net>
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="=-Dsa4YuRoxRyzJpZuOjC+"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-Dsa4YuRoxRyzJpZuOjC+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2018-02-02 at 22:31 +0100, Daniel Reichelt wrote:
> Hi Trond, Steven,
>=20
> eversince I switched from Debian Jessie to Stretch last summer, I've
> been seeing the very same hidden ports on an NFS server as described
> in
> [1], which is a follow-up to [2].
>=20
> Your patch ([3], [4]) solved the issue back then. Later on, you
> changed
> that fix again in [5], which lead to the situation we're seeing
> today.
>=20
> Reverting 0b0ab51 fixes the issue for me.
>=20
> Let me know if you need more info.
>=20
>=20
>=20
> Thanks
> Daniel
>=20
>=20
> [1] https://lkml.org/lkml/2016/6/30/341
> [2] https://lkml.org/lkml/2015/6/11/803
> [3] https://lkml.org/lkml/2015/6/19/759
> [4] 4876cc779ff525b9c2376d8076edf47815e71f2c
> [5] 4b0ab51db32eba0f48b7618254742f143364a28d

Does the following fix the issue?

8<-----------------------------------------------
=46rom 9b30889c548a4d45bfe6226e58de32504c1d682f Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Mon, 5 Feb 2018 10:20:06 -0500
Subject: [PATCH] SUNRPC: Ensure we always close the socket after a connecti=
on
 shuts down

Ensure that we release the TCP socket once it is in the TCP_CLOSE or
TCP_TIME_WAIT state (and only then) so that we don't confuse rkhunter
and its ilk.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 18803021f242..5d0108172ed3 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -807,13 +807,6 @@ static void xs_sock_reset_connection_flags(struct rpc_=
xprt *xprt)
 	smp_mb__after_atomic();
 }
=20
-static void xs_sock_mark_closed(struct rpc_xprt *xprt)
-{
-	xs_sock_reset_connection_flags(xprt);
-	/* Mark transport as closed and wake up all pending tasks */
-	xprt_disconnect_done(xprt);
-}
-
 /**
  * xs_error_report - callback to handle TCP socket state errors
  * @sk: socket
@@ -833,9 +826,6 @@ static void xs_error_report(struct sock *sk)
 	err =3D -sk->sk_err;
 	if (err =3D=3D 0)
 		goto out;
-	/* Is this a reset event? */
-	if (sk->sk_state =3D=3D TCP_CLOSE)
-		xs_sock_mark_closed(xprt);
 	dprintk("RPC:       xs_error_report client %p, error=3D%d...\n",
 			xprt, -err);
 	trace_rpc_socket_error(xprt, sk->sk_socket, err);
@@ -1655,9 +1645,11 @@ static void xs_tcp_state_change(struct sock *sk)
 		if (test_and_clear_bit(XPRT_SOCK_CONNECTING,
 					&transport->sock_state))
 			xprt_clear_connecting(xprt);
+		clear_bit(XPRT_CLOSING, &xprt->state);
 		if (sk->sk_err)
 			xprt_wake_pending_tasks(xprt, -sk->sk_err);
-		xs_sock_mark_closed(xprt);
+		/* Trigger the socket release */
+		xs_tcp_force_close(xprt);
 	}
  out:
 	read_unlock_bh(&sk->sk_callback_lock);
@@ -2265,14 +2257,19 @@ static void xs_tcp_shutdown(struct rpc_xprt *xprt)
 {
 	struct sock_xprt *transport =3D container_of(xprt, struct sock_xprt, xprt=
);
 	struct socket *sock =3D transport->sock;
+	int skst =3D transport->inet ? transport->inet->sk_state : TCP_CLOSE;
=20
 	if (sock =3D=3D NULL)
 		return;
-	if (xprt_connected(xprt)) {
+	switch (skst) {
+	default:
 		kernel_sock_shutdown(sock, SHUT_RDWR);
 		trace_rpc_socket_shutdown(xprt, sock);
-	} else
+		break;
+	case TCP_CLOSE:
+	case TCP_TIME_WAIT:
 		xs_reset_transport(transport);
+	}
 }
=20
 static void xs_tcp_set_socket_timeouts(struct rpc_xprt *xprt,
--=20
2.14.3

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

--=-Dsa4YuRoxRyzJpZuOjC+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEESQctxSBg8JpV8KqEZwvnipYKAPIFAlp49a4ACgkQZwvnipYK
APL3jQ/+I3rLPwdub2QDL+2dGrkD2RjhdskiMn3kpYdOxbvTOlZ3DKKsBAB8JMLy
+xuaXN7WvDczN4XRVM9+x35FRffzpqjpKbfShfHs6BEQXNYTqIh1llZOUYAucKg3
0TH2hdgx+5SIb7k5Qs2TrrAgbsKShYnZe4AOy8yvNIr8qDeL1QvytFdop0JuQe9c
1b0rsNlP9dllrsVti1UVxJRm7z2mAZQqWOm0bSWiBkcUZyHrMTKKbSAviNauivb6
foJcpu9dA8j+o5utqqOc0g2aVXH/R08GbrS7iMTg5b5rOnaVYqDYwgW2MIURcROh
B+VLpY2yCkpaT8j17CZhOB6vfqCCLynLeFfwfj67YGnsFBqBbbpbHpYHLPgDlh9T
c+VjCNTRL7ZcHxnHBWEujSRaZ+b0efmLBipPx+MSzWQucbqv7b2auqFz2NccTiHx
QCWinsTjDhd75bduoDtX4HFqpG/tv1WG6TdCFpubPWBb2q6uJasraiBGSUd6ztp/
NoNQ3LaYI7BWXggO9oGgkFJz5hJvu5y3dowWrNL5XnVR54FTRfk4TNpXnzVa5MFs
s5mFV4cBQ9daJ9Z+yy3lHW89jtQZ2M2EkFNSKWBnG3TmY5T/dRk7OwY6eZjWOU4x
GKGRnGtxlxMKI/7qwUwPwysCch4+W1+yO4WptXtU6UicPdG21eY=
=kr3V
-----END PGP SIGNATURE-----

--=-Dsa4YuRoxRyzJpZuOjC+--

