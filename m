From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2/2] Fix lockd panic
Date: Tue, 8 Jan 2008 16:31:49 +1100
Message-ID: <18307.2757.579354.785142@notabene.brown>
References: <4781BE72.7050404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: wcheng@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:35442 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695AbYAHFb6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 00:31:58 -0500
In-Reply-To: message from Wendy Cheng on Monday January 7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday January 7, wcheng@redhat.com wrote:
> This small patch has not been changed since our last discussion:
> http://www.opensubscriber.com/message/nfs@lists.sourceforge.net/6348912.html
> 
> To recap the issue, a client could ask for a posix lock that invokes:
> 
>  >>>     server calls nlm4svc_proc_lock() ->
>  >>>         * server lookup file (f_count++)
>  >>>         * server lock the file
>  >>>         * server calls nlm_release_host
>  >>>         * server calls nlm_release_file (f_count--)
>  >>>         * server return to client with status 0
>  >>>
> 
> As part of the lookup file, the lock stays on vfs inode->i_flock list 
> with zero f_count. Any call into nlm_traverse_files() will BUG() in 
> locks_remove_flock() (fs/locks.c:2034) during fclose(), if that file 
> happens to be of no interest to that particular search. Since after 
> nlm_inspect_file(), the logic unconditionally checks for possible 
> removing of the file. As the file is not blocked, nothing to do with 
> shares, and f_count is zero, it will get removed from hash and fclose() 
> invoked with the posix lock hanging on i_flock list.

If I'm reading this correctly, this bug is introduced by your previous
patch.

The important difference between the old code and the new code here is
that the old code tests "file->f_locks" while the new code iterates
through i_flock to see if there are any lockd locks.

f_locks is set to a count of lockd locks in nlm_traverse_locks which
*was* always called by nlm_inspect_file which is called immediately
before the code you are changing.
But since your patch, nlm_inspect_file does not always call
nlm_traverse_locks, so there is a chance that f_locks is wrong.

With this patch, f_locks it not used at all any more.

Introducing a bug in one patch and fixing in the next is bad style.

Some options:

 Have an initial patch which removes all references to f_locks and
 includes the change in this patch.  With that in place your main
 patch won't introduce a bug.  If you do this, you should attempt to
 understand and justify the performance impact (does nlm_traverse_files
 become quadratic in number of locks.  Is that acceptable?).

 Change the first patch to explicitly update f_count if you bypass the
 call to nlm_inspect_file.

 something else???

So NAK for this one in it's current form... unless I've misunderstood
something.

NeilBrown

> 
> -- Wendy
> 
> This fixes the incorrect fclose call inside nlm_traverse_files() where
> a posix lock could still be held by NFS client. Problem was found in a
> kernel panic inside locks_remove_flock() (fs/locks.c:2034) as part of
> the fclose call due to NFS-NLM locks still hanging on inode->i_flock list.
> 
> Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
> 
>  svcsubs.c |    3 +--
>  1 files changed, 1 insertion(+), 2 deletions(-)
> 
> --- linux-nlm-1/fs/lockd/svcsubs.c	2008-01-06 18:23:20.000000000 -0500
> +++ linux/fs/lockd/svcsubs.c	2008-01-06 18:24:12.000000000 -0500
> @@ -332,8 +332,7 @@ nlm_traverse_files(struct nlm_host *host
>  			mutex_lock(&nlm_file_mutex);
>  			file->f_count--;
>  			/* No more references to this file. Let go of it. */
> -			if (list_empty(&file->f_blocks) && !file->f_locks
> -			 && !file->f_shares && !file->f_count) {
> +			if (!nlm_file_inuse(file)) {
>  				hlist_del(&file->f_list);
>  				nlmsvc_ops->fclose(file->f_file);
>  				kfree(file);
