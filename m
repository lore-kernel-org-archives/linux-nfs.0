From: "Narasimha Valiveti" <nvaliveti@gmail.com>
Subject: NFS hang in nfs_complete_unlink() with RHEL 5.2
Date: Fri, 6 Jun 2008 06:57:07 -0700
Message-ID: <cc8f6ab0806060657p5de1e70exf9221eda9ab592e5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:49466 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631AbYFFN5p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2008 09:57:45 -0400
Received: by yw-out-2324.google.com with SMTP id 9so724368ywe.1
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jun 2008 06:57:39 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

With the latest RHEL 5.2 installed on one of the machines, I noticed a
NFS/RPC hang. Looking at
the stack of all the process, I noticed the following wait by rpciod thread.

PID: 7672   TASK: ed3bd550  CPU: 0   COMMAND: "rpciod/0"
 #0 [cc9c8e1c] schedule at c05facb9
 #1 [cc9c8e84] rpc_wait_bit_interruptible at f8cff9ed
 #2 [cc9c8e88] __wait_on_bit at c05fb52d
 #3 [cc9c8ea0] out_of_line_wait_on_bit at c05fb5b2
 #4 [cc9c8ed8] __rpc_wait_for_completion_task at f8cffa16
 #5 [cc9c8ee4] nfs_complete_unlink at f90a872b
 #6 [cc9c8efc] nfs_dentry_iput at f90a0e0c
 #7 [cc9c8f08] dentry_iput at c047de77
 #8 [cc9c8f14] dput at c047e996
 #9 [cc9c8f20] put_nfs_open_context at f90a2bad
#10 [cc9c8f38] nfs_writeback_done_full at f90aa450
#11 [cc9c8f60] __rpc_execute at f8cffe87
#12 [cc9c8f8c] worker_thread at c04329bb
#13 [cc9c8fcc] kthread at c0434d97
#14 [cc9c8fe4] kernel_thread_helper at c0404c39

This was never an issue earlier and looking at 5.1 nfs_complete_unlink() source:

void
nfs_complete_unlink(struct dentry *dentry)
{
       . . . .
        dentry->d_flags &= ~DCACHE_NFSFS_RENAMED;
        spin_unlock(&dentry->d_lock);
        rpc_wake_up_task(&data->task);
        nfs_put_unlinkdata(data);
}


So, it seems like __rpc_wait_for_completion_task() called is added to
nfs_comlete_unlink() in 5.2
Also looking at the RHEL 5.2 announcement, the following bug seems to
have pulled this into 5.2
https://bugzilla.redhat.com/show_bug.cgi?id=253663

The only way to resolve this is by rebooting the node, I don't have a
reproduction scenario, but it
hanged couple of time in last 2 days.

Any comments on how we can fix this now ?

Thanks,
- vnr
