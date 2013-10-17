Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:36188 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758642Ab3JQTeJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 15:34:09 -0400
Message-ID: <52603BAF.2030209@candelatech.com>
Date: Thu, 17 Oct 2013 12:34:07 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 'umount -f /mnt/foo' fails if server IP is gone.
References: <525D899F.5010604@candelatech.com>    <52601FED.6070708@candelatech.com>   <1382033137.3216.3.camel@leira.trondhjem.org>   <52602835.4000701@candelatech.com>  <1382034747.3216.8.camel@leira.trondhjem.org>  <52602DD7.6050708@candelatech.com> <1382035346.3216.15.camel@leira.trondhjem.org>
In-Reply-To: <1382035346.3216.15.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/17/2013 11:42 AM, Myklebust, Trond wrote:
> On Thu, 2013-10-17 at 11:35 -0700, Ben Greear wrote:

>>> 'umount -f -l' should normally work to at least hide the gruesome
>>> details of your hanging superblock.
>>>
>>> I'm guessing that you're falling afoul of the path revalidation that
>>> Chuck alluded to. There should already be a fix for that problem with
>>> the path_umountat() patches that went into Linux 3.12-rc1. Are those
>>> failing to help?
>>
>> I have not tried past 3.9.11 kernel yet.  I will go look for those patches
>> you mention as well.  Did any of this go to -stable by chance?
> 
> Not as far as I know.
> 
> The commit identifier is 8033426e6bdb2690d302872ac1e1fadaec1a5581 (vfs:
> allow umount to handle mountpoints without revalidating them) in case
> you are interested.

Ok, that is the one that Jeff pointed me to a bit ago.

I re-ran the test with this patch (which applies cleanly into 3.9.11+).

In this case, I see a hang in my file-io process, but, 'umount -l foo'
returns immediately and the mount is gone from /proc/mounts.

I tried 'kill -9' but the btserver process won't die.  I plugged the cable
so that the mount could recover, but still the process is hung.  Maybe
because I did the 'umount -l' ?

After cable is reconnected, (and with btserver process still hung),
I tried to re-mount the same partition.  Those mount calls are hanging
as well.

So, maybe some progress, but I think there are still some fixes needed.


[  167.229748] r8169 0000:02:00.0 eth1: link down
[  379.288195] INFO: task btserver:6895 blocked for more than 180 seconds.
[  379.300366] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  379.313502] btserver        D f3a3a2a4     0  6895   1431 0x00000080
[  379.325191]  f0615e08 00000086 00000282 f3a3a2a4 f0615dd8 f3a3a2a4 f1ed99a0 c0d41240
[  379.338396]  c0d41240 c0d41240 c0d41240 7913580e 00000027 f79db240 f1ed99a0 f5936680
[  379.351591]  f8e4ffd0 f0615dcc f3a3a2a4 f0615dcc f8e120df f0615e10 f8e4a3c7 f0f2a138
[  379.365431] Call Trace:
[  379.373114]  [<f8e120df>] ? rpc_put_task+0xf/0x20 [sunrpc]
[  379.384078]  [<f8e4a3c7>] ? nfs_initiate_write+0xb7/0xe0 [nfs]
[  379.395078]  [<c04a076e>] ? ktime_get_ts+0x3e/0x110
[  379.405192]  [<c09baf43>] schedule+0x23/0x60
[  379.414219]  [<c09baff6>] io_schedule+0x76/0xc0
[  379.423540]  [<c05080bd>] sleep_on_page+0xd/0x20
[  379.432895]  [<c09b8fcd>] __wait_on_bit+0x4d/0x70
[  379.442306]  [<c05080b0>] ? __lock_page+0x90/0x90
[  379.451693]  [<c0508381>] wait_on_page_bit+0x91/0xa0
[  379.461264]  [<c0472690>] ? autoremove_wake_function+0x50/0x50
[  379.472217]  [<c050855b>] filemap_fdatawait_range+0xdb/0x150
[  379.482471]  [<c0508727>] filemap_write_and_wait_range+0x77/0x90
[  379.493219]  [<f8e3f074>] nfs_file_fsync+0x44/0xa0 [nfs]
[  379.502922]  [<f8e3f030>] ? nfs_file_fsync_commit+0xb0/0xb0 [nfs]
[  379.513423]  [<c0581179>] vfs_fsync_range+0x59/0x70
[  379.522692]  [<c05811b7>] vfs_fsync+0x27/0x30
[  379.531426]  [<f8e3fabb>] nfs_file_flush+0x6b/0x90 [nfs]
[  379.541135]  [<c05546b1>] filp_close+0x31/0x80
[  379.549817]  [<c056fb9a>] __close_fd+0x6a/0x90
[  379.558490]  [<c055465c>] sys_close+0x1c/0x40
[  379.567062]  [<c09c26cd>] sysenter_do_call+0x12/0x28


