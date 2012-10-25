Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:5622 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932151Ab2JYTW3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2012 15:22:29 -0400
Received: from vmwexceht04-prd.hq.netapp.com (vmwexceht04-prd.hq.netapp.com [10.106.77.34])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q9PJMSL6025124
	for <linux-nfs@vger.kernel.org>; Thu, 25 Oct 2012 12:22:28 -0700 (PDT)
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: avoid deadlock in nfs_kill_super
Date: Thu, 25 Oct 2012 19:22:27 +0000
Message-ID: <0EC8763B847DB24D9ADF5EBD9CD7B41910744FBE@SACEXCMBX03-PRD.hq.netapp.com>
References: <1351188163-10067-1-git-send-email-dros@netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9092922A5@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092922A5@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 25, 2012, at 2:17 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2012-10-25 at 14:02 -0400, Weston Andros Adamson wrote:
>> Calling nfs_kill_super from an RPC task callback would result in a deadlock
>> where nfs_free_server (via rpc_shutdown_client) tries to kill all
>> RPC tasks associated with that connection - including itself!
>> 
>> Instead of calling nfs_kill_super directly, queue a job on the nfsiod
>> workqueue.
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>> ---
>> 
>> This fixes the current incarnation of the lockup I've been tracking down for
>> some time now.  I still have to go back and see why the reproducer changed
>> behavior a few weeks ago - tasks used to get stuck in rpc_prepare_task, but
>> now (before this patch) are stuck in rpc_exit.
>> 
>> The reproducer works against a server with write delegations:
>> 
>> ./nfsometer.py -m v4 server:/path dd_100m_100k
>> 
>> which is basically:
>> - mount
>> - dd if=/dev/zero of=./dd_file.100m_100k bs=102400 count=1024
>> - umount
>> - break if /proc/fs/nfsfs/servers still has entry after 5 seconds (in this
>>   case it NEVER goes away)
>> 
>> There are clearly other ways to trigger this deadlock, like a v4.1 CLOSE - the
>> done handler calls nfs_sb_deactivate...
>> 
>> I've tested this approach with 10 runs X 3 nfs versions X 5 workloads 
>> (dd_100m_100k, dd_100m_1k, python, kernel, cthon), so I'm pretty confident
>> its correct.
>> 
>> One question for the list: should nfs_free_server *always* be scheduled on
>> the nfsiod workqueue? It's called in error paths in several locations.
>> After looking at them, I don't think my approach would break anything, but 
>> some might have style objections.
>> 
> 
> This doesn't add up. There should be nothing calling nfs_sb_deactive()
> from a rpc_call_done() callback. If so, then that would be the bug.
> 
> All calls to things like rpc_put_task(), put_nfs_open_context(), dput(),
> or nfs_sb_deactive() should occur in the rpc_call_release() callback if
> they can't be done in a process context. In both those cases, the
> rpc_task will be invisible to rpc_killall_tasks and rpc_shutdown_client.

Ah, I misunderstood what was going on here.

nfs_kill_super *is* being called by rpc_release_calldata callback:

The kworker stuck in rpc_killall_tasks forever:

[   34.552600]  [<ffffffffa00868e6>] rpc_killall_tasks+0x2d/0xcd [sunrpc]
[   34.552608]  [<ffffffffa00883e4>] rpc_shutdown_client+0x4a/0xec [sunrpc]
[   34.552615]  [<ffffffffa002b973>] nfs_free_server+0xcf/0x133 [nfs]
[   34.552625]  [<ffffffffa0033193>] nfs_kill_super+0x37/0x3c [nfs]
[   34.552629]  [<ffffffff81136c68>] deactivate_locked_super+0x37/0x63
[   34.552633]  [<ffffffff8113785f>] deactivate_super+0x37/0x3b
[   34.552642]  [<ffffffffa0034fc1>] nfs_sb_deactive+0x23/0x25 [nfs]
[   34.552649]  [<ffffffffa00dbba2>] nfs4_free_closedata+0x53/0x63 [nfsv4]
[   34.552661]  [<ffffffffa008f997>] rpc_release_calldata+0x17/0x19 [sunrpc]
[   34.552671]  [<ffffffffa008f9f5>] rpc_free_task+0x5c/0x65 [sunrpc]
[   34.552680]  [<ffffffffa008fe07>] rpc_async_release+0x15/0x17 [sunrpc]
[   34.552684]  [<ffffffff810632b7>] process_one_work+0x192/0x2a0
[   34.552693]  [<ffffffffa008fdf2>] ? rpc_async_schedule+0x33/0x33 [sunrpc]
[   34.552697]  [<ffffffff81064169>] worker_thread+0x140/0x1d7
[   34.552700]  [<ffffffff81064029>] ? manage_workers+0x23b/0x23b
[   34.552704]  [<ffffffff81067d21>] kthread+0x8d/0x95
[   34.552708]  [<ffffffff81067c94>] ? kthread_freezable_should_stop+0x43/0x43
[   34.552713]  [<ffffffff814ef1ac>] ret_from_fork+0x7c/0xb0
[   34.552717]  [<ffffffff81067c94>] ? kthread_freezable_should_stop+0x43/0x43

And the client's task list:

[  174.574006] -pid- flgs status -client- --rqstp- -timeout ---ops--
[  174.574019]  1664 0181     -5 ffff880226474600   (null)        0 ffffffffa00f7ce0 nfsv4 DELEGRETURN a:rpc_exit_task [sunrpc] q:none

So it looks like a CLOSE's rpc_release_calldata is triggering the nfs_kill_super and this is stuck trying to kill the DELEGRETURN task - which never gets run.

I've debugged this from the workqueue side and the DELEGRETURN work is scheduled, but ends up having insert_wq_barrier called on it.  It seems to me that this means the work queue is enforcing queue ordering that the CLOSE work should complete before the DELEGRETURN work can proceed -- and *that* is the deadlock (CLOSE waiting until DELEGRETURN is dead, DELEGRETURN can't run until close is complete).

This would also explain our (Trond and me) failed attempts at canceling / rescheduling jobs in killall_tasks -- insert_wq_barrier's comment states:

 * Currently, a queued barrier can't be canceled.  This is because
 * try_to_grab_pending() can't determine whether the work to be
 * grabbed is at the head of the queue and thus can't clear LINKED
 * flag of the previous work while there must be a valid next work
 * after a work with LINKED flag set.

Now that I have a better understanding of what's happening, I'll go back to the drawing board.

Thanks!
-dros