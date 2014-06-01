Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752085AbaFAROi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Jun 2014 13:14:38 -0400
Message-ID: <538B5F79.6030908@RedHat.com>
Date: Sun, 01 Jun 2014 13:14:33 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
CC: linux-nfs@vger.kernel.org,
        =?UTF-8?B?VHVvbWFzIFLDpHPDpG5lbg==?= <tuomas.rasanen@opinsys.fi>,
        Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH] gssd: Fix allocated buffer size for the scraped acceptor
 name  in do_downcall
References: <41011674.48947.1401180626967.JavaMail.zimbra@opinsys.fi>
In-Reply-To: <41011674.48947.1401180626967.JavaMail.zimbra@opinsys.fi>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/27/2014 04:50 AM, Veli-Matti Lintu wrote:
> 
> In commit 51fda07a "gssd: scrape the acceptor name out of the context"
> the allocated buffer size is not large enough to hold the actual data
> that is written to the buffer. This fixes the allocated buffer size.
> 
> Signed-off-by: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>
Committed..

steved.
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
> 
