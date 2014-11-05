Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:36132 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbaKEWfm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 17:35:42 -0500
Date: Thu, 6 Nov 2014 09:35:27 +1100
From: NeilBrown <neilb@suse.de>
To: bstroesser@ts.fujitsu.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [nfs-utils] [PATCH 3/3] rpc.mountd: set libtirpc nonblocking
 mode to avoid DOS
Message-ID: <20141106093527.33ad43d6@notabene.brown>
In-Reply-To: <61eb00$5diu20@dgate20u.abg.fsc.net>
References: <61eb00$5diu20@dgate20u.abg.fsc.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/2N1Y6A5b9o_lN1WgMzGB2q6"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/2N1Y6A5b9o_lN1WgMzGB2q6
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 05 Nov 2014 21:24:29 +0100 bstroesser@ts.fujitsu.com wrote:

> From: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> Date: Thu, 09 Oct 2014 13:06:19 +0200
> Subject: [nfs-utils] [PATCH 3/3] rpc.mountd: set libtirpc nonblocking mod=
e to avoid DOS
>=20
> This patch is experimental. In works fine in that it removes the vulnerab=
ility
> against a DOS attack. rpc.mountd can be blocked by a bad client, that sen=
ds
> many RPC requests but never reads the responses. This might happen intent=
ionally
> or caused by a wrong network config (MTU).
> The patch switches on the nonblocking mode of libtirpc. In that mode writ=
es can
> block for a max. of 2 seconds. Attackers are forced to send requests slow=
er, as
> libtirpc will close a connection if it finds two requests to read at the =
same
> time.
> I do not know, whether setting MAXREC could cause trouble e.g. with big r=
eplies.
> =20
>=20
> Signed-off-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> ---
>=20
> --- nfs-utils-1.3.1/support/nfs/svc_create.c	2014-10-09 12:09:15.00000000=
0 +0200
> +++ nfs-utils-1.3.1/support/nfs/svc_create.c	2014-10-09 12:13:32.00000000=
0 +0200
> @@ -49,6 +49,8 @@
> =20
>  #ifdef HAVE_LIBTIRPC
> =20
> +#include <rpc/rpc_com.h>
> +
>  #define SVC_CREATE_XPRT_CACHE_SIZE	(8)
>  static SVCXPRT *svc_create_xprt_cache[SVC_CREATE_XPRT_CACHE_SIZE] =3D { =
NULL, };
> =20
> @@ -401,6 +403,7 @@
>  	const struct sigaction create_sigaction =3D {
>  		.sa_handler	=3D SIG_IGN,
>  	};
> +	int maxrec =3D RPC_MAXDATASIZE;
>  	unsigned int visible, up, servport;
>  	struct netconfig *nconf;
>  	void *handlep;
> @@ -412,6 +415,20 @@
>  	 */
>  	(void)sigaction(SIGPIPE, &create_sigaction, NULL);
> =20
> +	/*
> +	 * Setting MAXREC also enables non-blocking mode for tcp connections.
> +	 * This avoids DOS attacks by a client sending many requests but never
> +	 * reading the reply:
> +	 * - if a second request already is present for reading in the socket,
> +	 *   after the first request just was read, libtirpc will break the
> +	 *   connection. Thus an attacker can't simply send requests as fast as
> +	 *   he can without waiting for the response.
> +	 * - if the write buffer of the socket is full, the next write() will
> +	 *   fail with EAGAIN. libtirpc will retry the write in a loop for max.
> +	 *   2 seconds. If write still fails, the connection will be closed.
> +	 */  =20
> +	rpc_control(RPC_SVC_CONNMAXREC_SET, &maxrec);
> +
>  	handlep =3D setnetconfig();
>  	if (handlep =3D=3D NULL) {
>  		xlog(L_ERROR, "Failed to access local netconfig database: %s",


RPC_MAXDATASIZE is 9000.
This number is only relevant on the receive size.
When sending, the "sendsz" passed to svc_tli_create (which default to 64K f=
or
TCP) is used for the 'record size'.
When receiving, any 'record' in a tcp connection which is larger than 9000
bytes will be rejected.
No message to mountd or statd could ever be that large, so this number
does not impose a problematic limit.

As far as I can tell, this patch is safe and is a clear improvement.

Reviewed-by: NeilBrown <neilb@suse.de>

Thanks,
NeilBrown

--Sig_/2N1Y6A5b9o_lN1WgMzGB2q6
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVFqmLznsnt1WYoG5AQLnvQ//ekL1b5EKztLsnF8JumgPYPzV5daH7Gid
K/9LKEhVC+OHCislaLPS0ArBAqpAXHOwl9bS4uQu3TR3WJ8fS5FNexMu0C8WXL9X
cnbCA7oKgHYyiBdKK/1SxiZ2LSMVkcVNip8hcUEdwM6V1ZPvWkixxHnLls/J+N23
J32ntwYjqH64hjwH3gDwjs2tk8WZXyjcxgpyqMlhJdMHWFGDqnN0s7UYUR3KQ/Ba
hLt7bG1+P6Q2IKbe8aZL2fzZKpEhk7zUFZbIYm6b3PWdX498sFI5kIweht82nY8g
ZYbWo4A7JNpMkj1KO05uSptFj08CCORxIrIez12UPht9o37K88/lMuaxvt/r9hgZ
E8/MfMSdpI3sqdKnXRGC2Og8bgDW+9jTnnAcePjBjViUwfZDx6HtzxBe81j93bDO
bxEDWASKHUmGUXJaXvE30vGCxzgcp/iy6hMQPgVus8DLbcNCh9XOLe+bXchDvc1M
5DFeWJiBFdJK8pbYkuPiNVjLhpTMlcDGI7NQ0Qe9y32eGTfNykRMebJui1AZqxal
lYgZC1+Az6/0k3phl9UeN3sCmFS2gIn4bj7qaCwKDTFfQ9oW20LbrSeGb3LrqynK
wkRle+E1Imn7dlmYUeaWJvn8w354BW6FN8sWOqeuw3woTAtW6y8pCX/0bL4L9bzh
xvA1EH7VVfA=
=5XnN
-----END PGP SIGNATURE-----

--Sig_/2N1Y6A5b9o_lN1WgMzGB2q6--
