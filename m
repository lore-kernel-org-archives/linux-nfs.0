Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39726 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbaKJVym (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2014 16:54:42 -0500
Date: Mon, 10 Nov 2014 16:54:41 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: 3.18 lock warnings
Message-ID: <20141110215441.GI32702@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My test client is issuing intermittent warnings like the below.  Is this a
known issue?

I guess the problem is
net/sunrpc/auth_gss/auth_gss.c:gss_stringify_acceptor():

	rcu_read_lock();
	...
	string = kmalloc(acceptor->len + 1, GFP_KERNEL);
	...
	rcu_read_unlock();

introduced by c5e6aecd034e "sunrpc: fix RCU handling of gc_ctx field".

--b.

Nov  7 21:21:40 f20-2 kernel: BUG: sleeping function called from invalid context at mm/slab.c:2846
Nov  7 21:21:40 f20-2 kernel: in_atomic(): 0, irqs_disabled(): 0, pid: 4539, name: mount.nfs
Nov  7 21:21:40 f20-2 kernel: 2 locks held by mount.nfs/4539:
Nov  7 21:21:40 f20-2 kernel: #0:  (nfs_clid_init_mutex){+.+.+.}, at: [<ffffffffa01c0a9a>] nfs4_discover_server_trunking+0x4a/0x2f0 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: #1:  (rcu_read_lock){......}, at: [<ffffffffa00e3185>] gss_stringify_acceptor+0x5/0xb0 [auth_rpcgss]
Nov  7 21:21:40 f20-2 kernel: Preemption disabled at:[<ffffffff81a4f082>] printk+0x4d/0x4f
Nov  7 21:21:40 f20-2 kernel: 
Nov  7 21:21:40 f20-2 kernel: BUG: sleeping function called from invalid context at mm/slab.c:2846
Nov  7 21:21:40 f20-2 kernel: CPU: 3 PID: 4539 Comm: mount.nfs Not tainted 3.18.0-rc1-00013-g5b095e9 #3393
Nov  7 21:21:40 f20-2 kernel: Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
Nov  7 21:21:40 f20-2 kernel: in_atomic(): 0, irqs_disabled(): 0, pid: 4539, name: mount.nfs
Nov  7 21:21:40 f20-2 kernel: 2 locks held by mount.nfs/4539:
Nov  7 21:21:40 f20-2 kernel: #0:  (nfs_clid_init_mutex){+.+.+.}, at: [<ffffffffa01c0a9a>] nfs4_discover_server_trunking+0x4a/0x2f0 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: #1:  (rcu_read_lock){......}, at: [<ffffffffa00e3185>] gss_stringify_acceptor+0x5/0xb0 [auth_rpcgss]
Nov  7 21:21:40 f20-2 kernel: Preemption disabled at:[<ffffffff81a4f082>] printk+0x4d/0x4f
Nov  7 21:21:40 f20-2 kernel: 
Nov  7 21:21:40 f20-2 kernel: CPU: 3 PID: 4539 Comm: mount.nfs Not tainted 3.18.0-rc1-00013-g5b095e9 #3393
Nov  7 21:21:40 f20-2 kernel: Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
Nov  7 21:21:40 f20-2 kernel: ffff880021499390 ffff8800381476a8 ffffffff81a534cf 0000000000000001
Nov  7 21:21:40 f20-2 kernel: 0000000000000000 ffff8800381476c8 ffffffff81097854 00000000000000d0
Nov  7 21:21:40 f20-2 kernel: 0000000000000018 ffff880038147718 ffffffff8118e4f3 0000000020479f00
Nov  7 21:21:40 f20-2 kernel: Call Trace:
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81a534cf>] dump_stack+0x4f/0x7c
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81097854>] __might_sleep+0x114/0x180
Nov  7 21:21:40 f20-2 kernel: [<ffffffff8118e4f3>] __kmalloc+0x1a3/0x280
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa00e31d8>] gss_stringify_acceptor+0x58/0xb0 [auth_rpcgss]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa00e3185>] ? gss_stringify_acceptor+0x5/0xb0 [auth_rpcgss]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa006b438>] rpcauth_stringify_acceptor+0x18/0x30 [sunrpc]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01b0469>] nfs4_proc_setclientid+0x199/0x380 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01b04d0>] ? nfs4_proc_setclientid+0x200/0x380 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01bdf1a>] nfs40_discover_server_trunking+0xda/0x150 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01bde45>] ? nfs40_discover_server_trunking+0x5/0x150 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c0acf>] nfs4_discover_server_trunking+0x7f/0x2f0 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c8e24>] nfs4_init_client+0x104/0x2f0 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01539b4>] nfs_get_client+0x314/0x3f0 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa0153780>] ? nfs_get_client+0xe0/0x3f0 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c83aa>] nfs4_set_client+0x8a/0x110 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa0069708>] ? __rpc_init_priority_wait_queue+0xa8/0xf0 [sunrpc]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c9b2f>] nfs4_create_server+0x12f/0x390 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c1472>] nfs4_remote_mount+0x32/0x60 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81196489>] mount_fs+0x39/0x1b0
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81166145>] ? __alloc_percpu+0x15/0x20
Nov  7 21:21:40 f20-2 kernel: [<ffffffff811b276b>] vfs_kern_mount+0x6b/0x150
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c1396>] nfs_do_root_mount+0x86/0xc0 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c1784>] nfs4_try_mount+0x44/0xc0 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01549b7>] ? get_nfs_version+0x27/0x90 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa0161a2d>] nfs_fs_mount+0x47d/0xd60 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81a59c5e>] ? mutex_unlock+0xe/0x10
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01606a0>] ? nfs_remount+0x430/0x430 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01609c0>] ? nfs_clone_super+0x140/0x140 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81196489>] mount_fs+0x39/0x1b0
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81166145>] ? __alloc_percpu+0x15/0x20
Nov  7 21:21:40 f20-2 kernel: [<ffffffff811b276b>] vfs_kern_mount+0x6b/0x150
Nov  7 21:21:40 f20-2 kernel: [<ffffffff811b5830>] do_mount+0x210/0xbe0
Nov  7 21:21:40 f20-2 kernel: [<ffffffff811b54ca>] ? copy_mount_options+0x3a/0x160
Nov  7 21:21:40 f20-2 kernel: [<ffffffff811b651f>] SyS_mount+0x6f/0xb0
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81a5c852>] system_call_fastpath+0x12/0x17
Nov  7 21:21:40 f20-2 kernel: ffff880021499390 ffff8800381476a8 ffffffff81a534cf 0000000000000001
Nov  7 21:21:40 f20-2 kernel: 0000000000000000 ffff8800381476c8 ffffffff81097854 00000000000000d0
Nov  7 21:21:40 f20-2 kernel: 0000000000000018 ffff880038147718 ffffffff8118e4f3 0000000020479f00
Nov  7 21:21:40 f20-2 kernel: Call Trace:
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81a534cf>] dump_stack+0x4f/0x7c
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81097854>] __might_sleep+0x114/0x180
Nov  7 21:21:40 f20-2 kernel: [<ffffffff8118e4f3>] __kmalloc+0x1a3/0x280
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa00e31d8>] gss_stringify_acceptor+0x58/0xb0 [auth_rpcgss]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa00e3185>] ? gss_stringify_acceptor+0x5/0xb0 [auth_rpcgss]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa006b438>] rpcauth_stringify_acceptor+0x18/0x30 [sunrpc]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01b0469>] nfs4_proc_setclientid+0x199/0x380 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01b04d0>] ? nfs4_proc_setclientid+0x200/0x380 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01bdf1a>] nfs40_discover_server_trunking+0xda/0x150 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01bde45>] ? nfs40_discover_server_trunking+0x5/0x150 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c0acf>] nfs4_discover_server_trunking+0x7f/0x2f0 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c8e24>] nfs4_init_client+0x104/0x2f0 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01539b4>] nfs_get_client+0x314/0x3f0 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa0153780>] ? nfs_get_client+0xe0/0x3f0 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c83aa>] nfs4_set_client+0x8a/0x110 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa0069708>] ? __rpc_init_priority_wait_queue+0xa8/0xf0 [sunrpc]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c9b2f>] nfs4_create_server+0x12f/0x390 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c1472>] nfs4_remote_mount+0x32/0x60 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81196489>] mount_fs+0x39/0x1b0
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81166145>] ? __alloc_percpu+0x15/0x20
Nov  7 21:21:40 f20-2 kernel: [<ffffffff811b276b>] vfs_kern_mount+0x6b/0x150
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c1396>] nfs_do_root_mount+0x86/0xc0 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01c1784>] nfs4_try_mount+0x44/0xc0 [nfsv4]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01549b7>] ? get_nfs_version+0x27/0x90 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa0161a2d>] nfs_fs_mount+0x47d/0xd60 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81a59c5e>] ? mutex_unlock+0xe/0x10
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01606a0>] ? nfs_remount+0x430/0x430 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffffa01609c0>] ? nfs_clone_super+0x140/0x140 [nfs]
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81196489>] mount_fs+0x39/0x1b0
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81166145>] ? __alloc_percpu+0x15/0x20
Nov  7 21:21:40 f20-2 kernel: [<ffffffff811b276b>] vfs_kern_mount+0x6b/0x150
Nov  7 21:21:40 f20-2 kernel: [<ffffffff811b5830>] do_mount+0x210/0xbe0
Nov  7 21:21:40 f20-2 kernel: [<ffffffff811b54ca>] ? copy_mount_options+0x3a/0x160
Nov  7 21:21:40 f20-2 kernel: [<ffffffff811b651f>] SyS_mount+0x6f/0xb0
Nov  7 21:21:40 f20-2 kernel: [<ffffffff81a5c852>] system_call_fastpath+0x12/0x17
Nov  7 21:21:42 f20-2 kernel: mount.nfs (4539) used greatest stack depth: 10344 bytes left
Nov  7 21:21:42 f20-2 kernel: mount.nfs (4539) used greatest stack depth: 10344 bytes left
Nov  7 21:21:42 f20-2 kernel: BUG: sleeping function called from invalid context at mm/slab.c:2846
Nov  7 21:21:42 f20-2 kernel: in_atomic(): 0, irqs_disabled(): 0, pid: 4596, name: 192.168.122.21-
Nov  7 21:21:42 f20-2 kernel: 1 lock held by 192.168.122.21-/4596:
Nov  7 21:21:42 f20-2 kernel: #0:  (rcu_read_lock){......}, at: [<ffffffffa00e3185>] gss_stringify_acceptor+0x5/0xb0 [auth_rpcgss]
Nov  7 21:21:42 f20-2 kernel: Preemption disabled at:[<ffffffff81a4f082>] printk+0x4d/0x4f
