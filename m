Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33553 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761642AbaGRPyH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 11:54:07 -0400
Date: Fri, 18 Jul 2014 08:54:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 01/10] nfsd: Protect the nfs4_file delegation fields
 using the fi_lock
Message-ID: <20140718155402.GA23745@infradead.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
 <1405696416-32585-2-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405696416-32585-2-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +out_unlock:
> +	spin_unlock(&fp->fi_lock);
> +	spin_unlock(&state_lock);
> +out_fput:
> +	if (filp)
> +		fput(filp);

I don't think fput can be NULL here.

>  static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
>  {
> +	int status = 0;
> +
>  	if (fp->fi_had_conflict)
>  		return -EAGAIN;
>  	get_nfs4_file(fp);
> +	spin_lock(&state_lock);
> +	spin_lock(&fp->fi_lock);
>  	dp->dl_file = fp;
> +	if (!fp->fi_lease) {
> +		spin_unlock(&fp->fi_lock);
> +		spin_unlock(&state_lock);
>  		return nfs4_setlease(dp);
> +	}
>  	atomic_inc(&fp->fi_delegees);
>  	if (fp->fi_had_conflict) {
> +		status = -EAGAIN;
> +		goto out_unlock;
>  	}
>  	hash_delegation_locked(dp, fp);
> +out_unlock:
> +	spin_unlock(&fp->fi_lock);
>  	spin_unlock(&state_lock);
> +	return status;

I have to admit that I didn't have time to go through all the
surrounding code yet, but is there error handling correct here,
i.e. no need to rop the file reference and cleanup dp->dl_file for any
error or race case?

