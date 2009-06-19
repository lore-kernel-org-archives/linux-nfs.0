From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/4] VFS: Add VFS helper functions for setting up
	private namespaces
Date: Fri, 19 Jun 2009 03:43:10 -0400
Message-ID: <20090619074310.GA25197@infradead.org>
References: <20090618192500.19433.16770.stgit@heimdal.trondhjem.org> <20090618192500.19433.90622.stgit@heimdal.trondhjem.org> <20090618205547.GA10932@infradead.org> <1245361382.8756.47.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34516 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbZFSHnK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2009 03:43:10 -0400
In-Reply-To: <1245361382.8756.47.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 18, 2009 at 02:43:02PM -0700, Trond Myklebust wrote:
> On Thu, 2009-06-18 at 16:55 -0400, Christoph Hellwig wrote:
> > On Thu, Jun 18, 2009 at 12:25:01PM -0700, Trond Myklebust wrote:
> > >  /* spinlock for vfsmount related operations, inplace of dcache_lock */
> > >  __cacheline_aligned_in_smp DEFINE_SPINLOCK(vfsmount_lock);
> > > +EXPORT_SYMBOL(vfsmount_lock);
> > 
> > This is not mentioned in the patch description and also doesn't seem
> > to be used in the following patches.
> > 
> > Exporting it is a really bad idea anyway as it protects data structures
> > that should not be exposed to filesystems.
> 
> It is used by the inlined function put_mnt_ns(). It would be trivial to
> make that an extern, and avoid the need for the vfsmount_lock export.
> Would that be acceptable?

I think moving it out of line is much better.  You can also merged it
into __put_mnt_ns while you're at it.

