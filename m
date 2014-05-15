Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:39981 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaEOWHC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2014 18:07:02 -0400
MIME-Version: 1.0
In-Reply-To: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
References: <1400190998-28153-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Date: Thu, 15 May 2014 18:07:01 -0400
Message-ID: <CAABAsM69JO2F95+uVzbSzOSbnNz2ae0kdffy8m-pGDRr_QR=+g@mail.gmail.com>
Subject: Re: [PATCH] Fix for possible null pointer dereference in auth.c
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 15, 2014 at 5:56 PM, Rickard Strandqvist
<rickard_strandqvist@spectrumdigital.se> wrote:
> There is otherwise a risk of a possible null pointer dereference.
>
> Was largely found by using a static code analysis program called cppcheck.
>
> Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
> ---
>  net/sunrpc/auth.c |   10 +++++++---
>  1 fil ändrad, 7 tillägg(+), 3 borttagningar(-)
>
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 5285ead..3a55698 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -801,10 +801,14 @@ rpcauth_invalcred(struct rpc_task *task)
>  {
>         struct rpc_cred *cred = task->tk_rqstp->rq_cred;
>
> -       dprintk("RPC: %5u invalidating %s cred %p\n",
> -               task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
> -       if (cred)
> +       if (cred) {
> +               dprintk("RPC: %5u invalidating %s cred %p\n",
> +                       task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
> +
>                 clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
> +       }
> +       else
> +               dprintk("RPC: %5u invalidating is NULL\n", task->tk_pid);
>  }
>
>

Can you please explain how we can get to rpcauth_invalcred() without a
valid cred pointer? I'm not seeing it...

Cheers
  Trond
