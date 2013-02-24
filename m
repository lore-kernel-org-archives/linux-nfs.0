Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:40910 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759491Ab3BXWfM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Feb 2013 17:35:12 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Syam Sidhardhan <syamsidhardh@gmail.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Subject: Re: [PATCH] SUNRPC: Fix possible NULL pointer dereference
Date: Sun, 24 Feb 2013 22:35:08 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DE4C7@SACEXCMBX04-PRD.hq.netapp.com>
References: <1361744605-28235-1-git-send-email-s.syam@samsung.com>
In-Reply-To: <1361744605-28235-1-git-send-email-s.syam@samsung.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-02-25 at 03:53 +0530, Syam Sidhardhan wrote:
> Check for cred == NULL has to be done before accessing cred.
> 
> Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
> ---
>  net/sunrpc/auth.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index f529404..18678a6 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -695,10 +695,13 @@ rpcauth_invalcred(struct rpc_task *task)
>  {
>  	struct rpc_cred *cred = task->tk_rqstp->rq_cred;
>  
> +	if (cred == NULL)
> +		return;
> +
>  	dprintk("RPC: %5u invalidating %s cred %p\n",
>  		task->tk_pid, cred->cr_auth->au_ops->au_name, cred);
> -	if (cred)
> -		clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
> +
> +	clear_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
>  }
>  
>  int

Do we need that check at all?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
