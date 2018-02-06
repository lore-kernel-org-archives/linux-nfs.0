Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from srv06.itamservices.de ([78.46.48.226]:63755 "EHLO
        srv06.itamservices.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752213AbeBFJU1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Feb 2018 04:20:27 -0500
Subject: Re: It's back! (Re: [REGRESSION] NFS is creating a hidden port (left
 over from xs_bind() ))
To: Trond Myklebust <trondmy@primarydata.com>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <57220e1f-f81e-b30b-a4ea-39ad74c7c0d6@nachtgeist.net>
 <1517876654.79669.5.camel@primarydata.com>
From: Daniel Reichelt <hacking@nachtgeist.net>
Message-ID: <9518bb1f-ad0a-2c33-d3fc-78550be06a0c@nachtgeist.net>
Date: Tue, 6 Feb 2018 10:20:22 +0100
MIME-Version: 1.0
In-Reply-To: <1517876654.79669.5.camel@primarydata.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="Mrvc8Do60m4Vi01BQn8EmDBswbL577mMf"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Mrvc8Do60m4Vi01BQn8EmDBswbL577mMf
Content-Type: multipart/mixed; boundary="N4fNFHhBhgM90y6CJjK99FoVR7XExZWZd";
 protected-headers="v1"
From: Daniel Reichelt <hacking@nachtgeist.net>
To: Trond Myklebust <trondmy@primarydata.com>,
 "rostedt@goodmis.org" <rostedt@goodmis.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-ID: <9518bb1f-ad0a-2c33-d3fc-78550be06a0c@nachtgeist.net>
Subject: Re: It's back! (Re: [REGRESSION] NFS is creating a hidden port (left
 over from xs_bind() ))
References: <57220e1f-f81e-b30b-a4ea-39ad74c7c0d6@nachtgeist.net>
 <1517876654.79669.5.camel@primarydata.com>
In-Reply-To: <1517876654.79669.5.camel@primarydata.com>

--N4fNFHhBhgM90y6CJjK99FoVR7XExZWZd
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: quoted-printable

On 02/06/2018 01:24 AM, Trond Myklebust wrote:
> Does the following fix the issue?
>=20
> 8<-----------------------------------------------
> From 9b30889c548a4d45bfe6226e58de32504c1d682f Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Mon, 5 Feb 2018 10:20:06 -0500
> Subject: [PATCH] SUNRPC: Ensure we always close the socket after a conn=
ection
>  shuts down
>=20
> Ensure that we release the TCP socket once it is in the TCP_CLOSE or
> TCP_TIME_WAIT state (and only then) so that we don't confuse rkhunter
> and its ilk.
>=20
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/xprtsock.c | 23 ++++++++++-------------
>  1 file changed, 10 insertions(+), 13 deletions(-)
>=20
> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
> index 18803021f242..5d0108172ed3 100644
> --- a/net/sunrpc/xprtsock.c
> +++ b/net/sunrpc/xprtsock.c
> @@ -807,13 +807,6 @@ static void xs_sock_reset_connection_flags(struct =
rpc_xprt *xprt)
>  	smp_mb__after_atomic();
>  }
> =20
> -static void xs_sock_mark_closed(struct rpc_xprt *xprt)
> -{
> -	xs_sock_reset_connection_flags(xprt);
> -	/* Mark transport as closed and wake up all pending tasks */
> -	xprt_disconnect_done(xprt);
> -}
> -
>  /**
>   * xs_error_report - callback to handle TCP socket state errors
>   * @sk: socket
> @@ -833,9 +826,6 @@ static void xs_error_report(struct sock *sk)
>  	err =3D -sk->sk_err;
>  	if (err =3D=3D 0)
>  		goto out;
> -	/* Is this a reset event? */
> -	if (sk->sk_state =3D=3D TCP_CLOSE)
> -		xs_sock_mark_closed(xprt);
>  	dprintk("RPC:       xs_error_report client %p, error=3D%d...\n",
>  			xprt, -err);
>  	trace_rpc_socket_error(xprt, sk->sk_socket, err);
> @@ -1655,9 +1645,11 @@ static void xs_tcp_state_change(struct sock *sk)=

