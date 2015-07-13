Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615AbbGMOhK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 10:37:10 -0400
Message-ID: <55A3CD15.6070900@RedHat.com>
Date: Mon, 13 Jul 2015 10:37:09 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: ditang chen <ditang.c@gmail.com>
CC: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] [patch]libtirpc: check the makefd_xprt return value
References: <CAHnGgyG-01Ga-U_tvVuwLvQD_d9dei57rHzGXZgtYir4U3V5tg@mail.gmail.com>
In-Reply-To: <CAHnGgyG-01Ga-U_tvVuwLvQD_d9dei57rHzGXZgtYir4U3V5tg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/09/2015 09:59 AM, ditang chen wrote:
> xprt may return NULL, so check the return value is necessary.
> 
> Signed-off-by: Ditang Chen <ditang.c@gmail.com>
Committed... Thanks!

steved.

> ---
>  src/svc_vc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/src/svc_vc.c b/src/svc_vc.c
> index 9824631..f864951 100644
> --- a/src/svc_vc.c
> +++ b/src/svc_vc.c
> @@ -337,6 +337,8 @@ again:
>  	 */
> 
>  	newxprt = makefd_xprt(sock, r->sendsize, r->recvsize);
> +	if (!newxprt)
> +		return (FALSE);
> 
>  	if (!__rpc_set_netbuf(&newxprt->xp_rtaddr, &addr, len))
>  		return (FALSE);
> 
