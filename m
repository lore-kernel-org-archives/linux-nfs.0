From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] nfs-utils: Fix C aliasing rules violation in	nfs_getrpccaller()
Date: Mon, 19 Jul 2010 10:10:40 -0400
Message-ID: <4C445CE0.2030707@RedHat.com>
References: <20100706165849.4436.13124.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58162 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933591Ab0GSOKn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 10:10:43 -0400
In-Reply-To: <20100706165849.4436.13124.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/06/2010 12:59 PM, Chuck Lever wrote:
> Squelch compiler warnings reported with -Wextra:
>=20
> In file included from statd.c:24:
> ../../support/include/rpcmisc.h: In function =E2=80=98nfs_getrpccalle=
r_in=E2=80=99:
> ../../support/include/rpcmisc.h:58: warning: dereferencing type-punne=
d
> pointer might break strict-aliasing rules
> ../../support/include/rpcmisc.h: In function =E2=80=98nfs_getrpccalle=
r=E2=80=99:
> ../../support/include/rpcmisc.h:63: warning: dereferencing type-punne=
d
> pointer might break strict-aliasing rules
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> Steve-
>=20
> This minor clean-up patch has been floating around in my repo for a
> while.  Please consider applying it for the next release of nfs-utils=
=2E
Committed...=20

steved.

>=20
>=20
>  support/include/rpcmisc.h |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/support/include/rpcmisc.h b/support/include/rpcmisc.h
> index 1b8f411..c5847fa 100644
> --- a/support/include/rpcmisc.h
> +++ b/support/include/rpcmisc.h
> @@ -60,12 +60,12 @@ extern int	_rpcsvcdirty;
> =20
>  static inline struct sockaddr_in *nfs_getrpccaller_in(SVCXPRT *xprt)
>  {
> -	return (struct sockaddr_in *)svc_getcaller(xprt);
> +	return (struct sockaddr_in *)(char *)svc_getcaller(xprt);
>  }
> =20
>  static inline struct sockaddr *nfs_getrpccaller(SVCXPRT *xprt)
>  {
> -	return (struct sockaddr *)svc_getcaller(xprt);
> +	return (struct sockaddr *)(char *)svc_getcaller(xprt);
>  }
> =20
>  #endif /* RPCMISC_H */
>=20
