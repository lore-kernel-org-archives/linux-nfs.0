Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:35742 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751858AbaKEV6B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 16:58:01 -0500
Date: Thu, 6 Nov 2014 08:57:46 +1100
From: NeilBrown <neilb@suse.de>
To: bstroesser@ts.fujitsu.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [nfs-utils] [PATCH 2/3] rpc.mountd: set nonblocking mode with
 libtirpc
Message-ID: <20141106085746.78f9f395@notabene.brown>
In-Reply-To: <61eb00$5diu13@dgate20u.abg.fsc.net>
References: <61eb00$5diu13@dgate20u.abg.fsc.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/2l0SowT79YJZH_+Bk4uoXpd"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/2l0SowT79YJZH_+Bk4uoXpd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On 05 Nov 2014 21:23:39 +0100 bstroesser@ts.fujitsu.com wrote:

> From: Bodo Stroesser <bstroesser@ts.fujitsu.com>
> Date: Thu, 09 Oct 2014 13:07:33 +0200
> Subject: [nfs-utils] [PATCH 2/3] rpc.mountd: set nonblocking mode with li=
btirpc
>=20
> If mountd is built with libtirpc the tcp listeners and the sockets
> waiting for UDP messages are not in non-blocking mode. Thus if running
> with multiple threads (-t XX), all threads will wake up from select on
> a connection request or a UDP message, but only one thread will succeed.
> All others will wait on accept() or read() for the next event.
>=20
> Signed-off-by: Bodo Stroesser <bstroesser@ts.fujitsu.com>

Reviewed-by: NeilBrown <neilb@suse.de>

The two changes provide identical functionality: one in
   svc_create_nconf_rand_port
the other in
   svc_create_nconf_fixed_port

We really do want non-blocking sockets here!

Thanks,
NeilBrown

> ---
>=20
> --- nfs-utils-1.3.1/support/nfs/svc_create.c	2014-10-08 21:39:01.00000000=
0 +0200
> +++ nfs-utils-1.3.1/support/nfs/svc_create.c	2014-10-08 22:20:02.00000000=
0 +0200
> @@ -277,6 +277,12 @@
>  			"(%s, %u, %s)", name, version, nconf->nc_netid);
>  		return 0;
>  	}
> +	if (svcsock_nonblock(xprt->xp_fd) < 0) {
> +		/* close() already done by svcsock_nonblock() */
> +		xprt->xp_fd =3D RPC_ANYFD;
> +		SVC_DESTROY(xprt);
> +		return 0;
> +	}
> =20
>  	if (!svc_reg(xprt, program, version, dispatch, nconf)) {
>  		/* svc_reg(3) destroys @xprt in this case */
> @@ -332,6 +338,7 @@
>  		int fd;
> =20
>  		fd =3D svc_create_sock(ai->ai_addr, ai->ai_addrlen, nconf);
> +		fd =3D svcsock_nonblock(fd);
>  		if (fd =3D=3D -1)
>  			goto out_free;
> =20


--Sig_/2l0SowT79YJZH_+Bk4uoXpd
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVFqdWjnsnt1WYoG5AQIWPA/+N7UcXnFEslwpQPRZ4rjkAdcAwTGo7cCV
0nsarJfyCqUVPYpuicdux/n+XoQbwjqXvmHM42Xu7HaxTVVhanqgMy/zZHlf1qEt
rSsdrSltMSFbmU/8/t/FvWcl5Qj7xRaNmVM5r1xzQ6L8iMxgo5UZfDgGIT18h2Uz
bptsVftRiMcY72DW0YCJEL54dqU9oC7+jiMAi+b5ln5iFPBFAWWnZDz+bOwYkcrt
qai3O4EbaZs9SNJ/teTrQ8rYXkbAZtwqgkpf4cXpnaShEjdHHpHjq2P9dwbOydRZ
dTHZGyrMDt43nzIutW4WYRjaxmnjSAerc2PEAvEh6+YbEnzDWMZbVMUzpdXHceWQ
eq2lDrhmQ1Xn6pFhjL7yfUEr9Fx4nS7knOo9zDGvqcmsSqEhRSwUZ1xOQqeOoeyz
xMFYYABCyQXE5NEUTh97+mVx09btI+L9yuUsMcl1gbIP+p2oGGAnN+t1VDS3OmHP
SJb8H1GN0DqHpJ4izBW+1QULGhfDL0ZguFALD3o6ehYhKSLDolYEB8t2IrSwrye0
K9qy4SyRLTVDm15imisz569KLS8d4RiP7gTIicFdJNagnVP0a7vw0p0MDYhiHgzk
E7qIlXXnH5OA/Ta6a0WsU6VLZPKk1WBP5neWuhkBvcW1PUVp1suCX4fTQ2hwoAfZ
tUMfKkHlRdQ=
=ItmF
-----END PGP SIGNATURE-----

--Sig_/2l0SowT79YJZH_+Bk4uoXpd--
