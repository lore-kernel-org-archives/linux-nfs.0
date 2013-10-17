Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:50004 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756706Ab3JQRfm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 13:35:42 -0400
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r9HHZgDU000898
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 17 Oct 2013 10:35:42 -0700
Message-ID: <52601FED.6070708@candelatech.com>
Date: Thu, 17 Oct 2013 10:35:41 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 'umount -f /mnt/foo' fails if server IP is gone.
References: <525D899F.5010604@candelatech.com>
In-Reply-To: <525D899F.5010604@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/15/2013 11:29 AM, Ben Greear wrote:
> Is 'umount -f' supposed to always work, even if the file server
> goes away?
>
> I have a user's system that just hangs forever in this case.
>
> Could be local changes we have made, but I'm curious about
> the expected behaviour before I go digging too deep...

Any input on this?  I don't mind trying to fix it, but I
would like to know how it is supposed to work.

Older kernels do not hang (we tried 3.0.x), but I'm not sure
exactly where the problem started.

Test case was to set up NFSv3 mount, then pull the Ethernet cable
on the nfs client machine.  This system is running 3.9.11+ kernel.

 From /proc/mounts:

10.2.46.90:/nfs_export on /mnt/lf/nfs3-001 type nfs 
(rw,relatime,vers=3,rsize=131072,wsize=131072,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.2.46.90,mountvers=3,mountport=19408,mountproto=udp,srcaddr=10.2.46.91,local_lock=none,addr=10.2.46.90)

# umount /mnt/lf/nfs3-001
^C
# umount -f /mnt/lf/nfs3-001
[hangs forever it seems, certainly for a long time]


Here is a stack trace of hung processes, for instance:

