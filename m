Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:47284 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751339AbdJLNrf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Oct 2017 09:47:35 -0400
Date: Thu, 12 Oct 2017 14:47:30 +0100
From: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Remove redundant call to cancel_work_sync() in
 xprt_destroy()
Message-ID: <20171012134730.GA4803@red-moon>
References: <20171011180134.52476-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171011180134.52476-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Wed, Oct 11, 2017 at 02:01:34PM -0400, Trond Myklebust wrote:
> We know that the socket autoclose cannot be queued after we've set
> the XPRT_LOCKED bit, so the call to cancel_work_sync() is redundant.
> In addition, it is causing lockdep to complain about a false ABA
> lock dependency.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/xprt.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
> index e741ec2b4d8e..5f12fe145f02 100644
> --- a/net/sunrpc/xprt.c
> +++ b/net/sunrpc/xprt.c
> @@ -1464,7 +1464,6 @@ static void xprt_destroy(struct rpc_xprt *xprt)
>  	rpc_destroy_wait_queue(&xprt->pending);
>  	rpc_destroy_wait_queue(&xprt->sending);
>  	rpc_destroy_wait_queue(&xprt->backlog);
> -	cancel_work_sync(&xprt->task_cleanup);

This does not make the lockdep warning go away, actually the lockdep
is triggered by the xs_destroy() cancel_work_sync() call but I do not
know this code path so I can't really comment on it, let me know if
there is any specific test I can carry out.

Thanks for looking into this,
Lorenzo

Log:

[    6.223423] ======================================================
[    6.229611] WARNING: possible circular locking dependency detected
[    6.235801] 4.14.0-rc4-00001-g8ee3d7b #64 Not tainted
[    6.240856] ------------------------------------------------------
[    6.247044] kworker/1:0H/17 is trying to acquire lock:
[    6.252188]  ((&task->u.tk_work)){+.+.}, at: [<ffff0000080e64cc>] process_one_work+0x1cc/0x3f0
[    6.260836] 
               but task is already holding lock:
[    6.266676]  ("xprtiod"){+.+.}, at: [<ffff0000080e64cc>] process_one_work+0x1cc/0x3f0
[    6.274531] 
               which lock already depends on the new lock.

[    6.282723] 
               the existing dependency chain (in reverse order) is:
[    6.290217] 
               -> #1 ("xprtiod"){+.+.}:
[    6.295292]        lock_acquire+0x6c/0xb8
[    6.299307]        flush_work+0x188/0x270
[    6.303321]        __cancel_work_timer+0x120/0x198
[    6.308119]        cancel_work_sync+0x10/0x18
[    6.312484]        xs_destroy+0x34/0x58
[    6.316324]        xprt_destroy+0x7c/0x88
[    6.320338]        xprt_put+0x34/0x40
[    6.324004]        rpc_task_release_client+0x6c/0x80
[    6.328976]        rpc_release_resources_task+0x2c/0x38
[    6.334210]        __rpc_execute+0x9c/0x210
[    6.338399]        rpc_async_schedule+0x10/0x18
[    6.342935]        process_one_work+0x240/0x3f0
[    6.347471]        worker_thread+0x48/0x420
[    6.351661]        kthread+0x12c/0x158
[    6.355416]        ret_from_fork+0x10/0x18
[    6.359514] 
               -> #0 ((&task->u.tk_work)){+.+.}:
[    6.365372]        __lock_acquire+0x12ec/0x14a8
[    6.369908]        lock_acquire+0x6c/0xb8
[    6.373922]        process_one_work+0x22c/0x3f0
[    6.378459]        worker_thread+0x48/0x420
[    6.382648]        kthread+0x12c/0x158
[    6.386401]        ret_from_fork+0x10/0x18
[    6.390499] 
               other info that might help us debug this:

[    6.398518]  Possible unsafe locking scenario:

[    6.404445]        CPU0                    CPU1
[    6.408978]        ----                    ----
[    6.413511]   lock("xprtiod");
[    6.416571]                                lock((&task->u.tk_work));
[    6.422938]                                lock("xprtiod");
[    6.428521]   lock((&task->u.tk_work));
[    6.432364] 
                *** DEADLOCK ***

[    6.438295] 1 lock held by kworker/1:0H/17:
[    6.442480]  #0:  ("xprtiod"){+.+.}, at: [<ffff0000080e64cc>] process_one_work+0x1cc/0x3f0
[    6.450773] 
               stack backtrace:
[    6.455138] CPU: 1 PID: 17 Comm: kworker/1:0H Not tainted 4.14.0-rc4-00001-g8ee3d7b #64
[    6.463153] Hardware name: ARM Juno development board (r2) (DT)
[    6.469084] Workqueue: xprtiod rpc_async_schedule
[    6.473795] Call trace:
[    6.476246] [<ffff000008089430>] dump_backtrace+0x0/0x3c8
[    6.481654] [<ffff00000808980c>] show_stack+0x14/0x20
[    6.486715] [<ffff000008a01a30>] dump_stack+0xb8/0xf0
[    6.491776] [<ffff0000081194ac>] print_circular_bug+0x224/0x3a0
[    6.497706] [<ffff00000811a304>] check_prev_add+0x304/0x860
[    6.503288] [<ffff00000811c8c4>] __lock_acquire+0x12ec/0x14a8
[    6.509043] [<ffff00000811d144>] lock_acquire+0x6c/0xb8
[    6.514276] [<ffff0000080e652c>] process_one_work+0x22c/0x3f0
[    6.520031] [<ffff0000080e6738>] worker_thread+0x48/0x420
[    6.525439] [<ffff0000080ed5bc>] kthread+0x12c/0x158
[    6.530411] [<ffff000008084d48>] ret_from_fork+0x10/0x18
[    7.446907] systemd[1]: systemd 232 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD +IDN)
[    7.465397] systemd[1]: Detected architecture arm64.
[    7.487124] systemd[1]: Set hostname to <localhost.localdomain>.
[    8.016682] systemd[1]: Listening on Journal Socket.
[    8.034382] systemd[1]: Listening on udev Control Socket.
[    8.053967] systemd[1]: Listening on Syslog Socket.
[    8.069953] systemd[1]: Listening on udev Kernel Socket.
[    8.089774] systemd[1]: Reached target Remote File Systems.
[    8.110534] systemd[1]: Created slice User and Session Slice.
[    8.130143] systemd[1]: Listening on Journal Audit Socket.
[    8.781699] systemd-journald[1479]: Received request to flush runtime journal from PID 1
[    9.685766] sky2 0000:09:00.0 enp9s0: renamed from eth4
[    9.778209] igb 0000:07:00.2 enp7s0f2: renamed from eth2
[    9.802564] igb 0000:07:00.1 enp7s0f1: renamed from eth1
[    9.822138] igb 0000:07:00.3 enp7s0f3: renamed from eth3
[    9.838393] igb 0000:07:00.0 enp7s0f0: renamed from eth0
[   54.271348] random: crng init done
know this code path at all so I can't really comment on it, let me
know if I c
