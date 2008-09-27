From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: do_probe_callback should not clear rpc stats
Date: Fri, 26 Sep 2008 23:38:55 -0400
Message-ID: <20080927033855.GB12765@fieldses.org>
References: <48DCD215.8050508@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56443 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789AbYI0Di5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 23:38:57 -0400
In-Reply-To: <48DCD215.8050508@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 26, 2008 at 03:14:13PM +0300, Benny Halevy wrote:
> Now that cb_stats are static (since commit
> ff7d9756b501744540be65e172d27ee321d86103)
> there's no need to clear them.
> 
> Initially I thought it might make sense to do
> that every callback probing but since the stats
> are per-program and they are shared between possibly
> several client callback instances, zeroing them out
> seems like the wrong thing to do.
> 
> Note that that commit also introduced a bug
> since stats.program is also being cleared in the process
> and it is not restored after the memset as it used to be.

Thanks applied.--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4callback.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 5e95909..7b94701 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -399,9 +399,6 @@ static int do_probe_callback(void *data)
>  		__func__, args.program->name, args.program->number,
>  		args.program->nrvers, args.version);
>  
> -	/* Initialize rpc_stat */
> -	memset(args.program->stats, 0, sizeof(struct rpc_stat));
> -
>  	/* Create RPC client */
>  	client = rpc_create(&args);
>  	if (IS_ERR(client)) {
> 
