From: Jeff Layton <jlayton@redhat.com>
Subject: Re: interrupting the wait for NLM GRANT causes problems
Date: Thu, 13 Mar 2008 14:50:37 -0400
Message-ID: <1205434237.3736.10.camel@tleilax.poochiereds.net>
References: <20080313193226.4cf9100e@brian.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37940 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753949AbYCMSu4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 14:50:56 -0400
In-Reply-To: <20080313193226.4cf9100e-7cei8Ivw5CaoyI6RK4xok/XAX3CI6PSWQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Thu, 2008-03-13 at 19:32 +0100, Michal Schmidt wrote:
> [CC Jeff, I found your bz432855 where you noticed the same problem]
> 
> Hello,
> 
> When a client attempting to lock a file and waiting for NLM
> GRANTED callback is interrupted by a signal in nlmclnt_block(), bad
> things happen.
> 
> The userspace program will get EINTR and most likely retry the lock,
> which it can successfully obtain (when the GRANTED callback comes).
> That sounds OK, but something causes the client to lose track of this
> lock and when the program tries to release the lock, the NLM UNLOCK
> message is sent with a new SVID. The NFS server rightfully thinks
> the file is still locked by the original SVID. Noone can lock the file
> again.
> 
> I think the bug is in do_setlk(), where the VFS lock is created when
> the lock attempt was interrupted by a signal. I don't understand the
> reason why it does that. nlmclnt_lock() cancels the lock request if
> nlmclnt_block() is interrupted, so there should be no state on the
> server to be cleaned (as the comment suggests there is). But I may be
> missing something.
> 
> Attached is a test program. It locks a file and waits for Enter before
> unlocking it. It shows the locks held at the interesting moments
> (from /proc/locks).
> 
> To reproduce the bug, run the program on two clients at the same time:
> ./lockunlock /mnt/nfs_server/shared_file
> 
> The first client will get the lock. Press CTRL+C on the second one, to
> interrupt its wait for NLM GRANTED. Notice the VFS lock shown. Press
> Enter on the first client, to release the lock. The second client will
> obtain it. Let it release it. Try running it again and notice you can't
> lock the file anymore.
> 
> I have tried the following patch and it helps in my testcase. But maybe
> it breaks something else?
> 
> Comments welcome.
> 
> Michal
> 
> 
> ---
>  fs/nfs/file.c |   12 ++----------
>  1 files changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index ef57a5a..b311d9a 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -572,17 +572,9 @@ static int do_setlk(struct file *filp, int cmd,
> struct file_lock *fl) 
>  	lock_kernel();
>  	/* Use local locking if mounted with "-onolock" */
> -	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM)) {
> +	if (!(NFS_SERVER(inode)->flags & NFS_MOUNT_NONLM))
>  		status = NFS_PROTO(inode)->lock(filp, cmd, fl);
> -		/* If we were signalled we still need to ensure that
> -		 * we clean up any state on the server. We therefore
> -		 * record the lock call as having succeeded in order to
> -		 * ensure that locks_remove_posix() cleans it out when
> -		 * the process exits.
> -		 */
> -		if (status == -EINTR || status == -ERESTARTSYS)
> -			do_vfs_lock(filp, fl);
> -	} else
> +	else
>  		status = do_vfs_lock(filp, fl);
>  	unlock_kernel();
>  	if (status < 0)


I think the intent is basically what the comment says...

If the call is interrupted, we don't know what the state of the lock on
the server is. There's a chance that the server could have granted us
the lock. If we don't set a vfs lock then we never send an unlock
request to the server, and then nobody will get it or clean it up.

I guess the thinking is that if the process is signaled that it will
probably be exiting soon anyway. That's probably not a safe assumption,
however.

The ideal thing might be to send an async unlock request to the server
when the lock call is interrupted. This is tricky though, since the
process has been signaled and you have to deal with that as well.

--
Jeff Layton <jlayton@redhat.com>

