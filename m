Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:57680 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758359Ab2CAWzZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 17:55:25 -0500
Date: Thu, 1 Mar 2012 14:55:24 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [3.1-rc4] NFSv3 client hang
Message-ID: <20120301225524.GB27595@hostway.ca>
References: <20110909194509.GB6195@hostway.ca> <1315610322.17611.112.camel@lade.trondhjem.org> <20111020190334.GA22772@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111020190334.GA22772@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 12:03:34PM -0700, Simon Kirby wrote:

> On Fri, Sep 09, 2011 at 07:18:42PM -0400, Trond Myklebust wrote:
> 
> > On Fri, 2011-09-09 at 12:45 -0700, Simon Kirby wrote: 
> > > The 3.1-rc4 NFSv3 client hung on another box (separate from the other one
> > > which Oopsed in vfs_rmdir() with similar workload). This build was also
> > > of 9e79e3e9dd9672b37ac9412e9a926714306551fe (slightly past 3.1-rc4), and
> > > "git log 9e79e3e9dd96.. fs/nfs net/sunrpc" is empty.
> > > 
> > > All mounts to one server IP have hung, while all other mounts work fine.
> > > I ran "cd /proc/sys/sunrpc; echo 255 > rpc_debug; echo 255 > nfs_debug"
> > > for a while, then kill -9'd all D-state processes to simplify the
> > > debugging, and was left with one that was not interruptible:
> > > 
> > > 28612 D    /usr/local/apache2/bin/http sleep_on_page
> > > # cat /proc/28612/stack
> > > [<ffffffff810bdf49>] sleep_on_page+0x9/0x10
> > > [<ffffffff810bdf34>] __lock_page+0x64/0x70
> > > [<ffffffff8112a9e5>] __generic_file_splice_read+0x2d5/0x500
> > > [<ffffffff8112ac5a>] generic_file_splice_read+0x4a/0x90
> > > [<ffffffff812030e5>] nfs_file_splice_read+0x85/0xd0
> > > [<ffffffff81128fb2>] do_splice_to+0x72/0xa0
> > > [<ffffffff811297e4>] splice_direct_to_actor+0xc4/0x1d0
> > > [<ffffffff81129942>] do_splice_direct+0x52/0x70
> > > [<ffffffff81100096>] do_sendfile+0x166/0x1d0
> > > [<ffffffff81100185>] sys_sendfile64+0x85/0xb0
> > > [<ffffffff816af57b>] system_call_fastpath+0x16/0x1b
> > > [<ffffffffffffffff>] 0xffffffffffffffff
> > > 
> > > echo 1 > /proc/sys/sunrpc/rpc_debug emits:
> > > 
> > > -pid- flgs status -client- --rqstp- -timeout ---ops--
> > > 37163 0001    -11 ffff8802251bca00   (null)        0 ffffffff816e4110 nfsv3 READ a:call_reserveresult q:xprt_sending
> > > 
> > > tcpdump to this server shows absolutely no packets to the server IP for
> > > several minutes. netstat shows the socket in CLOSE_WAIT:
> > > 
> > > # netstat -tan|grep 2049
> > > tcp        0      0 10.10.52.50:806         10.10.52.230:2049       CLOSE_WAIT
> > > 
> > > This is the only port-2049 socket that still exists.
> > > rpcinfo -p 10.10.52.230, -t 10.10.52.230 lockmgr, etc., all show the
> > > server seems fine. rpciod is sleeping in rescuer_thread, and nothing
> > > else is in D state.
> > > 
> > > mount opts were "rw,hard,intr,tcp,timeo=300,retrans=2,vers=3"
> > > 
> > > Running another "df" on the mountpoint with rpc_debug = 255 shows:
> > > 
> > > -pid- flgs status -client- --rqstp- -timeout ---ops--
> > > 37163 0001    -11 ffff8802251bca00   (null)        0 ffffffff816e4110 nfsv3 READ a:call_reserveresult q:xprt_sending
> > > RPC:       looking up Generic cred
> > > NFS call  access
> > > RPC:       new task initialized, procpid 30679
> > > RPC:       allocated task ffff880030c17a00
> > > RPC: 37133 __rpc_execute flags=0x80
> > > RPC: 37133 call_start nfs3 proc ACCESS (sync)
> > > RPC: 37133 call_reserve (status 0)
> > > RPC: 37133 failed to lock transport ffff880223d0a000
> > > RPC: 37133 sleep_on(queue "xprt_sending" time 4489651610)
> > > RPC: 37133 added to queue ffff880223d0a178 "xprt_sending"
> > > RPC: 37133 sync task going to sleep
> > > 
> > > So something is not closing the old transport socket here?
> > 
> > Hi Simon,
> > 
> > I've stared at this for some time now, and I'm having trouble seeing
> > what could be going wrong. Can you therefore please apply the following
> > patch, and see if you can reproduce the problem?
> > 
> > Cheers
> >   Trond
> > 8<------------------------------------------------------------------------- 
> > From 7030a57b25ce1647cb8489851cff3419e8856189 Mon Sep 17 00:00:00 2001
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Date: Fri, 9 Sep 2011 19:14:36 -0400
> > Subject: [PATCH] NFS: debugging
> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> >  net/sunrpc/clnt.c |   10 ++++++++++
> >  net/sunrpc/xprt.c |    8 ++++----
> >  2 files changed, 14 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index c5347d2..3e32cfc 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -1867,6 +1867,16 @@ void rpc_show_tasks(void)
> >  			rpc_show_task(clnt, task);
> >  		}
> >  		spin_unlock(&clnt->cl_lock);
> > +		task = ACCESS_ONCE(clnt->cl_xprt->snd_task);
> > +		if (task)
> > +			printk("SUNRPC: xprt(%p) state=%lu, snd_task->tk_pid=%u\n",
> > +					clnt->cl_xprt,
> > +					clnt->cl_xprt->state,
> > +					task->tk_pid);
> > +		else
> > +			printk("SUNRPC: xprt(%p) state=%lu, snd_task=0\n",
> > +					clnt->cl_xprt,
> > +					clnt->cl_xprt->state);
> >  	}
> >  	spin_unlock(&rpc_client_lock);
> >  }
> > diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> > index f4385e4..9f5f0e1 100644
> > --- a/net/sunrpc/xprt.c
> > +++ b/net/sunrpc/xprt.c
> > @@ -235,7 +235,7 @@ static void xprt_clear_locked(struct rpc_xprt *xprt)
> >  		clear_bit(XPRT_LOCKED, &xprt->state);
> >  		smp_mb__after_clear_bit();
> >  	} else
> > -		queue_work(rpciod_workqueue, &xprt->task_cleanup);
> > +		BUG_ON(!queue_work(rpciod_workqueue, &xprt->task_cleanup));
> >  }
> >  
> >  /*
> > @@ -636,7 +636,7 @@ void xprt_force_disconnect(struct rpc_xprt *xprt)
> >  	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
> >  	/* Try to schedule an autoclose RPC call */
> >  	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
> > -		queue_work(rpciod_workqueue, &xprt->task_cleanup);
> > +		BUG_ON(!queue_work(rpciod_workqueue, &xprt->task_cleanup));
> >  	xprt_wake_pending_tasks(xprt, -EAGAIN);
> >  	spin_unlock_bh(&xprt->transport_lock);
> >  }
> > @@ -663,7 +663,7 @@ void xprt_conditional_disconnect(struct rpc_xprt *xprt, unsigned int cookie)
> >  	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
> >  	/* Try to schedule an autoclose RPC call */
> >  	if (test_and_set_bit(XPRT_LOCKED, &xprt->state) == 0)
> > -		queue_work(rpciod_workqueue, &xprt->task_cleanup);
> > +		BUG_ON(!queue_work(rpciod_workqueue, &xprt->task_cleanup));
> >  	xprt_wake_pending_tasks(xprt, -EAGAIN);
> >  out:
> >  	spin_unlock_bh(&xprt->transport_lock);
> > @@ -681,7 +681,7 @@ xprt_init_autodisconnect(unsigned long data)
> >  		goto out_abort;
> >  	spin_unlock(&xprt->transport_lock);
> >  	set_bit(XPRT_CONNECTION_CLOSE, &xprt->state);
> > -	queue_work(rpciod_workqueue, &xprt->task_cleanup);
> > +	BUG_ON(!queue_work(rpciod_workqueue, &xprt->task_cleanup));
> >  	return;
> >  out_abort:
> >  	spin_unlock(&xprt->transport_lock);
> > -- 
> > 1.7.6
> 
> Hello!
> 
> Finally hit this again, on 3.1-rc9. The port 2049 socket is in CLOSE_WAIT
> state again, and everything that touches any mount to that IP hangs.
> 
> I also have logs before unmounting anything, but I figured I'd clear the
> mounts that weren't hanging to simplify this output. Here is the output
> from echo 1 > /proc/sys/sunrpc/rpc_debug:
> 
> [592254.493768] SUNRPC: xprt(ffff880030d3d800) state=16, snd_task=0
> [592254.493847] SUNRPC: xprt(ffff880223a8b800) state=16, snd_task=0
> [592254.493919] SUNRPC: xprt(ffff880225122800) state=16, snd_task=0
> [592254.493991] SUNRPC: xprt(ffff880223a0c800) state=16, snd_task=0
> [592254.494064] SUNRPC: xprt(ffff88022280b000) state=18, snd_task=0
> [592254.494136] SUNRPC: xprt(ffff88022280b000) state=18, snd_task=0
> [592254.494208] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.494283] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.494357] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.494431] -pid- flgs status -client- --rqstp- -timeout ---ops--
> [592254.494512] 31859 0801    -11 ffff88022522c000 ffff88008aebb400        0 ffffffff816f0220 nfsv3 WRITE a:call_status q:xprt_sending
> [592254.494611] 60646 0801    -11 ffff88022522c000 ffff8800c4e21e00        0 ffffffff816f0220 nfsv3 WRITE a:call_status q:xprt_sending
> [592254.494709] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.494786] 61304 0080    -11 ffff880225e8a600   (null)        0 ffffffff81764ea0 nfsv3 GETATTR a:call_reserveresult q:xprt_sending
> [592254.494883] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.494958] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.495032] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.495106] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.495180] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.495254] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.495331] 63054 0080    -11 ffff88022522de00   (null)        0 ffffffff81764ea0 nfsv3 GETATTR a:call_reserveresult q:xprt_sending
> [592254.495428] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.495502] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.495576] SUNRPC: xprt(ffff880223946000) state=27, snd_task->tk_pid=34816
> [592254.495651] SUNRPC: xprt(ffff8802251d6800) state=18, snd_task=0
> [592254.495723] SUNRPC: xprt(ffff8802251d6800) state=18, snd_task=0
> [592254.495795] SUNRPC: xprt(ffff8802239d3800) state=18, snd_task=0
> [592254.495867] SUNRPC: xprt(ffff8802239d3800) state=18, snd_task=0
> [592254.495939] SUNRPC: xprt(ffff880225056800) state=16, snd_task=0
> 
> # ps -eo pid,stat,args,wchan | grep D
>   PID STAT COMMAND                     WCHAN
>  2627 D    [php]                       rpc_wait_bit_killable
>  8524 D    [php4]                      sleep_on_page
>  8525 D    /usr/lib/cgi-bin/php4       sleep_on_page
>  8528 D    /usr/lib/cgi-bin/php4       generic_file_aio_write
>  8530 D    /usr/lib/cgi-bin/php4       nfs_file_fsync
> 10892 D    /usr/lib/cgi-bin/php4       sleep_on_page
> 12157 D    [php4]                      rpc_wait_bit_killable
> 23965 S+   grep --colour D             pipe_wait
> 
> The box was pulled from the cluster for now, so we can leave it in this
> state temporarily, assuming there is anything further we can do to debug it.

