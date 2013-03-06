Return-Path: linux-nfs-owner@vger.kernel.org
Received: from www262.sakura.ne.jp ([202.181.97.72]:53828 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484Ab3CFNws (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Mar 2013 08:52:48 -0500
Received: from www262.sakura.ne.jp (ksav54.sakura.ne.jp [219.94.192.134])
	by www262.sakura.ne.jp (8.14.3/8.14.3) with ESMTP id r26Dqkat079148
	for <linux-nfs@vger.kernel.org>; Wed, 6 Mar 2013 22:52:46 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from CLAMP (KD175108057186.ppp-bb.dion.ne.jp [175.108.57.186])
	by www262.sakura.ne.jp (8.14.3/8.14.3) with ESMTP id r26DqjWR079143
	for <linux-nfs@vger.kernel.org>; Wed, 6 Mar 2013 22:52:46 +0900 (JST)
	(envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
To: linux-nfs@vger.kernel.org
Subject: [3.9-rc1 nfs] Locks held bug.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201303062252.AEI18773.SHFOFFJVQOLMOt@I-love.SAKURA.ne.jp>
Date: Wed, 6 Mar 2013 22:52:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I got below bug when starting NFS daemon on CentOS 6.3 x86_32.
100% reproducible.

[   35.071178] =====================================
[   35.071340] [ BUG: rpc.nfsd/3464 still has locks held! ]
[   35.074482] 3.9.0-rc1 #50 Tainted: G        W
[   35.074627] -------------------------------------
[   35.074751] 2 locks held by rpc.nfsd/3464:
[   35.078010]  #0:  (nfsd_mutex){+.+.+.}, at: [<c11d12d8>] write_ports+0x28/0x6f0
[   35.081121]  #1:  (rpcb_create_local_mutex){+.+.+.}, at: [<c146030c>] rpcb_create_local+0x3c/0x480
[   35.083678]
[   35.083678] stack backtrace:
[   35.084913] Pid: 3464, comm: rpc.nfsd Tainted: G        W    3.9.0-rc1 #50
[   35.086652] Call Trace:
[   35.087354]  [<c107b0b1>] debug_check_no_locks_held+0x91/0xa0
[   35.089598]  [<c14571ed>] rpc_wait_bit_killable+0x6d/0xa0
[   35.090988]  [<c1482de5>] __wait_on_bit+0x45/0x70
[   35.091220]  [<c1457180>] ? rpc_queue_empty+0x40/0x40
[   35.093504]  [<c1482e6d>] out_of_line_wait_on_bit+0x5d/0x70
[   35.094954]  [<c1457180>] ? rpc_queue_empty+0x40/0x40
[   35.095215]  [<c1054e80>] ? autoremove_wake_function+0x50/0x50
[   35.097755]  [<c1457587>] __rpc_execute+0x137/0x1d0
[   35.099756]  [<c1457042>] ? rpc_make_runnable+0x32/0x90
[   35.101100]  [<c145763d>] rpc_execute+0x1d/0x20
[   35.102299]  [<c1451584>] rpc_run_task+0x54/0x70
[   35.103507]  [<c145169d>] rpc_call_sync+0x3d/0xa0
[   35.104721]  [<c1451743>] rpc_ping+0x43/0x60
[   35.105826]  [<c1451d8d>] rpc_create+0x12d/0x1b0
[   35.107052]  [<c145f521>] ? rpcb_get_local+0xf1/0x1d0
[   35.107354]  [<c148631d>] ? _raw_spin_unlock+0x1d/0x30
[   35.110182]  [<c146037c>] rpcb_create_local+0xac/0x480
[   35.111491]  [<c10e10c8>] ? __kmalloc+0x128/0x1b0
[   35.111712]  [<c1459b7c>] svc_rpcb_setup+0x1c/0x40
[   35.114226]  [<c1459be8>] svc_bind+0x48/0x50
[   35.115331]  [<c11ce31c>] nfsd_create_serv+0x1fc/0x2c0
[   35.115611]  [<c11cf820>] ? nfsd_svc+0x700/0x700
[   35.115826]  [<c11ce120>] ? nfsd_shutdown_generic+0x30/0x30
[   35.119771]  [<c11d18ba>] write_ports+0x60a/0x6f0
[   35.121611]  [<c11d12f2>] ? write_ports+0x42/0x6f0
[   35.122899]  [<c10cb616>] ? might_fault+0x46/0xa0
[   35.124113]  [<c1280e54>] ? _copy_from_user+0x34/0x80
[   35.124253]  [<c1107328>] ? copy_from_user+0x8/0x10
[   35.126688]  [<c11d12b0>] ? write_versions+0x400/0x400
[   35.128799]  [<c11cfdc9>] nfsctl_transaction_write+0x59/0x70
[   35.130327]  [<c11cfd70>] ? export_features_show+0x30/0x30
[   35.131773]  [<c10e4016>] vfs_write+0x86/0xd0
[   35.132144]  [<c10e4879>] sys_write+0x49/0x90
[   35.134043]  [<c1486cda>] sysenter_do_call+0x12/0x32
[   35.167990] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state recovery directory
[   35.192676] NFSD: starting 90-second grace period (net c165f200)

Regards.
