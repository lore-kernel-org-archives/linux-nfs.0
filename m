Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:49410 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933603AbeAKPug (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jan 2018 10:50:36 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] Do not bind to reserved ports registered in /etc/services
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180110004920.11100-1-gjover@sipwise.com>
Date: Thu, 11 Jan 2018 10:50:14 -0500
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <49E44F63-42CF-4BF8-91E0-F89945D7CFE6@oracle.com>
References: <20180110004920.11100-1-gjover@sipwise.com>
To: Guillem Jover <gjover@sipwise.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 9, 2018, at 7:49 PM, Guillem Jover <gjover@sipwise.com> wrote:
>=20
> When using the bindresvport() function a privileged port will be =
looked
> for and bound to a socket. The problem is that any service using a =
static
> privileged port registered in the /etc/services file, can get its port
> taken over by libtirpc users, making the other service fail to start.
>=20
> Starting the other service before libtircp users is not an option as
> this does not cover restart situations, for example during package
> upgrades or HA switchovers and similar.
>=20
> In addition honoring the /etc/services registry is already done for
> example by rpc.statd, so it seems obvious to make libtirpc follow this
> same pattern too.

Does the glibc version of bindresvport(3) skip ports? I ask because
this hasn't been a noted problem before. Which service exactly is
causing the difficulty?

Usually applications that grab a privileged port are short-lived.
statd is careful to avoid ports in /etc/services because it allocates
one socket with a privileged port for contacting the kernel, and keeps
it in place.


> Signed-off-by: Guillem Jover <gjover@sipwise.com>
> ---
> src/bindresvport.c | 28 +++++++++++++++++++++++++++-
> 1 file changed, 27 insertions(+), 1 deletion(-)
>=20
> diff --git a/src/bindresvport.c b/src/bindresvport.c
> index 2d8f2bc..98e5f40 100644
> --- a/src/bindresvport.c
> +++ b/src/bindresvport.c
> @@ -40,6 +40,7 @@
> #include <netinet/in.h>
>=20
> #include <errno.h>
> +#include <netdb.h>
> #include <string.h>
> #include <unistd.h>
>=20
> @@ -73,12 +74,15 @@ bindresvport_sa(sd, sa)
>         int sd;
>         struct sockaddr *sa;
> {
> -        int res, af;
> +        int res, af, so_proto;
> +        socklen_t so_proto_len;
>         struct sockaddr_storage myaddr;
> 	struct sockaddr_in *sin;
> #ifdef INET6
> 	struct sockaddr_in6 *sin6;
> #endif
> +	struct servent *se;
> +	const char *se_proto;
> 	u_int16_t *portp;
> 	static u_int16_t port;
> 	static short startport =3D STARTPORT;
> @@ -125,6 +129,25 @@ bindresvport_sa(sd, sa)
>         }
>         sa->sa_family =3D af;
>=20
> +        so_proto_len =3D sizeof(so_proto);
> +        if (getsockopt(sd, SOL_SOCKET, SO_PROTOCOL, &so_proto, =
&so_proto_len) =3D=3D -1) {
> +                mutex_unlock(&port_lock);
> +                return -1;      /* errno is correctly set */
> +        }
> +        switch (so_proto) {
> +        case IPPROTO_UDP:
> +        case IPPROTO_UDPLITE:

What is UDPLITE? Would it require a separate netid
or other infrastructure? IMO it's not correct to add
this transport protocol in this patch. If you resend,
please remove this line.


> +                se_proto =3D "udp";
> +                break;
> +        case IPPROTO_TCP:
> +                se_proto =3D "tcp";
> +                break;
> +        default:
> +                errno =3D ENOPROTOOPT;
> +                mutex_unlock(&port_lock);
> +                return -1;
> +        }
> +
>         if (port =3D=3D 0) {
>                 port =3D (getpid() % NPORTS) + STARTPORT;
>         }
> @@ -135,6 +158,9 @@ bindresvport_sa(sd, sa)
>                 *portp =3D htons(port++);
>                  if (port > endport)=20
>                         port =3D startport;
> +                se =3D getservbyport(*portp, se_proto);
> +                if (se !=3D NULL)
> +                        continue;
>                 res =3D bind(sd, sa, salen);
> 		if (res >=3D 0 || errno !=3D EADDRINUSE)
> 	                break;
> --=20
> 2.15.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



