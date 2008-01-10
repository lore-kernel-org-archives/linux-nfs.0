From: Neil Brown <neilb@suse.de>
Subject: Strange lockup during unmount in 2.6.22 - maybe rpciod deadlock?
Date: Fri, 11 Jan 2008 08:51:31 +1100
Message-ID: <18310.37731.29874.582772@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:49668 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757017AbYAJVvk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jan 2008 16:51:40 -0500
Received: from Relay2.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 85267269DD
	for <linux-nfs@vger.kernel.org>; Thu, 10 Jan 2008 22:51:39 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



I have a report of an unusual NFS deadlock in OpenSuSE 10.3, which is
based on 2.6.22.

People who like bugzilla can find a little more detail at:
    https://bugzilla.novell.com/show_bug.cgi?id=352878

We start with a "soft,intr" mount over a VPN on an unreliable network.

I assume an unmount happened (by autofs) while there was some
outstanding requests  - at least one was a COMMIT but I'm guessing
there were others.

When the last commit completed (probably timed-out) it put the open
context, dropped the last reference on the vfsmnt and so called
nfs_free_server and thence rpc_shutdown_client.
All this is happened in rpciod/0.

rpc_shutdown_client calls rpc_killall_tasks and waits for them all to
complete.  This deadlocks.

I'm wondering if some other request (read-ahead?) might need service
from rpciod/0 before it can complete.  This would mean that it cannot
complete until rpciod/0 is free, and rpciod/0 won't be free until it
completes.

Is this a credible scenario?

There is an idle rpciod/1, so presumably some tasks could complete on
that, but maybe they are tided to a particular CPU ??

Some excerpts from the 'showtasks' list are:

This is where I think the deadlock is:


rpciod/0      D 0000066e2a868397     0  3407      2 (L-TLB)
 ffff81012bbbbd00 0000000000000046 0000000000000000 0000000000000000
 0000000000000441 ffff81012bbbbcb0 ffffffff80617800 ffffffff80617800
 ffffffff8061d210 ffffffff80617800 ffffffff80617800 ffff81006a507cb0
Call Trace:
 [<ffffffff803fa993>] schedule_timeout+0x8a/0xad
 [<ffffffff8023a5f6>] process_timeout+0x0/0x5
 [<ffffffff803fa98e>] schedule_timeout+0x85/0xad
 [<ffffffff88569e6d>] :sunrpc:rpc_shutdown_client+0x9f/0xfb
 [<ffffffff8024433b>] autoremove_wake_function+0x0/0x2e
 [<ffffffff803fabfa>] mutex_lock+0xd/0x1e
 [<ffffffff88668cd3>] :nfs:nfs_free_server+0x92/0xcf
 [<ffffffff8028b867>] deactivate_super+0x6a/0x82
 [<ffffffff8866edd6>] :nfs:put_nfs_open_context+0x9e/0xaf
 [<ffffffff88671fb5>] :nfs:nfs_release_request+0x1d/0x2f
 [<ffffffff886760da>] :nfs:nfs_commit_done+0x176/0x19f
 [<ffffffff8856e3aa>] :sunrpc:rpc_exit_task+0x33/0x79
 [<ffffffff8856e8e7>] :sunrpc:__rpc_execute+0x88/0x242
 [<ffffffff8856eaa1>] :sunrpc:rpc_async_schedule+0x0/0xc
 [<ffffffff80240bbe>] run_workqueue+0x7d/0x10c
 [<ffffffff80241472>] worker_thread+0xe1/0xf0
 [<ffffffff8024433b>] autoremove_wake_function+0x0/0x2e
 [<ffffffff80241391>] worker_thread+0x0/0xf0
 [<ffffffff80244214>] kthread+0x47/0x73
 [<ffffffff8020aa48>] child_rip+0xa/0x12
 [<ffffffff802441cd>] kthread+0x0/0x73
 [<ffffffff8020aa3e>] child_rip+0x0/0x12


This is a task trying to access a new NFS mount.  It is blocking on
IO.  "ls -l" and other metadata options work OK on this mount, but
anything requiring data access hangs like this.  Presumably it is
blocking on rpciod/0 ??

less          D 000005b8846cd503     0 31053      1 (NOTLB)
 ffff810055e05b78 0000000000000082 0000000000000002 0000000000000000
 ffff810001025800 ffff810055e05b28 ffffffff80617800 ffffffff80617800
 ffffffff8061d210 ffffffff80617800 ffffffff80617800 ffffffff80617800
Call Trace:
 [<ffffffff8856fac1>] :sunrpc:rpcauth_lookup_credcache+0x113/0x242
 [<ffffffff80264a27>] sync_page+0x0/0x42
 [<ffffffff803fa8d2>] io_schedule+0x3f/0x67
 [<ffffffff80264a65>] sync_page+0x3e/0x42
 [<ffffffff803faa1f>] __wait_on_bit_lock+0x3f/0x72
 [<ffffffff80264a14>] __lock_page+0x5e/0x64
 [<ffffffff80244369>] wake_bit_function+0x0/0x23
 [<ffffffff802652fd>] do_generic_mapping_read+0x1d9/0x3de
 [<ffffffff802647ec>] file_read_actor+0x0/0xf1
 [<ffffffff80266c83>] generic_file_aio_read+0x121/0x15e
 [<ffffffff80289c11>] do_sync_read+0xd1/0x118
 [<ffffffff8856f79c>] :sunrpc:rpcauth_lookupcred+0x6d/0x97
 [<ffffffff8866d94b>] :nfs:nfs_file_open+0x0/0x7d
 [<ffffffff8024433b>] autoremove_wake_function+0x0/0x2e
 [<ffffffff8028868a>] __dentry_open+0x101/0x1aa
 [<ffffffff802887ea>] do_filp_open+0x2d/0x3d
 [<ffffffff8028a42d>] vfs_read+0xcb/0x153
 [<ffffffff8028a7c1>] sys_read+0x45/0x6e
 [<ffffffff80209c2e>] system_call+0x7e/0x83

The other rpciod is doing nothing.

rpciod/1      S ffff81012b85c1c0     0 21829      2 (L-TLB)
 ffff810102c1fec0 0000000000000046 ffffffff802c1215 ffffffff80229aa7
 ffff810102c1fe10 ffff810102c1fe70 ffffffff80617800 ffffffff80617800
 ffffffff8061d210 ffffffff80617800 ffffffff80617800 ffffffff803fa014
Call Trace:
 [<ffffffff802c1215>] proc_delete_inode+0x0/0x4a
 [<ffffffff80229aa7>] task_rq_lock+0x3d/0x73
 [<ffffffff803fa014>] thread_return+0x0/0xf1
 [<ffffffff8024143a>] worker_thread+0xa9/0xf0
 [<ffffffff8024433b>] autoremove_wake_function+0x0/0x2e
 [<ffffffff80241391>] worker_thread+0x0/0xf0
 [<ffffffff80244214>] kthread+0x47/0x73
 [<ffffffff8020aa48>] child_rip+0xa/0x12
 [<ffffffff802441cd>] kthread+0x0/0x73
 [<ffffffff8020aa3e>] child_rip+0x0/0x12


Any input appreciated.

Thanks,
NeilBrown
