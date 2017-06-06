Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:34035 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751384AbdFFNP2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jun 2017 09:15:28 -0400
Received: by mail-qt0-f175.google.com with SMTP id c10so73909968qtd.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Jun 2017 06:15:27 -0700 (PDT)
Message-ID: <1496754924.2807.5.camel@redhat.com>
Subject: Re: [lkp-robot] [fs/locks]  9d21d181d0:
 will-it-scale.per_process_ops -14.1% regression
From: Jeff Layton <jlayton@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        kernel test robot <xiaolong.ye@intel.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lkp@01.org, Christoph Hellwig <hch@infradead.org>
Date: Tue, 06 Jun 2017 09:15:24 -0400
In-Reply-To: <3924EE88-DC6E-4D95-9A84-50032930A65C@redhat.com>
References: <20170601020556.GE16905@yexl-desktop>
         <1496317284.2845.4.camel@redhat.com>
         <8F2C3CFF-5C2D-41B0-A895-B1F074DA7943@redhat.com>
         <1496321961.2845.6.camel@redhat.com> <20170601151415.GA4079@fieldses.org>
         <1496332131.2845.8.camel@redhat.com>
         <E3321EB0-9365-456C-9470-E74291F6FFEA@redhat.com>
         <1496700162.2850.9.camel@redhat.com>
         <3924EE88-DC6E-4D95-9A84-50032930A65C@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-06-06 at 09:00 -0400, Benjamin Coddington wrote:
> 
> On 5 Jun 2017, at 18:02, Jeff Layton wrote:
> 
> > On Mon, 2017-06-05 at 14:34 -0400, Benjamin Coddington wrote:
> > > On 1 Jun 2017, at 11:48, Jeff Layton wrote:
> > > 
> > > > On Thu, 2017-06-01 at 11:14 -0400, J. Bruce Fields wrote:
> > > > > On Thu, Jun 01, 2017 at 08:59:21AM -0400, Jeff Layton wrote:
> > > > > > I'm not so sure. That would only be the case if the thing were
> > > > > > marked
> > > > > > for manadatory locking (a really rare thing).
> > > > > > 
> > > > > > The test is really simple and I don't think any read/write 
> > > > > > activity
> > > > > > is
> > > > > > involved:
> > > > > > 
> > > > > >     https://github.com/antonblanchard/will-it-scale/blob/master/tests/lock1.c
> > > > > 
> > > > > So it's just F_WRLCK/F_UNLCK in a loop spread across multiple 
> > > > > cores?
> > > > > I'd think real workloads do some work while holding the lock, and a
> > > > > 15%
> > > > > regression on just the pure lock/unlock loop might not matter?  But
> > > > > best
> > > > > to be careful, I guess.
> > > > > 
> > > > > --b.
> > > > > 
> > > > 
> > > > Yeah, that's my take.
> > > > 
> > > > I was assuming that getting a pid reference would be essentially 
> > > > free,
> > > > but it doesn't seem to be.
> > > > 
> > > > So, I think we probably want to avoid taking it for a file_lock that
> > > > we
> > > > use to request a lock, but do take it for a file_lock that is used 
> > > > to
> > > > record a lock. How best to code that up, I'm not quite sure...
> > > 
> > > Maybe as simple as only setting fl_nspid in locks_insert_lock_ctx(), 
> > > but
> > > that seems to just take us back to the problem of getting the pid 
> > > wrong
> > > if
> > > the lock is inserted later by a different worker than created the
> > > request.
> > > 
> > > I have a mind now to just drop fl_nspid off the struct file_lock
> > > completely,
> > > and instead just carry fl_pid, and when we do F_GETLK, we can do:
> > > 
> > > task = find_task_by_pid_ns(fl_pid, init_pid_ns)
> > > fl_nspid = task_pid_nr_ns(task, task_active_pid_ns(current))
> > > 
> > > That moves all the work off into the F_GETLK case, which I think is 
> > > not
> > > used
> > > so much.
> > > 
> > 
> > Actually I think what might work best is to:
> > 
> > - have locks_copy_conflock also copy the fl_nspid and take a reference
> > to it (as your patch #2 does)
> > 
> > - only set fl_nspid and take a reference there in 
> > locks_insert_lock_ctx
> > if it's not already set
> > 
> > - allow ->lock operations (like nfs) to set fl_nspid before they call
> > locks_lock_inode_wait to set the local lock. Might need to take a 
> > nspid
> > reference before dispatching an RPC so that you get the right thread
> > context.
> 
> It would, but I think fl_nspid is completely unnecessary.  The reason we
> have it so that we can translate the pid number into other namespaces,  
> the
> most common case being that F_GETLK and views of /proc/locks within a
> namespace represent the same pid numbers as the processes in that 
> namespace
> that are holding the locks.
> 
> It is much simpler to just keep using fl_pid as the pid number in the 
> init
> namespace, but move the translation of that pid number to lookup time,
> rather than creation time.
> 

I think that would also work and I like the idea of getting rid of a
field in file_lock.

So, to be clear:

fl_pid would then store the pid of the process in the init_pid_ns, and
you'd just translate it as appropriate to the requestor's namespace?

If we want to go that route, then you'll probably still need a flag of
some sort to indicate that the fl_pid is to be expressed "as is", for
remote filesystems.

OTOH, if the lock is held remotely, I wonder if we'd be better off
simply reporting the pid as '-1', like we do with OFD locks. Hardly
anything pays attention to l_pid anyway and it's more or less
meaningless once the filesystem extends beyond the machine you're on.

That said, I'd be inclined to do that in a separate set so we could
revert it if it caused problems somewhere.
-- 
Jeff Layton <jlayton@redhat.com>
