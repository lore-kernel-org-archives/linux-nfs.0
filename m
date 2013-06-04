Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751210Ab3FDKy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 06:54:56 -0400
Date: Tue, 4 Jun 2013 06:54:17 -0400
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
Subject: Re: [PATCH v1 00/11] locks: scalability improvements for file
 locking
Message-ID: <20130604065417.46080a57@tlielax.poochiereds.net>
In-Reply-To: <20130603213101.GC2109@fieldses.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
	<20130603213101.GC2109@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 3 Jun 2013 17:31:01 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, May 31, 2013 at 11:07:23PM -0400, Jeff Layton wrote:
> > Executive summary (tl;dr version): This patchset represents an overhaul
> > of the file locking code with an aim toward improving its scalability
> > and making the code a bit easier to understand.
> 
> Thanks for working on this, that code could use some love!
> 
> > Longer version:
> > 
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
> > less painful. The big gain is made by turning the blocked_list into a
> > hashtable, which greatly speeds up the deadlock detection code.
> > 
> > I rolled a couple of small programs in order to test this code. The
> > first one just forks off 128 children and has them lock and unlock the
> > same file 10k times. Running this under "time" against a file on tmpfs
> > gives typical values like this:
> 
> What kind of hardware was this?
> 

Mostly a KVM guest on Intel hardware. I've done some testing on bare
metal too, and the results are pretty similar.
 
> > 
> > Unpatched (3.10-rc3-ish):
> > real	0m5.283s
> > user	0m0.380s
> > sys	0m20.469s
> > 
> > Patched (same base kernel):
> > real	0m5.099s
> > user	0m0.478s
> > sys	0m19.662s
> > 
> > ...so there seems to be some modest performance gain in this test. I
> > think that's almost entirely due to the change to a hashtable and to
> > optimize removing and readding blocked locks to the global lists. Note
> > that with this code we have to take two spinlocks instead of just one,
> > and that has some performance impact too. So the real peformance gain
> > from that hashtable conversion is eaten up to some degree by this.
> 
> Might be nice to look at some profiles to confirm all of that.  I'd also
> be curious how much variation there was in the results above, as they're
> pretty close.
> 

The above is just a random representative sample. The results are
pretty close when running this test, but I can average up several runs
and present the numbers. I plan to get a bare-metal test box on which
to run some more detailed testing and maybe some profiling this week.

> > The next test just forks off a bunch of children that each create their
> > own file and then lock and unlock it 20k times. Obviously, the locks in
> > this case are uncontended. Running that under "time" typically gives
> > these rough numbers.
> > 
> > Unpatched (3.10-rc3-ish):
> > real	0m8.836s
> > user	0m1.018s
> > sys	0m34.094s
> > 
> > Patched (same base kernel):
> > real	0m4.965s
> > user	0m1.043s
> > sys	0m18.651s
> > 
> > In this test, we see the real benefit of moving to the i_lock for most
> > of this code. The run time is almost cut in half in this test. With
> > these changes locking different inodes needs very little serialization.
> > 
> > If people know of other file locking performance tests, then I'd be
> > happy to try them out too. It's possible that this might make some
> > workloads slower, and it would be helpful to know what they are (and
> > address them) if so.
> > 
> > This is not the first attempt at doing this. The conversion to the
> > i_lock was originally attempted by Bruce Fields a few years ago. His
> > approach was NAK'ed since it involved ripping out the deadlock
> > detection. People also really seem to like /proc/locks for debugging, so
> > keeping that in is probably worthwhile.
> 
> Yes, there's already code that depends on it.
> 
> The deadlock detection, though--I still wonder if we could get away with
> ripping it out.  Might be worth at least giving an option to configure
> it out as a first step.
> 
> --b.
> 


I considered that, and have patches that add such a config option. Some
of the later patches in this set optimize the code that is necessary to
support deadlock detection. In particular, turning the blocked_list
into a hashtable really speeds up the list walking. So much so that I
think the case for compiling it out is less obvious.

Should we add an option for people who really want their locks to
scream? Maybe, but I think it would be easy to add that later,
especially now that the code to handle the blocked_hash is fairly well
encapsulated with this patch.

Thanks for taking a look!

-- Jeff

> > There's more work to be done in this area and this patchset is just a
> > start. There's a horrible thundering herd problem when a blocking lock
> > is released, for instance. There was also interest in solving the goofy
> > "unlock on any close" POSIX lock semantics at this year's LSF. I think
> > this patchset will help lay the groundwork for those changes as well.
> > 
> > Comments and suggestions welcome.
> > 
> > Jeff Layton (11):
> >   cifs: use posix_unblock_lock instead of locks_delete_block
> >   locks: make generic_add_lease and generic_delete_lease static
> >   locks: comment cleanups and clarifications
> >   locks: make "added" in __posix_lock_file a bool
> >   locks: encapsulate the fl_link list handling
> >   locks: convert to i_lock to protect i_flock list
> >   locks: only pull entries off of blocked_list when they are really
> >     unblocked
> >   locks: convert fl_link to a hlist_node
> >   locks: turn the blocked_list into a hashtable
> >   locks: add a new "lm_owner_key" lock operation
> >   locks: give the blocked_hash its own spinlock
> > 
> >  Documentation/filesystems/Locking |   27 +++-
> >  fs/afs/flock.c                    |    5 +-
> >  fs/ceph/locks.c                   |    2 +-
> >  fs/ceph/mds_client.c              |    8 +-
> >  fs/cifs/cifsfs.c                  |    2 +-
> >  fs/cifs/file.c                    |   15 +-
> >  fs/gfs2/file.c                    |    2 +-
> >  fs/lockd/svclock.c                |   12 ++
> >  fs/lockd/svcsubs.c                |   12 +-
> >  fs/locks.c                        |  254 +++++++++++++++++++++++++------------
> >  fs/nfs/delegation.c               |   11 +-
> >  fs/nfs/nfs4state.c                |    8 +-
> >  fs/nfsd/nfs4state.c               |    8 +-
> >  include/linux/fs.h                |   25 +---
> >  14 files changed, 249 insertions(+), 142 deletions(-)
> > 
