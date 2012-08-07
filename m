Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44856 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754193Ab2HGNzS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 09:55:18 -0400
Message-ID: <50211E42.6040808@netapp.com>
Date: Tue, 07 Aug 2012 09:55:14 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Joerg Roedel <joerg.roedel@amd.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, joro@8bytes.org, wdauchy@gmail.com
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
References: <20120807134156.GP1996@amd.com>
In-Reply-To: <20120807134156.GP1996@amd.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/07/2012 09:41 AM, Joerg Roedel wrote:
> Hi,
> 
> starting with Linux 3.6-rc1 I experience this BUG on one of my test
> machines. Please let me know if you need any additional information.

I think this is the same bug that William Dauchy has been hitting.  Do you have a reproducer for this?  I haven't been able to trigger it on my own :(.

- Bryan

> 
> [   20.271810] ------------[ cut here ]------------
> [   20.276869] kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
> [   20.284306] invalid opcode: 0000 [#1] SMP
> [   20.288806] Modules linked in: nfs4 auth_rpcgss nfs fscache lockd sunrpc kvm_intel radeon kvm ttm drm_kms_helper i7core_edac drm edac_core joydev hpilo psmouse hid_generic i2c_algo_bit serio_raw usbhid hid bnx2
> [   20.309466] CPU 2
> [   20.311476] Pid: 1073, comm: mount.nfs Not tainted 3.6.0-rc1 #24 HP ProLiant DL360 G7
> [   20.320264] RIP: 0010:[<ffffffffa029108b>]  [<ffffffffa029108b>] nfs_idmap_legacy_upcall+0x34b/0x350 [nfs4]
> [   20.320266] RSP: 0018:ffff880214e333e8  EFLAGS: 00010286
> [   20.320267] RAX: 0000000000000010 RBX: ffff880211f22540 RCX: 0000000000000000
> [   20.320268] RDX: 0000000000000000 RSI: ffff880216ba6ef4 RDI: ffff880211f22552
> [   20.320269] RBP: ffff880214e33428 R08: 000000000000003a R09: ffff880214e33380
> [   20.320270] R10: 000000002e8cc855 R11: 000000001fce9892 R12: ffff8802130c1bc0
> [   20.320271] R13: ffff880216baa0c0 R14: ffff880415b78280 R15: 0000000000000010
> [   20.320273] FS:  00007fe6d4208720(0000) GS:ffff880217c20000(0000) knlGS:0000000000000000
> [   20.320274] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [   20.320275] CR2: 00007fa82360f6c0 CR3: 0000000216399000 CR4: 00000000000007e0
> [   20.320276] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [   20.320277] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [   20.320279] Process mount.nfs (pid: 1073, threadinfo ffff880214e32000, task ffff880213198000)
> [   20.320280] Stack:
> [   20.320282]  ffff880216ba6ee4 ffff880216ba6ef4 ffff880214e33428 ffff880216baa0c0
> [   20.320284]  ffff880211f22b40 ffff880211f226c0 0000000000000000 ffffffffa0296ddc
> [   20.320286]  ffff880214e334c8 ffffffff812a35b7 0000000000000000 ffff880415517080
> [   20.320287] Call Trace:
> [   20.320294]  [<ffffffff812a35b7>] request_key_and_link+0x2e7/0x410
> [   20.320297]  [<ffffffff812a374e>] request_key_with_auxdata+0x1e/0x70
> [   20.320304]  [<ffffffffa0291166>] nfs_idmap_request_key+0xd6/0x1b0 [nfs4]
> [   20.320310]  [<ffffffffa029143b>] nfs_idmap_lookup_id+0xeb/0x110 [nfs4]
> [   20.320316]  [<ffffffffa029166e>] ? nfs_map_string_to_numeric+0x3e/0xb0 [nfs4]
> [   20.320322]  [<ffffffffa0291e5c>] nfs_map_group_to_gid+0x5c/0x80 [nfs4]
> [   20.320327]  [<ffffffffa028bca1>] decode_getfattr_attrs+0xb71/0xb90 [nfs4]
> [   20.320331]  [<ffffffff810135ca>] ? __switch_to+0x17a/0x410
> [   20.320336]  [<ffffffffa028bd41>] decode_getfattr_generic.constprop.71+0x81/0xb0 [nfs4]
> [   20.320341]  [<ffffffffa028bfc0>] ? nfs4_xdr_dec_link+0xd0/0xd0 [nfs4]
> [   20.320346]  [<ffffffffa028bd83>] decode_getfattr+0x13/0x20 [nfs4]
> [   20.320350]  [<ffffffffa028c02b>] nfs4_xdr_dec_lookup_root+0x6b/0x70 [nfs4]
> [   20.320355]  [<ffffffffa028bfc0>] ? nfs4_xdr_dec_link+0xd0/0xd0 [nfs4]
> [   20.320370]  [<ffffffffa020e195>] rpcauth_unwrap_resp+0x65/0x70 [sunrpc]
> [   20.320377]  [<ffffffffa0203918>] call_decode+0x308/0x400 [sunrpc]
> [   20.320381]  [<ffffffff81079a70>] ? autoremove_wake_function+0x40/0x40
> [   20.320391]  [<ffffffffa020c6a0>] __rpc_execute+0x70/0x2c0 [sunrpc]
> [   20.320397]  [<ffffffffa0203610>] ? call_transmit_status+0xd0/0xd0 [sunrpc]
> [   20.320404]  [<ffffffffa0203610>] ? call_transmit_status+0xd0/0xd0 [sunrpc]
> [   20.320413]  [<ffffffffa020cf3f>] rpc_execute+0x4f/0xb0 [sunrpc]
> [   20.320420]  [<ffffffffa0205215>] rpc_run_task+0x75/0x90 [sunrpc]
> [   20.320427]  [<ffffffffa0205333>] rpc_call_sync+0x43/0x70 [sunrpc]
> [   20.320431]  [<ffffffffa027f393>] _nfs4_call_sync+0x13/0x20 [nfs4]
> [   20.320435]  [<ffffffffa028230c>] _nfs4_lookup_root.isra.37+0xac/0xc0 [nfs4]
> [   20.320440]  [<ffffffffa028236f>] nfs4_lookup_root+0x4f/0x90 [nfs4]
> [   20.320444]  [<ffffffffa0285c65>] nfs4_proc_get_rootfh+0x35/0xd0 [nfs4]
> [   20.320450]  [<ffffffffa0293a33>] nfs4_get_rootfh+0x33/0xd0 [nfs4]
> [   20.320459]  [<ffffffffa025cee4>] ? nfs_alloc_fattr+0x24/0x80 [nfs]
> [   20.320465]  [<ffffffffa0293b36>] nfs4_server_common_setup+0x66/0xf0 [nfs4]
> [   20.320471]  [<ffffffffa029432d>] nfs4_create_server+0x1bd/0x2e0 [nfs4]
> [   20.320474]  [<ffffffff8116c81d>] ? __kmalloc_track_caller+0x13d/0x190
> [   20.320480]  [<ffffffffa028f808>] nfs4_remote_mount+0x38/0x70 [nfs4]
> [   20.320483]  [<ffffffff8117abe3>] mount_fs+0x43/0x1b0
> [   20.320485]  [<ffffffff81195156>] vfs_kern_mount+0x76/0x120
> [   20.320491]  [<ffffffffa028f785>] nfs_do_root_mount+0x95/0xe0 [nfs4]
> [   20.320497]  [<ffffffffa028fac0>] nfs4_try_mount+0x40/0x60 [nfs4]
> [   20.320504]  [<ffffffffa0262077>] nfs_fs_mount+0x487/0xa40 [nfs]
> [   20.320512]  [<ffffffffa02619e0>] ? nfs_clone_super+0x140/0x140 [nfs]
> [   20.320519]  [<ffffffffa0260270>] ? nfs_clone_sb_security+0x60/0x60 [nfs]
> [   20.320521]  [<ffffffff8117abe3>] mount_fs+0x43/0x1b0
> [   20.320523]  [<ffffffff811942c3>] ? find_filesystem+0x63/0x80
> [   20.320526]  [<ffffffff81195156>] vfs_kern_mount+0x76/0x120
> [   20.320528]  [<ffffffff811959c4>] do_kern_mount+0x54/0x110
> [   20.320530]  [<ffffffff81197424>] do_mount+0x1a4/0x8a0
> [   20.320533]  [<ffffffff811970fa>] ? copy_mount_options+0x3a/0x170
> [   20.320535]  [<ffffffff81197bb0>] sys_mount+0x90/0xe0
> [   20.320538]  [<ffffffff81620ba9>] system_call_fastpath+0x16/0x1b
> [   20.320559] Code: ff 0f 1f 80 00 00 00 00 66 c7 07 00 00 83 ea 02 48 83 c7 02 e9 5e fd ff ff 0f 1f 80 00 00 00 00 41 bf f4 ff ff ff e9 0b fe ff ff <0f> 0b 0f 1f 00 55 48 89 e5 48 83 ec 60 48 89 5d d8 4c 89 65 e0
> [   20.320565] RIP  [<ffffffffa029108b>] nfs_idmap_legacy_upcall+0x34b/0x350 [nfs4]
> [   20.320566]  RSP <ffff880214e333e8>
> [   20.320635] ---[ end trace 883f5b90b0291611 ]---
> 

