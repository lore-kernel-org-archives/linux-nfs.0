Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:11444 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753997Ab3KYR5z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Nov 2013 12:57:55 -0500
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/1] NFSv4.1 fix a kswap nfs4_state_manger race
Date: Mon, 25 Nov 2013 12:57:49 -0500
Message-ID: <1385402270-14284-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This is a three way race between the state manager, kswapd and sys_open. We are
hitting this regularily in our long term testing. This patch should fix the
race - but before we test with this patch, I'd like comments from the list.

The state manager is waiting in __rpc_wait_for_completion_task for a 
recovery OPEN to complete:

kernel: Call Trace:
kernel: [<ffffffff81054a39>] ? __wake_up_common+0x59/0x90
kernel: [<ffffffffa0358110>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
kernel: [<ffffffffa0358152>] rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
kernel: [<ffffffff8152914f>] __wait_on_bit+0x5f/0x90
kernel: [<ffffffffa0358110>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
kernel: [<ffffffff815291f8>] out_of_line_wait_on_bit+0x78/0x90
kernel: [<ffffffff8109b520>] ? wake_bit_function+0x0/0x50
kernel: [<ffffffffa035810d>] __rpc_wait_for_completion_task+0x2d/0x30 [sunrpc]
kernel: [<ffffffffa040d44c>] nfs4_run_open_task+0x11c/0x160 [nfs]
kernel: [<ffffffffa04114d7>] nfs4_open_recover_helper+0x87/0x120 [nfs]
kernel: [<ffffffffa0411636>] nfs4_open_recover+0xc6/0x150 [nfs]
kernel: [<ffffffffa040cc6f>] ? nfs4_open_recoverdata_alloc+0x2f/0x60 [nfs]
kernel: [<ffffffffa041192d>] nfs4_open_reclaim+0xad/0x140 [nfs]
kernel: [<ffffffffa0421bfb>] nfs4_do_reclaim+0x15b/0x5e0 [nfs]
kernel: [<ffffffffa042afc3>] ? pnfs_destroy_layout+0x63/0x80 [nfs]
kernel: [<ffffffffa04224cb>] nfs4_run_state_manager+0x44b/0x620 [nfs]
kernel: [<ffffffffa0422080>] ? nfs4_run_state_manager+0x0/0x620 [nfs]
kernel: [<ffffffff8109b0f6>] kthread+0x96/0xa0
kernel: [<ffffffff8100c20a>] child_rip+0xa/0x20
kernel: [<ffffffff8109b060>] ? kthread+0x0/0xa0
kernel: [<ffffffff8100c200>] ? child_rip+0x0/0x20


Kswapd is shrinking the inode cache, and waiting for a layoutreturn:

kernel: Call Trace:
kernel: [<ffffffffa0358110>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
kernel: [<ffffffffa0358152>] rpc_wait_bit_killable+0x42/0xa0 [sunrpc]
kernel: [<ffffffff8152914f>] __wait_on_bit+0x5f/0x90
kernel: [<ffffffff8152aacb>] ? _spin_unlock_bh+0x1b/0x20
kernel: [<ffffffffa0358110>] ? rpc_wait_bit_killable+0x0/0xa0 [sunrpc]
kernel: [<ffffffff815291f8>] out_of_line_wait_on_bit+0x78/0x90
kernel: [<ffffffff8109b520>] ? wake_bit_function+0x0/0x50
kernel: [<ffffffffa0357b90>] ? rpc_exit_task+0x0/0x60 [sunrpc]
kernel: [<ffffffffa0358695>] __rpc_execute+0xf5/0x350 [sunrpc]
kernel: [<ffffffff8109b327>] ? bit_waitqueue+0x17/0xd0
kernel: [<ffffffffa0358951>] rpc_execute+0x61/0xa0 [sunrpc]
kernel: [<ffffffffa034f3a5>] rpc_run_task+0x75/0x90 [sunrpc]
kernel: [<ffffffffa040b86c>] nfs4_proc_layoutreturn+0x9c/0x110 [nfs]
kernel: [<ffffffffa042b22e>] _pnfs_return_layout+0x11e/0x1e0 [nfs]
kernel: [<ffffffffa03f3ef4>] nfs4_clear_inode+0x44/0x70 [nfs]
kernel: [<ffffffff811a5c7c>] clear_inode+0xac/0x140
kernel: [<ffffffff811a5d50>] dispose_list+0x40/0x120
kernel: [<ffffffff811a60a4>] shrink_icache_memory+0x274/0x2e0
kernel: [<ffffffff81138cca>] shrink_slab+0x12a/0x1a0
kernel: [<ffffffff8113c10a>] balance_pgdat+0x59a/0x820
kernel: [<ffffffff8113c4c4>] kswapd+0x134/0x3b0
kernel: [<ffffffff8109b4a0>] ? autoremove_wake_function+0x0/0x40
kernel: [<ffffffff8113c390>] ? kswapd+0x0/0x3b0
kernel: [<ffffffff8109b0f6>] kthread+0x96/0xa0
kernel: [<ffffffff8100c20a>] child_rip+0xa/0x20
kernel: [<ffffffff8109b060>] ? kthread+0x0/0xa0
kernel: [<ffffffff8100c200>] ? child_rip+0x0/0x20

The layoutreturn is on the cl_rpcwaitq waiting for the state manager to
complete:

kernel: 14628 0a80      0 ffff88013c8a3a00   (null)        0 ffffffffa0430580 nfsv4 LAYOUTRETURN a:rpc_prepare_task q:NFS client

Meanwhile, a sys_open is waiting in __wait_on_freeing_inode for kswapd to
complete the inode deletion. Note that this OPEN RPC has almost completed - it
is stuck processing nfs4_opendata_to_nfs4_state, but it has yet to call
nfs_release_seqid:

kernel: Call Trace:
kernel: [<ffffffff81224590>] ? user_match+0x0/0x20
kernel: [<ffffffff8109b7ce>] ? prepare_to_wait+0x4e/0x80
kernel: [<ffffffff811a55b8>] __wait_on_freeing_inode+0x98/0xc0
kernel: [<ffffffff8109b520>] ? wake_bit_function+0x0/0x50
kernel: [<ffffffffa03f3d80>] ? nfs_find_actor+0x0/0x90 [nfs]
kernel: [<ffffffff811a5764>] find_inode+0x64/0x90
kernel: [<ffffffffa03f3d80>] ? nfs_find_actor+0x0/0x90 [nfs]
kernel: [<ffffffff811a68ad>] ifind+0x4d/0xd0
kernel: [<ffffffffa03f3d80>] ? nfs_find_actor+0x0/0x90 [nfs]
kernel: [<ffffffff811a6d29>] iget5_locked+0x59/0x1b0
kernel: [<ffffffffa03f3280>] ? nfs_init_locked+0x0/0x40 [nfs]
kernel: [<ffffffffa03f54f6>] nfs_fhget+0xc6/0x6c0 [nfs]
kernel: [<ffffffffa040def1>] nfs4_opendata_to_nfs4_state+0x1c1/0x330 [nfs]
kernel: [<ffffffffa040ec3c>] _nfs4_do_open+0x21c/0x4f0 [nfs]
kernel: [<ffffffffa035ac05>] ? rpcauth_lookup_credcache+0xc5/0x260 [sunrpc]
kernel: [<ffffffffa040ef95>] nfs4_do_open+0x85/0x170 [nfs]
kernel: [<ffffffffa040f0a8>] nfs4_atomic_open+0x28/0x50 [nfs]
kernel: [<ffffffffa03ee9fd>] nfs_atomic_lookup+0x15d/0x310 [nfs]
kernel: [<ffffffff81198ae5>] do_lookup+0x1a5/0x230
kernel: [<ffffffff811993fc>] __link_path_walk+0x78c/0xfe0
kernel: [<ffffffff81121f20>] ? __generic_file_aio_write+0x260/0x490
kernel: [<ffffffffa0357d30>] ? rpc_do_put_task+0x30/0x40 [sunrpc]
kernel: [<ffffffff81199f1a>] path_walk+0x6a/0xe0
kernel: [<ffffffff8119a12b>] filename_lookup+0x6b/0xc0
kernel: [<ffffffff81226466>] ? security_file_alloc+0x16/0x20
kernel: [<ffffffff8119b5f4>] do_filp_open+0x104/0xd20
kernel: [<ffffffff8109b4a0>] ? autoremove_wake_function+0x0/0x40
kernel: [<ffffffff8118e9a4>] ? cp_new_stat+0xe4/0x100
kernel: [<ffffffff811a82b2>] ? alloc_fd+0x92/0x160
kernel: [<ffffffff81185f19>] do_sys_open+0x69/0x140
kernel: [<ffffffff81189a61>] ? sys_write+0x51/0x90
kernel: [<ffffffff81186030>] sys_open+0x20/0x30
kernel: [<ffffffff8100b072>] system_call_fastpath+0x16/0x1b

The OPEN from the state manager (this is an educated guess) is waiting for the
above open to release the seqid - so it is waiting on the Seqid_waitqueue

kernel: 11683 0081      0 ffff880037827c00   (null)        0 ffffffffa0430180 nfsv4 OPEN a:rpc_prepare_task q:Seqid_waitqueue

Turning off error handling for layoutreturn calls that come from nfs4_evict_inode will prevent the race.  It would be more accurate to only turn off this error handling when kswapd and the state manager are running, but that seemed too complicated to worry about as layoutreturn already passes in a NULL state to nfs4_async_handle_errors and so does not handle a good number errors.


Andy Adamson (1):
  NFSv4.1 Don't handle layoutreturn errors when state manager is running

 fs/nfs/nfs4proc.c       | 6 ++++++
 fs/nfs/pnfs.c           | 5 ++++-
 include/linux/nfs_xdr.h | 1 +
 3 files changed, 11 insertions(+), 1 deletion(-)

-- 
1.8.3.1

