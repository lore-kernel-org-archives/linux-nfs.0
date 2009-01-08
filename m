From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs client lockdep warning
Date: Thu, 8 Jan 2009 16:20:56 -0500
Message-ID: <20090108212056.GF19312@fieldses.org>
References: <20090108203658.GE19312@fieldses.org> <1231447707.7179.10.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
To: netdev@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:53826 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754521AbZAHVU6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 16:20:58 -0500
In-Reply-To: <1231447707.7179.10.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is this something known?

--b.

On Thu, Jan 08, 2009 at 03:48:27PM -0500, Trond Myklebust wrote:
> Looks more like one for the networking folks. All this appears to be
> going on deep down in the tcp stack...
> 
> Trond
> 
> 
> On Thu, 2009-01-08 at 15:36 -0500, J. Bruce Fields wrote:
> > I'm seeing this on my test client; I haven't tried to investigate.
> > 
> > --b.
> > 
> > Jan  8 15:29:17 ying3 kernel: =======================================================
> > Jan  8 15:29:17 ying3 kernel: [ INFO: possible circular locking dependency detected ]
> > Jan  8 15:29:17 ying3 kernel: 2.6.28-07532-g393a64e #71
> > Jan  8 15:29:17 ying3 kernel: -------------------------------------------------------
> > Jan  8 15:29:17 ying3 kernel: tlocklfs/3527 is trying to acquire lock:
> > Jan  8 15:29:17 ying3 kernel:  (sk_lock-AF_INET-RPC){--..}, at: [<c076609c>] tcp_sendmsg+0x1c/0xa80
> > Jan  8 15:29:17 ying3 kernel: 
> > Jan  8 15:29:17 ying3 kernel: but task is already holding lock:
> > Jan  8 15:29:17 ying3 kernel:  (&mm->mmap_sem){----}, at: [<c0835fb7>] do_page_fault+0xc7/0x820
> > Jan  8 15:29:17 ying3 kernel: 
> > Jan  8 15:29:17 ying3 kernel: which lock already depends on the new lock.
> > Jan  8 15:29:17 ying3 kernel: 
> > Jan  8 15:29:17 ying3 kernel: 
> > Jan  8 15:29:17 ying3 kernel: the existing dependency chain (in reverse order) is:
> > Jan  8 15:29:17 ying3 kernel: 
> > Jan  8 15:29:17 ying3 kernel: -> #1 (&mm->mmap_sem){----}:
> > Jan  8 15:29:17 ying3 kernel:        [<c024900d>] __lock_acquire+0xfcd/0x18e0
> > Jan  8 15:29:17 ying3 kernel:        [<c024997c>] lock_acquire+0x5c/0x80
> > Jan  8 15:29:17 ying3 kernel:        [<c027dffb>] might_fault+0x7b/0xa0
> > Jan  8 15:29:17 ying3 kernel:        [<c054bb26>] copy_from_user+0x36/0x90
> > Jan  8 15:29:17 ying3 kernel:        [<c0737800>] memcpy_fromiovecend+0x60/0x90
> > Jan  8 15:29:17 ying3 kernel:        [<c075ce9f>] ip_generic_getfrag+0x9f/0xb0
> > Jan  8 15:29:17 ying3 kernel:        [<c075cb6b>] ip_append_data+0x6bb/0x950
> > Jan  8 15:29:17 ying3 kernel:        [<c077cb0d>] udp_sendmsg+0x2bd/0x680
> > Jan  8 15:29:17 ying3 kernel:        [<c07835f9>] inet_sendmsg+0x39/0x70
> > Jan  8 15:29:17 ying3 kernel:        [<c072f0e6>] sock_sendmsg+0xd6/0x100
> > Jan  8 15:29:17 ying3 kernel:        [<c072f485>] kernel_sendmsg+0x35/0x50
> > Jan  8 15:29:17 ying3 kernel:        [<c07da698>] xs_send_kvec+0xa8/0xb0
> > Jan  8 15:29:17 ying3 kernel:        [<c07da711>] xs_sendpages+0x71/0x210
> > Jan  8 15:29:17 ying3 kernel:        [<c07dab30>] xs_udp_send_request+0x40/0x120
> > Jan  8 15:29:17 ying3 kernel:        [<c07d91ff>] xprt_transmit+0x6f/0x280
> > Jan  8 15:29:17 ying3 kernel:        [<c07d6c1f>] call_transmit+0x17f/0x250
> > Jan  8 15:29:17 ying3 kernel:        [<c07dda13>] __rpc_execute+0x73/0x250
> > Jan  8 15:29:17 ying3 kernel:        [<c07ddc0e>] rpc_execute+0x1e/0x30
> > Jan  8 15:29:17 ying3 kernel:        [<c07d7705>] rpc_run_task+0x35/0x70
> > Jan  8 15:29:17 ying3 kernel:        [<c07d7860>] rpc_call_sync+0x40/0x70
> > Jan  8 15:29:17 ying3 kernel:        [<c07e5312>] rpcb_register_call+0xa2/0xd0
> > Jan  8 15:29:17 ying3 kernel:        [<c07e53d2>] rpcb_register+0x92/0xe0
> > Jan  8 15:29:17 ying3 kernel:        [<c07e0446>] svc_unregister+0x66/0xe0
> > Jan  8 15:29:17 ying3 kernel:        [<c07e0c66>] __svc_create+0x1c6/0x1f0
> > Jan  8 15:29:17 ying3 kernel:        [<c07e0e13>] svc_create+0x23/0x30
> > Jan  8 15:29:17 ying3 kernel:        [<c0396293>] nfs_callback_up+0x73/0x1b0
> > Jan  8 15:29:17 ying3 kernel:        [<c036bb95>] nfs_get_client+0x2d5/0x410
> > Jan  8 15:29:17 ying3 kernel:        [<c036bd15>] nfs4_set_client+0x45/0x1e0
> > Jan  8 15:29:17 ying3 kernel:        [<c036c57e>] nfs4_create_server+0xae/0x430
> > Jan  8 15:29:17 ying3 kernel:        [<c0376fda>] nfs4_get_sb+0x34a/0x5d0
> > Jan  8 15:29:17 ying3 kernel:        [<c029663e>] vfs_kern_mount+0x5e/0x130
> > Jan  8 15:29:17 ying3 kernel:        [<c029676e>] do_kern_mount+0x3e/0xe0
> > Jan  8 15:29:17 ying3 kernel:        [<c02aca44>] do_mount+0x434/0x7b0
> > Jan  8 15:29:17 ying3 kernel:        [<c02ace51>] sys_mount+0x91/0xc0
> > Jan  8 15:29:17 ying3 kernel:        [<c02034c5>] sysenter_do_call+0x12/0x35
> > Jan  8 15:29:17 ying3 kernel:        [<ffffffff>] 0xffffffff
> > Jan  8 15:29:17 ying3 kernel: 
> > Jan  8 15:29:17 ying3 kernel: -> #0 (sk_lock-AF_INET-RPC){--..}:
> > Jan  8 15:29:17 ying3 kernel:        [<c024923d>] __lock_acquire+0x11fd/0x18e0
> > Jan  8 15:29:17 ying3 kernel:        [<c024997c>] lock_acquire+0x5c/0x80
> > Jan  8 15:29:17 ying3 kernel:        [<c0731574>] lock_sock_nested+0xc4/0xe0
> > Jan  8 15:29:17 ying3 kernel:        [<c076609c>] tcp_sendmsg+0x1c/0xa80
> > Jan  8 15:29:17 ying3 kernel:        [<c072f0e6>] sock_sendmsg+0xd6/0x100
> > Jan  8 15:29:17 ying3 kernel:        [<c072f485>] kernel_sendmsg+0x35/0x50
> > Jan  8 15:29:17 ying3 kernel:        [<c07da698>] xs_send_kvec+0xa8/0xb0
> > Jan  8 15:29:17 ying3 kernel:        [<c07da711>] xs_sendpages+0x71/0x210
> > Jan  8 15:29:17 ying3 kernel:        [<c07da9d8>] xs_tcp_send_request+0x58/0x170
> > Jan  8 15:29:17 ying3 kernel:        [<c07d91ff>] xprt_transmit+0x6f/0x280
> > Jan  8 15:29:17 ying3 kernel:        [<c07d6c1f>] call_transmit+0x17f/0x250
> > Jan  8 15:29:17 ying3 kernel:        [<c07dda13>] __rpc_execute+0x73/0x250
> > Jan  8 15:29:17 ying3 kernel:        [<c07ddc0e>] rpc_execute+0x1e/0x30
> > Jan  8 15:29:17 ying3 kernel:        [<c07d7705>] rpc_run_task+0x35/0x70
> > Jan  8 15:29:17 ying3 kernel:        [<c037c924>] nfs_read_rpcsetup+0x174/0x1f0
> > Jan  8 15:29:17 ying3 kernel:        [<c037ce8e>] nfs_pagein_one+0x9e/0xe0
> > Jan  8 15:29:17 ying3 kernel:        [<c037a73a>] nfs_pageio_doio+0x3a/0x80
> > Jan  8 15:29:17 ying3 kernel:        [<c037a78d>] nfs_pageio_complete+0xd/0x10
> > Jan  8 15:29:17 ying3 kernel:        [<c037c21c>] nfs_readpages+0xec/0x1d0
> > Jan  8 15:29:17 ying3 kernel:        [<c02735cc>] __do_page_cache_readahead+0x1bc/0x280
> > Jan  8 15:29:17 ying3 kernel:        [<c02736e0>] do_page_cache_readahead+0x50/0x70
> > Jan  8 15:29:17 ying3 kernel:        [<c026b82f>] filemap_fault+0x31f/0x470
> > Jan  8 15:29:17 ying3 kernel:        [<c027e370>] __do_fault+0x40/0x3d0
> > Jan  8 15:29:17 ying3 kernel:        [<c027ff91>] handle_mm_fault+0x111/0x610
> > Jan  8 15:29:17 ying3 kernel:        [<c0836105>] do_page_fault+0x215/0x820
> > Jan  8 15:29:17 ying3 kernel:        [<c0834347>] error_code+0x6f/0x74
> > Jan  8 15:29:17 ying3 kernel:        [<c02caff5>] load_elf_binary+0x8e5/0x1a20
> > Jan  8 15:29:17 ying3 kernel:        [<c02990a3>] search_binary_handler+0x173/0x2f0
> > Jan  8 15:29:17 ying3 kernel:        [<c029a31d>] do_execve+0x1cd/0x220
> > Jan  8 15:29:17 ying3 kernel:        [<c0201793>] sys_execve+0x43/0x70
> > Jan  8 15:29:17 ying3 kernel:        [<c02034c5>] sysenter_do_call+0x12/0x35
> > Jan  8 15:29:17 ying3 kernel:        [<ffffffff>] 0xffffffff
> > Jan  8 15:29:17 ying3 kernel: 
> > Jan  8 15:29:17 ying3 kernel: other info that might help us debug this:
> > Jan  8 15:29:17 ying3 kernel: 
> > Jan  8 15:29:17 ying3 kernel: 2 locks held by tlocklfs/3527:
> > Jan  8 15:29:17 ying3 kernel:  #0:  (&p->cred_exec_mutex){--..}, at: [<c029a1bb>] do_execve+0x6b/0x220
> > Jan  8 15:29:17 ying3 kernel:  #1:  (&mm->mmap_sem){----}, at: [<c0835fb7>] do_page_fault+0xc7/0x820
> > Jan  8 15:29:17 ying3 kernel: 
> > Jan  8 15:29:17 ying3 kernel: stack backtrace:
> > Jan  8 15:29:17 ying3 kernel: Pid: 3527, comm: tlocklfs Not tainted 2.6.28-07532-g393a64e #71
> > Jan  8 15:29:17 ying3 kernel: Call Trace:
> > Jan  8 15:29:17 ying3 kernel:  [<c083091a>] ? printk+0x1d/0x1f
> > Jan  8 15:29:17 ying3 kernel:  [<c0247c18>] print_circular_bug_tail+0xc8/0xd0
> > Jan  8 15:29:17 ying3 kernel:  [<c024923d>] __lock_acquire+0x11fd/0x18e0
> > Jan  8 15:29:17 ying3 kernel:  [<c07314dc>] ? lock_sock_nested+0x2c/0xe0
> > Jan  8 15:29:17 ying3 kernel:  [<c024997c>] lock_acquire+0x5c/0x80
> > Jan  8 15:29:17 ying3 kernel:  [<c076609c>] ? tcp_sendmsg+0x1c/0xa80
> > Jan  8 15:29:17 ying3 kernel:  [<c0731574>] lock_sock_nested+0xc4/0xe0
> > Jan  8 15:29:17 ying3 kernel:  [<c076609c>] ? tcp_sendmsg+0x1c/0xa80
> > Jan  8 15:29:17 ying3 kernel:  [<c0270934>] ? free_hot_cold_page+0x174/0x2a0
> > Jan  8 15:29:17 ying3 kernel:  [<c076609c>] tcp_sendmsg+0x1c/0xa80
> > Jan  8 15:29:17 ying3 kernel:  [<c02451aa>] ? find_usage_backwards+0xaa/0x120
> > Jan  8 15:29:17 ying3 kernel:  [<c0270b86>] ? free_pages+0x46/0x50
> > Jan  8 15:29:17 ying3 kernel:  [<c02451aa>] ? find_usage_backwards+0xaa/0x120
> > Jan  8 15:29:17 ying3 kernel:  [<c02451aa>] ? find_usage_backwards+0xaa/0x120
> > Jan  8 15:29:17 ying3 kernel:  [<c072f0e6>] sock_sendmsg+0xd6/0x100
> > Jan  8 15:29:17 ying3 kernel:  [<c0239280>] ? autoremove_wake_function+0x0/0x50
> > Jan  8 15:29:17 ying3 kernel:  [<c0248ea0>] ? __lock_acquire+0xe60/0x18e0
> > Jan  8 15:29:17 ying3 kernel:  [<c0248ea0>] ? __lock_acquire+0xe60/0x18e0
> > Jan  8 15:29:17 ying3 kernel:  [<c072f485>] kernel_sendmsg+0x35/0x50
> > Jan  8 15:29:17 ying3 kernel:  [<c07da698>] xs_send_kvec+0xa8/0xb0
> > Jan  8 15:29:17 ying3 kernel:  [<c07da711>] xs_sendpages+0x71/0x210
> > Jan  8 15:29:17 ying3 kernel:  [<c055020f>] ? debug_object_deactivate+0xbf/0x100
> > Jan  8 15:29:17 ying3 kernel:  [<c07da9d8>] xs_tcp_send_request+0x58/0x170
> > Jan  8 15:29:17 ying3 kernel:  [<c07d91ff>] xprt_transmit+0x6f/0x280
> > Jan  8 15:29:17 ying3 kernel:  [<c0392760>] ? nfs4_xdr_enc_read+0x0/0x110
> > Jan  8 15:29:17 ying3 kernel:  [<c07d6c1f>] call_transmit+0x17f/0x250
> > Jan  8 15:29:17 ying3 kernel:  [<c07dda13>] __rpc_execute+0x73/0x250
> > Jan  8 15:29:17 ying3 kernel:  [<c0833a9c>] ? _spin_unlock+0x2c/0x50
> > Jan  8 15:29:17 ying3 kernel:  [<c07dd297>] ? rpc_set_active+0x67/0x80
> > Jan  8 15:29:17 ying3 kernel:  [<c07ddc0e>] rpc_execute+0x1e/0x30
> > Jan  8 15:29:17 ying3 kernel:  [<c07d7705>] rpc_run_task+0x35/0x70
> > Jan  8 15:29:17 ying3 kernel:  [<c037c924>] nfs_read_rpcsetup+0x174/0x1f0
> > Jan  8 15:29:17 ying3 kernel:  [<c0290b61>] ? kmem_cache_alloc+0xd1/0x140
> > Jan  8 15:29:17 ying3 kernel:  [<c026d583>] ? mempool_alloc_slab+0x13/0x20
> > Jan  8 15:29:17 ying3 last message repeated 2 times
> > Jan  8 15:29:17 ying3 kernel:  [<c037ce8e>] nfs_pagein_one+0x9e/0xe0
> > Jan  8 15:29:17 ying3 kernel:  [<c037a73a>] nfs_pageio_doio+0x3a/0x80
> > Jan  8 15:29:17 ying3 kernel:  [<c037a78d>] nfs_pageio_complete+0xd/0x10
> > Jan  8 15:29:17 ying3 kernel:  [<c037c21c>] nfs_readpages+0xec/0x1d0
> > Jan  8 15:29:17 ying3 kernel:  [<c02711c3>] ? __alloc_pages_internal+0xc3/0x4d0
> > Jan  8 15:29:17 ying3 kernel:  [<c037cdf0>] ? nfs_pagein_one+0x0/0xe0
> > Jan  8 15:29:17 ying3 kernel:  [<c037c130>] ? nfs_readpages+0x0/0x1d0
> > Jan  8 15:29:17 ying3 kernel:  [<c02735cc>] __do_page_cache_readahead+0x1bc/0x280
> > Jan  8 15:29:17 ying3 kernel:  [<c02734d5>] ? __do_page_cache_readahead+0xc5/0x280
> > Jan  8 15:29:17 ying3 kernel:  [<c02736e0>] do_page_cache_readahead+0x50/0x70
> > Jan  8 15:29:17 ying3 kernel:  [<c026b82f>] filemap_fault+0x31f/0x470
> > Jan  8 15:29:17 ying3 kernel:  [<c027e370>] __do_fault+0x40/0x3d0
> > Jan  8 15:29:17 ying3 kernel:  [<c0833a9c>] ? _spin_unlock+0x2c/0x50
> > Jan  8 15:29:17 ying3 kernel:  [<c027ff91>] handle_mm_fault+0x111/0x610
> > Jan  8 15:29:17 ying3 kernel:  [<c0835fb7>] ? do_page_fault+0xc7/0x820
> > Jan  8 15:29:17 ying3 kernel:  [<c023cd8d>] ? down_read_trylock+0x5d/0x70
> > Jan  8 15:29:17 ying3 kernel:  [<c0836105>] do_page_fault+0x215/0x820
> > Jan  8 15:29:17 ying3 kernel:  [<c0546741>] ? prio_tree_insert+0x211/0x290
> > Jan  8 15:29:17 ying3 kernel:  [<c0833a9c>] ? _spin_unlock+0x2c/0x50
> > Jan  8 15:29:17 ying3 kernel:  [<c0283a52>] ? vma_link+0x82/0xa0
> > Jan  8 15:29:17 ying3 kernel:  [<c0284fd2>] ? mmap_region+0x2d2/0x4f0
> > Jan  8 15:29:17 ying3 kernel:  [<c027dfca>] ? might_fault+0x4a/0xa0
> > Jan  8 15:29:17 ying3 kernel:  [<c0835ef0>] ? do_page_fault+0x0/0x820
> > Jan  8 15:29:17 ying3 kernel:  [<c0834347>] error_code+0x6f/0x74
> > Jan  8 15:29:17 ying3 kernel:  [<c027007b>] ? __free_pages_ok+0x27b/0x480
> > Jan  8 15:29:17 ying3 kernel:  [<c054b9b7>] ? clear_user+0x47/0x60
> > Jan  8 15:29:17 ying3 kernel:  [<c02caff5>] load_elf_binary+0x8e5/0x1a20
> > Jan  8 15:29:17 ying3 kernel:  [<c0247411>] ? mark_held_locks+0x41/0x80
> > Jan  8 15:29:17 ying3 kernel:  [<c0833a55>] ? _spin_unlock_irqrestore+0x55/0x70
> > Jan  8 15:29:17 ying3 kernel:  [<c0247651>] ? trace_hardirqs_on_caller+0x141/0x1a0
> > Jan  8 15:29:17 ying3 kernel:  [<c0298f8f>] ? search_binary_handler+0x5f/0x2f0
> > Jan  8 15:29:17 ying3 kernel:  [<c02990a3>] search_binary_handler+0x173/0x2f0
> > Jan  8 15:29:17 ying3 kernel:  [<c02ca710>] ? load_elf_binary+0x0/0x1a20
> > Jan  8 15:29:17 ying3 kernel:  [<c029a31d>] do_execve+0x1cd/0x220
> > Jan  8 15:29:17 ying3 kernel:  [<c0201793>] sys_execve+0x43/0x70
> > Jan  8 15:29:17 ying3 kernel:  [<c02034c5>] sysenter_do_call+0x12/0x35
> > Jan  8 15:29:26 ying3 kernel: tlocklfs used greatest stack depth: 4252 bytes left
> > Jan  8 15:29:55 ying3 kernel: aoe: 00188b809a6e e2.3 v400f has 2048000 sectors
> > Jan  8 15:29:55 ying3 kernel:  etherd/e2.3: unknown partition table
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
