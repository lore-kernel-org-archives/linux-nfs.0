Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:53357 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbaDUNBk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 09:01:40 -0400
Received: by mail-ig0-f169.google.com with SMTP id h18so1685269igc.0
        for <linux-nfs@vger.kernel.org>; Mon, 21 Apr 2014 06:01:40 -0700 (PDT)
Message-ID: <1398085297.2891.8.camel@leira.trondhjem.org>
Subject: Re: [PATCH 15/70] NFSd: Add locking to the nfs4_file->fi_fds[] array
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Date: Mon, 21 Apr 2014 09:01:37 -0400
In-Reply-To: <20140419143549.GA25682@infradead.org>
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
	 <20140419143549.GA25682@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph,

Thanks for reviewing these!

On Sat, 2014-04-19 at 07:35 -0700, Christoph Hellwig wrote:
> > +/* XXX: for first cut may fall back on returning file that doesn't work
> > + * at all? */
> 
> I think moving this code around might be a good opportunity to remove
> this confusing comment.

Will do.

> > +static struct file *find_writeable_file(struct nfs4_file *f)
> > +{
> > +	struct file *ret;
> > +
> > +	spin_lock(&f->fi_lock);
> > +	ret = __nfs4_get_fd(f, O_WRONLY);
> > +	if (!ret)
> > +		ret = __nfs4_get_fd(f, O_RDWR);
> > +	spin_unlock(&f->fi_lock);
> > +	return ret;
> > +}
> > +
> > +static struct file *find_readable_file(struct nfs4_file *f)
> > +{
> > +	struct file *ret;
> > +
> > +	spin_lock(&f->fi_lock);
> > +	ret = __nfs4_get_fd(f, O_RDONLY);
> > +	if (!ret)
> > +		ret = __nfs4_get_fd(f, O_RDWR);
> > +	spin_unlock(&f->fi_lock);
> > +	return ret;
> 
> Seems like these two functions could be easily consolidated by passing
> a single flags argument.

Yes, but we'd have to invent a new set of flags for just this function
and so I'm not sure that the end result would be more readable.
We can't reuse O_RDONLY/O_WRONLY/O_RDWR since they can't be bitwise ORed
to produce the 'read or read/write', 'write or read/write' combinations
that we need.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


