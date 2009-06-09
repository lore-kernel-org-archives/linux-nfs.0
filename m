From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: mmotm 2009-06-02-16-11 uploaded (readahead)
Date: Tue, 9 Jun 2009 12:51:06 +0800
Message-ID: <20090609045106.GA9370@localhost>
References: <200906022331.n52NVJhG015117@imap1.linux-foundation.org> <4A25F3FF.5060404@oracle.com> <20090603134739.97d8a461.akpm@linux-foundation.org> <20090609035915.GW11363@kernel.dk> <20090608213817.999143dd.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"hifumi.hisashi-gVGce1chcLdL9jVzuh4AOg@public.gmane.org" <hifumi.hisashi-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>,
	Vladislav Bolkhovitin <vst-d+Crzxg7Rs0@public.gmane.org>,
	Bart Van Assche <bart.vanassche@gmail.com>,
	Beheer InterCommIT <intercommit@gmail.com>,
	linux-nfs@vger.kernel.org, scst-devel@lists.sourceforge.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49221 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751524AbZFIEvQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jun 2009 00:51:16 -0400
In-Reply-To: <20090608213817.999143dd.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 09, 2009 at 12:38:17PM +0800, Andrew Morton wrote:
> On Tue, 9 Jun 2009 05:59:16 +0200 Jens Axboe <jens.axboe@oracle.com> wrote:
> 
> > ...
> > > Doing a block-specific call from inside page_cache_async_readahead() is
> > > a bit of a layering violation - this may not be a block-backed
> > > filesystem at all.
> > > 
> > > otoh, perhaps blk_run_backing_dev() is wrongly named and defined in the
> > > wrong place.  Perhaps non-block-backed backing_devs want to implement
> > > an unplug-style function too?  In which case the whole thing should be
> > > renamed and moved outside blkdev.h.
> > > 
> > > If we don't want to do that, shouldn't backing_dev_info.unplug* be
> > > wrapped in #ifdef CONFIG_BLOCK?  And wasn't it a layering violation to
> > > put block-specific things into the backing_dev_info?
> > > 
> > > Jens, talk to me!
> > > 
> > > From the readahead POV: does it make sense to call the backing-dev's
> > > "unplug" function even if that isn't a block-based device?  Or was this
> > > just a weird block-device-only performance problem?  Hard to say.
> > 
> > Layering wise, I don't think it's that bad. It would have looked cleaner
> > to do:
> > 
> >         blk_run_address_space(mapping);
> > 
> > instead, but we would still need to make that available outside of
> > CONFIG_BLOCK as well.
> > 
> > What I don't like about the patch is that it's a heuristic, a "I poked
> > this and it made that faster" with nobody really understanding why.
> 
> Well.  I _think_ we understand it.  I'm not sure that we understand why
> it made scst faster though.

Because the NFS/SCST servers are running RAID?

Also the client side NFS/SCST IO request may be slitted up and served
by a pool of server processes, which introduces the same disorderness
as in RAID configuration. But I wonder whether blk_* work for them,
or NFS/SCST have the "plug" concept at all.

> > And
> > it's second guessing the block layer unplugging, so perhaps the real fix
> > should be going on there. Or perhaps it's just fine and this micro
> > optimization just helps this one case and that's great.
> > 
> > So ho humm, not terribly excited about it, but I guess we can shove it
> > in there for testing. But lets please use blk_run_address_space() and
> > add an empty stub for that.
> 
> But blk_anything() shouldn't be in the readahead code - readahead isn't
> specific to block-based devices!

Yup, the "#ifdef CONFIG_BLOCK" looks ugly..

Thanks,
Fengguang

> y:/usr/src/25> egrep "blk|block" mm/readahead.c 
> #include <linux/blkdev.h>
>  * block layer to abandon the readahead if request allocation would block.
>  * force_page_cache_readahead() will ignore queue congestion and will block on
> y:/usr/src/25> 
> 
> 
> >From a layering POV we should have some mapping_start_io(address_space
> *) which of course calls blk_run_address_space() if it's a block-backed
> and calls <something else> if it's not block-backed.  Problem is, if
> the backing device is, say, NFS then we have no reason to believe that
> starting IO at this time is beneficial to NFS.
> 
> But sure, the world wouldn't end if we put a block-specific IO hint in
> there.  It just isn't quite right.
