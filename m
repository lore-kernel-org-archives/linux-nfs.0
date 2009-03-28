From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] writeback: reset inode dirty time when adding it back
	to empty s_dirty list
Date: Sat, 28 Mar 2009 20:44:01 +0800
Message-ID: <20090328124401.GA12608@localhost>
References: <20090325075110.028f0d1d@tleilax.poochiereds.net> <20090325121742.GA22869@localhost> <20090325091325.17c997fd@tleilax.poochiereds.net> <49CA2F41.8030804@themaw.net> <49CA33E7.6090309@themaw.net> <20090325100049.0cc4de87@tleilax.poochiereds.net> <20090325141618.GA5684@localhost> <20090326130327.3206e00b@barsoom.rdu.redhat.com> <20090327021303.GA7547@localhost> <20090327071633.0c1a0e3a@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Kent <raven@themaw.net>, Dave Chinner <david@fromorbit.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"jens.axboe@oracle.com" <jens.axboe@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hch@infradead.org" <hch@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27700 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751052AbZC2AFr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Mar 2009 20:05:47 -0400
In-Reply-To: <20090327071633.0c1a0e3a-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2009 at 07:16:33PM +0800, Jeff Layton wrote:
> On Fri, 27 Mar 2009 10:13:03 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
>
> >
> > > They also don't eliminate the problematic check above. Regardless of
> > > whether your or Jens' patches make it in, I think we'll still need
> > > something like the following (untested) patch.
> > >
> > > If this looks ok, I'll flesh out the comments some and "officially" post
> > > it. Thoughts?
> >
> > It's good in itself. However with more_io_wait queue, the first two
> > chunks will be eliminated. Mind I carry this patch with my patchset?
> >
>
> It makes sense to roll that fix in with the stuff you're doing.
>
> If it's going to be a little while before your patches get taken into
> mainline though, it might not hurt to go ahead and push my patch in as
> an interim fix. It shouldn't change the behavior of the code in the
> normal case of a short-lived dirtied_when value, and should guard
> against major problems when there's a long-lived one.

I'm afraid my patchset will miss the 2.6.30 merge window, so it makes
sense to merge your patch first:

> From: Jeff Layton <jlayton@redhat.com>
> Subject: [PATCH] writeback: guard against jiffies wraparound on inode->dirtied_when checks

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

Thanks,
Fengguang
