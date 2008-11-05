From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 10/12] lockd: move immediate host expiry into separate function
Date: Wed, 5 Nov 2008 17:33:31 -0500
Message-ID: <C938CDFE-34D6-4561-AB65-BAB9A24363A4@oracle.com>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net> <1225915611-2401-1-git-send-email-bfields@citi.umich.edu> <1225915611-2401-2-git-send-email-bfields@citi.umich.edu> <1225915611-2401-3-git-send-email-bfields@citi.umich.edu> <1225915611-2401-4-git-send-email-bfields@citi.umich.edu> <1225915611-2401-5-git-send-email-bfields@citi.umich.edu> <1225915611-2401-6-git-send-email-bfields@citi.umich.edu> <1225915611-2401-7-git-send-email-bfields@citi.umich.edu> <1225915611-2401-8-git-send-email-bfields@citi.umich.edu> <1225915611-2401-9-git-send-email-bfields@citi.umich.edu> <1225915611-2401-10-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:50553 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbYKEWdl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 17:33:41 -0500
In-Reply-To: <1225915611-2401-10-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Not that this is a performance-critical path...

But it might be cleaner to create a helper that garbage collects a  
single host, and then call that routine from a loop in both  
nlm_shutdown_hosts() and nlm_gc_hosts(), instead of using a two pass  
shutdown.

On Nov 5, 2008, at 3:06 PM, J. Bruce Fields wrote:

> This code will later be shared.
>
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
> fs/lockd/host.c |   27 ++++++++++++++++-----------
> 1 files changed, 16 insertions(+), 11 deletions(-)
>
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index fa006af..588017f 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -593,29 +593,34 @@ static void warn_host_leak(struct host_table  
> *table)
> 	}
> }
>
> -/*
> - * Shut down the hosts module.
> - * Note that this routine is called only at server shutdown time.
> - */
> -void
> -nlm_shutdown_hosts(void)
> +static void expire_hosts(struct host_table *table)
> {
> 	struct hlist_head *chain;
> 	struct hlist_node *pos;
> 	struct nlm_host	*host;
>
> -	dprintk("lockd: shutting down host module\n");
> -	mutex_lock(&nlm_hosts.ht_mutex);
> -
> -	/* First, make all hosts eligible for gc */
> 	dprintk("lockd: nuking all hosts...\n");
> -	for_each_host(host, pos, chain, &nlm_hosts) {
> +	for_each_host(host, pos, chain, table) {
> 		host->h_expires = jiffies - 1;
> 		if (host->h_rpcclnt) {
> 			rpc_shutdown_client(host->h_rpcclnt);
> 			host->h_rpcclnt = NULL;
> 		}
> 	}
> +}
> +
> +/*
> + * Shut down the hosts module.
> + * Note that this routine is called only at server shutdown time.
> + */
> +void
> +nlm_shutdown_hosts(void)
> +{
> +	dprintk("lockd: shutting down host module\n");
> +	mutex_lock(&nlm_hosts.ht_mutex);
> +
> +	/* First, make all hosts eligible for gc */
> +	expire_hosts(&nlm_hosts);
>
> 	/* Then, perform a garbage collection pass */
> 	nlm_gc_hosts();
> -- 
> 1.5.5.rc1
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



