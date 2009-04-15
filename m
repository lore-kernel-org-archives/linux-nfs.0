From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] getport.c: fix non-standard C
Date: Wed, 15 Apr 2009 13:58:44 -0400
Message-ID: <49E62054.9030804@RedHat.com>
References: <20090406160411.7179.41228.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38436 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752605AbZDOSBi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Apr 2009 14:01:38 -0400
In-Reply-To: <20090406160411.7179.41228.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Squelch a compiler warning in getport.c:
>=20
>   getport.c:65: warning: =E2=80=98static=E2=80=99 is not at beginning=
 of declaration
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>=20
>  support/nfs/getport.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/support/nfs/getport.c b/support/nfs/getport.c
> index 734d21a..cf1677e 100644
> --- a/support/nfs/getport.c
> +++ b/support/nfs/getport.c
> @@ -60,9 +60,9 @@
>  #endif	/* !HAVE_LIBTIRPC */
> =20
>  #ifdef HAVE_LIBTIRPC
> -const static rpcvers_t default_rpcb_version =3D RPCBVERS_4;
> +static const rpcvers_t default_rpcb_version =3D RPCBVERS_4;
>  #else	/* !HAVE_LIBTIRPC */
> -const static rpcvers_t default_rpcb_version =3D PMAPVERS;
> +static const rpcvers_t default_rpcb_version =3D PMAPVERS;
>  #endif	/* !HAVE_LIBTIRPC */
> =20
>  #ifdef HAVE_DECL_AI_ADDRCONFIG
>=20
Committed....

steved.
