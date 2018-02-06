Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:30525 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751554AbeBFT0f (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Feb 2018 14:26:35 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "rostedt@goodmis.org" <rostedt@goodmis.org>,
        "hacking@nachtgeist.net" <hacking@nachtgeist.net>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: It's back! (Re: [REGRESSION] NFS is creating a hidden port (left
 over from xs_bind() ))
Date: Tue, 6 Feb 2018 19:26:29 +0000
Message-ID: <1517945183.39096.4.camel@primarydata.com>
References: <57220e1f-f81e-b30b-a4ea-39ad74c7c0d6@nachtgeist.net>
         <1517876654.79669.5.camel@primarydata.com>
         <9518bb1f-ad0a-2c33-d3fc-78550be06a0c@nachtgeist.net>
In-Reply-To: <9518bb1f-ad0a-2c33-d3fc-78550be06a0c@nachtgeist.net>
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="=-t+YRnEZijbyrem38IAFf"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-t+YRnEZijbyrem38IAFf
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2018-02-06 at 10:20 +0100, Daniel Reichelt wrote:
> On 02/06/2018 01:24 AM, Trond Myklebust wrote:
> > Does the following fix the issue?
> >=20
> > 8<-----------------------------------------------
> > From 9b30889c548a4d45bfe6226e58de32504c1d682f Mon Sep 17 00:00:00
> > 2001
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > Date: Mon, 5 Feb 2018 10:20:06 -0500
> > Subject: [PATCH] SUNRPC: Ensure we always close the socket after a
> > connection
> >  shuts down
> >=20
> > Ensure that we release the TCP socket once it is in the TCP_CLOSE
> > or
> > TCP_TIME_WAIT state (and only then) so that we don't confuse
> > rkhunter
> > and its ilk.
> >=20
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  net/sunrpc/xprtsock.c | 23 ++++++++++-------------
> >  1 file changed, 10 insertions(+), 13 deletions(-)
> >=20
> > diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> > index 18803021f242..5d0108172ed3 100644
> > --- a/net/sunrpc/xprtsock.c
> > +++ b/net/sunrpc/xprtsock.c
> > @@ -807,13 +807,6 @@ static void
> > xs_sock_reset_connection_flags(struct rpc_xprt *xprt)
> >  	smp_mb__after_atomic();
> >  }
> > =20
> > -static void xs_sock_mark_closed(struct rpc_xprt *xprt)
> > -{
> > -	xs_sock_reset_connection_flags(xprt);
> > -	/* Mark transport as closed and wake up all pending tasks
> > */
> > -	xprt_disconnect_done(xprt);
> > -}
> > -
> >  /**
> >   * xs_error_report - callback to handle TCP socket state errors
> >   * @sk: socket
> > @@ -833,9 +826,6 @@ static void xs_error_report(struct sock *sk)
> >  	err =3D -sk->sk_err;
> >  	if (err =3D=3D 0)
> >  		goto out;
> > -	/* Is this a reset event? */
> > -	if (sk->sk_state =3D=3D TCP_CLOSE)
> > -		xs_sock_mark_closed(xprt);
> >  	dprintk("RPC:       xs_error_report client %p,
> > error=3D%d...\n",
> >  			xprt, -err);
> >  	trace_rpc_socket_error(xprt, sk->sk_socket, err);
> > @@ -1655,9 +1645,11 @@ static void xs_tcp_state_change(struct sock
> > *sk)
> >  		if (test_and_clear_bit(XPRT_SOCK_CONNECTING,
> >  					&transport->sock_state))
> >  			xprt_clear_connecting(xprt);
> > +		clear_bit(XPRT_CLOSING, &xprt->state);
> >  		if (sk->sk_err)
> >  			xprt_wake_pending_tasks(xprt, -sk-
> > >sk_err);
> > -		xs_sock_mark_closed(xprt);
> > +		/* Trigger the socket release */
> > +		xs_tcp_force_close(xprt);
> >  	}
> >   out:
> >  	read_unlock_bh(&sk->sk_callback_lock);
> > @@ -2265,14 +2257,19 @@ static void xs_tcp_shutdown(struct rpc_xprt
> > *xprt)
> >  {
> >  	struct sock_xprt *transport =3D container_of(xprt, struct
> > sock_xprt, xprt);
> >  	struct socket *sock =3D transport->sock;
> > +	int skst =3D transport->inet ? transport->inet->sk_state :
> > TCP_CLOSE;
> > =20
> >  	if (sock =3D=3D NULL)
> >  		return;
> > -	if (xprt_connected(xprt)) {
> > +	switch (skst) {
> > +	default:
> >  		kernel_sock_shutdown(sock, SHUT_RDWR);
> >  		trace_rpc_socket_shutdown(xprt, sock);
> > -	} else
> > +		break;
> > +	case TCP_CLOSE:
> > +	case TCP_TIME_WAIT:
> >  		xs_reset_transport(transport);
> > +	}
> >  }
> > =20
> >  static void xs_tcp_set_socket_timeouts(struct rpc_xprt *xprt,
> >=20
>=20
>=20
> Previously, I've seen hidden ports within 5-6 minutes after re-
> starting
> the nfsd and re-mounting nfs-exports on clients.
>=20
> With this patch applied, I don't see any hidden ports after 15mins. I
> guess it's a valid fix.

For the record, the intention of the patch is not to adjust or correct
any connection timeout values. Merely to ensure that once the
connection breakage is detected by the socket layer, so that is it no
longer usable by the RPC client, we release the socket.

--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

--=-t+YRnEZijbyrem38IAFf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEESQctxSBg8JpV8KqEZwvnipYKAPIFAlp6AV8ACgkQZwvnipYK
APK7uQ/9E318IX/ZMSHB5NbkbyVEx202GIiUmNTamO9Vi8aWGs1pSvurna5yfaNe
fkTuTpHoNHRY40HZzaNCluJB8VWRsjTZwJ3z9vj7TVfFlk+udXwD3CCNQkFc4fUo
M4U2uMGQ3Vz3OrA0nwT38h6WaHaiyePN8yvRtXgh4Yq0HQJKFmRRyqaukecSW4er
TOGpo38Qjn2ecVD6CCbCzxJdAnapmFqWglz9br0E65R2ZJvX3oFZGlIFlTwDLZJl
PraBIWncuECPRYXq3/4oLPcJxCdZ1Gp13+naiLfWW2D5/C72nx2vGZn9q0a1YWN7
+W1zaQ1RiSB/mQ7oM8jnZDntqcVo6Oeox1vg304fMYFRW/LgWeL4nHku4vR/Optg
Md6D9pdc6adaTRl52lZ8m4ganv2OwyIR7cMCs36ngn1xMIWbRqmpINyPOATaQeMg
sw3lD2mPQb7zHvagGy8WK4J624OZjasRI5QRtIx14LnlwsGHb3pvF5/S1wtk+T2L
A1L/GEuogz8zbK32oFvZUAUY/Zui0EomZhE+xpLVKMrK7BhN4KyAPcj8N6J8pwOm
WndE3Sb6Om1PecGWV66dWYjN5b3vOiDSHJvObtFA2jsYfMpoLJUXo3gRrwOafKDR
UkKBjXq5jsxJfWKtfKyya4XCFBGoyiDq4EGJPUgrKdq1ktKwNpU=
=i3tz
-----END PGP SIGNATURE-----

--=-t+YRnEZijbyrem38IAFf--

