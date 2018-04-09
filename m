Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:36684 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbeDIRcX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Apr 2018 13:32:23 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH] clnt_com_create: Restore backwards compatibility with the
 legacy glibc code.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180409172825.169380-1-steved@redhat.com>
Date: Mon, 9 Apr 2018 11:32:08 -0600
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A536D92D-14FF-41B1-9943-A838FF8FCBC1@oracle.com>
References: <20180409172825.169380-1-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 9, 2018, at 11:28 AM, Steve Dickson <steved@redhat.com> wrote:
>=20
> Commit 46e04a73 changed clnt_com_create() to avoid
> using reserved ports when creating the the CLIENT ptr.
> This change breaks backward compatibility with the
> legacy RPC code that was in glibc.
>=20
> This patch reverts that commit to restore backwards compatibility
>=20
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> src/rpc_soc.c | 10 ++++++----
> 1 file changed, 6 insertions(+), 4 deletions(-)
>=20
> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
> index af6c482..ed0892a 100644
> --- a/src/rpc_soc.c
> +++ b/src/rpc_soc.c
> @@ -67,8 +67,6 @@
>=20
> extern mutex_t	rpcsoc_lock;
>=20
> -extern int __binddynport(int fd);
> -
> static CLIENT *clnt_com_create(struct sockaddr_in *, rpcprog_t, =
rpcvers_t,
>     int *, u_int, u_int, char *, int);
> static SVCXPRT *svc_com_create(int, u_int, u_int, char *);
> @@ -147,8 +145,7 @@ clnt_com_create(raddr, prog, vers, sockp, sendsz, =
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
> @@ -316,6 +313,7 @@ svc_com_create(fd, sendsize, recvsize, netid)
> 	SVCXPRT *svc;
> 	int madefd =3D FALSE;
> 	int port;
> +	struct sockaddr_in sin;
>=20
> 	if ((nconf =3D __rpc_getconfip(netid)) =3D=3D NULL) {
> 		(void) syslog(LOG_ERR, "Could not get %s transport", =
netid);
> @@ -332,6 +330,10 @@ svc_com_create(fd, sendsize, recvsize, netid)
> 		madefd =3D TRUE;
> 	}
>=20
> +	memset(&sin, 0, sizeof sin);
> +	sin.sin_family =3D AF_INET;
> +	bindresvport(fd, &sin);
> +	listen(fd, SOMAXCONN);

Why do we need to fix the server API too?


> 	svc =3D svc_tli_create(fd, nconf, NULL, sendsize, recvsize);
> 	(void) freenetconfigent(nconf);
> 	if (svc =3D=3D NULL) {
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



