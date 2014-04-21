Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:45972 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbaDUNON (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 09:14:13 -0400
Date: Mon, 21 Apr 2014 06:14:12 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, Bruce Fields <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 15/70] NFSd: Add locking to the nfs4_file->fi_fds[] array
Message-ID: <20140421131412.GB24289@infradead.org>
References: <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <20140419143549.GA25682@infradead.org>
 <1398085297.2891.8.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1398085297.2891.8.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 21, 2014 at 09:01:37AM -0400, Trond Myklebust wrote:
> > > +static struct file *find_readable_file(struct nfs4_file *f)
> > > +{
> > > +	struct file *ret;
> > > +
> > > +	spin_lock(&f->fi_lock);
> > > +	ret = __nfs4_get_fd(f, O_RDONLY);
> > > +	if (!ret)
> > > +		ret = __nfs4_get_fd(f, O_RDWR);
> > > +	spin_unlock(&f->fi_lock);
> > > +	return ret;
> > 
> > Seems like these two functions could be easily consolidated by passing
> > a single flags argument.
> 
> Yes, but we'd have to invent a new set of flags for just this function
> and so I'm not sure that the end result would be more readable.
> We can't reuse O_RDONLY/O_WRONLY/O_RDWR since they can't be bitwise ORed
> to produce the 'read or read/write', 'write or read/write' combinations
> that we need.

One option would be:

static struct file *__nfs4_get_fd(struct nfs4_file *f, int oflag,
		int type)
{
	if ((oflag & type) && f->fi_fds[type])
		return get_file(f->fi_fds[type]);
	return NULL;
}

struct file *nfsd4_find_file(struct nfs4_file *f, unsigned int oflag)
{
	struct file *ret;

	BUG_ON(oflag & ~(O_RDONLY|O_WRONLY|O_RDWR);

	spin_lock(&f->fi_lock);
	ret = __nfs4_get_fd(f, oflag, O_RDONLY);
	if (!ret) {
		ret = __nfs4_get_fd(f, oflag, O_WRONLY);
		if (!ret) 
			ret = __nfs4_get_fd(f, oflag, O_RDWR);
	}
	spin_unlock(&f->fi_lock);
	return ret;
}
