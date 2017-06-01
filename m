Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:33298 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751078AbdFAM7Y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jun 2017 08:59:24 -0400
Received: by mail-qk0-f180.google.com with SMTP id y201so35311386qka.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Jun 2017 05:59:24 -0700 (PDT)
Message-ID: <1496321961.2845.6.camel@redhat.com>
Subject: Re: [lkp-robot] [fs/locks]  9d21d181d0:
 will-it-scale.per_process_ops -14.1% regression
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: kernel test robot <xiaolong.ye@intel.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>, bfields@fieldses.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lkp@01.org, Christoph Hellwig <hch@infradead.org>
Date: Thu, 01 Jun 2017 08:59:21 -0400
In-Reply-To: <8F2C3CFF-5C2D-41B0-A895-B1F074DA7943@redhat.com>
References: <20170601020556.GE16905@yexl-desktop>
         <1496317284.2845.4.camel@redhat.com>
         <8F2C3CFF-5C2D-41B0-A895-B1F074DA7943@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-06-01 at 07:49 -0400, Benjamin Coddington wrote:
> On 1 Jun 2017, at 7:41, Jeff Layton wrote:
> 
> > On Thu, 2017-06-01 at 10:05 +0800, kernel test robot wrote:
> > > Greeting,
> > > 
> > > FYI, we noticed a -14.1% regression of will-it-scale.per_process_ops 
> > > due to commit:
> > > 
> > > 
> > > commit: 9d21d181d06acab9a8e80eac2ec4eed77b656793 ("fs/locks: Set 
> > > fl_nspid at file_lock allocation")
> > > url: 
> > > https://github.com/0day-ci/linux/commits/Benjamin-Coddington/fs-locks-Alloc-file_lock-where-practical/20170527-050700
> > > 
> > > 
> > 
> > Ouch, that's a rather nasty performance hit. In hindsight, maybe we
> > shouldn't move those off the stack after all? Heck, if it's that
> > significant, maybe we should move the F_SETLK callers to allocate 
> > these
> > on the stack as well?
> 
> We can do that.  But, I think this is picking up the 
> locks_mandatory_area()
> allocation which is now removed.  The attached config has
> CONFIG_MANDATORY_FILE_LOCKING=y,  so there's allocation on every 
> read/write.
> 

I'm not so sure. That would only be the case if the thing were marked
for manadatory locking (a really rare thing).

The test is really simple and I don't think any read/write activity is
involved:

    https://github.com/antonblanchard/will-it-scale/blob/master/tests/lock1.c

...and the 0 day bisected it down to this patch, IIUC:

    https://github.com/0day-ci/linux/commit/9d21d181d06acab9a8e80eac2ec4eed77b656793

It seems likely that it's the extra get_pid/put_pid in the allocation
and free codepath. I expected those to be pretty cheap, but maybe
they're not?
-- 
Jeff Layton <jlayton@redhat.com>
