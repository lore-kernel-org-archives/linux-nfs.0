From: "hch@infradead.org" <hch@infradead.org>
Subject: Re: [PATCH] writeback: reset inode dirty time when adding it back
	to empty s_dirty list
Date: Wed, 25 Mar 2009 12:55:00 -0400
Message-ID: <20090325165500.GA6047@infradead.org>
References: <1237840233-11045-1-git-send-email-jlayton@redhat.com> <20090324135720.GA25314@localhost> <20090324102806.4f38fd26@tleilax.poochiereds.net> <20090324104657.6907b19e@tleilax.poochiereds.net> <20090325012829.GA7506@localhost> <20090324221528.2bb7c50b@tleilax.poochiereds.net> <20090325025037.GA17374@localhost> <20090325075110.028f0d1d@tleilax.poochiereds.net> <20090325121742.GA22869@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, Ian Kent <raven@themaw.net>,
	Dave Chinner <david@fromorbit.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"jens.axboe@oracle.com" <jens.axboe@oracle.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hch@infradead.org" <hch@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090325121742.GA22869@localhost>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2009 at 08:17:43PM +0800, Wu Fengguang wrote:
> Now there are now two possible solutions:
> - unconditionally update dirtied_when in redirty_tail();
> - keep dirtied_when and redirty inodes to a new dedicated queue.
> The first one involves less code, the second one allows more flexible timing.
> 
> NFS/XFS could be a good starting point for discussing the
> requirements, so that we can reach a suitable solution.

Note that the XFS requirement also applies to all filesystems that
perform some sort of metadata updats on I/O completeion.  That includes
at least ext4, btrfs and most likely the cluster filesystems too.