Oct 17 10:24:18 localhost kernel: [688601.930366] SysRq : Show Blocked State
Oct 17 10:24:18 localhost kernel: [688601.931016]   task                PC stack   pid father
Oct 17 10:24:18 localhost kernel: [688601.931016] mkdir           D f1bf6700     0 16898  16831 0x00000082
Oct 17 10:24:18 localhost kernel: [688601.931016]  f070bd8c 00000046 00000282 f1bf6700 f5b55a20 c0d7e400 f5b55a20 c0d7e400
Oct 17 10:24:18 localhost kernel: [688601.931016]  c0d7e400 c0d7e400 c0d7e400 f79e9400 f5b55a20 f79e9400 f5b55a20 f58b19c0
Oct 17 10:24:18 localhost kernel: [688601.931016]  f8dc4fd0 f070bd50 f0ce9924 f070bd50 f8ec6bff f070bd94 f8dbf9f7 ee91a138
Oct 17 10:24:18 localhost kernel: [688601.931016] Call Trace:
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<f8ec6bff>] ? rpc_put_task+0xf/0x20 [sunrpc]
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<f8dbf9f7>] ? nfs_initiate_write+0xb7/0xe0 [nfs]
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c04a9f0e>] ? ktime_get_ts+0x3e/0x110
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c09cb133>] schedule+0x23/0x60
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c09cb1e6>] io_schedule+0x76/0xc0
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c051607d>] sleep_on_page+0xd/0x20
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c09c8d4d>] __wait_on_bit+0x4d/0x70
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c0516070>] ? __lock_page+0x90/0x90
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c0516301>] wait_on_page_bit+0x91/0xa0
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c0478710>] ? wake_atomic_t_function+0x50/0x50
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c05164cb>] filemap_fdatawait_range+0xcb/0x150
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c05166c7>] filemap_write_and_wait_range+0x97/0xb0
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<f8db4074>] nfs_file_fsync+0x44/0xa0 [nfs]
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<f8db4030>] ? nfs_file_fsync_commit+0xb0/0xb0 [nfs]
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c058e1f9>] vfs_fsync_range+0x59/0x70
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c058e237>] vfs_fsync+0x27/0x30
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<f8db4b0b>] nfs_file_flush+0x6b/0x90 [nfs]
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c05631a1>] filp_close+0x31/0x80
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c057ea55>] put_files_struct+0x85/0xe0
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c057eaf7>] exit_files+0x47/0x60
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c045b83c>] do_exit+0x25c/0x980
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c056a0be>] ? SyS_stat64+0x2e/0x40
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c045bf9e>] do_group_exit+0x3e/0xa0
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c045c018>] SyS_exit_group+0x18/0x20
Oct 17 10:24:18 localhost kernel: [688601.931016]  [<c09d370d>] sysenter_do_call+0x12/0x28
Oct 17 10:24:18 localhost kernel: [688601.931016] umount.nfs      D f11c4900     0 17150  17149 0x00000080
Oct 17 10:24:18 localhost kernel: [688602.225057]  f3955d00 00000082 efea0d8c f11c4900 f3955c8c c08d9f96 f104e700 c0d7e400
Oct 17 10:24:18 localhost kernel: [688602.225057]  c0d7e400 c0d7e400 c0d7e400 efea0d8c efea0c80 f79db400 f104e700 c0c3e980
Oct 17 10:24:18 localhost kernel: [688602.225057]  f3955cd0 f3955cb4 f3955e90 0000002c 0000005c 132df575 efea0d80 0000005c
Oct 17 10:24:18 localhost kernel: [688602.225057] Call Trace:
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c08d9f96>] ? __kfree_skb+0x36/0x90
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c09cb133>] schedule+0x23/0x60
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8ec6edd>] rpc_wait_bit_killable+0x2d/0x70 [sunrpc]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c09c8d4d>] __wait_on_bit+0x4d/0x70
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8ec6eb0>] ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8ec6eb0>] ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c09c8e1b>] out_of_line_wait_on_bit+0xab/0xc0
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c0478710>] ? wake_atomic_t_function+0x50/0x50
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8ec7f9e>] __rpc_execute+0x11e/0x290 [sunrpc]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8ebf130>] ? rpcproc_decode_null+0x10/0x10 [sunrpc]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8ebf130>] ? rpcproc_decode_null+0x10/0x10 [sunrpc]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c047865f>] ? wake_up_bit+0x5f/0x70
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8ec814c>] rpc_execute+0x3c/0xa0 [sunrpc]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8ec0f09>] rpc_run_task+0x59/0x70 [sunrpc]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8ec1022>] rpc_call_sync+0x42/0xa0 [sunrpc]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8e0b46c>] nfs3_rpc_wrapper.clone.0+0x5c/0xa0 [nfsv3]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8e0c0d4>] nfs3_proc_getattr+0x34/0x40 [nfsv3]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8db7397>] __nfs_revalidate_inode+0xc7/0x140 [nfs]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8db743f>] nfs_revalidate_inode+0x2f/0x60 [nfs]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<f8db14a8>] nfs_weak_revalidate+0x38/0x50 [nfs]
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c056fba8>] complete_walk+0xa8/0xf0
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c0571e53>] path_lookupat+0x63/0x690
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c05724ae>] filename_lookup+0x2e/0xc0
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c05733a3>] user_path_at_empty+0x43/0x80
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c0578b9e>] ? __d_free+0x2e/0x50
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c064450c>] ? security_capable+0x1c/0x30
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c05733ff>] user_path_at+0x1f/0x30
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c05807c3>] SyS_umount+0x83/0x380
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c04d2606>] ? __audit_syscall_exit+0x1f6/0x290
Oct 17 10:24:18 localhost kernel: [688602.225057]  [<c09d370d>] sysenter_do_call+0x12/0x28

....

