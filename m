Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52466 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965616AbaGPSJo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 14:09:44 -0400
Date: Wed, 16 Jul 2014 11:09:43 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 06/10] nfsd: Protect the nfs4_file delegation fields
 using the fi_lock
Message-ID: <20140716180943.GA6920@infradead.org>
References: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
 <1405521125-2303-7-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405521125-2303-7-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
> +	spin_lock(&fp->fi_lock);
>  	list_del_init(&dp->dl_perclnt);
>  	list_del_init(&dp->dl_recall_lru);
> -	spin_lock(&fp->fi_lock);
>  	list_del_init(&dp->dl_perfile);
>  	spin_unlock(&fp->fi_lock);
> -	spin_unlock(&state_lock);
>  	if (fp) {
>  		nfs4_put_deleg_lease(fp);
> -		put_nfs4_file(fp);
>  		dp->dl_file = NULL;
>  	}
> +	spin_unlock(&state_lock);
> +	put_nfs4_file(fp);
>  }

Unless I've missed something put_nfs4_file does not handle a NULL
pointer argument in the current tree, so this needs a NULL check
for fp.

> +	spin_lock(&state_lock);
> +	/* Did the lease get broken before we took the lock? */
> +	status = -EAGAIN;
> +	if (!file_has_lease(fl->fl_file))
> +		goto out_unlock;

So if the delegation we just tried to add got broken, but someone else
managed to add one this would also return true.  But could that happen
either in real life or in theory?  Shouldn't we instead have an
atomic flag on the delegation that it got broken which we could check
here?

