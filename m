Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59990 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750856AbcEYUKW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 16:10:22 -0400
Date: Wed, 25 May 2016 16:10:20 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: "suspicious RCU usage"
Message-ID: <20160525201020.GB15795@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Other user_key_payload() are preceded by a down_read(&key->sem); do we
need that in nfs_idmap_get_key() too?


--b.

[  123.609400] ===============================
[  123.609700] [ INFO: suspicious RCU usage. ]
[  123.609992] 4.6.0-12295-gecc5fbd #540 Not tainted
[  123.610326] -------------------------------
[  123.610598] include/keys/user-type.h:53 suspicious rcu_dereference_protected() usage!
[  123.611119] 
other info that might help us debug this:

[  123.611525] 
rcu_scheduler_active = 1, debug_locks = 0
[  123.611869] 1 lock held by mount.nfs/4971:
[  123.612190]  #0:  (rcu_read_lock){......}, at: [<ffffffffa01971e9>] nfs_idmap_get_key+0xe9/0x2f0 [nfsv4]
[  123.613295] 
stack backtrace:
[  123.613493] CPU: 0 PID: 4971 Comm: mount.nfs Not tainted 4.6.0-12295-gecc5fbd #540
[  123.614089] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.2-20150714_191134- 04/01/2014
[  123.614927]  0000000000000000 ffff8800baa87478 ffffffff8164e5d5 ffff88023461d500
[  123.615823]  0000000000000001 ffff8800baa874a8 ffffffff810cf867 0000000000000000
[  123.616175]  ffff880236bf4440 ffffffffa01bd74e 0000000000000003 ffff8800baa87510
[  123.616175] Call Trace:
[  123.616175]  [<ffffffff8164e5d5>] dump_stack+0x67/0x92
[  123.616175]  [<ffffffff810cf867>] lockdep_rcu_suspicious+0xd7/0x110
[  123.616175]  [<ffffffffa019736e>] nfs_idmap_get_key+0x26e/0x2f0 [nfsv4]
[  123.616175]  [<ffffffffa01971e9>] ? nfs_idmap_get_key+0xe9/0x2f0 [nfsv4]
[  123.616175]  [<ffffffffa0197a58>] nfs_map_name_to_uid+0x158/0x210 [nfsv4]
[  123.616175]  [<ffffffffa001dee7>] ? __read_bytes_from_xdr_buf+0x87/0xa0 [sunrpc]
[  123.616175]  [<ffffffffa018a722>] decode_getfattr_attrs+0x10f2/0x15f0 [nfsv4]
[  123.616175]  [<ffffffffa018e3fc>] decode_getfattr_generic.constprop.96+0x8c/0xe0 [nfsv4]
[  123.616175]  [<ffffffffa018f460>] nfs4_xdr_dec_lookup_root+0x80/0x90 [nfsv4]
[  123.616175]  [<ffffffffa009d797>] gss_unwrap_resp+0xb7/0x2a0 [auth_rpcgss]
[  123.616175]  [<ffffffffa018f3e0>] ? nfs4_xdr_dec_setclientid+0x190/0x190 [nfsv4]
[  123.616175]  [<ffffffffa018f3e0>] ? nfs4_xdr_dec_setclientid+0x190/0x190 [nfsv4]
[  123.616175]  [<ffffffffa0013604>] rpcauth_unwrap_resp+0x54/0xd0 [sunrpc]
[  123.616175]  [<ffffffffa018f3e0>] ? nfs4_xdr_dec_setclientid+0x190/0x190 [nfsv4]
[  123.616175]  [<ffffffffa018f3e0>] ? nfs4_xdr_dec_setclientid+0x190/0x190 [nfsv4]
[  123.616175]  [<ffffffffa0002acf>] call_decode+0x1ef/0x820 [sunrpc]
[  123.616175]  [<ffffffffa00028e0>] ? call_connect_status+0x230/0x230 [sunrpc]
[  123.616175]  [<ffffffffa00028e0>] ? call_connect_status+0x230/0x230 [sunrpc]
[  123.616175]  [<ffffffffa0011762>] __rpc_execute+0xa2/0x5f0 [sunrpc]
[  123.616175]  [<ffffffff810c5935>] ? wake_up_bit+0x25/0x30
[  123.616175]  [<ffffffffa0011f96>] rpc_execute+0x76/0x1a0 [sunrpc]
[  123.616175]  [<ffffffffa0004939>] rpc_run_task+0x109/0x150 [sunrpc]
[  123.616175]  [<ffffffffa0171806>] nfs4_call_sync_sequence+0x56/0x80 [nfsv4]
[  123.616175]  [<ffffffffa017b60d>] _nfs4_lookup_root.isra.38+0xcd/0xe0 [nfsv4]
[  123.616175]  [<ffffffffa017d829>] nfs4_lookup_root+0x79/0x1e0 [nfsv4]
[  123.616175]  [<ffffffffa0013d1f>] ? unx_destroy+0x1f/0x40 [sunrpc]
[  123.616175]  [<ffffffffa017d9ea>] nfs4_lookup_root_sec+0x5a/0x70 [nfsv4]
[  123.616175]  [<ffffffffa017da7c>] nfs4_find_root_sec+0x7c/0xc0 [nfsv4]
[  123.616175]  [<ffffffffa0181719>] nfs4_proc_get_rootfh+0x39/0x90 [nfsv4]
[  123.616175]  [<ffffffffa019ce3a>] nfs4_get_rootfh+0x4a/0x120 [nfsv4]
[  123.616175]  [<ffffffff811c1ab4>] ? kmem_cache_alloc_trace+0x294/0x300
[  123.616175]  [<ffffffffa0125b4f>] ? nfs_alloc_fattr+0x1f/0x70 [nfs]
[  123.616175]  [<ffffffffa019d1cf>] nfs4_server_common_setup+0x9f/0x1d0 [nfsv4]
[  123.616175]  [<ffffffffa019ede4>] nfs4_create_server+0x2b4/0x350 [nfsv4]
[  123.616175]  [<ffffffffa0193d4e>] nfs4_remote_mount+0x2e/0x60 [nfsv4]
[  123.616175]  [<ffffffff811cbcd8>] mount_fs+0x38/0x170
[  123.616175]  [<ffffffff811eb3fb>] vfs_kern_mount+0x6b/0x150
[  123.616175]  [<ffffffffa0193c74>] nfs_do_root_mount+0x84/0xc0 [nfsv4]
[  123.616175]  [<ffffffffa0194044>] nfs4_try_mount+0x44/0xd0 [nfsv4]
[  123.616175]  [<ffffffffa011d387>] ? get_nfs_version+0x27/0x90 [nfs]
[  123.616175]  [<ffffffffa012c91f>] nfs_fs_mount+0x64f/0xd80 [nfs]
[  123.616175]  [<ffffffffa012b420>] ? nfs_remount+0x3c0/0x3c0 [nfs]
[  123.616175]  [<ffffffffa012b710>] ? nfs_clone_super+0x130/0x130 [nfs]
[  123.616175]  [<ffffffff811cbcd8>] mount_fs+0x38/0x170
[  123.616175]  [<ffffffff811eb3fb>] vfs_kern_mount+0x6b/0x150
[  123.616175]  [<ffffffff811ee16e>] do_mount+0x22e/0xee0
[  123.616175]  [<ffffffff811eddc7>] ? copy_mount_options+0xb7/0x210
[  123.616175]  [<ffffffff811ef165>] SyS_mount+0x95/0xe0
[  123.616175]  [<ffffffff81aec465>] entry_SYSCALL_64_fastpath+0x18/0xa8
[  123.689817] mount.nfs (4971) used greatest stack depth: 11320 bytes left

