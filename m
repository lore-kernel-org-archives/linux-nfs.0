Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:35521 "EHLO
	mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165AbcHCR7x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2016 13:59:53 -0400
Received: by mail-qt0-f176.google.com with SMTP id x25so147845665qtx.2
        for <linux-nfs@vger.kernel.org>; Wed, 03 Aug 2016 10:59:23 -0700 (PDT)
Message-ID: <1470245777.13804.34.camel@redhat.com>
Subject: Re: [RFC PATCH] sunrpc: do not allow process to freeze within RPC
 state machine
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>, bfields@fieldses.org,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, gorcunov@virtuozzo.com,
        davem@davemloft.net, devel@openvz.org
Date: Wed, 03 Aug 2016 13:36:17 -0400
In-Reply-To: <20160803165412.22407.47399.stgit@localhost.localdomain>
References: <20160803165412.22407.47399.stgit@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-08-03 at 20:54 +0400, Stanislav Kinsburskiy wrote:
> Otherwise freezer cgroup state might never become "FROZEN".
> 
> Here is a deadlock scheme for 2 processes in one freezer cgroup,
> which is
> freezing:
> 
> CPU 0                                   CPU 1
> --------                                --------
> do_last
> inode_lock(dir->d_inode)
> vfs_create
> nfs_create
> ...
> __rpc_execute
> rpc_wait_bit_killable
> __refrigerator
>                                         do_last
>                                         inode_lock(dir->d_inode)
> 
> So, the problem is that one process takes directory inode mutex,
> executes
> creation request and goes to refrigerator.
> Another one waits till directory lock is released, remains "thawed"
> and thus
> freezer cgroup state never becomes "FROZEN".
> 
> Notes:
> 1) Interesting, that this is not a pure deadlock: one can thaw cgroup
> and then
> freeze it again.
> 2) The issue was introduced by commit
> d310310cbff18ec385c6ab4d58f33b100192a96a.
> 3) This patch is not aimed to fix the issue, but to show the problem
> root.
> Look like this problem moght be applicable to other hunks from the
> commit,
> mentioned above.
> 
> 
> Signed-off-by: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>
> ---
>  net/sunrpc/sched.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> index 9ae5885..ec7ccc1 100644
> --- a/net/sunrpc/sched.c
> +++ b/net/sunrpc/sched.c
> @@ -253,7 +253,6 @@ EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
>  
>  static int rpc_wait_bit_killable(struct wait_bit_key *key, int mode)
>  {
> -	freezable_schedule_unsafe();
>  	if (signal_pending_state(mode, current))
>  		return -ERESTARTSYS;
>  	return 0;
> 

Ummm...so what actually does the schedule() with this patch?

There was a bit of discussion on this recently -- see the thread with
this subject line in linux-nfs:

    Re: Hang due to nfs letting tasks freeze with locked inodes

Basically it comes down to this:

All of the proposals so far to fix this problem just switch out the
freezable_schedule_unsafe (and similar) calls for those that don't
allow the process to freeze.

The problem there is that we originally added that stuff in response to
bug reports about machines failing to suspend. What often happens is
that the network interfaces come down, and then the freezer runs over
all of the processes, which never return because they're blocked
waiting on the server to reply.

...shrug...

Maybe we should just go ahead and do it (and to CIFS as well). Just be
prepared for the inevitable complaints about laptops failing to suspend
once you do.

Part of the fix, I think is to add a return code (similar to
ERESTARTSYS) that gets interpreted near the kernel-userland boundary
as: "allow the process to be frozen, and then retry the call once it's
resumed".

With that, filesystems could return the error code when they want to
redrive the entire syscall from that level. That won't work for non-
idempotent requests though. We'd need to do something more elaborate
there.

-- 
Jeff Layton <jlayton@redhat.com>