....


Oct 17 12:25:09 localhost kernel: [ 1240.992796] SysRq : Show Blocked State
Oct 17 12:25:09 localhost kernel: [ 1240.993012]   task                PC stack   pid father
Oct 17 12:25:09 localhost kernel: [ 1240.993012] btserver        D f0f2a204     0  8701   1431 0x00000086
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  f5bc3c64 00000046 00000000 f0f2a204 00000000 f5aec010 f153e680 c0d41240
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  c0d41240 c0d41240 c0d41240 cbf49405 00000103 f79e9240 f153e680 f11a8000
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  f5bc3c28 c04a076e f582a148 00000246 00000246 f5bc3c5c c04d6ff6 00014993
Oct 17 12:25:09 localhost kernel: [ 1240.993012] Call Trace:
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c04a076e>] ? ktime_get_ts+0x3e/0x110
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c04d6ff6>] ? delayacct_end+0x96/0xb0
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c04a076e>] ? ktime_get_ts+0x3e/0x110
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c09baf43>] schedule+0x23/0x60
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c09baff6>] io_schedule+0x76/0xc0
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c05080bd>] sleep_on_page+0xd/0x20
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c09b8fcd>] __wait_on_bit+0x4d/0x70
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c05080b0>] ? __lock_page+0x90/0x90
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c0508381>] wait_on_page_bit+0x91/0xa0
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c0472690>] ? autoremove_wake_function+0x50/0x50
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c050855b>] filemap_fdatawait_range+0xdb/0x150
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c0508727>] filemap_write_and_wait_range+0x77/0x90
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<f8e3f074>] nfs_file_fsync+0x44/0xa0 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<f8e3f030>] ? nfs_file_fsync_commit+0xb0/0xb0 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1240.993012]  [<c0581179>] vfs_fsync_range+0x59/0x70
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c05811b7>] vfs_fsync+0x27/0x30
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e3fabb>] nfs_file_flush+0x6b/0x90 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c05546b1>] filp_close+0x31/0x80
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0570085>] put_files_struct+0x85/0xe0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0570127>] exit_files+0x47/0x60
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c045653c>] do_exit+0x25c/0x980
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0456c9e>] do_group_exit+0x3e/0xa0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c046630b>] get_signal_to_deliver+0x1db/0x5f0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c09ba9f3>] ? __schedule+0x3e3/0x7e0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c04135aa>] do_signal+0x3a/0x920
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c047eedb>] ? update_rq_clock+0x3b/0x2b0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0456eee>] ? do_wait+0xfe/0x210
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c045707d>] ? sys_wait4+0x7d/0xb0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c04c8126>] ? __audit_syscall_exit+0x1f6/0x280
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0454f70>] ? wait_noreap_copyout+0xd0/0xd0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0413eff>] do_notify_resume+0x6f/0xa0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c09bc505>] work_notifysig+0x30/0x37
Oct 17 12:25:09 localhost kernel: [ 1241.175689] mkdir           D f5aec010     0  8741   8701 0x00000082
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  f3abfd8c 00000046 00000282 f5aec010 f11a8000 f153e680 f11a8000 c0d41240
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  c0d41240 c0d41240 c0d41240 cbf72225 00000103 f79e9240 f11a8000 f3188cd0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  f3abfd50 c04a076e f15526e8 00000246 00000246 f3abfd84 c04d6ff6 00019454
Oct 17 12:25:09 localhost kernel: [ 1241.175689] Call Trace:
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c04a076e>] ? ktime_get_ts+0x3e/0x110
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c04d6ff6>] ? delayacct_end+0x96/0xb0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c04a076e>] ? ktime_get_ts+0x3e/0x110
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c09baf43>] schedule+0x23/0x60
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c09baff6>] io_schedule+0x76/0xc0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c05080bd>] sleep_on_page+0xd/0x20
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c09b8fcd>] __wait_on_bit+0x4d/0x70
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c05080b0>] ? __lock_page+0x90/0x90
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0508381>] wait_on_page_bit+0x91/0xa0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0472690>] ? autoremove_wake_function+0x50/0x50
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c050855b>] filemap_fdatawait_range+0xdb/0x150
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0508727>] filemap_write_and_wait_range+0x77/0x90
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e3f074>] nfs_file_fsync+0x44/0xa0 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e3f030>] ? nfs_file_fsync_commit+0xb0/0xb0 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0581179>] vfs_fsync_range+0x59/0x70
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c05811b7>] vfs_fsync+0x27/0x30
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e3fabb>] nfs_file_flush+0x6b/0x90 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c05546b1>] filp_close+0x31/0x80
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0570085>] put_files_struct+0x85/0xe0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0570127>] exit_files+0x47/0x60
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c045653c>] do_exit+0x25c/0x980
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0456c9e>] do_group_exit+0x3e/0xa0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0456d18>] sys_exit_group+0x18/0x20
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c09c26cd>] sysenter_do_call+0x12/0x28
Oct 17 12:25:09 localhost kernel: [ 1241.175689] mount.nfs       D 00000000     0  9474   9473 0x00000080
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  f04d1be0 00000082 d07942dc 00000000 00000082 0000b800 f1fec010 c0d41240
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  c0d41240 c0d41240 c0d41240 f58bc570 00000000 f79db240 f1fec010 c0c19180
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  00000000 00000000 00000020 00000000 f582b400 f79db240 00000000 f04d1c10
Oct 17 12:25:09 localhost kernel: [ 1241.175689] Call Trace:
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c048b2a0>] ? idle_balance+0x100/0x420
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c09baf43>] schedule+0x23/0x60
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e123fd>] rpc_wait_bit_killable+0x2d/0x70 [sunrpc]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c09b8fcd>] __wait_on_bit+0x4d/0x70
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e123d0>] ? rpc_queue_empty+0x40/0x40 [sunrpc]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e123d0>] ? rpc_queue_empty+0x40/0x40 [sunrpc]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c09b909b>] out_of_line_wait_on_bit+0xab/0xc0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0472690>] ? autoremove_wake_function+0x50/0x50
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e134fe>] __rpc_execute+0x11e/0x2a0 [sunrpc]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e0a130>] ? rpcproc_decode_null+0x10/0x10 [sunrpc]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e0a130>] ? rpcproc_decode_null+0x10/0x10 [sunrpc]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c047262f>] ? wake_up_bit+0x5f/0x70
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e136b4>] rpc_execute+0x34/0x90 [sunrpc]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e0bc79>] rpc_run_task+0x59/0x70 [sunrpc]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e0bd92>] rpc_call_sync+0x42/0xa0 [sunrpc]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8c0547c>] nfs3_rpc_wrapper.clone.0+0x5c/0xa0 [nfsv3]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8c06153>] do_proc_fsinfo+0x33/0x40 [nfsv3]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8c06183>] nfs3_proc_fsinfo+0x23/0x50 [nfsv3]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e3a97f>] nfs_probe_fsinfo+0x4f/0x500 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e3bef1>] nfs_create_server+0x201/0x440 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8c050ae>] nfs3_create_server+0xe/0x30 [nfsv3]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e43fc1>] nfs_try_mount+0x151/0x280 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e42e1d>] ? nfs_get_option_ul+0x3d/0x50 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e45d1b>] ? nfs_fs_mount+0x6db/0x9c0 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e3a7d8>] ? get_nfs_version+0x28/0x80 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e3a7d8>] ? get_nfs_version+0x28/0x80 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0520453>] ? kstrndup+0x43/0x60
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e457cd>] nfs_fs_mount+0x18d/0x9c0 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e45450>] ? nfs_clone_super+0x150/0x150 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<f8e43d50>] ? nfs_clone_sb_security+0x50/0x50 [nfs]
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0559036>] mount_fs+0x36/0x180
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0524b3f>] ? __alloc_percpu+0xf/0x20
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0572180>] vfs_kern_mount+0x50/0xc0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c05737d8>] do_mount+0x2b8/0x810
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c050f68b>] ? __get_free_pages+0x2b/0x30
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c05714e1>] ? copy_mount_options+0x41/0x120
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c0573d9b>] sys_mount+0x6b/0xa0
Oct 17 12:25:09 localhost kernel: [ 1241.175689]  [<c09c26cd>] sysenter_do_call+0x12/0x28

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

