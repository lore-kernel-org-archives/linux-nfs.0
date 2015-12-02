Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:2861 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932226AbbLBP2x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2015 10:28:53 -0500
Subject: Re: [PATCH] xprtrdma: add missing curly braces, set rc to zero on
 non-zero
To: Colin King <colin.king@canonical.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S . Miller" <davem@davemloft.net>,
        Chuck Lever <chuck.lever@oracle.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Doug Ledford <dledford@redhat.com>, <linux-nfs@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
References: <1448406701-12474-1-git-send-email-colin.king@canonical.com>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <565F0E2F.7070301@Netapp.com>
Date: Wed, 2 Dec 2015 10:28:47 -0500
MIME-Version: 1.0
In-Reply-To: <1448406701-12474-1-git-send-email-colin.king@canonical.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/24/2015 06:11 PM, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Add the missing curly braces so that rc is only set to zero when
> it is non-zero.  Without this minor fix, rc is set to zero even
> when it is zero, which is slightly redundant.
> 
> Detected with smatch static analysis.

Thanks for the patch, but I've already have a patch from Dan Carpenter queued up to fix this.

Anna

> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/sunrpc/xprtrdma/verbs.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index eadd1655..2cc1014 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -852,10 +852,11 @@ retry:
>  
>  		if (extras) {
>  			rc = rpcrdma_ep_post_extra_recv(r_xprt, extras);
> -			if (rc)
> +			if (rc) {
>  				pr_warn("%s: rpcrdma_ep_post_extra_recv: %i\n",
>  					__func__, rc);
>  				rc = 0;
> +			}
>  		}
>  	}
>  
> 

