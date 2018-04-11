Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:35022 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752846AbeDKPVV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Apr 2018 11:21:21 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH] clnt_create: Restore using reserve ports for client
 connections
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180411150803.26680-1-steved@redhat.com>
Date: Wed, 11 Apr 2018 09:20:32 -0600
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <04AFBB38-DB95-4B3F-A39F-C323F914F780@oracle.com>
References: <20180411150803.26680-1-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

> On Apr 11, 2018, at 9:08 AM, Steve Dickson <steved@redhat.com> wrote:
>=20
> Commit 46e04a73 changed clnt_create(3) not to
> use reserve ports when binding a connection to
> a server.
>=20
> For certain legacy apps, like some of the NIS commands,
> the client has to used reserve port to be able
> to communicate with the server.

This is still not clear.

The problem is not that the RPC client has to use a reserved
port, it's that the client implementations currently assume
that clnt_create(3) will allocate a reserved port for them,
which is undocumented API behavior.

One more comment below.


> So the use of reserve ports in clnt_create(3)
> has been restored.
>=20
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

If this is the last __binddynport call site in clnt_generic.c,
you can remove its forward declaration (line 50 in my copy of
the source).


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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



