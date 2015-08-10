Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60386 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752767AbbHJOdu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Aug 2015 10:33:50 -0400
Date: Mon, 10 Aug 2015 10:33:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 03/18] nfsd: convert laundry_wq to something less
 nfsd4 specific
Message-ID: <20150810143349.GC9066@fieldses.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-4-git-send-email-jeff.layton@primarydata.com>
 <20150809071438.GC9772@infradead.org>
 <20150809071137.28ca8f19@tlielax.poochiereds.net>
 <20150810082622.GA18624@infradead.org>
 <20150810072351.39b1b189@tlielax.poochiereds.net>
 <20150810121035.GA19713@infradead.org>
 <20150810081456.48c60112@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150810081456.48c60112@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 10, 2015 at 08:14:56AM -0400, Jeff Layton wrote:
> On Mon, 10 Aug 2015 05:10:35 -0700
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Mon, Aug 10, 2015 at 07:23:51AM -0400, Jeff Layton wrote:
> > > I did consider a shrinker and LRU list for this. The problem there is
> > > that shrinkers are triggered on memory pressure. Keeping these files
> > > open after they've been idle for a long period of time would prevent
> > > the kernel from handing out leases on them, so closing them after a
> > > reasonable idle period seemed like the right thing to do.
> > 
> > True.
> > 
> > > I suppose however we could use a shrinker/LRU _and_ add a mechanism
> > > that would cause the kernel to close idle nfsd_files for an inode when
> > > there is an attempt to do a F_SETLEASE. That would probably work,
> > > unless I'm missing other reasons that keeping unused files open might
> > > be problematic. Are there any?
> > 
> > That seems reasonable.  Keepign the file open also will prevent
> > unmounting the file system, although currently any NFS export already
> > causes that as well.
> 
> Yes, though that's the reason for the new ->flush hook in the sunrpc
> cache code. On any export table change, we'll clean out the nfsd_file
> cache to help ensure that you'll be able to unmount soon after
> unexporting a filesystem.

There are definitely people with scripts that try to unexport and then
immediately unmount, e.g. to migrate a filesystem elsewhere.  They
already run into problems thanks to export caches, locks, and v4 state.
A complete shutdown of nfsd is currently the only supported way to
unmount.  Still, I wouldn't be surprised if there are people who
(possibly just out of luck) have a working setup now that will start
failing after we take these additional references.

Extending the unlock_* interfaces or getting Kinglong's stuff working
would help.

--b.

> 
> In any case, I'll look at the shrinker/lru thing for the next respin
> and see whether adding a hook into the setlease code might be
> reasonable.
> 
> Thanks for the review so far,
> -- 
> Jeff Layton <jlayton@poochiereds.net>
