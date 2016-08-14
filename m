Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42944 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932205AbcHNSau (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Aug 2016 14:30:50 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH rpcbind] src: include cdefs.h for the __P() macro
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1471097125-13193-1-git-send-email-yann.morin.1998@free.fr>
Date: Sun, 14 Aug 2016 14:30:43 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7736F23D-7AA5-4ABD-9693-99C9DCE03B91@oracle.com>
References: <1471097125-13193-1-git-send-email-yann.morin.1998@free.fr>
To: "Yann E. MORIN" <yann.morin.1998@free.fr>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Yann-


> On Aug 13, 2016, at 10:05 AM, Yann E. MORIN <yann.morin.1998@free.fr> wrote:
> 
> The __P() macro is defined in cdefs.h, so we must include it explicitly
> rather than relying on it being included by another header.
> 
> cdefs.h is a glibc-ism; glibc includes it almost everywhere from its own
> headers. So it automatically gets included for glibc.
> 
> However, cdefs.h is not present in musl, so its headers do not include
> it. We must thus include it when we need __P() (of course, one will have
> to provide his own cdefs.h in this case).

Simply adding "#include <sys/cdefs.h>" seems like the wrong approach.
If cdefs.h is not guaranteed to exist, the appropriate thing to do
is provide some autoconf machinery to define __P() in its absence.

On the other hand, I wonder if we need to continue to preserve K&R C
compatibility in this code base. Perhaps instead the uses of __P()
should be eliminated?


> Signed-off-by: "Yann E. MORIN" <yann.morin.1998@free.fr>
> ---
> src/check_bound.c  | 1 +
> src/pmap_svc.c     | 1 +
> src/rpcb_svc.c     | 1 +
> src/rpcb_svc_4.c   | 1 +
> src/rpcb_svc_com.c | 1 +
> src/rpcbind.c      | 1 +
> src/util.c         | 1 +
> src/warmstart.c    | 1 +
> 8 files changed, 8 insertions(+)
> 
> diff --git a/src/check_bound.c b/src/check_bound.c
> index c70b845..df14fbc 100644
> --- a/src/check_bound.c
> +++ b/src/check_bound.c
> @@ -49,6 +49,7 @@ static	char sccsid[] = "@(#)check_bound.c 1.11 89/04/21 Copyr 1989 Sun Micro";
> 
> #include <sys/types.h>
> #include <sys/socket.h>
> +#include <sys/cdefs.h>
> #include <rpc/rpc.h>
> #include <stdio.h>
> #include <netconfig.h>
> diff --git a/src/pmap_svc.c b/src/pmap_svc.c
> index ad28b93..5993c0b 100644
> --- a/src/pmap_svc.c
> +++ b/src/pmap_svc.c
> @@ -49,6 +49,7 @@ static	char sccsid[] = "@(#)pmap_svc.c 1.23 89/04/05 Copyr 1984 Sun Micro";
> #ifdef PORTMAP
> #include <sys/types.h>
> #include <sys/socket.h>
> +#include <sys/cdefs.h>
> #include <stdio.h>
> #include <rpc/rpc.h>
> #include <rpc/pmap_prot.h>
> diff --git a/src/rpcb_svc.c b/src/rpcb_svc.c
> index bd92201..eb5b49c 100644
> --- a/src/rpcb_svc.c
> +++ b/src/rpcb_svc.c
> @@ -42,6 +42,7 @@
>  * version 3 of rpcbind.
>  */
> #include <sys/types.h>
> +#include <sys/cdefs.h>
> #include <rpc/rpc.h>
> #include <rpc/rpcb_prot.h>
> #include <netconfig.h>
> diff --git a/src/rpcb_svc_4.c b/src/rpcb_svc_4.c
> index b673452..69d75e3 100644
> --- a/src/rpcb_svc_4.c
> +++ b/src/rpcb_svc_4.c
> @@ -44,6 +44,7 @@
> 
> #include <sys/types.h>
> #include <sys/stat.h>
> +#include <sys/cdefs.h>
> #include <rpc/rpc.h>
> #include <stdio.h>
> #include <unistd.h>
> diff --git a/src/rpcb_svc_com.c b/src/rpcb_svc_com.c
> index 148fe42..9369e27 100644
> --- a/src/rpcb_svc_com.c
> +++ b/src/rpcb_svc_com.c
> @@ -43,6 +43,7 @@
> #include <sys/stat.h>
> #include <sys/param.h>
> #include <sys/poll.h>
> +#include <sys/cdefs.h>
> #include <bits/poll.h>
> #include <sys/socket.h>
> #include <rpc/rpc.h>
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index c4265cd..37fc660 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -50,6 +50,7 @@
> #include <sys/file.h>
> #include <sys/socket.h>
> #include <sys/un.h>
> +#include <sys/cdefs.h>
> #include <netinet/in.h>
> #include <rpc/rpc.h>
> #include <rpc/rpc_com.h>
> diff --git a/src/util.c b/src/util.c
> index a6c835b..5bbec1d 100644
> --- a/src/util.c
> +++ b/src/util.c
> @@ -42,6 +42,7 @@
> #include <sys/types.h>
> #include <sys/socket.h>
> #include <sys/queue.h>
> +#include <sys/cdefs.h>
> #include <net/if.h>
> #include <netinet/in.h>
> #include <ifaddrs.h>
> diff --git a/src/warmstart.c b/src/warmstart.c
> index b6eb73e..f3a9c29 100644
> --- a/src/warmstart.c
> +++ b/src/warmstart.c
> @@ -34,6 +34,7 @@
> 
> #include <sys/types.h>
> #include <sys/stat.h>
> +#include <sys/cdefs.h>
> #include <stdio.h>
> #include <rpc/rpc.h>
> #include <rpc/rpcb_prot.h>
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



