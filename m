From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS hang
Date: Mon, 27 Nov 2006 14:17:07 -0500
Message-ID: <1164655027.5727.5.camel@lade.trondhjem.org>
References: <1162840599.31460.8.camel@zod.rchland.ibm.com>
	<Pine.LNX.4.64.0611230737500.10489@nacho.alt.net>
	<Pine.LNX.4.64.0611271907070.10489@nacho.alt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilz@us.ibm.com>, nfs@lists.sourceforge.net,
	Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GolzE-0003x6-8Z
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 11:17:52 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19S4dgI1k4QeNAYv8fVqy4C/gM38MrIi3E=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GolzC-0004x9-Ef
	for nfs@lists.sourceforge.net; Mon, 27 Nov 2006 11:17:53 -0800
To: Chris Caputo <ccaputo@alt.net>
In-Reply-To: <Pine.LNX.4.64.0611271907070.10489@nacho.alt.net>
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

On Mon, 2006-11-27 at 19:09 +0000, Chris Caputo wrote:
> On Thu, 23 Nov 2006, Chris Caputo wrote:
> > On Mon, 6 Nov 2006, Josh Boyer wrote:
> > > We've got an IBM bladecenter we're using to do some NFS stress testing
> > > (v3).  It seems with kernel 2.6.16.21 we get a hang during our stress
> > > tests after roughly and hour or two.  The hanging process has a
> > > backtrace that looks like this:
> > > 
> > > cp            D 000000000ff0b198  6672 16505  16296
> > > (NOTLB)
> > > Call Trace:
> > > [C00000000F43B1D0] [C00000002DD5B088] 0xc00000002dd5b088 (unreliable)
> > > [C00000000F43B3A0] [C00000000000F0B4] .__switch_to+0x12c/0x150
> > > [C00000000F43B430] [C00000000039980C] .schedule+0xcec/0xe4c
> > > [C00000000F43B540] [C00000000039A688] .io_schedule+0x68/0xb8
> > > [C00000000F43B5D0] [C000000000093D60] .sync_page+0x7c/0x98
> > > [C00000000F43B650] [C00000000039A8B4] .__wait_on_bit_lock+0x8c/0x114
> > > [C00000000F43B700] [C000000000093C94] .__lock_page+0xa0/0xc8
> > > [C00000000F43B820] [C000000000094A6C] .do_generic_mapping_read+0x21c/0x4a0
> > > [C00000000F43B970] [C000000000095624] .__generic_file_aio_read+0x17c/0x228
> > > [C00000000F43BA40] [C0000000000957C4] .generic_file_aio_read+0x44/0x54
> > > [C00000000F43BAD0] [D000000000320F58] .nfs_file_read+0xb8/0xec [nfs]
> > > [C00000000F43BB70] [C0000000000C5298] .do_sync_read+0xd4/0x130
> > > [C00000000F43BCF0] [C0000000000C60E0] .vfs_read+0x128/0x20c
> > > [C00000000F43BD90] [C0000000000C65C0] .sys_read+0x4c/0x8c
> > > [C00000000F43BE30] [C00000000000871C] syscall_exit+0x0/0x40
> > > 
> > > So far, we've only been able to recreate this with the client and server
> > > blades both in the same chassis.  We tried recreating with nfs_debug
> > > enabled, but it did not hang.  So perhaps there is a correlation with
> > > the high-speed network (gigabit ethernet over fibre) that comes with
> > > that configuration.
> > > 
> > > Does anyone recognize the backtrace of the process or the symptoms of
> > > the problem?  We'd appreciate any info that you may have.
> > > 
> > > Please CC me in responses as I'm not subscribed to this list.
> > 
> > Hi.  I am digging into a hang file issue (albeit NFSv2) that I've narrowed 
> > down to beginning with 2.6.11 and continuing to happen through 2.6.18, but 
> > which does not happen on 2.6.10 or prior.
> > 
> > I wonder if you could run your tests on 2.6.10 and 2.6.11.12 and share the 
> > results with me.
> 
> If you were running into the same problem I was, the following should fix 
> it.  The below patch should apply with ease to 2.6.16.21.
> 
> Chris
> 
> ---
> 
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
> --- a/net/sunrpc/sched.c	2006-11-27 08:41:07.000000000 +0000
> +++ b/net/sunrpc/sched.c	2006-11-27 11:14:21.000000000 +0000
> @@ -587,6 +587,7 @@ EXPORT_SYMBOL(rpc_exit_task);
>  static int __rpc_execute(struct rpc_task *task)
>  {
>  	int		status = 0;
> +	struct rpc_wait_queue *queue;
>  
>  	dprintk("RPC: %4d rpc_execute flgs %x\n",
>  				task->tk_pid, task->tk_flags);
> @@ -631,22 +632,27 @@ static int __rpc_execute(struct rpc_task
>  			lock_kernel();
>  			task->tk_action(task);
>  			unlock_kernel();
> +			/* micro-optimization to avoid spinlock */
> +			if (!RPC_IS_QUEUED(task))
> +				continue;
>  		}
>  
>  		/*
> -		 * Lockless check for whether task is sleeping or not.
> +		 * Check whether task is sleeping.
>  		 */
> -		if (!RPC_IS_QUEUED(task))
> -			continue;
> -		rpc_clear_running(task);
> +		queue = task->u.tk_wait.rpc_waitq;

NACK... There is no guarantee that task->u.tk_wait has any meaning here.
Particularly not so in the case of an asynchronous task, where the
storage is shared with the work_struct.

> +		spin_lock_bh(&queue->lock);
>  		if (RPC_IS_ASYNC(task)) {
> -			/* Careful! we may have raced... */
> -			if (RPC_IS_QUEUED(task))
> -				return 0;
> -			if (rpc_test_and_set_running(task))
> +			if (RPC_IS_QUEUED(task)) {
> +				rpc_clear_running(task);
> +				spin_unlock_bh(&queue->lock);
>  				return 0;
> +			}
> +			spin_unlock_bh(&queue->lock);
>  			continue;
>  		}
> +		rpc_clear_running(task);
> +		spin_unlock_bh(&queue->lock);
>  
>  		/* sync task: sleep here */
>  		dprintk("RPC: %4d sync task going to sleep\n", task->tk_pid);
> 
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys - and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
