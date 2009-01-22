From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [Cluster-devel] Re: [PATCH 1/2] dlm: initialize file_lock
	struct in GETLK before copying conflicting lock
Date: Thu, 22 Jan 2009 13:37:33 -0500
Message-ID: <20090122133733.5d692a09@barsoom.rdu.redhat.com>
References: <1232555691-29859-1-git-send-email-jlayton@redhat.com>
	<1232555691-29859-2-git-send-email-jlayton@redhat.com>
	<20090121234239.GM4295@fieldses.org>
	<20090122180543.GA23796@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, linux-nfs@vger.kernel.org, lkml@vger.kernel.org,
	nfsv4@linux-nfs.org, linux-fsdevel@vger.kernel.org
To: David Teigland <teigland@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090122180543.GA23796@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 22 Jan 2009 12:05:43 -0600
David Teigland <teigland@redhat.com> wrote:

> On Wed, Jan 21, 2009 at 06:42:39PM -0500, J. Bruce Fields wrote:
> > On Wed, Jan 21, 2009 at 11:34:50AM -0500, Jeff Layton wrote:
> > > dlm_posix_get fills out the relevant fields in the file_lock before
> > > returning when there is a lock conflict, but doesn't clean out any of
> > > the other fields in the file_lock.
> > > 
> > > When nfsd does a NFSv4 lockt call, it sets the fl_lmops to
> > > nfsd_posix_mng_ops before calling the lower fs. When the lock comes back
> > > after testing a lock on GFS2, it still has that field set. This confuses
> > > nfsd into thinking that the file_lock is a nfsd4 lock.
> > 
> > I think of the lock system as supporting two types of objects, both
> > stored in "struct lock"'s:
> > 
> > 	- Heavyweight locks: these have callbacks set and the filesystem
> > 	  or lock manager could in theory have some private data
> > 	  associated with them, so it's important that the appropriate
> > 	  callbacks be called when they're released or copied.  These
> > 	  are what are actually passed to posix_lock_file() and kept on
> > 	  the inode lock lists.
> > 	- Lightweight locks: just start, end, pid, flags, and type, with
> > 	  everything zeroed out and/or ignored.
> > 
> > I don't see any reason why the lock passed into dlm_posix_get() needs to
> > be a heavyweight lock.  In any case, if it were, then dlm_posix_get()
> > would need to release the passed-in-lock before initializing the new one
> > that it's returning.
> 
> It seems the nfs code is mixing those two types up a bit.  Regardless, the
> rationale I see in Jeff's dlm patch is to make the two different locking paths
> equivalent:
> 
> Without cfs/dlm,
> nfsd4_lockt -> nfsd_test_lock -> vfs_test_lock -> posix_test_lock
> 
> With cfs/dlm,
> nfsd4_lockt -> nfsd_test_lock -> vfs_test_lock -> (cfs) -> dlm_posix_get
> 
> When there's a conflict, dlm_posix_get() and posix_test_lock() should do the
> same/equivalent things to the fl they are given.
> 
> posix_test_lock() does __locks_copy_lock() on the fl and then sets the pid.
> dlm_posix_get() isn't using __locks_copy_lock() because it doesn't have a
> conflicting file_lock to copy from.  Jeff's patch does nearly the same thing
> using locks_init_lock() plus the existing assignments.  But, I think the best
> solution may be for dlm_posix_get() to set up a new lightweight file_lock with
> the values we need, and then call __locks_copy_lock() with it, just like
> posix_test_lock().
> 

Why would we want to make another lock here? Is that just to make sure
that if new fields are added later that we deal with them appropriately?

-- 
Jeff Layton <jlayton@redhat.com>
