Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:35306 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbaE0KXf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2014 06:23:35 -0400
Received: by mail-qg0-f45.google.com with SMTP id z60so13188527qgd.4
        for <linux-nfs@vger.kernel.org>; Tue, 27 May 2014 03:23:35 -0700 (PDT)
Date: Tue, 27 May 2014 06:23:31 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org,
        Tuomas =?UTF-8?B?UsOk?= =?UTF-8?B?c8OkbmVu?=
	<tuomas.rasanen@opinsys.fi>
Subject: Re: [PATCH] gssd: Fix allocated buffer size for the scraped
 acceptor name  in do_downcall
Message-ID: <20140527062331.0ccd43ad@poochiereds.net>
In-Reply-To: <41011674.48947.1401180626967.JavaMail.zimbra@opinsys.fi>
References: <454183694.48823.1401178027425.JavaMail.zimbra@opinsys.fi>
	<41011674.48947.1401180626967.JavaMail.zimbra@opinsys.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 27 May 2014 08:50:26 +0000 (UTC)
Veli-Matti Lintu <veli-matti.lintu@opinsys.fi> wrote:

> 
> In commit 51fda07a "gssd: scrape the acceptor name out of the context"
> the allocated buffer size is not large enough to hold the actual data
> that is written to the buffer. This fixes the allocated buffer size.
> 
> Signed-off-by: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
> ---
>  utils/gssd/gssd_proc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 69bb3c6..40ff188 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -696,7 +696,7 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
>  	buf_size = sizeof(uid) + sizeof(timeout) + sizeof(pd->pd_seq_win) +
>  		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
>  		sizeof(context_token->length) + context_token->length +
> -		acceptor->length;
> +		sizeof(acceptor->length) + acceptor->length;
>  	p = buf = malloc(buf_size);
>  	if (!buf)
>  		goto out_err;

Nice catch...

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
