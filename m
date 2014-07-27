Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:56905 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290AbaG0NVB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 09:21:01 -0400
Date: Sun, 27 Jul 2014 06:21:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org,
        Benny Halevy <bhalevy@primarydata.com>
Subject: Re: [PATCH 01/40] nfsd4: use cl_lock to synchronize all stateid idr
 calls
Message-ID: <20140727132100.GC32153@infradead.org>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
 <1405954972-28904-2-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405954972-28904-2-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
> @@ -1421,7 +1426,9 @@ free_client(struct nfs4_client *clp)
>  	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
>  	free_svc_cred(&clp->cl_cred);
>  	kfree(clp->cl_name.data);
> +	spin_lock(&clp->cl_lock);
>  	idr_destroy(&clp->cl_stateids);
> +	spin_unlock(&clp->cl_lock);
>  	kfree(clp);
>  }

No need for  locking around idr_destroy - the client structure better
be dead by the time we free it.

