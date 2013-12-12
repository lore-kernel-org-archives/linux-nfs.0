Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40072 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751488Ab3LLQTc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Dec 2013 11:19:32 -0500
Date: Thu, 12 Dec 2013 11:19:31 -0500
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: fix printk format string in nfsd4_open
Message-ID: <20131212161931.GF11521@fieldses.org>
References: <1386608743-23718-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386608743-23718-1-git-send-email-bhalevy@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 09, 2013 at 07:05:43PM +0200, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>

Are you sure?  Reminding myself from the sprintf man page.... %*s
provides padding, %.*s limits the number of characters taken from the
string.  We need that limit since there's no guarantee of null
termination here.

--b.

> ---
>  fs/nfsd/nfs4proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 0a964f1..8624bee 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -361,7 +361,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	struct net *net = SVC_NET(rqstp);
>  	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
>  
> -	dprintk("NFSD: nfsd4_open filename %.*s op_openowner %p\n",
> +	dprintk("NFSD: nfsd4_open filename %*s op_openowner %p\n",
>  		(int)open->op_fname.len, open->op_fname.data,
>  		open->op_openowner);
>  
> -- 
> 1.8.3.1
> 
