From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: nfsd: Use vfs_fsync_range() in nfsd_commit
Date: Fri, 29 Jan 2010 16:39:11 -0500
Message-ID: <1264801151.3644.27.camel@localhost>
References: <1264796353.3644.4.camel@localhost>
	 <20100129205022.GA14449@infradead.org> <1264798623.3644.18.camel@localhost>
	 <1264799906.3644.21.camel@localhost> <20100129212706.GA28361@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Dr. J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41379 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703Ab0A2Vjj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jan 2010 16:39:39 -0500
In-Reply-To: <20100129212706.GA28361@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-01-29 at 16:27 -0500, Christoph Hellwig wrote: 
> On Fri, Jan 29, 2010 at 04:18:26PM -0500, Trond Myklebust wrote:
> > nfsd: Use vfs_fsync_range() in nfsd_commit
> > 
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > The NFS COMMIT operation allows the client to specify the exact byte range
> > that it wishes to sync to disk in order to optimise server performance.
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Looks good to me,
> 
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Thanks!

> >   * Commit all pending writes to stable storage.
> > - * Strictly speaking, we could sync just the indicated file region here,
> > - * but there's currently no way we can ask the VFS to do so.
> 
> The commit above could use some addition that the commit only happens
> for the specified range.

I'll add in a couple of words. 

> And not actually touched by your patch, but that is the reason to
> open/close the file if we don't actually do anything with it for an
> async export?

I must admit that I was wondering about that too. I'm assuming that the
reason is to provide consistent behaviour w.r.t. access checks and
possibly also to ensure that NFSv4 delegations are revoked. Perhaps
Bruce could comment?

Cheers
  Trond
