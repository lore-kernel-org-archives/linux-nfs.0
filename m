Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:35086 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751180AbdFEWCp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jun 2017 18:02:45 -0400
Received: by mail-qt0-f177.google.com with SMTP id w1so106330374qtg.2
        for <linux-nfs@vger.kernel.org>; Mon, 05 Jun 2017 15:02:45 -0700 (PDT)
Message-ID: <1496700162.2850.9.camel@redhat.com>
Subject: Re: [lkp-robot] [fs/locks]  9d21d181d0:
 will-it-scale.per_process_ops -14.1% regression
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        kernel test robot <xiaolong.ye@intel.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lkp@01.org, Christoph Hellwig <hch@infradead.org>
Date: Mon, 05 Jun 2017 18:02:42 -0400
In-Reply-To: <E3321EB0-9365-456C-9470-E74291F6FFEA@redhat.com>
References: <20170601020556.GE16905@yexl-desktop>
         <1496317284.2845.4.camel@redhat.com>
         <8F2C3CFF-5C2D-41B0-A895-B1F074DA7943@redhat.com>
         <1496321961.2845.6.camel@redhat.com> <20170601151415.GA4079@fieldses.org>
         <1496332131.2845.8.camel@redhat.com>
         <E3321EB0-9365-456C-9470-E74291F6FFEA@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-06-05 at 14:34 -0400, Benjamin Coddington wrote:
> On 1 Jun 2017, at 11:48, Jeff Layton wrote:
> 
> > On Thu, 2017-06-01 at 11:14 -0400, J. Bruce Fields wrote:
> > > On Thu, Jun 01, 2017 at 08:59:21AM -0400, Jeff Layton wrote:
> > > > I'm not so sure. That would only be the case if the thing were 
> > > > marked
> > > > for manadatory locking (a really rare thing).
> > > > 
> > > > The test is really simple and I don't think any read/write activity 
> > > > is
> > > > involved:
> > > > 
> > > >     https://github.com/antonblanchard/will-it-scale/blob/master/tests/lock1.c
> > > 
> > > So it's just F_WRLCK/F_UNLCK in a loop spread across multiple cores?
> > > I'd think real workloads do some work while holding the lock, and a 
> > > 15%
> > > regression on just the pure lock/unlock loop might not matter?  But 
> > > best
> > > to be careful, I guess.
> > > 
> > > --b.
> > > 
> > 
> > Yeah, that's my take.
> > 
> > I was assuming that getting a pid reference would be essentially free,
> > but it doesn't seem to be.
> > 
> > So, I think we probably want to avoid taking it for a file_lock that 
> > we
> > use to request a lock, but do take it for a file_lock that is used to
> > record a lock. How best to code that up, I'm not quite sure...
> 
> Maybe as simple as only setting fl_nspid in locks_insert_lock_ctx(), but
> that seems to just take us back to the problem of getting the pid wrong 
> if
> the lock is inserted later by a different worker than created the 
> request.
> 
> I have a mind now to just drop fl_nspid off the struct file_lock 
> completely,
> and instead just carry fl_pid, and when we do F_GETLK, we can do:
> 
> task = find_task_by_pid_ns(fl_pid, init_pid_ns)
> fl_nspid = task_pid_nr_ns(task, task_active_pid_ns(current))
> 
> That moves all the work off into the F_GETLK case, which I think is not 
> used
> so much.
> 

Actually I think what might work best is to:

- have locks_copy_conflock also copy the fl_nspid and take a reference
to it (as your patch #2 does)

- only set fl_nspid and take a reference there in locks_insert_lock_ctx
if it's not already set

- allow ->lock operations (like nfs) to set fl_nspid before they call
locks_lock_inode_wait to set the local lock. Might need to take a nspid
reference before dispatching an RPC so that you get the right thread
context.

Would that work?
-- 
Jeff Layton <jlayton@redhat.com>
