Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48170 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756835AbaGRRTb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 13:19:31 -0400
Date: Fri, 18 Jul 2014 10:19:30 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 09/10] nfsd: clean up nfs4_set_delegation
Message-ID: <20140718171930.GA12375@infradead.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
 <1405696416-32585-10-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405696416-32585-10-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
> +		    struct nfs4_file *fp)
>  {
> -	int status = 0;
> +	int status;
> +	struct nfs4_delegation *dp;
>  
>  	if (fp->fi_had_conflict)
> -		return -EAGAIN;
> +		return ERR_PTR(-EAGAIN);
> +
> +	dp = alloc_init_deleg(clp, fh);
> +	if (!dp)
> +		return ERR_PTR(-ENOMEM);
> +
>  	get_nfs4_file(fp);

Seems like we should pass the file pointer to alloc_init_deleg as well
so it can set that one one up and grab the reference without any lock?

Otherwise looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
