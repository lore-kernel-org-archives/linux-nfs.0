From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Ping: d_obtain_alias
Date: Sat, 21 Feb 2009 11:40:15 -0800
Message-ID: <20090221114015.7bb5c9d8.akpm@linux-foundation.org>
References: <499FA991.8080909@panasas.com>
	<20090221174046.GA27374@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56947 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753159AbZBUTlL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Feb 2009 14:41:11 -0500
In-Reply-To: <20090221174046.GA27374@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 21 Feb 2009 12:40:46 -0500 Christoph Hellwig <hch@infradead.org> wrote:
>

(top-posting repaired)

> On Sat, Feb 21, 2009 at 09:13:21AM +0200, Benny Halevy wrote:
> > Christoph?
> > 
> > On Feb. 16, 2009, 19:31 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> > 
> > Christoph,
> > 
> > I see that in 4ea3ada2955e4519befa98ff55dd62d6dfbd1705,
> > you declared d_obtain_alias() as EXPORT_SYMBOL_GPL
> > and that it's supposed to replace d_alloc_anon which
> > was declared as EXPORT_SYMBOL and thus available to any
> > loadable module.
> > 
> > Do you consider d_obtain_alias() an internal API?
> > What exported API non-GPL'ed loadable file systems are
> > supposed to use now for fh_to_dentry?
> > 
> > Benny
> 
> All the nfs exported filesystem are tied intimately to the kernel,
> so yes, this is an internal export.
> 
> Non-GPL filesystem are illegal to distribute anyway, so I don't know why
> you even bother.
> 

Here's the patch in question:

commit 4ea3ada2955e4519befa98ff55dd62d6dfbd1705
Author: Christoph Hellwig <hch@lst.de>
Date:   Mon Aug 11 15:48:57 2008 +0200

    [PATCH] new helper: d_obtain_alias
    
    The calling conventions of d_alloc_anon are rather unfortunate for all
    users, and it's name is not very descriptive either.
    
    Add d_obtain_alias as a new exported helper that drops the inode
    reference in the failure case, too and allows to pass-through NULL
    pointers and inodes to allow for tail-calls in the export operations.
    
    Incidentally this helper already existed as a private function in
    libfs.c as exportfs_d_alloc so kill that one and switch the callers
    to d_obtain_alias.
    


Neither the title nor the changelog mentioned anything about disabling
non-GPL filesystems, so this effect was a mistake.  I didn't know this
was the effect and I doubt if Linus knew and quite possibly Christoph
and Al didn't know either.

We should correct that mistake.  Afterwards, feel free to prepare and
send out a patch titled "[patch] disable non-GPL filesystems" and we
can discuss it.

And before you start: I personally won't have any particularly strong
opinions in that discussion and will be interested to see the
discussion.

But preempting that discussion by leaving this mistake in place is not
the right way to go about this.