Oct 17 10:24:42 localhost kernel: [688631.186190] INFO: task mkdir:16898 blocked for more than 180 seconds.
Oct 17 10:24:42 localhost kernel: [688631.195666] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Oct 17 10:24:42 localhost kernel: [688631.206304] mkdir           D f1bf6700     0 16898  16831 0x00000082
Oct 17 10:24:42 localhost kernel: [688631.215220]  f070bd8c 00000046 00000282 f1bf6700 f5b55a20 c0d7e400 f5b55a20 c0d7e400
Oct 17 10:24:42 localhost kernel: [688631.225933]  c0d7e400 c0d7e400 c0d7e400 f79e9400 f5b55a20 f79e9400 f5b55a20 f58b19c0
Oct 17 10:24:42 localhost kernel: [688631.236712]  f8dc4fd0 f070bd50 f0ce9924 f070bd50 f8ec6bff f070bd94 f8dbf9f7 ee91a138
Oct 17 10:24:42 localhost kernel: [688631.247550] Call Trace:
Oct 17 10:24:42 localhost kernel: [688631.252746]  [<f8ec6bff>] ? rpc_put_task+0xf/0x20 [sunrpc]
Oct 17 10:24:42 localhost kernel: [688631.261369]  [<f8dbf9f7>] ? nfs_initiate_write+0xb7/0xe0 [nfs]
Oct 17 10:24:42 localhost kernel: [688631.270065]  [<c04a9f0e>] ? ktime_get_ts+0x3e/0x110
Oct 17 10:24:42 localhost kernel: [688631.277724]  [<c09cb133>] schedule+0x23/0x60
Oct 17 10:24:42 localhost kernel: [688631.285298]  [<c09cb1e6>] io_schedule+0x76/0xc0
Oct 17 10:24:42 localhost kernel: [688631.292738]  [<c051607d>] sleep_on_page+0xd/0x20
Oct 17 10:24:42 localhost kernel: [688631.300316]  [<c09c8d4d>] __wait_on_bit+0x4d/0x70
Oct 17 10:24:42 localhost kernel: [688631.308117]  [<c0516070>] ? __lock_page+0x90/0x90
Oct 17 10:24:42 localhost kernel: [688631.315731]  [<c0516301>] wait_on_page_bit+0x91/0xa0
Oct 17 10:24:42 localhost kernel: [688631.323630]  [<c0478710>] ? wake_atomic_t_function+0x50/0x50
Oct 17 10:24:42 localhost kernel: [688631.332536]  [<c05164cb>] filemap_fdatawait_range+0xcb/0x150
Oct 17 10:24:42 localhost kernel: [688631.341221]  [<c05166c7>] filemap_write_and_wait_range+0x97/0xb0
Oct 17 10:24:42 localhost kernel: [688631.350224]  [<f8db4074>] nfs_file_fsync+0x44/0xa0 [nfs]
Oct 17 10:24:42 localhost kernel: [688631.358569]  [<f8db4030>] ? nfs_file_fsync_commit+0xb0/0xb0 [nfs]
Oct 17 10:24:42 localhost kernel: [688631.367764]  [<c058e1f9>] vfs_fsync_range+0x59/0x70
Oct 17 10:24:42 localhost kernel: [688631.375818]  [<c058e237>] vfs_fsync+0x27/0x30
Oct 17 10:24:42 localhost kernel: [688631.383346]  [<f8db4b0b>] nfs_file_flush+0x6b/0x90 [nfs]
Oct 17 10:24:42 localhost kernel: [688631.392117]  [<c05631a1>] filp_close+0x31/0x80
Oct 17 10:24:42 localhost kernel: [688631.399741]  [<c057ea55>] put_files_struct+0x85/0xe0
Oct 17 10:24:42 localhost kernel: [688631.407871]  [<c057eaf7>] exit_files+0x47/0x60
Oct 17 10:24:42 localhost kernel: [688631.415535]  [<c045b83c>] do_exit+0x25c/0x980
Oct 17 10:24:42 localhost kernel: [688631.423133]  [<c056a0be>] ? SyS_stat64+0x2e/0x40
Oct 17 10:24:42 localhost kernel: [688631.431078]  [<c045bf9e>] do_group_exit+0x3e/0xa0
Oct 17 10:24:42 localhost kernel: [688631.439103]  [<c045c018>] SyS_exit_group+0x18/0x20
Oct 17 10:24:42 localhost kernel: [688631.447169]  [<c09d370d>] sysenter_do_call+0x12/0x28
Oct 17 10:24:54 localhost kernel: [688643.517069] RPC: AUTH_GSS upcall timed out.


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

