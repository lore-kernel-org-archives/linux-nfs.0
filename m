Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f182.google.com ([209.85.217.182]:40822 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932461AbaEPMTg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 May 2014 08:19:36 -0400
Received: by mail-lb0-f182.google.com with SMTP id z11so1656286lbi.27
        for <linux-nfs@vger.kernel.org>; Fri, 16 May 2014 05:19:34 -0700 (PDT)
Message-ID: <5376025B.6010202@cogentembedded.com>
Date: Fri, 16 May 2014 16:19:39 +0400
From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
MIME-Version: 1.0
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Fix for possible null pointer dereference in auth.c
References: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
In-Reply-To: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.

On 16-05-2014 1:56, Rickard Strandqvist wrote:

> There is otherwise a risk of a possible null pointer dereference.

> Was largely found by using a static code analysis program called cppcheck.

> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>   net/sunrpc/auth.c |   10 +++++++---
>   1 fil ändrad, 7 tillägg(+), 3 borttagningar(-)

> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 5285ead..3a55698 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -801,10 +801,14 @@ rpcauth_invalcred(struct rpc_task *task)
>   {
>   	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
>
> -	dprintk("RPC: %5u invalidating %s cred %p\n",
> -		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
> -	if (cred)
> +	if (cred) {
> +		dprintk("RPC: %5u invalidating %s cred %p\n",
> +			task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
> +
>   		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
> +	}
> +	else

    } and *else* should be on the same line, and there should be {} in the 
*else* arm since there's {} in the *if* arm already, according to 
Documentation/CodingStyle.

> +		dprintk("RPC: %5u invalidating is NULL\n", task->tk_pid);

    That's not a proper English, I'm afraid.

>   }

WBR, Sergei


