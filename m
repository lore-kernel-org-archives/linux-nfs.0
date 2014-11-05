Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35696 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751333AbaKEVw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 16:52:56 -0500
Date: Thu, 6 Nov 2014 08:52:45 +1100
From: NeilBrown <neilb@suse.de>
To: bstroesser@ts.fujitsu.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [nfs-utils] [PATCH 1/3] rpc.mountd: set nonblocking mode if no
 libtirpc
Message-ID: <20141106085245.384d24ac@notabene.brown>
In-Reply-To: <d6437a$6ag12u@dgate10u.abg.fsc.net>
References: <d6437a$6ag12u@dgate10u.abg.fsc.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/Y=7shAlDh=ujbUsj3zbjUsn"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Y=7shAlDh=ujbUsj3zbjUsn
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 05 Nov 2014 21:22:56 +0100 bstroesser@ts.fujitsu.com wrote:

> From: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> Date: Thu, 09 Oct 2014 13:06:19 +0200
> Subject: [nfs-utils] [PATCH 1/3] rpc.mountd: set nonblocking mode if no l=
ibtirpc
>=20
> If mountd is built without libtirpc and it is started using "-p XXX" opti=
on,
> the tcp listeners and the sockets waiting for UDP messages are not in
> non-blocking mode. Thus if running with multiple threads (-t XX),
> all threads will wake up from select on a connection request or a UDP mes=
sage,
> but only one thread will succeed. All others will wait on accept() or rea=
d()
> for the next event.
>=20
> Signed-off-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> ---

Reviewed-by: NeilBrown <neilb@suse.de>

This is just taking the code that already applies in svc_socket() when no
explicit port number is requested, and applying it also in makesock() which
is used when an explicit port number *is* requested.

Thanks,
NeilBrown


