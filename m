Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43821 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755319Ab3FKQqu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 12:46:50 -0400
Date: Tue, 11 Jun 2013 12:35:52 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v2 00/14] locks: scalability improvements for file
 locking
Message-ID: <20130611123552.12743dd7@tlielax.poochiereds.net>
In-Reply-To: <20130611160405.GC8653@fieldses.org>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
	<20130611160405.GC8653@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 11 Jun 2013 12:04:05 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jun 11, 2013 at 07:08:54AM -0400, Jeff Layton wrote:
> > Summary of Significant Changes:
> > -------------------------------
> > v2:
> > - Fix potential races in deadlock detection. Manipulation of global
> >   blocked_hash and deadlock detection are now atomic. This is a
> >   little slower than the earlier set, but is provably correct. Also,
> >   the patch that converts to using the i_lock has been split out from
> >   most of the other changes. That should make it easier to review, but
> >   it does leave a potential race in the deadlock detection that is fixed
> >   up by the following patch. It may make sense to fold patches 7 and 8
> >   together before merging.
> > 
> > - Add percpu hlists and lglocks for global file_lock_list. This gives
> >   us some speedup since this list is seldom read.
> > 
> > Abstract (tl;dr version):
> > -------------------------
> > This patchset represents an overhaul of the file locking code with an
> > aim toward improving its scalability and making the code a bit easier to
> > understand.
> > 
> > Longer version:
> > ---------------
> > When the BKL was finally ripped out of the kernel in 2010, the strategy
> > taken for the file locking code was to simply turn it into a new
> > file_lock_locks spinlock. It was an expedient way to deal with the file
> > locking code at the time, but having a giant spinlock around all of this
> > code is clearly not great for scalability. Red Hat has bug reports that
> > go back into the 2.6.18 era that point to BKL scalability problems in
> > the file locking code and the file_lock_lock suffers from the same
> > issues.
> > 
> > This patchset is my first attempt to make this code less dependent on
> > global locking. The main change is to switch most of the file locking
> > code to be protected by the inode->i_lock instead of the file_lock_lock.
> > 
> > While that works for most things, there are a couple of global data
> > structures (lists in the current code) that need a global lock to
> > protect them. So we still need a global lock in order to deal with
> > those. The remaining patches are intended to make that global locking
> > less painful. The big gainis are made by turning the blocked_list into a
> > hashtable, which greatly speeds up the deadlock detection code.
> > 
> > This is not the first attempt at doing this. The conversion to the
> > i_lock was originally attempted by Bruce Fields a few years ago. His
> > approach was NAK'ed since it involved ripping out the deadlock
> > detection. People also really seem to like /proc/locks for debugging, so
> > keeping that in is probably worthwhile.
> > 
> > There's more work to be done in this area and this patchset is just a
> > start. There's a horrible thundering herd problem when a blocking lock
> > is released, for instance. There was also interest in solving the goofy
> > "unlock on any close" POSIX lock semantics at this year's LSF. I think
> > this patchset will help lay the groundwork for those changes as well.
> > 
> > While file locking is not usually considered to be a high-performance
> > codepath, it *is* an IPC mechanism and I think it behooves us to try to
> > make it as fast as possible.
> > 
> > I'd like to see this considered for 3.11. Comments and suggestions
> > welcome.
> > 
> > Performance testing and results:
> > --------------------------------
> > In order to measure performance here, I've written some locking
> > performance tests that I've made available here:
> > 
> >     git://git.samba.org/jlayton/lockperf.git
> > 
> > ...there are only 4 tests so far that measure performance of BSD and
> > POSIX locking. I ran each test 100 times. The first number in each set
> > of results is the unpatched (baseline) and the second is the patched
> > results. The arch in both cases was x86_64. I've also done some testing
> > on i686 and the results are more or less inline with the ones below.
> > The files were all on tmpfs, to eliminate any storage-related latencies
> > that might creep in.
> > 
> > Here's a description of each test with their results. I've also included
> > the standard deviation with each:
> > 
> > posix01: fork off 128 children, and have them all open the same file and
> > lock and unlock it 10k times (whole file, FL_WRLCK). Measure the time
> > that it takes to perform all of the locks and unlocks in each process,
> > and the total them all up. Note that the "mean time" here is not the
> > time to run the test, but the total time that all the tasks spent
> > locking and unlocking:
> 
> Why that and not the time to run the test?
> 

