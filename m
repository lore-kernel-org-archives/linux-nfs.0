Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54074 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751058AbdFAPOQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Jun 2017 11:14:16 -0400
Date: Thu, 1 Jun 2017 11:14:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        kernel test robot <xiaolong.ye@intel.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lkp@01.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [lkp-robot] [fs/locks]  9d21d181d0:
 will-it-scale.per_process_ops -14.1% regression
Message-ID: <20170601151415.GA4079@fieldses.org>
References: <20170601020556.GE16905@yexl-desktop>
 <1496317284.2845.4.camel@redhat.com>
 <8F2C3CFF-5C2D-41B0-A895-B1F074DA7943@redhat.com>
 <1496321961.2845.6.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1496321961.2845.6.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 01, 2017 at 08:59:21AM -0400, Jeff Layton wrote:
> On Thu, 2017-06-01 at 07:49 -0400, Benjamin Coddington wrote:
> > On 1 Jun 2017, at 7:41, Jeff Layton wrote:
> > 
> > > On Thu, 2017-06-01 at 10:05 +0800, kernel test robot wrote:
> > > > Greeting,
> > > > 
> > > > FYI, we noticed a -14.1% regression of will-it-scale.per_process_ops 
> > > > due to commit:
> > > > 
> > > > 
> > > > commit: 9d21d181d06acab9a8e80eac2ec4eed77b656793 ("fs/locks: Set 
> > > > fl_nspid at file_lock allocation")
> > > > url: 
> > > > https://github.com/0day-ci/linux/commits/Benjamin-Coddington/fs-locks-Alloc-file_lock-where-practical/20170527-050700
> > > > 
> > > > 
> > > 
> > > Ouch, that's a rather nasty performance hit. In hindsight, maybe we
> > > shouldn't move those off the stack after all? Heck, if it's that
> > > significant, maybe we should move the F_SETLK callers to allocate 
> > > these
> > > on the stack as well?
> > 
> > We can do that.  But, I think this is picking up the 
> > locks_mandatory_area()
> > allocation which is now removed.  The attached config has
> > CONFIG_MANDATORY_FILE_LOCKING=y,  so there's allocation on every 
> > read/write.
> > 
> 
> I'm not so sure. That would only be the case if the thing were marked
> for manadatory locking (a really rare thing).
> 
> The test is really simple and I don't think any read/write activity is
> involved:
> 
>     https://github.com/antonblanchard/will-it-scale/blob/master/tests/lock1.c

So it's just F_WRLCK/F_UNLCK in a loop spread across multiple cores?
I'd think real workloads do some work while holding the lock, and a 15%
regression on just the pure lock/unlock loop might not matter?  But best
to be careful, I guess.

--b.

> 
> ...and the 0 day bisected it down to this patch, IIUC:
> 
>     https://github.com/0day-ci/linux/commit/9d21d181d06acab9a8e80eac2ec4eed77b656793
> 
> It seems likely that it's the extra get_pid/put_pid in the allocation
> and free codepath. I expected those to be pretty cheap, but maybe
> they're not?


