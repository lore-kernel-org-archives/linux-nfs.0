Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:59502 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754644Ab0E0SLe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 May 2010 14:11:34 -0400
Message-ID: <4BFEB5D4.30608@panasas.com>
Date: Thu, 27 May 2010 21:11:32 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/5] backported patches for pnfs-all-2.6.33
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following patches were backported to pnfs-all-2.6.33-2010-05-27:

commit 1d7e6862446faa85a6783c91a9da892ac93222d2
Author: Boaz Harrosh <bharrosh@panasas.com>
Date:   Thu May 27 17:52:24 2010 +0300

    pnfs-obj: panlayout: Fix very old BUG_ONs on ol_state.status
    
    OK This is definitely my stupidity when converting panfs_shim to the
    new objlayout_read/write_done() API. But that was very, very long
    time ago.
    
    So I fixed the stale check on ol_state.status which is never set
    until much later inside the call to generic layer.
    
    While at it I converted the BUG_ONs to WARN_ONs because it could
    be data corruption but otherwise it will not crush the Kernel.
    Better continue to be able to debug it better. (And added missing
    information to the WARN_ON)
    
    Congratulation, I've successfully ran all tests over
    panfs-export/panfs_shim over real Panasas HW. With latest code.
    [ This is with the new panfs-export that is also compatible with
      the std objects layout driver. Patches to that will follow]
    
    TODO:
      I should also simulate/cause some IO errors and see that
      errors are reported at layout_return
    
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 422e0e67b2933a47afd2e426eee1ff8922de4135
Author: Tao Guo <guotao@nrchpc.ac.cn>
Date:   Tue May 25 16:33:52 2010 +0300

    pnfs: unlock lo_lock before calling layoutdriver's setup_layoutcommit
    
    So in blocklayoutdriver, we can use GFP_KERNEL to do memory
    allocation in bl_setup_layoutcommit().
    
    The state protected by the lo_lock here is clear now, which is the
    layout_commit's position and state. .i.e write_begin/end_pos,
    nfsi->lo_cred, and the call to pnfs_get_layout_stateid.
    
    Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
    Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit a19e718c6be6b1e10627f1985483b9cff2bca53b
Author: Andy Adamson <andros@netapp.com>
Date:   Mon May 24 14:28:46 2010 -0400

    pnfs-submit: replace layoutcommit_ctx with rpc_cred
    
    Taking a reference on the nfs_open_context to signal that a layoutcommit is
    needed is problematic because the last reference to the context triggers a
    close (nfs_release).  But, if the layout holds a reference on the
    nfs_open_context, then close will not be triggered.
    
    Since we only use the rpc credential from the layoutcommit_ctx, replace the
    layoutcommit_ctx with the rpc_cred.
    
    Hold a reference on the rpc_cred until the layoutcommit rpc returns.
    
    If the layoutdriver fails to setup the layoutcommit, clear the layoutcommit
    properties and put the credential.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Tested-by: Boaz Harrosh <bharrosh@panasas.com>
    [s/do_layoutcommit/layoutcommit_needed/]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit d947cd6af78f5426bd6833d513df4aa95e7a116e
