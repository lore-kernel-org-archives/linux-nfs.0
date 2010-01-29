From: Christoph Hellwig <hch@infradead.org>
Subject: Re: nfsd: Use vfs_fsync_range() in nfsd_commit
Date: Fri, 29 Jan 2010 16:27:06 -0500
Message-ID: <20100129212706.GA28361@infradead.org>
References: <1264796353.3644.4.camel@localhost> <20100129205022.GA14449@infradead.org> <1264798623.3644.18.camel@localhost> <1264799906.3644.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	"Dr. J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:54956 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752554Ab0A2V1J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Jan 2010 16:27:09 -0500
In-Reply-To: <1264799906.3644.21.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 29, 2010 at 04:18:26PM -0500, Trond Myklebust wrote:
> nfsd: Use vfs_fsync_range() in nfsd_commit
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> The NFS COMMIT operation allows the client to specify the exact byte range
> that it wishes to sync to disk in order to optimise server performance.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Looks good to me,


Reviewed-by: Christoph Hellwig <hch@lst.de>

>   * Commit all pending writes to stable storage.
> - * Strictly speaking, we could sync just the indicated file region here,
> - * but there's currently no way we can ask the VFS to do so.

The commit above could use some addition that the commit only happens
for the specified range.


And not actually touched by your patch, but that is the reason to
open/close the file if we don't actually do anything with it for an
async export?
