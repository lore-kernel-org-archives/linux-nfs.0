From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NLM: tear down RPC clients in nlm_shutdown_hosts
Date: Mon, 28 Jan 2008 18:18:26 -0500
Message-ID: <20080128231826.GU16785@fieldses.org>
References: <1201548551-23592-1-git-send-email-jlayton@redhat.com> <1201548551-23592-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46185 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764914AbYA1XSc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 18:18:32 -0500
In-Reply-To: <1201548551-23592-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 02:29:10PM -0500, Jeff Layton wrote:
> It's possible for a RPC to outlive the lockd daemon that created it, so
> we need to make sure that all RPC's are killed when lockd is coming
> down. When nlm_shutdown_hosts is called, kill off all RPC tasks
> associated with the host. Since we need to wait until they have all gone
> away, we might as well just shut down the RPC client altogether.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/lockd/host.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index ebec009..ca6b16f 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -379,8 +379,13 @@ nlm_shutdown_hosts(void)
>  	/* First, make all hosts eligible for gc */
>  	dprintk("lockd: nuking all hosts...\n");
>  	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
> -		hlist_for_each_entry(host, pos, chain, h_hash)
> +		hlist_for_each_entry(host, pos, chain, h_hash) {
>  			host->h_expires = jiffies - 1;
> +			if (host->h_rpcclnt) {

So the only difference from the previous patch is this test and the
following assignment?  OK.

--b.

> +				rpc_shutdown_client(host->h_rpcclnt);
> +				host->h_rpcclnt = NULL;
> +			}
> +		}
>  	}
>  
>  	/* Then, perform a garbage collection pass */
> -- 
> 1.5.3.7
> 
