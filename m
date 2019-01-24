Return-Path: <SRS0=k36n=QA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69348C282C6
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 20:09:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3845E218D0
	for <linux-nfs@archiver.kernel.org>; Thu, 24 Jan 2019 20:09:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728732AbfAXUJH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 24 Jan 2019 15:09:07 -0500
Received: from mx2.math.uh.edu ([129.7.128.33]:59836 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731041AbfAXT2u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Jan 2019 14:28:50 -0500
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx2.math.uh.edu with esmtp (Exim 4.91)
        (envelope-from <tibbs@math.uh.edu>)
        id 1gmkgA-0005hx-HJ
        for linux-nfs@vger.kernel.org; Thu, 24 Jan 2019 13:28:48 -0600
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id 72268801554; Thu, 24 Jan 2019 13:28:46 -0600 (CST)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     linux-nfs@vger.kernel.org
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
Date:   Thu, 24 Jan 2019 13:28:46 -0600
In-Reply-To: <ufaimyearlx.fsf@epithumia.math.uh.edu> (Jason L. Tibbitts, III's
        message of "Thu, 24 Jan 2019 11:32:42 -0600")
Message-ID: <ufaa7jpam8h.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Just had another machine get into this state.  This time I thought to at
least do alt-sysrq-w.  The result is a big pile of backtraces but it
looks like basically every NFS operation is hung up.

I'm not sure how useful it will be, but I tried to categorize the
various backtraces.  Most of them are like the following, going through
nfs_file_fsync:

tcsh            D    0  9511      1 0x80000006
Call Trace:
 ? __schedule+0x253/0x850
 schedule+0x28/0x80
 io_schedule+0x12/0x40
 wait_on_page_bit_common+0x11a/0x270
 ? file_check_and_advance_wb_err+0xc0/0xc0
 __filemap_fdatawait_range+0xe2/0x130
 ? __filemap_fdatawrite_range+0xc8/0xf0
 filemap_write_and_wait_range+0x45/0x80
 nfs_file_fsync+0x44/0x1e0 [nfs]
 filp_close+0x31/0x60
 put_files_struct+0x6c/0xc0
 do_exit+0x2b4/0xb30
 ? __fput+0x151/0x220
 do_group_exit+0x3a/0xa0
 get_signal+0x276/0x590
 do_signal+0x36/0x610
 ? do_sys_open+0x128/0x210
 exit_to_usermode_loop+0x71/0xe0
 do_syscall_64+0x14d/0x160
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7f4760d46ca2
Code: Bad RIP value.
RSP: 002b:00007ffc29c788d0 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
RAX: fffffffffffffe00 RBX: 00005652381bf990 RCX: 00007f4760d46ca2
RDX: 0000000000000000 RSI: 00005652381d4b40 RDI: 00000000ffffff9c
RBP: 0000000000000000 R08: 0000000000000000 R09: 00007ffc29c78920
R10: 0000000000000000 R11: 0000000000000246 R12: 00005652381d4b40
R13: 0000000000000000 R14: 00005652381dcd30 R15: 0000000000000000


There are a few others which are hung on locking operations:

QThread         D    0  9740      1 0x80000006
Call Trace:
 ? __schedule+0x253/0x850
 ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
 schedule+0x28/0x80
 rpc_wait_bit_killable+0x1e/0x90 [sunrpc]
 __wait_on_bit+0x6c/0x80
 out_of_line_wait_on_bit+0x91/0xb0
 ? init_wait_var_entry+0x40/0x40
 nfs4_proc_lock+0x1a9/0x320 [nfsv4]
 ? do_unlk+0x98/0xe0 [nfs]
 locks_remove_posix+0xb1/0x140
 ? __nfs_commit_inode+0xc4/0x1b0 [nfs]
 filp_close+0x50/0x60
 put_files_struct+0x6c/0xc0
 do_exit+0x2b4/0xb30
 ? mem_cgroup_try_charge+0xe6/0x180
 do_group_exit+0x3a/0xa0
 get_signal+0x276/0x590
 do_signal+0x36/0x610
 exit_to_usermode_loop+0x71/0xe0
 do_syscall_64+0x14d/0x160
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7ff3e9321421
Code: Bad RIP value.
RSP: 002b:00007ff3d7ffeac0 EFLAGS: 00000293 ORIG_RAX: 0000000000000007
RAX: fffffffffffffdfc RBX: 00007ff3c8004db0 RCX: 00007ff3e9321421
RDX: 00000000ffffffff RSI: 0000000000000001 RDI: 00007ff3c8004db0
RBP: 0000000000000001 R08: 0000000000000000 R09: 00007ff3c8000c78
R10: 00007ff3d0003480 R11: 0000000000000293 R12: 00000000ffffffff
R13: 00007ff3e6e48f10 R14: 00000000ffffffff R15: 0000000000000001

gvfsd-metadata  D    0 24382      1 0x80000006
Call Trace:
 ? __schedule+0x253/0x850
 ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
 schedule+0x28/0x80
 rpc_wait_bit_killable+0x1e/0x90 [sunrpc]
 __wait_on_bit+0x6c/0x80
 out_of_line_wait_on_bit+0x91/0xb0
 ? init_wait_var_entry+0x40/0x40
 nfs4_do_close+0x2bf/0x2f0 [nfsv4]
 __put_nfs_open_context+0xa9/0x100 [nfs]
 nfs_file_release+0x39/0x40 [nfs]
 __fput+0xb4/0x220
 task_work_run+0x84/0xa0
 do_exit+0x2d2/0xb30
 do_group_exit+0x3a/0xa0
 get_signal+0x276/0x590
 do_signal+0x36/0x610
 ? handle_mm_fault+0xda/0x200
 exit_to_usermode_loop+0x71/0xe0
 do_syscall_64+0x14d/0x160
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7f3cf843d421
Code: Bad RIP value.
RSP: 002b:00007ffc224ea250 EFLAGS: 00000293 ORIG_RAX: 0000000000000007
RAX: fffffffffffffdfc RBX: 000055c9db8fa2a0 RCX: 00007f3cf843d421
RDX: 00000000ffffffff RSI: 0000000000000001 RDI: 000055c9db8fa2a0
RBP: 0000000000000001 R08: 0000000000000000 R09: 000055c9db8ea488
R10: 000055c9db8dbae0 R11: 0000000000000293 R12: 00000000ffffffff
R13: 00007f3cf85bff10 R14: 00000000ffffffff R15: 0000000000000001


And some others waiting on metadata operations:

localStorage DB D    0 24794   9621 0x00000004
Call Trace:
 ? __schedule+0x253/0x850
 schedule+0x28/0x80
 io_schedule+0x12/0x40
 wait_on_page_bit_common+0x11a/0x270
 ? file_check_and_advance_wb_err+0xc0/0xc0
 __filemap_fdatawait_range+0xe2/0x130
 filemap_write_and_wait+0x47/0x70
 nfs_wb_all+0x1a/0x120 [nfs]
 nfs_setattr+0x1cb/0x1d0 [nfs]
 notify_change+0x2da/0x440
 do_truncate+0x74/0xc0
 do_sys_ftruncate+0xb6/0x100
 do_syscall_64+0x5b/0x160
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7eff1cd1382b
Code: Bad RIP value.
RSP: 002b:00007eff0c3787c8 EFLAGS: 00000246 ORIG_RAX: 000000000000004d
RAX: ffffffffffffffda RBX: 0000000000bd0000 RCX: 00007eff1cd1382b
RDX: 0002000100000000 RSI: 0000000000bd0000 RDI: 000000000000005c
RBP: 00007eff034d61a0 R08: 00007ffc7d3b40b0 R09: 00007ffc7d3b4080
R10: 000000000274ded2 R11: 0000000000000246 R12: 000000000000005c
R13: 00007eff02f081c0 R14: 00007eff025fd8e0 R15: 00007eff034832e0

df              D    0 25187  25186 0x00000000
Call Trace:
 ? __schedule+0x253/0x850
 ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
 ? __rpc_atrun+0x20/0x20 [sunrpc]
 schedule+0x28/0x80
 rpc_wait_bit_killable+0x1e/0x90 [sunrpc]
 __wait_on_bit+0x6c/0x80
 ? trace_event_raw_event_rpc_stats_latency+0x240/0x240 [sunrpc]
 out_of_line_wait_on_bit+0x91/0xb0
 ? init_wait_var_entry+0x40/0x40
 __rpc_execute+0xe0/0x350 [sunrpc]
 ? recalibrate_cpu_khz+0x10/0x10
 ? ktime_get+0x36/0xa0
 rpc_run_task+0x121/0x180 [sunrpc]
 nfs4_call_sync_sequence+0x64/0xa0 [nfsv4]
 _nfs4_proc_getattr+0xf8/0x120 [nfsv4]
 nfs4_proc_getattr+0x75/0x100 [nfsv4]
 __nfs_revalidate_inode+0x1b7/0x2a0 [nfs]
 nfs_getattr+0x118/0x2b0 [nfs]
 ? security_inode_getattr+0x30/0x50
 vfs_statx+0x89/0xe0
 __do_sys_newstat+0x39/0x70
 do_syscall_64+0x5b/0x160
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7f7dc6195579
Code: Bad RIP value.
RSP: 002b:00007ffd44e725a8 EFLAGS: 00000246 ORIG_RAX: 0000000000000004
RAX: ffffffffffffffda RBX: 000055ad9832ef80 RCX: 00007f7dc6195579
RDX: 00007ffd44e72650 RSI: 00007ffd44e72650 RDI: 000055ad9832e380
RBP: 000055ad9832e310 R08: 0000000000000003 R09: aaaaaaaaaaaaaaab
R10: 000055ad98326010 R11: 0000000000000246 R12: 000055ad9832e3c0
R13: 0000000000000000 R14: 000055ad9832b9b0 R15: 0000000000000000


And others on writes:

mozStorage #1   D    0 24816   9621 0x00000004
Call Trace:
 ? __schedule+0x253/0x850
 ? __switch_to_asm+0x40/0x70
 schedule+0x28/0x80
 io_schedule+0x12/0x40
 __lock_page+0x13c/0x230
 ? file_check_and_advance_wb_err+0xc0/0xc0
 pagecache_get_page+0x1ae/0x340
 grab_cache_page_write_begin+0x1c/0x40
 nfs_write_begin+0x63/0x340 [nfs]
 generic_perform_write+0xf4/0x1b0
 ? __handle_mm_fault+0xb9d/0x1380
 nfs_file_write+0xdc/0x200 [nfs]
 __vfs_write+0x136/0x1a0
 vfs_write+0xa5/0x1a0
 ksys_write+0x4f/0xb0
 do_syscall_64+0x5b/0x160
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7eff1d131d57
Code: Bad RIP value.
RSP: 002b:00007eff00546380 EFLAGS: 00000293 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 000000000000002d RCX: 00007eff1d131d57
RDX: 0000000000008000 RSI: 00007efef8085000 RDI: 000000000000002d
RBP: 00007efef8085000 R08: 0000000000000000 R09: 00007ffc7d3b4080
R10: 000000000274d526 R11: 0000000000000293 R12: 0000000000008000
R13: 00007eff08604868 R14: 00000000000300c8 R15: 00007efef8085000


Not sure what this one is waiting on:

kdm-uh          D    0 25357  25345 0x00000000
Call Trace:
 ? __schedule+0x253/0x850
 ? __switch_to_asm+0x34/0x70
 ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
 ? __rpc_atrun+0x20/0x20 [sunrpc]
 schedule+0x28/0x80
 rpc_wait_bit_killable+0x1e/0x90 [sunrpc]
 __wait_on_bit+0x6c/0x80
 ? trace_event_raw_event_rpc_stats_latency+0x240/0x240 [sunrpc]
 out_of_line_wait_on_bit+0x91/0xb0
 ? init_wait_var_entry+0x40/0x40
 __rpc_execute+0xe0/0x350 [sunrpc]
 ? recalibrate_cpu_khz+0x10/0x10
 ? ktime_get+0x36/0xa0
 rpc_run_task+0x121/0x180 [sunrpc]
 nfs4_call_sync_sequence+0x64/0xa0 [nfsv4]
 _nfs4_proc_getattr+0xf8/0x120 [nfsv4]
 nfs4_proc_getattr+0x75/0x100 [nfsv4]
 __nfs_revalidate_inode+0x1b7/0x2a0 [nfs]
 nfs_do_access+0x2cd/0x400 [nfs]
 ? rpcauth_lookupcred+0x99/0xc0 [sunrpc]
 nfs_permission+0x1b9/0x1e0 [nfs]
 inode_permission+0xbe/0x180
 link_path_walk.part.49+0x3f2/0x520
 path_openat+0x9f/0x1610
 ? page_counter_try_charge+0x57/0xc0
 ? memcg_kmem_charge_memcg+0x76/0xa0
 ? get_random_u32+0x3e/0xd0
 do_filp_open+0x93/0x100
 ? __check_object_size+0x15d/0x189
 do_sys_open+0x186/0x210
 do_syscall_64+0x5b/0x160
 entry_SYSCALL_64_after_hwframe+0x44/0xa9
RIP: 0033:0x7f3f0fc5dca2
Code: Bad RIP value.
RSP: 002b:00007ffc18c62840 EFLAGS: 00000246 ORIG_RAX: 0000000000000101
RAX: ffffffffffffffda RBX: 000055a70650bfa0 RCX: 00007f3f0fc5dca2
RDX: 0000000000000800 RSI: 000055a70650bcf0 RDI: 00000000ffffff9c
RBP: 0000000000001e34 R08: 000055a70650c3b0 R09: 0000000000000002
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000001
R13: 00007ffc18c62a30 R14: 000055a70650bcf0 R15: 00007ffc18c62afc

And there's one kernel thread, I assume for the mount since that's the
IP of the NFS server.

172.21.86.74-ma D    0 25099      2 0x80000000
Call Trace:
 ? __schedule+0x253/0x850
 ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
 schedule+0x28/0x80
 rpc_wait_bit_killable+0x1e/0x90 [sunrpc]
 __wait_on_bit+0x6c/0x80
 out_of_line_wait_on_bit+0x91/0xb0
 ? init_wait_var_entry+0x40/0x40
 nfs4_proc_sequence+0x3c/0x50 [nfsv4]
 nfs4_run_state_manager+0x257/0x760 [nfsv4]
 ? nfs4_do_reclaim+0x680/0x680 [nfsv4]
 kthread+0x112/0x130
 ? kthread_create_on_node+0x60/0x60
 ret_from_fork+0x35/0x40

