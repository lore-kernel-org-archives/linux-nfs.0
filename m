Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:63552 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249AbaGJMpU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 08:45:20 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so1804431qac.12
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 05:45:20 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 08:45:18 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 006/100] nfsd4: use cl_lock to synchronize all
 stateid idr calls
Message-ID: <20140710084518.59fc001e@tlielax.poochiereds.net>
In-Reply-To: <20140710113249.GB7257@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
	<1404842668-22521-7-git-send-email-jlayton@primarydata.com>
	<20140710113249.GB7257@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 04:32:49 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> >  static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
> > @@ -1266,7 +1271,9 @@ free_client(struct nfs4_client *clp)
> >  	rpc_destroy_wait_queue(&clp->cl_cb_waitq);
> >  	free_svc_cred(&clp->cl_cred);
> >  	kfree(clp->cl_name.data);
> > +	spin_lock(&clp->cl_lock);
> >  	idr_destroy(&clp->cl_stateids);
> > +	spin_unlock(&clp->cl_lock);
> >  	kfree(clp);
> 
> Taking cl_lock in free_client looks wrong to me, the client shall better be
> removed from any data structures that allows looking it up at this
> point.
> 

Yeah, ok -- good point. I'll remove that.

> Except for that looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>


-- 
Jeff Layton <jlayton@primarydata.com>
