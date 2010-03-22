From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfsd: don't break lease while servicing a COMMIT call
	(try #2)
Date: Mon, 22 Mar 2010 16:33:40 -0400
Message-ID: <20100322163340.4b3b285f@tlielax.poochiereds.net>
References: <1269000388-5543-1-git-send-email-jlayton@redhat.com>
	<20100322194710.GO5359@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20100322194710.GO5359@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 22 Mar 2010 15:47:10 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Mar 19, 2010 at 08:06:28AM -0400, Jeff Layton wrote:
> > This is the second attempt to fix the problem whereby a COMMIT call
> > causes a lease break and triggers a possible deadlock.
> > 
> > The problem is that nfsd attempts to break a lease on a COMMIT call.
> > This triggers a delegation recall if the lease is held for a delegation.
> > If the client is the one holding the delegation and it's the same one on
> > which it's issuing the COMMIT, then it can't return that delegation
> > until the COMMIT is complete. But, nfsd won't complete the COMMIT until
> > the delegation is returned. The client and server are essentially
> > deadlocked until the state is marked bad (due to the client not
> > responding on the callback channel).
> > 
> > The first patch attempted to deal with this by eliminating the open of
> > the file altogether and simply had nfsd_commit pass a NULL file pointer
> > to the vfs_fsync_range. That would conflict with some work in progress
> > by Christoph Hellwig to clean up the fsync interface, so this patch
> > takes a different approach.
> > 
> > This declares a new NFSD_MAY_NOT_BREAK_LEASE access flag that indicates
> > to nfsd_open that it should not break any leases when opening the file,
> > and has nfsd_commit set that flag on the nfsd_open call.
> 
> Thanks; applying (after I run a few basic tests).
> 
> But: why would a client be waiting on a commit to return a read
> delegation?  (We don't give out write delegations.)
> 
> --b.
> 

It looks like nfs_inode_return_delegation always calls nfs_msync_inode
on any valid delegation before returning it, regardless of the
delegation type.

RFC 3530 says this:

   If the client is granted a read delegation, it is assured that no
   other client has the ability to write to the file for the duration of
   the delegation.  If the client is granted a write delegation, the
   client is assured that no other client has read or write access to
   the file.

That doesn't seem to imply that we must flush writes before returning
either type of delegation. OTOH, maybe it makes sense to treat those as
cache consistency points since a delegreturn sort of implies that
another client wants to use the file.

I'm not quite sure how to interpret the spec here...

-- 
Jeff Layton <jlayton@redhat.com>
