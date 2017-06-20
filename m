Return-Path: <jlayton@poochiereds.net>
Message-ID: <1497978415.4555.14.camel@poochiereds.net>
Subject: Re: [PATCH 2/2] fs/locks: Remove fl_nspid and use fs-specific l_pid
 for remote locks
From: Jeff Layton <jlayton@poochiereds.net>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: bfields@fieldses.org, Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, open list
	 <linux-kernel@vger.kernel.org>
Date: Tue, 20 Jun 2017 13:06:55 -0400
In-Reply-To: <D1AFE5C7-427F-4B0B-8337-3D6A247156A3@redhat.com>
References: <cover.1497877897.git.bcodding@redhat.com>
	 <901367ff4ffd87594a380e3a0a5d20c4e4195b0e.1497877897.git.bcodding@redhat.com>
	 <1497893534.4654.11.camel@poochiereds.net>
	 <9037C362-D6F7-4545-80C2-08B072005055@redhat.com>
	 <D1AFE5C7-427F-4B0B-8337-3D6A247156A3@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-06-20 at 12:09 -0400, Benjamin Coddington wrote:
> On 20 Jun 2017, at 10:03, Benjamin Coddington wrote:
> 
> > On 19 Jun 2017, at 13:32, Jeff Layton wrote:
> > 
> > > On Mon, 2017-06-19 at 09:24 -0400, Benjamin Coddington wrote:
> > > > @@ -2041,16 +2034,46 @@ SYSCALL_DEFINE2(flock, unsigned int, fd, 
> > > > unsigned int, cmd)
> > > >   */
> > > >  int vfs_test_lock(struct file *filp, struct file_lock *fl)
> > > >  {
> > > > -	if (filp->f_op->lock && is_remote_lock(filp))
> > > > +	if (filp->f_op->lock && is_remote_lock(filp)) {
> > > > +		fl->fl_flags |= FL_PID_PRIV;
> > > >  		return filp->f_op->lock(filp, F_GETLK, fl);
> > > > +	}
> > > >  	posix_test_lock(filp, fl);
> > > >  	return 0;
> > > >  }
> > > >  EXPORT_SYMBOL_GPL(vfs_test_lock);
> > > > 
> > > 
> > > I think this looks wrong for NFS.
> > 
> > Oh yes, this is completely wrong..  It should be looking for fl_ops, 
> > which
> > would set the flag for lock managers.
> 
> OK, please disregard this response completely.  You're absolutely 
> correct.
> I spent too much time away from this problem and was confused.
> 
> > > There are really two cases we're concerned with here:
> > > 
> > > 1) the lock is held by a task on the client itself, in which case we
> > > probably want to report the pid as we would on a local fs.
> > > 
> > > ...or...
> > > 
> > > 2) the lock is held by another host entirely in which case the pid
> > > doesn't have any meaning. We probably ought to return something like 
> > > '-
> > > 1' as the pid (like we would for OFD locks).
> 
> Right, exactly.
> 
> > I don't think we have f_op->lock() users that only set remote locks.  
> > For
> > NFS, the remote lock is always matched by a local lock.
> 
> But we can do F_GETLK for a remote file with a remote lock.
> 
> > > The problem for NFS is that you're setting the flag unconditionally
> > > there. It may very well be the case that we _want_ to translate the
> > > fl_pid according to the local namespace (i.e. if the lock is held by 
> > > a
> > > task on the same host).
> > > 
> > > I think what you want to do here is have the fs ->lock operation set
> > > that flag if the fl_pid should be used "as-is" instead of being
> > > translated.
> > > 
> > > Most of the current lock operations can just set it early (to 
> > > preserve
> > > the existing behavior), but NFS could be set up to set that flag if 
> > > the
> > > lock request goes to the server.
> 
> Yes, I think we ought to add the flag in this patch, but as you suggest 
> push
> the responsibility for setting it out to the filesystems.  I'll send one
> more version that adds the flag, but doesn't set it in vfs_test_lock(), 
> and
> follow that with a patch for where the flag ought to be set.
> 
> Ben

Now that I think about it a bit more, I don't think we really need a
flag here.

Just have the ->lock operation set the fl_pid to a negative value. That
will never be a valid pid anyway. Then flock_translate_pid could just
return any negative value directly instead of trying to translate it.

In practice we would always just set it to -1. Maybe even add something
like this that the lock-> operation could set it to?

#define    FILE_LOCK_OWNER_UNDEFINED       -1

-- 
Jeff Layton <jlayton@poochiereds.net>
