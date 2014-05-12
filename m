Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:36048 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297AbaELPcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 May 2014 11:32:53 -0400
Date: Mon, 12 May 2014 17:32:50 +0200
From: Jan Kara <jack@suse.cz>
To: NeilBrown <neilb@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Dave Chinner <david@fromorbit.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Mel Gorman <mgorman@suse.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/5] nfsd: Only set PF_LESS_THROTTLE when really needed.
Message-ID: <20140512153250.GB3685@quack.suse.cz>
References: <20140423022441.4725.89693.stgit@notabene.brown>
 <20140423024058.4725.38098.stgit@notabene.brown>
 <53694E7D.6060706@redhat.com>
 <20140512110437.296846ad@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140512110437.296846ad@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 12-05-14 11:04:37, NeilBrown wrote:
> On Tue, 06 May 2014 17:05:01 -0400 Rik van Riel <riel@redhat.com> wrote:
> 
> > On 04/22/2014 10:40 PM, NeilBrown wrote:
> > > PF_LESS_THROTTLE has a very specific use case: to avoid deadlocks
> > > and live-locks while writing to the page cache in a loop-back
> > > NFS mount situation.
> > > 
> > > It therefore makes sense to *only* set PF_LESS_THROTTLE in this
> > > situation.
> > > We now know when a request came from the local-host so it could be a
> > > loop-back mount.  We already know when we are handling write requests,
> > > and when we are doing anything else.
> > > 
> > > So combine those two to allow nfsd to still be throttled (like any
> > > other process) in every situation except when it is known to be
> > > problematic.
> > 
> > The FUSE code has something similar, but on the "client"
> > side.
> > 
> > See BDI_CAP_STRICTLIMIT in mm/writeback.c
> > 
> > Would it make sense to use that flag on loopback-mounted
> > NFS filesystems?
> > 
> 
> I don't think so.
> 
> I don't fully understand BDI_CAP_STRICTLIMIT, but it seems to be very
> fuse-specific and relates to NR_WRITEBACK_TEMP, which only fuse uses.  NFS
> doesn't need any 'strict' limits.
> i.e. it looks like fuse-specific code inside core-vm code, which I would
> rather steer clear of.
  It doesn't really relate to NR_WRITEBACK_TEMP. We have two dirty limits
in the VM - the global one and a per bdi one (which is a fraction of a
global one computed based on how much device has been writing back in the
past). Normally until we have more than (dirty_limit +
dirty_background_limit) / 2 dirty pages globally, the per bdi limit is
ignored. And BDI_CAP_STRICTLIMIT means that the per-bdi dirty limit is
always observed. Together with max_ratio and min_ratio this is useful for
limiting amount of dirty pages for specific bdis. And FUSE uses it so that
userspace filesystems cannot easily lockup the system by creating lots of
dirty pages which cannot be written back.

So I actually don't think BDI_CAP_STRICTLIMIT is a particularly good fit
for your problem although I agree with Rik that FUSE faces a similar
problem.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
