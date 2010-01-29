From: "Dr. J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd: Use vfs_fsync_range() in nfsd_commit
Date: Fri, 29 Jan 2010 18:58:52 -0500
Message-ID: <20100129235852.GC30852@fieldses.org>
References: <1264796353.3644.4.camel@localhost> <20100129205022.GA14449@infradead.org> <1264798623.3644.18.camel@localhost> <1264799906.3644.21.camel@localhost> <20100129212706.GA28361@infradead.org> <1264801151.3644.27.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48058 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752645Ab0A2X6u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jan 2010 18:58:50 -0500
In-Reply-To: <1264801151.3644.27.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 29, 2010 at 04:39:11PM -0500, Trond Myklebust wrote:
> On Fri, 2010-01-29 at 16:27 -0500, Christoph Hellwig wrote: 
> > And not actually touched by your patch, but that is the reason to
> > open/close the file if we don't actually do anything with it for an
> > async export?
> 
> I must admit that I was wondering about that too. I'm assuming that the
> reason is to provide consistent behaviour w.r.t. access checks and
> possibly also to ensure that NFSv4 delegations are revoked. Perhaps
> Bruce could comment?

Do delegations need to be revoked on commit?  (And do we care about
access checks?)

We could do both without the need for an actual open, but I don't know
that it matters much either way.

--b.
