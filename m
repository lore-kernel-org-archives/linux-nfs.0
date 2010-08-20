Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:53508 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660Ab0HTMof (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Aug 2010 08:44:35 -0400
Date: Fri, 20 Aug 2010 20:44:24 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        Chris Mason <chris.mason@oracle.com>,
        Jens Axboe <jens.axboe@oracle.com>
Subject: Re: why are WB_SYNC_NONE COMMITs being done with FLUSH_SYNC set ?
Message-ID: <20100820124424.GA17022@localhost>
References: <20100819101525.076831ad@barsoom.rdu.redhat.com>
 <20100819143710.GA4752@infradead.org>
 <20100819235553.GB22747@localhost>
 <20100820091904.GB20138@infradead.org>
 <20100820072757.6ae9741a@tlielax.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100820072757.6ae9741a@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 20, 2010 at 07:27:57AM -0400, Jeff Layton wrote:
> On Fri, 20 Aug 2010 05:19:04 -0400
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > On Fri, Aug 20, 2010 at 07:55:53AM +0800, Wu Fengguang wrote:
> > > Since migration and pageout still set nonblocking for ->writepage, we
> > > may keep them in the near future, until VM does not start IO on itself.
> > 
> > Why does pageout() and memory migration need to be even more
> > non-blocking than the already non-blockig WB_SYNC_NONE writeout?
> > 
> 
> Just an idle thought on this...
> 
> I think a lot of the confusion here comes from the fact that we have
> sync_mode and a bunch of flags, and it's not at all clear how
> filesystems are supposed to treat the union of them. There are also
> possible unions of flags/sync_modes that never happen in practice. It's
> not always obvious though and as filesystem implementors we have to
> consider the possibility that they might occur (consider WB_SYNC_ALL +
> for_background).
> 
> Perhaps a lot of this confusion could be lifted by getting rid of the
> extra flags and adding new sync_mode's. Maybe something like:
> 
> WB_SYNC_ALL /* wait on everything to complete */
> WB_SYNC_NONE /* don't wait on anything */
> WB_SYNC_FOR_RECLAIM /* sync for reclaim */
> WB_SYNC_FOR_KUPDATED /* sync by kupdate */
> ...etc...
> 
> That does mean that all of the filesystem specific code may need to be
> touched when new modes are added and removed. I think it would be
> clearer though about what you're supposed to do in ->writepages.

No, we are moving towards the other direction :)

I just removed the definition of wbc->nonblocking and
wbc->encountered_congestion and all of the references.

Sorry for the confusion!

Thanks,
Fengguang
