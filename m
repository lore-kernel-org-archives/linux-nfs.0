Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35538 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbaGJLcu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 07:32:50 -0400
Date: Thu, 10 Jul 2014 04:32:49 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 006/100] nfsd4: use cl_lock to synchronize all stateid
 idr calls
Message-ID: <20140710113249.GB7257@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-7-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404842668-22521-7-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
> @@ -1266,7 +1271,9 @@ free_client(struct nfs4_client *clp)
>  	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
>  	free_svc_cred(&clp->cl_cred);
>  	kfree(clp->cl_name.data);
> +	spin_lock(&clp->cl_lock);
>  	idr_destroy(&clp->cl_stateids);
> +	spin_unlock(&clp->cl_lock);
>  	kfree(clp);

Taking cl_lock in free_client looks wrong to me, the client shall better be
removed from any data structures that allows looking it up at this
point.

Except for that looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
