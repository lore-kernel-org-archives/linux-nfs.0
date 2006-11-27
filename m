From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 2.6.19-rc6] sunrpc: fix race condition
Date: Mon, 27 Nov 2006 14:53:12 -0500
Message-ID: <76bd70e30611271153hca57293ie1efdfd1bb446953@mail.gmail.com>
References: <Pine.LNX.4.64.0611271900120.10489@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GomXU-0007en-9c
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 11:53:16 -0800
Received: from wr-out-0506.google.com ([64.233.184.228])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GomXV-0007DG-8k
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 11:53:17 -0800
Received: by wr-out-0506.google.com with SMTP id i20so257686wra
	for <nfs@lists.sourceforge.net>; Mon, 27 Nov 2006 11:53:16 -0800 (PST)
To: "Chris Caputo" <ccaputo@alt.net>
In-Reply-To: <Pine.LNX.4.64.0611271900120.10489@nacho.alt.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 11/27/06, Chris Caputo <ccaputo@alt.net> wrote:
> From: Chris Caputo <ccaputo@alt.net>
> [PATCH 2.6.19-rc6] sunrpc: fix race condition
>
> Patch linux-2.6.10-01-rpc_workqueue.dif introduced a race condition into
> net/sunrpc/sched.c in kernels 2.6.11-rc1 through 2.6.19-rc6.  The race
> scenario is as follows...
>
> Given: RPC_TASK_QUEUED, RPC_TASK_RUNNING and RPC_TASK_ASYNC are set.
>
> __rpc_execute() (no spinlock)    rpc_make_runnable() (queue spinlock held)
> -----------------------------    -----------------------------------------
>                                  do_ret = rpc_test_and_set_running(task);
> rpc_clear_running(task);
> if (RPC_IS_ASYNC(task)) {
>         if (RPC_IS_QUEUED(task))
>                 return 0;
>                                  rpc_clear_queued(task);
>                                  if (do_ret)
>                                          return;
>
> Thus both threads return and the task is abandoned forever.
>
> In my test NFS client usage (~200 Mb/s at ~3,000 RPC calls/s) this race
> condition has resulted in processes getting permanently stuck in 'D' state
> often in less than 15 minutes of uptime.
>
> The following patch fixes the problem by returning to use of a spinlock in
> __rpc_execute().
>
> Signed-off-by: Chris Caputo <ccaputo@alt.net>
> ---
>
> diff -up a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> --- a/net/sunrpc/sched.c        2006-11-27 08:41:07.000000000 +0000
> +++ b/net/sunrpc/sched.c        2006-11-27 11:14:21.000000000 +0000
> @@ -587,6 +587,7 @@ EXPORT_SYMBOL(rpc_exit_task);
>  static int __rpc_execute(struct rpc_task *task)
>  {
>         int             status = 0;
> +       struct rpc_wait_queue *queue;
>
>         dprintk("RPC: %4d rpc_execute flgs %x\n",
>                                 task->tk_pid, task->tk_flags);
> @@ -631,22 +632,27 @@ static int __rpc_execute(struct rpc_task
>                         lock_kernel();
>                         task->tk_action(task);
>                         unlock_kernel();
> +                       /* micro-optimization to avoid spinlock */
> +                       if (!RPC_IS_QUEUED(task))
> +                               continue;
>                 }
>
>                 /*
> -                * Lockless check for whether task is sleeping or not.
> +                * Check whether task is sleeping.
>                  */
> -               if (!RPC_IS_QUEUED(task))
> -                       continue;
> -               rpc_clear_running(task);
> +               queue = task->u.tk_wait.rpc_waitq;
> +               spin_lock_bh(&queue->lock);
>                 if (RPC_IS_ASYNC(task)) {
> -                       /* Careful! we may have raced... */
> -                       if (RPC_IS_QUEUED(task))
> -                               return 0;
> -                       if (rpc_test_and_set_running(task))
> +                       if (RPC_IS_QUEUED(task)) {
> +                               rpc_clear_running(task);
> +                               spin_unlock_bh(&queue->lock);
>                                 return 0;
> +                       }
> +                       spin_unlock_bh(&queue->lock);
>                         continue;
>                 }
> +               rpc_clear_running(task);
> +               spin_unlock_bh(&queue->lock);
>
>                 /* sync task: sleep here */
>                 dprintk("RPC: %4d sync task going to sleep\n", task->tk_pid);

The reason the spin lock was removed from the scheduler is because
once the BKL is removed from the RPC and NFS clients, the locks in the
RPC scheduler become contented.  Each RPC request passes through this
part of the scheduler an average of 12 times (probably more if a bind
or credential refresh is required), so the locking overhead becomes
critical.

As you are working this fix, can you make sure to test with a heavy
RPC workload against a fast server and make sure that lock contention
remains reasonable?

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
