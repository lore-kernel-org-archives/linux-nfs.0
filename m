From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] dlm: initialize file_lock struct in GETLK before
	copying conflicting lock
Date: Wed, 21 Jan 2009 18:42:39 -0500
Message-ID: <20090121234239.GM4295@fieldses.org>
References: <1232555691-29859-1-git-send-email-jlayton@redhat.com> <1232555691-29859-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1232555691-29859-2-git-send-email-jlayton@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 21, 2009 at 11:34:50AM -0500, Jeff Layton wrote:
> dlm_posix_get fills out the relevant fields in the file_lock before
> returning when there is a lock conflict, but doesn't clean out any of
> the other fields in the file_lock.
> 
> When nfsd does a NFSv4 lockt call, it sets the fl_lmops to
> nfsd_posix_mng_ops before calling the lower fs. When the lock comes back
> after testing a lock on GFS2, it still has that field set. This confuses
> nfsd into thinking that the file_lock is a nfsd4 lock.

I think of the lock system as supporting two types of objects, both
stored in "struct lock"'s:

	- Heavyweight locks: these have callbacks set and the filesystem
	  or lock manager could in theory have some private data
	  associated with them, so it's important that the appropriate
	  callbacks be called when they're released or copied.  These
	  are what are actually passed to posix_lock_file() and kept on
	  the inode lock lists.
	- Lightweight locks: just start, end, pid, flags, and type, with
	  everything zeroed out and/or ignored.

I don't see any reason why the lock passed into dlm_posix_get() needs to
be a heavyweight lock.  In any case, if it were, then dlm_posix_get()
would need to release the passed-in-lock before initializing the new one
that it's returning.

The returned lock should probably also be a lightweight lock that's a
copy of whatever conflicting lock was found; otherwise we need to
require the caller to for example release the thing correctly.

That's unfortunate for nfsv4 since that doesn't allow returning the
lockowner information to the client.  But it's not terribly important
to get that right.

Since gfs2 doesn't report the conflicting lock, I guess we just punt and
return a copy of the passed-in lock, OK.

--b.

> 
> Fix this by making DLM reinitialize the file_lock before copying the
> fields from the conflicting lock.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/dlm/plock.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/dlm/plock.c b/fs/dlm/plock.c
> index eba87ff..ca46f11 100644
> --- a/fs/dlm/plock.c
> +++ b/fs/dlm/plock.c
> @@ -304,7 +304,9 @@ int dlm_posix_get(dlm_lockspace_t *lockspace, u64 number, struct file *file,
>  	if (rv == -ENOENT)
>  		rv = 0;
>  	else if (rv > 0) {
> +		locks_init_lock(fl);
>  		fl->fl_type = (op->info.ex) ? F_WRLCK : F_RDLCK;
> +		fl->fl_flags = FL_POSIX;
>  		fl->fl_pid = op->info.pid;
>  		fl->fl_start = op->info.start;
>  		fl->fl_end = op->info.end;
> -- 
> 1.5.5.6
> 
> _______________________________________________
> NFSv4 mailing list
> NFSv4@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