>  		if (test_and_clear_bit(XPRT_SOCK_CONNECTING,
>  					&transport->sock_state))
>  			xprt_clear_connecting(xprt);
> +		clear_bit(XPRT_CLOSING, &xprt->state);
>  		if (sk->sk_err)
>  			xprt_wake_pending_tasks(xprt, -sk->sk_err);
> -		xs_sock_mark_closed(xprt);
> +		/* Trigger the socket release */
> +		xs_tcp_force_close(xprt);
>  	}
>   out:
>  	read_unlock_bh(&sk->sk_callback_lock);
> @@ -2265,14 +2257,19 @@ static void xs_tcp_shutdown(struct rpc_xprt *xp=
rt)
>  {
>  	struct sock_xprt *transport =3D container_of(xprt, struct sock_xprt, =
xprt);
>  	struct socket *sock =3D transport->sock;
> +	int skst =3D transport->inet ? transport->inet->sk_state : TCP_CLOSE;=

> =20
>  	if (sock =3D=3D NULL)
>  		return;
> -	if (xprt_connected(xprt)) {
> +	switch (skst) {
> +	default:
>  		kernel_sock_shutdown(sock, SHUT_RDWR);
>  		trace_rpc_socket_shutdown(xprt, sock);
> -	} else
> +		break;
> +	case TCP_CLOSE:
> +	case TCP_TIME_WAIT:
>  		xs_reset_transport(transport);
> +	}
>  }
> =20
>  static void xs_tcp_set_socket_timeouts(struct rpc_xprt *xprt,
>=20


Previously, I've seen hidden ports within 5-6 minutes after re-starting
the nfsd and re-mounting nfs-exports on clients.

With this patch applied, I don't see any hidden ports after 15mins. I
guess it's a valid fix.


Thank you!

Daniel


--N4fNFHhBhgM90y6CJjK99FoVR7XExZWZd--

--Mrvc8Do60m4Vi01BQn8EmDBswbL577mMf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJLBAEBCAA1FiEEg2wMpOXGvc4nunsZnjl+Rc/8gF8FAlp5c1cXHGhhY2tpbmdA
bmFjaHRnZWlzdC5uZXQACgkQnjl+Rc/8gF9vlQ/9HIqRpAAEUie4ajh0Dc5AD6CL
jochGqEyMEMIBFojkl63wOfEo36MSRjHaUxVNRwjtXcTIaQIxOxogYfzgJnjLGBu
zbw2EFzeXdgyj5YwF6KS9tqWQf2K1w3FTY0bxTL8FImamDPFYhmAyj1oPIe/7olB
ElLfp0OAbD0nTUUd7i/jw9r4IZfVMPQnd+04qcIFB5W5nTTvFbUAX0ssu/EUcnJu
8yQ3xa9JLbqKu2C0M/d4BedXk7m/IAiS9R1IVoIws+Y/oFv2QzPwJe04iKIyV0lS
+aqjXtv8oIY196EwONPSJe66KXJquqLqjwJ4CM0hOfZX7KoHmhGifd0SVLlkisTn
nhVPneTWAysUZGeDd2SZsomS835MniK6soAs5zjhpWGdtbQyR7NxX/iJe7d9Ova0
NMEoRups2zkjX8GBjG0XJwoEXjUbkOtpL5YcknS69XHXaZ04HoUB9XnSd4O4iSOX
TC1I5GPt2ZbKyQLVLDAXD9kf6GX5YP6ppCpsjg0e5quL3xY9WIG6jfaUr82kOxEO
8x/JNa4nj37DHUfpxCIVFMsHSxmpERJ1luIODRmwlY5lFsDXluH2p/F3b6ZQ9aX3
lAD4kkE281DJIrnX5OweR2Yq3Q83ZL3a5KKdbRAyEHdOHPpPVAihCOziMRhY3kXh
5bRFx16AKd4JBpQXWuU=
=JYko
-----END PGP SIGNATURE-----

--Mrvc8Do60m4Vi01BQn8EmDBswbL577mMf--
