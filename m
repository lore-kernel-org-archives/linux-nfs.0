From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] writeback: reset inode dirty time when adding it back
 to empty s_dirty list
Date: Fri, 27 Mar 2009 07:16:33 -0400
Message-ID: <20090327071633.0c1a0e3a@tleilax.poochiereds.net>
References: <20090324221528.2bb7c50b@tleilax.poochiereds.net>
	<20090325025037.GA17374@localhost>
	<20090325075110.028f0d1d@tleilax.poochiereds.net>
	<20090325121742.GA22869@localhost>
	<20090325091325.17c997fd@tleilax.poochiereds.net>
	<49CA2F41.8030804@themaw.net>
	<49CA33E7.6090309@themaw.net>
	<20090325100049.0cc4de87@tleilax.poochiereds.net>
	<20090325141618.GA5684@localhost>
	<20090326130327.3206e00b@barsoom.rdu.redhat.com>
	<20090327021303.GA7547@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Ian Kent <raven@themaw.net>, Dave Chinner <david@fromorbit.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"jens.axboe@oracle.com" <jens.axboe@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hch@infradead.org" <hch@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090327021303.GA7547@localhost>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 27 Mar 2009 10:13:03 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> 
> > They also don't eliminate the problematic check above. Regardless of
> > whether your or Jens' patches make it in, I think we'll still need
> > something like the following (untested) patch.
> > 
> > If this looks ok, I'll flesh out the comments some and "officially" post
> > it. Thoughts?
> 
> It's good in itself. However with more_io_wait queue, the first two
> chunks will be eliminated. Mind I carry this patch with my patchset?
> 

It makes sense to roll that fix in with the stuff you're doing.

If it's going to be a little while before your patches get taken into
mainline though, it might not hurt to go ahead and push my patch in as
an interim fix. It shouldn't change the behavior of the code in the
normal case of a short-lived dirtied_when value, and should guard
against major problems when there's a long-lived one.

-- 
Jeff Layton <jlayton@redhat.com>
