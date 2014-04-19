Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:43194 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751198AbaDSOfv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Apr 2014 10:35:51 -0400
Date: Sat, 19 Apr 2014 07:35:49 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 15/70] NFSd: Add locking to the nfs4_file->fi_fds[] array
Message-ID: <20140419143549.GA25682@infradead.org>
References: <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +/* XXX: for first cut may fall back on returning file that doesn't work
> + * at all? */

I think moving this code around might be a good opportunity to remove
this confusing comment.

> +static struct file *find_writeable_file(struct nfs4_file *f)
> +{
> +	struct file *ret;
> +
> +	spin_lock(&f->fi_lock);
> +	ret = __nfs4_get_fd(f, O_WRONLY);
> +	if (!ret)
> +		ret = __nfs4_get_fd(f, O_RDWR);
> +	spin_unlock(&f->fi_lock);
> +	return ret;
> +}
> +
> +static struct file *find_readable_file(struct nfs4_file *f)
> +{
> +	struct file *ret;
> +
> +	spin_lock(&f->fi_lock);
> +	ret = __nfs4_get_fd(f, O_RDONLY);
> +	if (!ret)
> +		ret = __nfs4_get_fd(f, O_RDWR);
> +	spin_unlock(&f->fi_lock);
> +	return ret;

Seems like these two functions could be easily consolidated by passing
a single flags argument.

