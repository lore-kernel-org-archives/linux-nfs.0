Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:33055 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbbHJMO7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2015 08:14:59 -0400
Received: by ykaz130 with SMTP id z130so29908365yka.0
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2015 05:14:59 -0700 (PDT)
Date: Mon, 10 Aug 2015 08:14:56 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 03/18] nfsd: convert laundry_wq to something less
 nfsd4 specific
Message-ID: <20150810081456.48c60112@tlielax.poochiereds.net>
In-Reply-To: <20150810121035.GA19713@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-4-git-send-email-jeff.layton@primarydata.com>
	<20150809071438.GC9772@infradead.org>
	<20150809071137.28ca8f19@tlielax.poochiereds.net>
	<20150810082622.GA18624@infradead.org>
	<20150810072351.39b1b189@tlielax.poochiereds.net>
	<20150810121035.GA19713@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Aug 2015 05:10:35 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Aug 10, 2015 at 07:23:51AM -0400, Jeff Layton wrote:
> > I did consider a shrinker and LRU list for this. The problem there is
> > that shrinkers are triggered on memory pressure. Keeping these files
> > open after they've been idle for a long period of time would prevent
> > the kernel from handing out leases on them, so closing them after a
> > reasonable idle period seemed like the right thing to do.
> 
> True.
> 
> > I suppose however we could use a shrinker/LRU _and_ add a mechanism
> > that would cause the kernel to close idle nfsd_files for an inode when
> > there is an attempt to do a F_SETLEASE. That would probably work,
> > unless I'm missing other reasons that keeping unused files open might
> > be problematic. Are there any?
> 
> That seems reasonable.  Keepign the file open also will prevent
> unmounting the file system, although currently any NFS export already
> causes that as well.

Yes, though that's the reason for the new ->flush hook in the sunrpc
cache code. On any export table change, we'll clean out the nfsd_file
cache to help ensure that you'll be able to unmount soon after
unexporting a filesystem.

In any case, I'll look at the shrinker/lru thing for the next respin
and see whether adding a hook into the setlease code might be
reasonable.

Thanks for the review so far,
-- 
Jeff Layton <jlayton@poochiereds.net>