Author: Benny Halevy <bhalevy@panasas.com>
Date:   Wed Apr 14 19:05:13 2010 +0300

    pnfs: async layout return
    
    FIXME: currently there's only one path that requires async layout return
    to avoid blocking of the rpciod like the stack below.
    
    We really neee the pnfs state machine instead.
    
    rpciod/0      D 0000003d8c2d83b0     0  1029      2 0x00000000
    778ccdd0 60264f00 77a6a000 778ccb20 77a6ba20 6001375b 77a6ba20 77a6a000
           77a6a000 778cc8a0 77a6ba70 601b192f 77a6ba50 601b35a6 6ed537f0 77a6a000
           77a6bb00 63506fd8 7b1870c8 77a6bb10 77a6ba90 7b187100 63506fd8 77a6a000
    Call Trace:
    77a6b9f8:  [<6001375b>] _switch_to+0x5e/0xae
    77a6ba28:  [<601b192f>] schedule+0x1dd/0x21b
    77a6ba38:  [<601b35a6>] _raw_spin_unlock_irqrestore+0x18/0x1c
    77a6ba60:  [<7b1870c8>] rpc_wait_bit_killable+0x0/0x3c [sunrpc]
    77a6ba78:  [<7b187100>] rpc_wait_bit_killable+0x38/0x3c [sunrpc]
    77a6ba98:  [<601b1d9f>] __wait_on_bit+0x43/0x76
    77a6bae8:  [<601b1e43>] out_of_line_wait_on_bit+0x71/0x7c
    77a6baf8:  [<7b1870c8>] rpc_wait_bit_killable+0x0/0x3c [sunrpc]
    77a6bb20:  [<600430d6>] wake_bit_function+0x0/0x2e
    77a6bb68:  [<7b18709d>] __rpc_wait_for_completion_task+0x34/0x36 [sunrpc]
    77a6bb78:  [<7bf36048>] nfs4_wait_for_completion_rpc_task+0xb/0xd [nfs]
    77a6bb88:  [<7bf369ac>] pnfs4_proc_layoutreturn+0xae/0xe6 [nfs]
    77a6bbc8:  [<6007c8b1>] kmem_cache_alloc+0xaf/0xbe
    77a6bc08:  [<7bf4dc39>] _pnfs_return_layout+0x450/0x4d4 [nfs]
    77a6bc38:  [<7bf3cb79>] decode_attr_time+0x17/0x4d [nfs]
    77a6bc58:  [<7bf429d7>] decode_getfattr+0xaae/0xc02 [nfs]
    77a6bcb8:  [<7bf4601b>] __nfs4_close+0x15d/0x17a [nfs]
    77a6bd28:  [<7bf46053>] nfs4_close_state+0xb/0xd [nfs]
    77a6bd38:  [<7bf34183>] nfs4_close_context+0x26/0x28 [nfs]
    77a6bd48:  [<7bf2315c>] __put_nfs_open_context+0x79/0xa1 [nfs]
    77a6bd78:  [<7bf23227>] put_nfs_open_context+0xb/0xd [nfs]
    77a6bd88:  [<7bf4b763>] pnfs_layoutcommit_done+0xa5/0xad [nfs]
    77a6bdb8:  [<7bf3b12e>] pnfs_layoutcommit_rpc_done+0x39/0x56 [nfs]
    77a6bde8:  [<7b18712b>] rpc_exit_task+0x27/0x52 [sunrpc]
    77a6be08:  [<7b187817>] __rpc_execute+0x88/0x23a [sunrpc]
    77a6be30:  [<7b1879ee>] rpc_async_schedule+0x0/0x12 [sunrpc]
    77a6be48:  [<7b1879fe>] rpc_async_schedule+0x10/0x12 [sunrpc]
    77a6be58:  [<6003fc45>] worker_thread+0x114/0x1a5
    77a6be80:  [<600430a2>] autoremove_wake_function+0x0/0x34
    77a6beb8:  [<6003fb31>] worker_thread+0x0/0x1a5
    77a6bed8:  [<60042cf7>] kthread+0x8e/0x96
    77a6bf48:  [<60021429>] run_kernel_thread+0x41/0x4a
    77a6bf58:  [<60042c69>] kthread+0x0/0x96
    77a6bf98:  [<60021410>] run_kernel_thread+0x28/0x4a
    77a6bfc8:  [<600136d3>] new_thread_handler+0x71/0x9b
    
    [missing from FIXME: async layout return]
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>

commit 7ccc11a731bc2f8021add9907b89654c9146bb32
Author: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
Date:   Tue May 11 16:59:44 2010 +0800

    pnfs-submit: send layoutcommit until IO completed when return layout
    
    If we call layoutcommit before IO completed, then some extents we are
    writing may not be in the commit list. When we return layout, they
    may not get a chance to be committed to server.
    
    Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
    Signed-off-by: Benny Halevy <bhalevy@panasas.com>
