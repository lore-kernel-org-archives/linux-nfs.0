Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cirse-smtp-out.extra.cea.fr ([132.167.192.148]:43924 "EHLO
        cirse-smtp-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935428AbdEVPh5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2017 11:37:57 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
        by cirse-sys.extra.cea.fr (8.14.7/8.14.7/CEAnet-Internet-out-4.0) with ESMTP id v4MEJnTD033196
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 16:19:49 +0200
Received: from pisaure.intra.cea.fr (localhost [127.0.0.1])
        by localhost (Postfix) with SMTP id 2C753203E0C
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 16:19:48 +0200 (CEST)
Received: from muguet2.intra.cea.fr (muguet2.intra.cea.fr [132.166.192.7])
        by pisaure.intra.cea.fr (Postfix) with ESMTP id 373F6203563
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 16:19:46 +0200 (CEST)
Received: from zia.cdc.esteban.ctsi (out.dam.intra.cea.fr [132.165.76.10])
        by muguet2.intra.cea.fr (8.15.2/8.15.2/CEAnet-Intranet-out-1.4) with SMTP id v4MEJjOE010348
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 16:19:45 +0200
Date: Mon, 22 May 2017 16:19:29 +0200
From: Dominique Martinet <dominique.martinet@cea.fr>
To: <linux-nfs@vger.kernel.org>
Subject: NULL deref in nfs4_put_deviceid_node
Message-ID: <20170522141929.GA2079@u-isr-cdi-08>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi list,


I've got this oops on 4.12-rc1:

[ 1545.290236] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[ 1545.292492] IP: nfs4_put_deviceid_node+0xa/0x80 [nfsv4]
[ 1545.294048] PGD 35238067 
[ 1545.294049] P4D 35238067 
[ 1545.294864] PUD 371b7067
[ 1545.295679] PMD 0 
[ 1545.296466]
[ 1545.297490] Oops: 0000 [#1] SMP
[ 1545.298349] Modules linked in: nfs_layout_nfsv41_files des_generic rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache ip6t_rpfiltect_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrpv6 nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nfangle iptable_security iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter nfsd nfs_acl lockd ppdev parlloon i2c_piix4 parport pcspkr auth_rpcgss grace sunrpc ip_tables xfs libcrc32c sd_mod ata_generic pata_acpi cirrus drm_kms_helpelrect sysimgblt fb_sys_fops ttm drm ata_piix libata virtio_net virtio_pci
[ 1545.315291]  virtio_ring serio_raw i2c_core virtio floppy dm_mirror dm_region_hash dm_log dm_mod
[ 1545.317294] CPU: 2 PID: 74 Comm: kswapd0 Not tainted 4.12.0-rc1 #1
[ 1545.318682] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
[ 1545.319982] task: ffff92d4f66e9540 task.stack: ffffa33c40470000
[ 1545.321347] RIP: 0010:nfs4_put_deviceid_node+0xa/0x80 [nfsv4]
[ 1545.322585] RSP: 0018:ffffa33c40473af0 EFLAGS: 00010246
[ 1545.323703] RAX: ffffffffc07cb060 RBX: ffff92d4f86a7840 RCX: dead000000000200
[ 1545.325224] RDX: ffffa33c40473b60 RSI: ffffa33c40473b60 RDI: 0000000000000000
[ 1545.326736] RBP: ffffa33c40473af8 R08: ffffa33c40473a90 R09: 0000000000000000
[ 1545.328260] R10: ffff92d4fbd46408 R11: 0000000000000000 R12: ffffa33c40473b60
[ 1545.329780] R13: ffffa33c40473b60 R14: ffff92d4fbd46308 R15: ffff92d4fbd46280
[ 1545.331307] FS:  0000000000000000(0000) GS:ffff92d4ffc80000(0000) knlGS:0000000000000000
[ 1545.332937] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 1545.334115] CR2: 0000000000000030 CR3: 00000000371b5000 CR4: 00000000000006e0
[ 1545.335542] Call Trace:
[ 1545.336055]  nfs4_fl_put_deviceid+0xe/0x10 [nfs_layout_nfsv41_files]
[ 1545.337354]  filelayout_free_lseg+0x24/0x90 [nfs_layout_nfsv41_files]
[ 1545.338668]  pnfs_free_lseg_list+0x83/0xa0 [nfsv4]
[ 1545.339657]  _pnfs_return_layout+0x121/0x2a0 [nfsv4]
[ 1545.340673]  ? nfs_inode_detach_delegation+0x28/0x70 [nfsv4]
[ 1545.341803]  nfs4_evict_inode+0x4d/0x70 [nfsv4]
[ 1545.342681]  evict+0xd3/0x1a0
[ 1545.343263]  dispose_list+0x4d/0x70
[ 1545.343938]  prune_icache_sb+0x5a/0x80
[ 1545.344666]  super_cache_scan+0x13e/0x190
[ 1545.345441]  shrink_slab+0x261/0x470
[ 1545.346141]  shrink_node+0x2f7/0x310
[ 1545.346827]  kswapd+0x2cf/0x730  
[ 1545.347445]  kthread+0x109/0x140 
[ 1545.348066]  ? mem_cgroup_shrink_node+0x180/0x180
[ 1545.348978]  ? kthread_park+0x60/0x60
[ 1545.349694]  ret_from_fork+0x2c/0x40
[ 1545.350387] Code: 48 89 d7 e8 19 00 00 00 5b 41 5c 41 5d 5d c3 48 c7 c7 c0 b3 8f c0 ff 14 25 08 5a c3 9a eb e9 66 90 0f 1f 44 00 00 55 48 89 e5 53 <48> 8b 47 30 48 89 fb a8 04 75 20 f0 ff 4b 60 74 05 5b 31 c0 5d 
[ 1545.353897] RIP: nfs4_put_deviceid_node+0xa/0x80 [nfsv4] RSP: ffffa33c40473af0
[ 1545.355207] CR2: 0000000000000030
[ 1545.355817] ---[ end trace 1c04f66c677f552a ]---
[ 1545.356657] Kernel panic - not syncing: Fatal exception
[ 1545.359505] Kernel Offset: 0x19000000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[ 1545.361471] ---[ end Kernel panic - not syncing: Fatal exception


My old kexec-kdump scripts can't handle newer kernels, and gdb with
qemu's gdbserver doesn't seem to work much better, so can't give much
trace right now (working on it...), but this happens when I try to
reproduce a gss rpc hang I have on older kernels as follow:
 - setup a mount with nfs 4.1, sec=krb5, server is a single netapp.
The client has low memory (1GB) to help flushing cache more easily.

 - as user1 with a short ticket lifetime trigger many layout get (I'm
running "find /mnt/share -type f -exec less -f {} \; >& /dev/null")

 - once ticket expires, log in as another user and do stuff to evict
inodes (I try to compile something in the same mount)

I don't *think* I'm getting this crash if I start doing activity/evicts
before the ticket expires, so it's probably related.


----------------8<------
The hang used to be that rpc.gssd does a syscall that tries to allocate
memory and needs to evict an inode, that needs to contact rpc.gssd for a
new krb5_cred_init... which is now stuck.
Exact trace as follow, if it rings a bell:
PID: 28082  TASK: ffff880079fd2f10  CPU: 6   COMMAND: "rpc.gssd"
 #0 [ffff88000cb83170] __schedule at ffffffff8168bb15
 #1 [ffff88000cb831d8] schedule at ffffffff8168c169
 #2 [ffff88000cb831e8] gss_cred_init at ffffffffa030a737 [auth_rpcgss]
 #3 [ffff88000cb832b0] rpcauth_lookup_credcache at ffffffffa02a7789  [sunrpc]
 #4 [ffff88000cb83330] gss_lookup_cred at ffffffffa03085b3 [auth_rpcgss]
 #5 [ffff88000cb83340] generic_bind_cred at ffffffffa02a83dc [sunrpc]
 #6 [ffff88000cb83350] rpcauth_refreshcred at ffffffffa02a7bd1 [sunrpc]
 #7 [ffff88000cb833b0] call_refresh at ffffffffa0296cdc [sunrpc]
 #8 [ffff88000cb833c8] __rpc_execute at ffffffffa02a32a4 [sunrpc]
 #9 [ffff88000cb83430] rpc_execute at ffffffffa02a639e [sunrpc]
#10 [ffff88000cb83460] rpc_run_task at ffffffffa0299310 [sunrpc]
#11 [ffff88000cb83480] nfs4_proc_layoutreturn at ffffffffa04e25c4 [nfsv4]
#12 [ffff88000cb83518] pnfs_send_layoutreturn at ffffffffa0506967 [nfsv4]
#13 [ffff88000cb83548] _pnfs_return_layout at ffffffffa0506e3a [nfsv4]
#14 [ffff88000cb835f0] nfs4_evict_inode at ffffffffa04f330d [nfsv4]
#15 [ffff88000cb83608] evict at ffffffff8121a767
#16 [ffff88000cb83630] dispose_list at ffffffff8121a86e
#17 [ffff88000cb83658] prune_icache_sb at ffffffff8121b7b3
#18 [ffff88000cb836c0] prune_super at ffffffff81200ee3
#19 [ffff88000cb836f8] shrink_slab at ffffffff81194723
#20 [ffff88000cb83798] do_try_to_free_pages at ffffffff81197a22
#21 [ffff88000cb83810] try_to_free_pages at ffffffff81197c3c
#22 [ffff88000cb838a8] __alloc_pages_slowpath at ffffffff816823f8
#23 [ffff88000cb83998] __alloc_pages_nodemask at ffffffff8118b5c5
#24 [ffff88000cb83a48] alloc_pages_vma at ffffffff811d272a
#25 [ffff88000cb83ab0] handle_mm_fault at ffffffff811b19ef
#26 [ffff88000cb83b48] __do_page_fault at ffffffff81692644
#27 [ffff88000cb83ba8] trace_do_page_fault at ffffffff81692a26
#28 [ffff88000cb83be8] do_async_page_fault at ffffffff816920cb
#29 [ffff88000cb83c00] async_page_fault at ffffffff8168ebb8
    [exception RIP: file_read_actor+60]
    RIP: ffffffff8117ffcc  RSP: ffff88000cb83cb0  RFLAGS: 00010246
    RAX: 0000000000000000  RBX: ffff88000cb83d68  RCX: 00007f7017b82000
    RDX: 0000000000000000  RSI: ffffea0001db1f80  RDI: ffff88000cb83d68
    RBP: ffff88000cb83ce8   R8: 0000000000000001   R9: ffffea0001db1f9c
    R10: ffff88000cb83cb8  R11: 0000000000000202  R12: 00000000000007c8
    R13: 00000000000007c8  R14: 0000000000001000  R15: 00000000000007c8
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
#30 [ffff88000cb83cf0] generic_file_aio_read at ffffffff81182a9b
#31 [ffff88000cb83dc0] xfs_file_aio_read at ffffffffa01f6cad [xfs]
#32 [ffff88000cb83e28] do_sync_read at ffffffff811fde6d
#33 [ffff88000cb83f00] vfs_read at ffffffff811fe61e
#34 [ffff88000cb83f38] sys_read at ffffffff811ff1ef
#35 [ffff88000cb83f80] system_call_fastpath at ffffffff81697189
    RIP: 00007f7016692c00  RSP: 00007f7014e82d98  RFLAGS: 00010246
    RAX: 0000000000000000  RBX: ffffffff81697189  RCX: 0000000000000024
    RDX: 0000000000001000  RSI: 00007f7017b82000  RDI: 000000000000000e
    RBP: 000000000000000a   R8: ffffffffffffffff   R9: 0000000000000000
    R10: 0000000000000022  R11: 0000000000000202  R12: 00007f7010131670
    R13: 0000000000000000  R14: 0000000000000000  R15: 00007f7010131670
    ORIG_RAX: 0000000000000000  CS: 0033  SS: 002b

RDI is the fd number, the corresponding file is /etc/passwd (so just a
local read)
------------8<---------



Anyway, I'm a bit stuck with kexec requiring a newer version of dracut
requiring a newer version of systemd... So i'll setup a shinier VM to
get a proper dump and post more info once I get them.

Was about to say reproducing is easy but doesn't look like sure-shot as
I'm hitting other bugs too, but feel free to suggest patchs/some
reasonable level of debug logs/etc while I improve the environment.


Thanks,
-- 
Dominique
