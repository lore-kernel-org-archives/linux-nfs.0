Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:36824 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161667AbeBOVL2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Feb 2018 16:11:28 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH RFC 2/3] Avoid choosing reserved ports in
 svc_tli_create(3)
Date: Thu, 15 Feb 2018 16:11:24 -0500
References: <20180215201832.16924.28659.stgit@klimt.1015granger.net>
 <20180215202216.16924.4607.stgit@klimt.1015granger.net>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
In-Reply-To: <20180215202216.16924.4607.stgit@klimt.1015granger.net>
Message-Id: <9BFE0AEA-24BA-4721-8674-7449F613C8CA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Feb 15, 2018, at 3:22 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
> Callers of svc_tli_create(3) can specify that an arbitrary port
> number be dynamically assigned for the service listener being
> created. svc_tli_create(3) tries bindresvport(3) first in this
> case. bindresvport(3) chooses a reserved port if the caller has
> CAP_NET_ADMIN_BIND privilege. If this fails, bind(2) is used to
> assign a port number from the range above 1024.
>=20
> This approach becomes a problem whenever bindresvport(3) happens to
> choose the port number of a well-known service. If the caller is a
> long-running service (like rpc.statd), it indefinitely prevents the
> IANA-assigned well-known service from starting.
>=20
> It seems that a reserved port is completely unnecessary for listener
> sockets. It does not confer any extra privilege or functionality to
> the listener socket, nor do remote clients infer any extra privilege
> from a listener on a port number lower than 1024.
>=20
> Therefore, remove the bindresvport step to prevent svc_tli_create(3)
> from choosing a port number that interferes with well-known services
> assigned to a privileged port.
>=20
> svc_tli_create(3) will now never assign a privileged port
> dynamically. If needed, a caller may still bind to a dynamically-
> assigned reserved port by invoking bindresvport(3) directly and
> passing the already-bound file descriptor to svc_tli_create(3).
>=20
> But that should be a special case. It is no longer the default
> behavior.
>=20
> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=3D320
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> src/rpc_soc.c     |    7 +++++--
> src/svc_generic.c |   12 ++++--------
> 2 files changed, 9 insertions(+), 10 deletions(-)
>=20
> diff --git a/src/rpc_soc.c b/src/rpc_soc.c
> index ed0892a..5ec96a7 100644
> --- a/src/rpc_soc.c
> +++ b/src/rpc_soc.c
> @@ -67,6 +67,8 @@
>=20
> extern mutex_t	rpcsoc_lock;
>=20
> +extern int __binddynport(int fd);
> +
> static CLIENT *clnt_com_create(struct sockaddr_in *, rpcprog_t, =
rpcvers_t,
>     int *, u_int, u_int, char *, int);
> static SVCXPRT *svc_com_create(int, u_int, u_int, char *);
> @@ -145,7 +147,8 @@ clnt_com_create(raddr, prog, vers, sockp, sendsz, =
recvsz, tp, flags)
> 	bindaddr.maxlen =3D bindaddr.len =3D  sizeof (struct =
sockaddr_in);
> 	bindaddr.buf =3D raddr;
>=20
> -	bindresvport(fd, NULL);
> +	if (__binddynport(fd) =3D=3D -1)
> +		goto err;

This hunk belongs in the clnt_tli_create(3) patch.


> 	cl =3D clnt_tli_create(fd, nconf, &bindaddr, prog, vers,
> 				sendsz, recvsz);
> 	if (cl) {
> @@ -332,7 +335,7 @@ svc_com_create(fd, sendsize, recvsize, netid)
>=20
> 	memset(&sin, 0, sizeof sin);
> 	sin.sin_family =3D AF_INET;
> -	bindresvport(fd, &sin);
> +	bind(fd, (struct sockaddr *)(void *)&sin, sizeof sin);

This allows dynamic allocation of a reserved port if the caller
has CAP_NET_ADMIN_BIND. A better choice might be to just pass the
fd to svc_tli_create and let it do the bind if needed.

I'll be sending along a "v2" RFC series at some point.


> 	listen(fd, SOMAXCONN);
> 	svc =3D svc_tli_create(fd, nconf, NULL, sendsize, recvsize);
> 	(void) freenetconfigent(nconf);
> diff --git a/src/svc_generic.c b/src/svc_generic.c
> index 7aae796..52a56c2 100644
> --- a/src/svc_generic.c
> +++ b/src/svc_generic.c
> @@ -53,6 +53,7 @@
> #include <rpc/svc.h>
>=20
> extern int __svc_vc_setflag(SVCXPRT *, int);
> +extern int __binddynport(int fd);
>=20
> /*
>  * The highest level interface for server creation.
> @@ -220,15 +221,10 @@ svc_tli_create(fd, nconf, bindaddr, sendsz, =
recvsz)
> 	 */
> 	if (madefd || !__rpc_sockisbound(fd)) {
> 		if (bindaddr =3D=3D NULL) {
> -			if (bindresvport(fd, NULL) < 0) {
> -				memset(&ss, 0, sizeof ss);
> -				ss.ss_family =3D si.si_af;
> -				if (bind(fd, (struct sockaddr *)(void =
*)&ss,
> -				    (socklen_t)si.si_alen) < 0) {
> -					warnx(
> +			if (__binddynport(fd) =3D=3D -1) {
> +				warnx(
> 			"svc_tli_create: could not bind to anonymous =
port");
> -					goto freedata;
> -				}
> +				goto freedata;
> 			}
> 			listen(fd, SOMAXCONN);
> 		} else {
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



