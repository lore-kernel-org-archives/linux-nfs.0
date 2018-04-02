Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:53124 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751295AbeDBM45 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Apr 2018 08:56:57 -0400
Message-ID: <1522673814.4914.36.camel@kernel.org>
Subject: Re: [PATCH v2] locks: change POSIX lock ownership on execve when
 files_struct is displaced
From: Jeff Layton <jlayton@kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Daniel =?ISO-8859-1?Q?P=2EBerrang=E9?= <berrange@redhat.com>,
        Kate Stewart <kstewart@linuxfoundation.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Philippe Ombredanne <pombredanne@nexb.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>
Date: Mon, 02 Apr 2018 08:56:54 -0400
In-Reply-To: <871sgcvfh7.fsf@xmission.com>
References: <20180317142520.30520-1-jlayton@kernel.org>
         <20180317165859.26200-1-jlayton@kernel.org> <87bmfgvg8w.fsf@xmission.com>
         <871sgcvfh7.fsf@xmission.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2018-03-22 at 00:36 -0500, Eric W. Biederman wrote:
> ebiederm@xmission.com (Eric W. Biederman) writes:
> 
> > Jeff Layton <jlayton@kernel.org> writes:
> > 
> > > From: Jeff Layton <jlayton@redhat.com>
> > > 
> > > POSIX mandates that open fds and their associated file locks should be
> > > preserved across an execve. This works, unless the process is
> > > multithreaded at the time that execve is called.
> > Would this perhaps work better if we moved unshare_files to after or
> > inside of de_thread.  That would remove any cases where fd->count is > 1
> > simply because you are multi-threaded.  It would only leave the strange
> > cases where files struct is shared between different processes.
> 
> The fact we have a problem here appears to be a regression caused by:
> fd8328be874f ("[PATCH] sanitize handling of shared descriptor tables in
> failing execve()")
> 
> So I really think we are calling unshare_files in the wrong location.
> 
> We could perhaps keep the benefit of being able to fail exec cleanly
> if we freeze the threads and then only unshare if the count of threads
> differs from the fd->count.  I don't know if it is worth it.
> 
> Eric
> 

Yeah, that's a possibility. If you can freeze the other threads, and
ensure that they don't execute before they are killed, then in almost
all cases, unshare_files would be a noop.

Also, I have spotted a potential problem with this patch too:

If this situation occurs on NFS, then the state handling code is likely
to get very confused. It uses the fl_owner as the key to the
lock_stateid.

After you execve, the all the locks will still be present but you won't
be able to find them by fl_owner anymore. I imagine they'll just hang
out until the client expires.

David Howells suggested: "you could allocate a 1-byte lock cookie and
point to that from fdtable, then pass that cookie over exec"

I'm not sure about that implementation (maybe consider using ida?), but
an opaque fl_owner cookie for posix locks might be the way to go. It
would mean growing struct fdtable however.

> > > In that case, we'll end up unsharing the files_struct but the locks will
> > > still have their fl_owner set to the address of the old one. Eventually,
> > > when the other threads die and the last reference to the old
> > > files_struct is put, any POSIX locks get torn down since it looks like
> > > a close occurred on them.
> > > 
> > > The result is that all of your open files will be intact with none of
> > > the locks you held before execve. The simple answer to this is "use OFD
> > > locks", but this is a nasty surprise and it violates the spec.
> > > 
> > > On a successful execve, change ownership of any POSIX file_locks
> > > associated with the old files_struct to the new one, if we ended up
> > > swapping it out.
> > 
> > If we can move unshare_files I believe the need for changing the
> > ownership would go away.  Which seems like easier to understand
> > and simpler code in the end.  With fewer surprises.
> > 
> > Eric
> > 
> > 
> > > Reported-by: Daniel P. Berrangé <berrange@redhat.com>
> > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > 
> > 
> > > ---
> > >  fs/exec.c          |  4 +++-
> > >  fs/locks.c         | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
> > >  include/linux/fs.h |  8 ++++++++
> > >  3 files changed, 71 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/fs/exec.c b/fs/exec.c
> > > index 7eb8d21bcab9..35b05376bf78 100644
> > > --- a/fs/exec.c
> > > +++ b/fs/exec.c
> > > @@ -1812,8 +1812,10 @@ static int do_execveat_common(int fd, struct filename *filename,
> > >  	free_bprm(bprm);
> > >  	kfree(pathbuf);
> > >  	putname(filename);
> > > -	if (displaced)
> > > +	if (displaced) {
> > > +		posix_change_lock_owners(current->files, displaced);
> > >  		put_files_struct(displaced);
> > > +	}
> > >  	return retval;
> > >  
> > >  out:
> > > diff --git a/fs/locks.c b/fs/locks.c
> > > index d6ff4beb70ce..ab428ca8bb11 100644
> > > --- a/fs/locks.c
> > > +++ b/fs/locks.c
> > > @@ -993,6 +993,66 @@ static int flock_lock_inode(struct inode *inode, struct file_lock *request)
> > >  	return error;
> > >  }
> > >  
> > > +struct posix_change_lock_owners_arg {
> > > +	fl_owner_t old;
> > > +	fl_owner_t new;
> > > +};
> > > +
> > > +static int posix_change_lock_owners_cb(const void *varg, struct file *file,
> > > +					  unsigned int fd)
> > > +{
> > > +	const struct posix_change_lock_owners_arg *arg = varg;
> > > +	struct inode *inode = file_inode(file);
> > > +	struct file_lock_context *ctx;
> > > +	struct file_lock *fl, *tmp;
> > > +
> > > +	/* If there is no context, then no locks need to be changed */
> > > +	ctx = locks_get_lock_context(inode, F_UNLCK);
> > > +	if (!ctx)
> > > +		return 0;
> > > +
> > > +	percpu_down_read_preempt_disable(&file_rwsem);
> > > +	spin_lock(&ctx->flc_lock);
> > > +	/* Find the first lock with the old owner */
> > > +	list_for_each_entry(fl, &ctx->flc_posix, fl_list) {
> > > +		if (fl->fl_owner == arg->old)
> > > +			break;
> > > +	}
> > > +
> > > +	list_for_each_entry_safe_from(fl, tmp, &ctx->flc_posix, fl_list) {
> > > +		if (fl->fl_owner != arg->old)
> > > +			break;
> > > +
> > > +		/* This should only be used for normal userland lockmanager */
> > > +		if (fl->fl_lmops) {
> > > +			WARN_ON_ONCE(1);
> > > +			break;
> > > +		}
> > > +		fl->fl_owner = arg->new;
> > > +	}
> > > +	spin_unlock(&ctx->flc_lock);
> > > +	percpu_up_read_preempt_enable(&file_rwsem);
> > > +	return 0;
> > > +}
> > > +
> > > +/**
> > > + * posix_change_lock_owners - change lock owners from old files_struct to new
> > > + * @files: new files struct to own locks
> > > + * @old: old files struct that previously held locks
> > > + *
> > > + * On execve, a process may end up with a new files_struct. In that case, we
> > > + * must change all of the locks that were owned by the previous files_struct
> > > + * to the new one.
> > > + */
> > > +void posix_change_lock_owners(struct files_struct *new,
> > > +			      struct files_struct *old)
> > > +{
> > > +	struct posix_change_lock_owners_arg arg = { .old = old,
> > > +						    .new = new };
> > > +
> > > +	iterate_fd(new, 0, posix_change_lock_owners_cb, &arg);
> > > +}
> > > +
> > >  static int posix_lock_inode(struct inode *inode, struct file_lock *request,
> > >  			    struct file_lock *conflock)
> > >  {
> > > diff --git a/include/linux/fs.h b/include/linux/fs.h
> > > index 79c413985305..65fa99707bf9 100644
> > > --- a/include/linux/fs.h
> > > +++ b/include/linux/fs.h
> > > @@ -1098,6 +1098,8 @@ extern int lease_modify(struct file_lock *, int, struct list_head *);
> > >  struct files_struct;
> > >  extern void show_fd_locks(struct seq_file *f,
> > >  			 struct file *filp, struct files_struct *files);
> > > +extern void posix_change_lock_owners(struct files_struct *new,
> > > +				     struct files_struct *old);
> > >  #else /* !CONFIG_FILE_LOCKING */
> > >  static inline int fcntl_getlk(struct file *file, unsigned int cmd,
> > >  			      struct flock __user *user)
> > > @@ -1232,6 +1234,12 @@ static inline int lease_modify(struct file_lock *fl, int arg,
> > >  struct files_struct;
> > >  static inline void show_fd_locks(struct seq_file *f,
> > >  			struct file *filp, struct files_struct *files) {}
> > > +
> > > +static inline void posix_change_lock_owners(struct files_struct *new,
> > > +					    struct files_struct *old)
> > > +{
> > > +}
> > > +
> > >  #endif /* !CONFIG_FILE_LOCKING */
> > >  
> > >  static inline struct inode *file_inode(const struct file *f)

-- 
Jeff Layton <jlayton@kernel.org>