Yeah, the fact that there is time spent both sleeping to wait for the
lock as well as time spent processing when you're awake makes this
difficult to quantify.

I was really trying to eliminate measuring anything *but* the locking
performance. In most cases, the open/close/fork overhead is pretty
insignificant, but by measuring it this way, I know they don't matter.

I did look at the times to run the test and in general, the time to run
the test is smaller when the numbers above are smaller.

> Maybe what you're doing is right, but measuring total time seems more
> realistic and simpler, and less likely to accumulate errors.
> 
> If we're measuring individual calls I think I'd rather see mean and
> variance of the time of individual calls instead of of the sum.
> 
> It might also be interested to see how this changes as the number of
> cores varies.  (Could you do that by pinning the test threads to some
> subset of the 32 cores?)
> 
> Admittedly the difference seems clear enough already....  But it'd be
> interesting to see how we scale with the new code in addition to just
> seeing that's in an improvement.
> 
> (And, nit: round these numbers a little?:)
> 

I'll see...getting these numbers took long enough. I'm not sure I
really want to spend that much of my life running these tests and
collecting results. ;)

If I get the time, I'll do so but I'd also like to start work on some
patches to help the thundering herd problem when a lock is released.
I'm fairly convinced at this point that these patches do help
performance overall.

And yeah, I just cut and pasted the numbers from my simple perl script
to gather these stats, they obviously could use some rounding...