>=20
> --- nfs-utils-1.3.1/support/include/nfslib.h	2014-10-09 12:52:30.00000000=
0 +0200
> +++ nfs-utils-1.3.1/support/include/nfslib.h	2014-10-09 12:53:37.00000000=
0 +0200
> @@ -174,6 +174,7 @@ void closeall(int min);
> =20
>  int			svctcp_socket (u_long __number, int __reuse);
>  int			svcudp_socket (u_long __number);
> +int			svcsock_nonblock (int __sock);
> =20
>  /* Misc shared code prototypes */
>  size_t  strlcat(char *, const char *, size_t);
> --- nfs-utils-1.3.1/support/nfs/svc_socket.c	2014-10-09 12:56:14.00000000=
0 +0200
> +++ nfs-utils-1.3.1/support/nfs/svc_socket.c	2014-10-09 13:10:44.00000000=
0 +0200
> @@ -76,6 +76,39 @@ int getservport(u_long number, const cha
>  	return 0;
>  }
> =20
> +int
> +svcsock_nonblock(int sock)
> +{
> +	int flags;
> +
> +	if (sock < 0)
> +		return sock;
> +
> +	/* This socket might be shared among multiple processes
> +	 * if mountd is run multi-threaded.  So it is safest to
> +	 * make it non-blocking, else all threads might wake
> +	 * one will get the data, and the others will block
> +	 * indefinitely.
> +	 * In all cases, transaction on this socket are atomic
> +	 * (accept for TCP, packet-read and packet-write for UDP)
> +	 * so O_NONBLOCK will not confuse unprepared code causing
> +	 * it to corrupt messages.
> +	 * It generally safest to have O_NONBLOCK when doing an accept
> +	 * as if we get a RST after the SYN and before accept runs,
> +	 * we can block despite being told there was an acceptable
> +	 * connection.
> +	 */
> +	if ((flags =3D fcntl(sock, F_GETFL)) < 0)
> +		perror(_("svc_socket: can't get socket flags"));
> +	else if (fcntl(sock, F_SETFL, flags|O_NONBLOCK) < 0)
> +		perror(_("svc_socket: can't set socket flags"));
> +	else
> +		return sock;
> +
> +	(void) __close(sock);
> +	return -1;
> +}
> +
>  static int
>  svc_socket (u_long number, int type, int protocol, int reuse)
>  {
> @@ -113,38 +146,7 @@ svc_socket (u_long number, int type, int
>        sock =3D -1;
>      }
> =20
> -  if (sock >=3D 0)
> -    {
> -	    /* This socket might be shared among multiple processes
> -	     * if mountd is run multi-threaded.  So it is safest to
> -	     * make it non-blocking, else all threads might wake
> -	     * one will get the data, and the others will block
> -	     * indefinitely.
> -	     * In all cases, transaction on this socket are atomic
> -	     * (accept for TCP, packet-read and packet-write for UDP)
> -	     * so O_NONBLOCK will not confuse unprepared code causing
> -	     * it to corrupt messages.
> -	     * It generally safest to have O_NONBLOCK when doing an accept
> -	     * as if we get a RST after the SYN and before accept runs,
> -	     * we can block despite being told there was an acceptable
> -	     * connection.
> -	     */
> -	int flags;
> -	if ((flags =3D fcntl(sock, F_GETFL)) < 0)
> -	  {
> -	      perror (_("svc_socket: can't get socket flags"));
> -	      (void) __close (sock);
> -	      sock =3D -1;
> -	  }
> -	else if (fcntl(sock, F_SETFL, flags|O_NONBLOCK) < 0)
> -	  {
> -	      perror (_("svc_socket: can't set socket flags"));
> -	      (void) __close (sock);
> -	      sock =3D -1;
> -	  }
> -    }
> -
> -  return sock;
> +  return svcsock_nonblock(sock);
>  }
> =20
>  /*
> --- nfs-utils-1.3.1/support/nfs/rpcmisc.c	2014-10-08 21:22:04.000000000 +=
0200
> +++ nfs-utils-1.3.1/support/nfs/rpcmisc.c	2014-10-08 21:22:36.000000000 +=
0200
> @@ -104,7 +104,7 @@ makesock(int port, int proto)
>  		return -1;
>  	}
> =20
> -	return sock;
> +	return svcsock_nonblock(sock);
>  }
> =20
>  void


--Sig_/Y=7shAlDh=ujbUsj3zbjUsn
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVFqcLTnsnt1WYoG5AQKanBAAsPjH/OKmLsjKYk4Pa2gX02Y9Xn7wUEpO
sgzCt6EuIr6wRSE89zNzwxQTHPczwGWInF1Is5aX+7RY5yb8a5iRaHS/Nbmha/3K
Id/yxkUsEYuNDN8ueJl6/Q4AR7loBJp68MAyLPrw68541GB7MFUgvNltSYo2CJah
ZNa5GplZLAUHRWv2FZMCFH/wPZlMDv20yzoz9KpxLmEgXSA06fR3boMYJmpnOEtU
MktU3LTwyiGC/74obWtXTYnRRQ0STXvcGOm+hNg9FSK9rOeKWfaUgeK7FvM7kp6B
QyyyV+h9TF7fN6pq87MK2v0KL8cUm52/atc7hWli57m0WXRtDxRy24JcctGLPEfw
58AYDGVziwy5DvjMUy7+DyJuwlhGoZlRHdg5TKOcdR8Qkvsgh9unZOH0cFqSMTxV
BH4KGUcwBstD07ylSZ/OWpkkPbF2ZrE5lIJebYGzzpe7S+dyEgPk5FOTzzqlWC9A
MBLd8Ah5nIitsow7UK/jixK9UL0DU9zKxYKcGl/j3EyflyTJBwGWnUXvRqRiAUAV
jyBaReRRP8+5TO803LX+/v1kwyRuZAHUyEm+lazimmOJpJuU9sNGedmQ9yOM6Msm
QHYrL8mTklKpnv+5GKL3K+b0EctlC5sqsrkQkj7iH3HpyCbLM9stFFpg57QdM3cG
9AS4TEYRfuM=
=qnm+
-----END PGP SIGNATURE-----

--Sig_/Y=7shAlDh=ujbUsj3zbjUsn--
