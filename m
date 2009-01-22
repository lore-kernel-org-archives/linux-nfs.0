From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/2] dlm: initialize file_lock struct in GETLK before
	copying conflicting lock
Date: Thu, 22 Jan 2009 13:37:05 -0500
Message-ID: <20090122133705.54da79c0@barsoom.rdu.redhat.com>
References: <1232555691-29859-1-git-send-email-jlayton@redhat.com>
	<1232555691-29859-2-git-send-email-jlayton@redhat.com>
	<20090121234239.GM4295@fieldses.org>
	<20090121212608.65ae4ed4@tupile.poochiereds.net>
	<20090122183241.GA15279@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, cluster-devel@redhat.com,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090122183241.GA15279@fieldses.org>
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

On Thu, 22 Jan 2009 13:32:41 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jan 21, 2009 at 09:26:08PM -0500, Jeff Layton wrote:
> > On Wed, 21 Jan 2009 18:42:39 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Wed, Jan 21, 2009 at 11:34:50AM -0500, Jeff Layton wrote:
> > > > dlm_posix_get fills out the relevant fields in the file_lock before
> > > > returning when there is a lock conflict, but doesn't clean out any of
> > > > the other fields in the file_lock.
> > > > 
> > > > When nfsd does a NFSv4 lockt call, it sets the fl_lmops to
> > > > nfsd_posix_mng_ops before calling the lower fs. When the lock comes back
> > > > after testing a lock on GFS2, it still has that field set. This confuses
> > > > nfsd into thinking that the file_lock is a nfsd4 lock.
> > > 
> > > I think of the lock system as supporting two types of objects, both
> > > stored in "struct lock"'s:
> > > 
> > > 	- Heavyweight locks: these have callbacks set and the filesystem
> > > 	  or lock manager could in theory have some private data
> > > 	  associated with them, so it's important that the appropriate
> > > 	  callbacks be called when they're released or copied.  These
> > > 	  are what are actually passed to posix_lock_file() and kept on
> > > 	  the inode lock lists.
> > > 	- Lightweight locks: just start, end, pid, flags, and type, with
> > > 	  everything zeroed out and/or ignored.
> > > 
> > > I don't see any reason why the lock passed into dlm_posix_get() needs to
> > > be a heavyweight lock.  In any case, if it were, then dlm_posix_get()
> > > would need to release the passed-in-lock before initializing the new one
> > > that it's returning.
> > > 
> > 
> > 
> > From what I can tell, dlm_posix_lock is always passed a "lightweight"
> > lock.
> 
> Right, so in your second patch, I think the fl_lmops assignment in
> nfsd4_lockt should also be removed.
> 

Ok, that works too. I'll respin and repost once we come to some
concensus on the first patch.

> > > The returned lock should probably also be a lightweight lock that's a
> > > copy of whatever conflicting lock was found; otherwise we need to
> > > require the caller to for example release the thing correctly.
> > > 
> > > That's unfortunate for nfsv4 since that doesn't allow returning the
> > > lockowner information to the client.  But it's not terribly important
> > > to get that right.
> > > 
> > > Since gfs2 doesn't report the conflicting lock, I guess we just punt and
> > > return a copy of the passed-in lock, OK.
> > > 
> > 
> > I'm not sure I follow you here...
> > 
> > GFS2/DLM does report the conflicting lock. It's just that when there is
> > one, it's only overwriting some of the fields in the lock.
> 
> Whoops, sorry, OK.
> 
> > The idea with this patch is to basically try and make dlm_posix_get()
> > fill out the same fields as __locks_copy_lock() and make sure the rest
> > are initialized.
> 
> Yes, this patch seems fine.  I'm less sure of the second.
> 
> --b.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