> > 2-way Intel machine, 1G RAM, UMA:
> > kernel				mean time		std. deviation
> > -------------------------------------------------------------------------
> > 3.10.0-rc4-00034-g042dd60	780.50511606027		20.0773085693901
> > 3.10.0-rc4-00049-ge0b71e1	420.178537863755	24.4692621642102
> > 
> > 32-way AMD Opteron machine, 32G RAM in 4 NUMA nodes:
> > kernel				mean time		std. deviation
> > -------------------------------------------------------------------------
> > 3.10.0-rc4-00034-g042dd60	30889.1603525361	267.767126085587
> > 3.10.0-rc4-00049-ge0b71e1	25504.7748006928	336.232893246214
> > 
> > The first thing to note here is how painful this test is as the number
> > of CPUs scales out, and when NUMA is thrown into the mix. It takes a
> > staggeringly long time to run on such a machine. The patchset helps this
> > use-case a lot, but it's still painful. I think these numbers help
> > illustrate why we need to worry about this as the machines get more
> > parallel.
> > 
> > posix02: fork off 128 children, and have them each open their own file
> > and lock and unlock it 20k times. Measure the time that it takes to
> > complete the locks and unlocks in each process and then total them up:
> > 
> > 2-way Intel machine, 1G RAM, UMA:
> > kernel				mean time		std. deviation
> > -------------------------------------------------------------------------
> > 3.10.0-rc4-00034-g042dd60	319.86610077757		11.0827165395713
> > 3.10.0-rc4-00049-ge0b71e1	257.24231139548		 8.0772950753018
> > 
> > 32-way AMD Opteron machine, 32G RAM in 4 NUMA nodes:
> > kernel				mean time		std. deviation
> > -------------------------------------------------------------------------
> > 3.10.0-rc4-00034-g042dd60	1354.73702552958	40.5202787251742
> > 3.10.0-rc4-00049-ge0b71e1	 541.35526474265	12.0492755786782
> > 
> > ...so again, multiple CPUs and NUMA take their toll on this workload,
> > but the results are still universally positive from the patchset.
> > 
> > flock01: fork off 128 children, and have them all open the same file and
> > lock (LOCK_EX) and unlock it 10k times. Measure the time that it takes
> > to perform all of the locks and unlocks in each process, and the total
> > them all up. Note that the "mean time" here is not the time to run the
> > test, but the total time that all the tasks spent locking and unlocking:
> > 
> > 2-way Intel machine, 1G RAM, UMA:
> > kernel				mean time		std. deviation
> > -------------------------------------------------------------------------
> > 3.10.0-rc4-00034-g042dd60	704.60957498018		10.6182455520549
> > 3.10.0-rc4-00049-ge0b71e1	729.30782576048		 4.62185698266119
> > 
> > 32-way AMD Opteron machine, 32G RAM in 4 NUMA nodes:
> > kernel				mean time		std. deviation
> > -------------------------------------------------------------------------
> > 3.10.0-rc4-00034-g042dd60	23617.876013741		221.445828515533
> > 3.10.0-rc4-00049-ge0b71e1	24743.3849476248	340.664907591012
> > 
> > ...so here we see some slight slowdown (3-5%). In the case of the UMA
> > box, it's on the order of the standard deviation, and in a similar test
> > on a different box, the patched kernel turned out to be faster. Go
> > figure...
> > 
> > In any case, I'm suspect that this is due to the fact that with this
> > set, we need to take two spinlocks in order to do the work (the i_lock
> > and the file_lock_lglock). Since the flock codepath doesn't use the
> > global blocked_list, it sees no benefit to the conversion of it to a
> > hash table.
> > 
> > flock02: fork off 128 children, and have them each open their own file
> > and lock (LOCK_EX) and unlock it 20k times. Measure the time that it
> > takes to complete the locks and unlocks in each process and then total
> > them up:
> > 
> > 2-way Intel machine, 1G RAM, UMA:
> > kernel				mean time		std. deviation
> > -------------------------------------------------------------------------
> > 3.10.0-rc4-00034-g042dd60	241.26319896997		7.69747220750147
> > 3.10.0-rc4-00049-ge0b71e1	167.23062027739		5.1643997156006
> > 
> > 32-way AMD Opteron machine, 32G RAM in 4 NUMA nodes:
> > kernel				mean time		std. deviation
> > --------------------------------------------------------------------------
> > 3.10.0-rc4-00034-g042dd60	1348.64594042422	39.5186585988528
> > 3.10.0-rc4-00049-ge0b71e1	   8.4762987879		 0.347121187462215
> > 
> > ...the speedup here is really dramatic, especially in the NUMA case.
> > This was so much faster that I had to double check that flock locking
> > still worked properly afterward.
> 
> I guess deadlock detection is the most likely explanation of the
> difference between the posix and flock cases?
> 
> If so that'd make a pretty strong case for eliminating (or somehow
> greatly reducing) the deadlock detection.
> 

Well yes, the deadlock detection itself and the addition/removal from
the blocked_hash/blocked_list. The conversion to a hashtable help the
deadlock detection itself, but we can't really do much about the list
manipulation.

I'm not opposed to some sort of CONFIG_* option to allow compiling out
the deadlock detection, but I'd probably prefer to leave that for
another set. It might also make sense to have some sort of boot-time
switch to enable it?

For a distro like Fedora or RHEL, I could envision turning off deadlock
detection in "production" kernels and leaving it enabled in -debug
kernels. I have my doubts as to how useful deadlock detection really is
though...

> With /proc/locks using a percpu lock and everything else a per-file
> lock, in theory the deadlock detectionis the only thing that should
> cause contention between cores, so the test should scale perfectly in
> the flock case.  (Might be interesting to confirm that by looking at how
> it changes over # of cores.)

Sure, if you assume that the locks are uncontended. You can still have
contention for the i_lock of course if tasks running on different CPUs
are trying to lock the same file.

Also the file_lock_lock is a percpu lglock, but occasionally tasks
acquire a lock on one CPU and then get migrated to another. At that
point you have to "reach across" to another CPU to take the entry off
the percpu hlists.

But yeah...for the most part these changes make the code have very
little contention, and the flock02 test results seem to really bear
that out.

Thanks for taking a look!
-- 
Jeff Layton <jlayton@redhat.com>
