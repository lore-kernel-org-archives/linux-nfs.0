From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 0/8] RDMA Transport Provider
Date: Fri, 30 Nov 2007 09:59:28 -0600
Message-ID: <1196438368.5432.10.camel@trinity.ogc.int>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int>
	 <20071130044553.GA29851@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:59348 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935273AbXK3PzZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2007 10:55:25 -0500
In-Reply-To: <20071130044553.GA29851@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2007-11-29 at 23:45 -0500, J. Bruce Fields wrote:
> On Thu, Nov 29, 2007 at 04:44:12PM -0600, Tom Tucker wrote:
> > This patchset implements the RDMA Transport Driver for the=20
[...snip...]

I resent the two offending patches with fixes as required.

> I still need the following to get it to compile.  Also, I'm getting
> these warnings:
>=20
> net/sunrpc/svc_rdma_transport.c: In function =E2=80=98dto_tasklet_fun=
c=E2=80=99:
> net/sunrpc/svc_rdma_transport.c:232: warning: passing argument 2 of =E2=
=80=98test_and_clear_bit=E2=80=99 from incompatible pointer type
> net/sunrpc/svc_rdma_transport.c:241: warning: passing argument 2 of =E2=
=80=98constant_test_bit=E2=80=99 from incompatible pointer type
> net/sunrpc/svc_rdma_transport.c:241: warning: passing argument 2 of =E2=
=80=98variable_test_bit=E2=80=99 from incompatible pointer type
> net/sunrpc/svc_rdma_transport.c:245: warning: passing argument 2 of =E2=
=80=98test_and_clear_bit=E2=80=99 from incompatible pointer type
> net/sunrpc/svc_rdma_transport.c: In function =E2=80=98rq_comp_handler=
=E2=80=99:
> net/sunrpc/svc_rdma_transport.c:271: warning: passing argument 2 of =E2=
=80=98set_bit=E2=80=99 from incompatible pointer type
> net/sunrpc/svc_rdma_transport.c: In function =E2=80=98sq_comp_handler=
=E2=80=99:
> net/sunrpc/svc_rdma_transport.c:382: warning: passing argument 2 of =E2=
=80=98set_bit=E2=80=99 from incompatible pointer type
> net/sunrpc/svc_rdma_transport.c: In function =E2=80=98rdma_cma_handle=
r=E2=80=99:
> net/sunrpc/svc_rdma_transport.c:617: warning: passing argument 2 of =E2=
=80=98clear_bit=E2=80=99 from incompatible pointer type
> net/sunrpc/svc_rdma_transport.c: In function =E2=80=98svc_rdma_accept=
=E2=80=99:
> net/sunrpc/svc_rdma_transport.c:848: warning: passing argument 2 of =E2=
=80=98set_bit=E2=80=99 from incompatible pointer type
>=20

I'm mystified as to why I didn't get these warnings. I built on a 64 bi=
t
machine. It seems like that would give the warning since unsigned long
isn't even the same size as int.

> --b.
>=20
>=20
> commit d128e461892e6aa5332e1b87d0f94eba4728ee90
> Author: akpm@linux-foundation.org <akpm@linux-foundation.org>
> Date:   Tue Nov 20 01:10:43 2007 -0800
>=20
>     git-nfsd build fix
>    =20
>     From: Andrew Morton <akpm@linux-foundation.org>
>    =20
>     net/sunrpc/svcsock.c: In function 'svc_reclassify_socket':
>     net/sunrpc/svcsock.c:100: error: 'struct sock' has no member name=
d 'sk_xprt'
>    =20
>     Cc: "J. Bruce Fields" <bfields@fieldses.org>
>     Cc: Neil Brown <neilb@suse.de>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>=20
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 03207c9..2d0405a 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -97,7 +97,6 @@ static struct lock_class_key svc_slock_key[2];
>  static inline void svc_reclassify_socket(struct socket *sock)
>  {
>  	struct sock *sk =3D sock->sk;
> -	BUG_ON(sk->sk_xprt.xpt_lock.owner !=3D NULL);

Somehow when I merged up to 2.6.24, this got merged incorrectly. The ne=
w
version still has the bug_on, but with the original argument.

>  	switch (sk->sk_family) {
>  	case AF_INET:
>  		sock_lock_init_class_and_name(sk, "slock-AF_INET-NFSD",
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

