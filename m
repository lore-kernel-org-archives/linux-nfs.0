Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:42388 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbeDJWRm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Apr 2018 18:17:42 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [Libtirpc-devel] [PATCH 1/2] Restore using reserve ports for
 client connections
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180410213043.5545-1-steved@redhat.com>
Date: Tue, 10 Apr 2018 16:17:30 -0600
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1E130010-3BB3-4BB8-9521-1B6096BC615B@oracle.com>
References: <20180410213043.5545-1-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 10, 2018, at 3:30 PM, Steve Dickson <steved@redhat.com> wrote:
>=20
> Commit 46e04a73 changed both clnt_com_create()
> and clnt_tli_create() to avoid using reserve ports when
> creating connection to the server.
>=20
> For certain legacy apps, the client has to used
> reserve port to be able to communicate with its
> server so using of reserve ports is restored.

Hi Steve-

Which legacy apps use clnt_tli_create and require this behavior?
There is no backwards compatibility requirement for this API.


> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> src/clnt_generic.c | 3 +--
> src/rpc_soc.c      | 3 +--
> 2 files changed, 2 insertions(+), 4 deletions(-)
>=20
> diff --git a/src/clnt_generic.c b/src/clnt_generic.c
> index e5a314f..774292b 100644
> --- a/src/clnt_generic.c
> +++ b/src/clnt_generic.c
> @@ -341,8 +341,7 @@ clnt_tli_create(int fd, const struct netconfig =
*nconf,
> 		servtype =3D nconf->nc_semantics;
> 		if (!__rpc_fd2sockinfo(fd, &si))
> 			goto err;
> -		if (__binddynport(fd) =3D=3D -1)
> -			goto err;
> +		bindresvport(fd, NULL);
> 	} else {
> 		if (!__rpc_fd2sockinfo(fd, &si))
> 			goto err;
> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
> index af6c482..f32a27c 100644
> --- a/src/rpc_soc.c
> +++ b/src/rpc_soc.c
> @@ -147,8 +147,7 @@ clnt_com_create(raddr, prog, vers, sockp, sendsz, =
recvsz, tp, flags)
> 	bindaddr.maxlen =3D bindaddr.len =3D  sizeof (struct =
sockaddr_in);
> 	bindaddr.buf =3D raddr;
>=20
> -	if (__binddynport(fd) =3D=3D -1)
> -		goto err;
> +	bindresvport(fd, NULL);
> 	cl =3D clnt_tli_create(fd, nconf, &bindaddr, prog, vers,
> 				sendsz, recvsz);
> 	if (cl) {
> --=20
> 2.14.3
>=20
>=20
> =
--------------------------------------------------------------------------=
----
> Check out the vibrant tech community on one of the world's most
> engaging tech sites, Slashdot.org! http://sdm.link/slashdot
> _______________________________________________
> Libtirpc-devel mailing list
> Libtirpc-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel

--
Chuck Lever



