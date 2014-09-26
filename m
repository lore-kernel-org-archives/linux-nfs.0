Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:53954 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752384AbaIZBKQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2014 21:10:16 -0400
Date: Fri, 26 Sep 2014 11:10:05 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Add missing support for
 RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT
Message-ID: <20140926111005.3124f859@notabene.brown>
In-Reply-To: <1411613479-8803-1-git-send-email-trond.myklebust@primarydata.com>
References: <1411613479-8803-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/s5tcX5ArLK9uTY1Qq+kTwQQ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/s5tcX5ArLK9uTY1Qq+kTwQQ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 24 Sep 2014 22:51:19 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> The flag RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT was intended introduced in
> order to allow NFSv4 clients to disable resend timeouts. Since those
> cause the RPC layer to break the connection, they mess up the duplicate
> reply caches that remain indexed on the port number in NFSv4..
>=20
> This patch includes the code that was missing in the original to
> set the appropriate flag in struct rpc_clnt, when the caller of
> rpc_create() sets RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT.
>=20
> Fixes: 8a19a0b6cb2e (SUNRPC: Add RPC task and client level options to...)
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/clnt.c | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 488ddeed9363..841565450354 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -461,6 +461,8 @@ struct rpc_clnt *rpc_create_xprt(struct rpc_create_ar=
gs *args,
> =20
>  	if (args->flags & RPC_CLNT_CREATE_AUTOBIND)
>  		clnt->cl_autobind =3D 1;
> +	if (args->flags & RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT)
> +		clnt->cl_noretranstimeo =3D 1;
>  	if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
>  		clnt->cl_discrtry =3D 1;
>  	if (!(args->flags & RPC_CLNT_CREATE_QUIET))

Hi Trond,
 do this relate to my observation in=20
    Subject: Re: NFS auto-reconnect tuning

 that NFSv4 closes a connections after the first timeout?
 This patch seems to be a step towards changing that behaviour, though it
 doesn't succeed.

You would need

@@ -580,6 +582,7 @@ static struct rpc_clnt *__rpc_clone_client(struct rpc_c=
reate_args *args,
 	new->cl_autobind =3D 0;
 	new->cl_softrtry =3D clnt->cl_softrtry;
 	new->cl_discrtry =3D clnt->cl_discrtry;
+	new->cl_noretranstimeo =3D clnt->cl_noretranstimeo;
 	new->cl_chatty =3D clnt->cl_chatty;
 	return new;

as well.

What do you think of having the client close the connection more quickly wh=
en
there is a timeout?  There does seem to be a case for closing sooner than 30
minutes...

I must admit I'm a bit confused by these flags so I might be missing
something important.

Thanks,
NeilBrown


--Sig_/s5tcX5ArLK9uTY1Qq+kTwQQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCS87Tnsnt1WYoG5AQIYUw//e54rB1zN37pRz+IQXTu2jSFY+6oKydo7
sHFHM/dsQweS7DlTI5gNooyu7DPhUAxrMSWhOL1ZncglhTpkCL5hCefMh2yf/eQ5
Yb6npX5uQYRDJc0eNAfhJFViFt2DtZpF96FIJJrsgKFpqUFjBkpF1+AU52yQBpcr
PWHMoYWkPijd5ay1s5mzDdlMXj+84hohoUIpLIJIiis0dGxDG7AaeJ1WR/9psd/e
YlWnZGgKMjk/Bs8YVPDWYHOd4fT0VNP2IYLjeH+YMwbqj3YSePc0eXkH2XpHS9uM
20/i04aZAqkq/ZDCjz4K8tdWj+AHEwEtdnGN5z7z/yEKxBmxwYb2+zaDifeL1bh4
XqSefDP7Wn1ZYNWD2xvahasY8EJdCU/W6QKZ2MrzI8E3ZeMEvlZTJu9bJBhH6cel
TVy3vG/i+nbP+v1NyRvYVmzufIV0AaAeVj7dOEyuRE9qlKrcd4j4UR+9rr5TOOmt
bV4hm1Keu8FDuaqjPef3/PoRdNv8Qzve44k0HeJprkpJFftj9QvtuwECi6zCa0xI
G5SAPEwzYs66pZqGJ0btmFdm8Y4CrDNCwYKquTM+sQTH4IM/sOgVGMFvc/7QOGLf
XtB4SMRa+fhiHWdKyEFMdcng1iTjNGPMuVKO0O6js0SqvZXPlSZAb5pu3JH6mYK7
3JNNF5KB+3g=
=mp8X
-----END PGP SIGNATURE-----

--Sig_/s5tcX5ArLK9uTY1Qq+kTwQQ--
