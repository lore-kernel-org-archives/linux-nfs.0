From: " J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 4/8] nfsd4: extend the client_lock to cover cl_lru
Date: Fri, 7 May 2010 18:29:27 -0400
Message-ID: <20100507222926.GN19142@fieldses.org>
References: <4BE0A1AE.4040905@panasas.com> <1273013057-32460-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60533 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178Ab0EGW31 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 May 2010 18:29:27 -0400
In-Reply-To: <1273013057-32460-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 05, 2010 at 01:44:17AM +0300, Benny Halevy wrote:
> @@ -2557,6 +2562,7 @@ nfs4_laundromat(void)
>  	dprintk("NFSD: laundromat service - starting\n");
>  	if (locks_in_grace())
>  		nfsd4_end_grace();
> +	spin_lock(&client_lock);
>  	list_for_each_safe(pos, next, &client_lru) {
>  		clp = list_entry(pos, struct nfs4_client, cl_lru);
>  		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
> @@ -2565,11 +2571,15 @@ nfs4_laundromat(void)
>  				clientid_val = t;
>  			break;
>  		}
> +		list_del_init(&clp->cl_lru);
> +		spin_unlock(&client_lock);
>  		dprintk("NFSD: purging unused client (clientid %08x)\n",
>  			clp->cl_clientid.cl_id);
>  		nfsd4_remove_clid_dir(clp);
>  		expire_client(clp);
> +		spin_lock(&client_lock);
>  	}
> +	spin_unlock(&client_lock);
>  	INIT_LIST_HEAD(&reaplist);
>  	spin_lock(&recall_lock);
>  	list_for_each_safe(pos, next, &del_recall_lru) {

Careful--the list_for_each_safe() isn't enough to handle the results of
concurrent modifications that might occur while the client_lock is
dropped.

Maybe just use the trick of moving everything to a temporary list, then
doing the real work on that list after dropping the lock?

--b.
