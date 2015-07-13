Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:34624 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbbGMO1j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 10:27:39 -0400
Received: by qgep37 with SMTP id p37so64822819qge.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 07:27:38 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2102\))
Subject: Re: [PATCH] [patch]libtirpc: check the makefd_xprt return value
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <CAHnGgyG-01Ga-U_tvVuwLvQD_d9dei57rHzGXZgtYir4U3V5tg@mail.gmail.com>
Date: Mon, 13 Jul 2015 10:27:35 -0400
Cc: Steve Dickson <steved@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <A44CA622-48B8-4D44-9D5B-4D770D7BBBDC@gmail.com>
References: <CAHnGgyG-01Ga-U_tvVuwLvQD_d9dei57rHzGXZgtYir4U3V5tg@mail.gmail.com>
To: ditang chen <ditang.c@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 9, 2015, at 9:59 AM, ditang chen <ditang.c@gmail.com> wrote:
> 
> xprt may return NULL, so check the return value is necessary.

This would only happen if the malloc() calls in makefd_xprt() failed,
which I think would be exceptionally rare?

Otherwise, this change adds reasonable defensive coding.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>


> Signed-off-by: Ditang Chen <ditang.c@gmail.com>
> ---
> src/svc_vc.c | 2 ++
> 1 file changed, 2 insertions(+)
> 
> diff --git a/src/svc_vc.c b/src/svc_vc.c
> index 9824631..f864951 100644
> --- a/src/svc_vc.c
> +++ b/src/svc_vc.c
> @@ -337,6 +337,8 @@ again:
> 	 */
> 
> 	newxprt = makefd_xprt(sock, r->sendsize, r->recvsize);
> +	if (!newxprt)
> +		return (FALSE);
> 
> 	if (!__rpc_set_netbuf(&newxprt->xp_rtaddr, &addr, len))
> 		return (FALSE);
> -- 
> 1.9.3
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chucklever@gmail.com