Here's another one, from 3.2.2. I guess it's still happening. :/

One mount point is stuck (hangs on access), and netstat shows the socket
to what should be the server in CLOSE_WAIT state. The other mounts work,
and are in ESTABLISHED state. With your debugging patch still applied,
echo 0 > /proc/sys/sunrpc/rpc_debug shows:

# dmesg | grep SUNRPC: | cut -f2- -d' ' | sort -u
SUNRPC: xprt(ffff88008a111000) state=16, snd_task=0
SUNRPC: xprt(ffff8801daae5800) state=16, snd_task=0
SUNRPC: xprt(ffff880209f04000) state=18, snd_task=0
SUNRPC: xprt(ffff88020ec78800) state=16, snd_task=0
SUNRPC: xprt(ffff880222c10800) state=16, snd_task=0
SUNRPC: xprt(ffff880222c13000) state=18, snd_task=0
SUNRPC: xprt(ffff880222c18800) state=16, snd_task=0
SUNRPC: xprt(ffff880222ca0800) state=18, snd_task=0
SUNRPC: xprt(ffff880223f6b000) state=18, snd_task=0
SUNRPC: xprt(ffff880223f79800) state=18, snd_task=0
SUNRPC: xprt(ffff880223f91800) state=18, snd_task=0
SUNRPC: xprt(ffff880223f93000) state=18, snd_task=0
SUNRPC: xprt(ffff880223f97000) state=18, snd_task=0
SUNRPC: xprt(ffff880223f9b800) state=18, snd_task=0
SUNRPC: xprt(ffff880223faa800) state=18, snd_task=0
SUNRPC: xprt(ffff880223fc1000) state=16, snd_task=0
SUNRPC: xprt(ffff880223fc7800) state=27, snd_task->tk_pid=0
SUNRPC: xprt(ffff880223fd3800) state=18, snd_task=0
SUNRPC: xprt(ffff880225069800) state=18, snd_task=0
SUNRPC: xprt(ffff8802251bb800) state=18, snd_task=0
SUNRPC: xprt(ffff8802257c3800) state=16, snd_task=0
SUNRPC: xprt(ffff8802257c6000) state=18, snd_task=0
SUNRPC: xprt(ffff880225e8c000) state=16, snd_task=0
SUNRPC: xprt(ffff880226181000) state=18, snd_task=0
SUNRPC: xprt(ffff880226182000) state=18, snd_task=0
SUNRPC: xprt(ffff880226185800) state=18, snd_task=0
SUNRPC: xprt(ffff880226187800) state=16, snd_task=0

Full dmesg: 0x.ca/sim/ref/3.2.2/rpc_debug.txt

Simon-
