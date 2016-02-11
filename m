Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from MG3.fis.unical.it ([192.167.201.160]:58051 "EHLO
	mg3.fis.unical.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbcBKLD4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Feb 2016 06:03:56 -0500
Message-ID: <1455188078.4536.31.camel@fis.unical.it>
Subject: Re: Kernel crash in Centos 6.6 NEWS using NFS-RDMA
From: Fedele Stabile <fedele.stabile@fis.unical.it>
Reply-To: fedele.stabile@fis.unical.it
To: linux-nfs@vger.kernel.org
Cc: Jack Wang <jack.wang.usish@gmail.com>, chuck.lever@oracle.com
Date: Thu, 11 Feb 2016 11:54:38 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi to all,
I have to add informations to help me solve the problem...
Tomorrow morning I better investigate and noticed that hang is followed
by this messages on /var/log/messages and on console.
This is the commands I execute on the client:

echo 32767 > /proc/sys/sunrpc/rpc_debug
echo 65535 > /proc/sys/sunrpc/nfs_debug
mount -o rdma,port=20049 ib-newton-fe:/data /mnt
client hangs with this message:
....
....
Feb 11 11:39:37 wn007 kernel: RPC: Registered rdma transport module.
Feb 11 11:39:37 wn007 kernel: RPCRDMA Module Init, register RPC RDMA
transport
Feb 11 11:39:37 wn007 kernel: Defaults:
Feb 11 11:39:37 wn007 kernel: 	Slots 32
Feb 11 11:39:37 wn007 kernel: 	MaxInlineRead 1024
Feb 11 11:39:37 wn007 kernel: 	MaxInlineWrite 1024
Feb 11 11:39:37 wn007 kernel: 	Padding 0
Feb 11 11:39:37 wn007 kernel: 	Memreg 5
Feb 11 11:39:37 wn007 kernel: NFS:   parsing nfs mount option
'port=20049'
Feb 11 11:39:37 wn007 kernel: NFS:   parsing nfs mount option 'vers=4'
Feb 11 11:39:37 wn007 kernel: NFS:   parsing nfs mount option
'addr=172.16.1.2'
Feb 11 11:39:37 wn007 kernel: NFS:   parsing nfs mount option
'clientaddr=172.16.2.7'
Feb 11 11:39:37 wn007 kernel: NFS: MNTPATH: '/data'
Feb 11 11:39:37 wn007 kernel: --> nfs4_try_mount()
Feb 11 11:39:37 wn007 kernel: --> nfs4_create_server()
Feb 11 11:39:37 wn007 kernel: --> nfs4_init_server()
Feb 11 11:39:37 wn007 kernel: --> nfs4_set_client()
Feb 11 11:39:37 wn007 kernel: --> nfs_get_client(ib-newton-fe,v4)
Feb 11 11:39:37 wn007 kernel: RPC:       looking up machine cred for
service *
Feb 11 11:39:37 wn007 kernel: NFS: get client cookie
(0xffff88206626d400/0xffff8820653615a0)
Feb 11 11:39:37 wn007 kernel: RPC:       xprt_setup_rdma:
172.16.1.2:20049
Feb 11 11:39:37 wn007 kernel: RPC:       rpcrdma_ia_open: FRMR
registration not supported by HCA
Feb 11 11:39:37 wn007 kernel: RPC:       rpcrdma_ia_open: memory
registration strategy is 4
Feb 11 11:39:37 wn007 kernel: RPC:       rpcrdma_ep_create: requested
max: dtos: send 32 recv 32; iovs: send 2 recv 1
Feb 11 11:39:37 wn007 kernel: RPC:       rpcrdma_buffer_create: wlen =
8192, rlen = 4096
Feb 11 11:39:37 wn007 kernel: RPC:       rpcrdma_buffer_create:
max_requests 32
Feb 11 11:39:37 wn007 kernel: RPC:       created transport
ffff88205b5a4000 with 32 slots
Feb 11 11:39:37 wn007 kernel: RPC:       creating nfs client for ib
-newton-fe (xprt ffff88205b5a4000)
Feb 11 11:39:37 wn007 kernel: RPC:       creating UNIX authenticator
for client ffff882067c5b600
Feb 11 11:39:37 wn007 kernel: RPC:       new task initialized, procpid
4948
Feb 11 11:39:37 wn007 kernel: RPC:       allocated task
ffff882041f01e80
Feb 11 11:39:37 wn007 kernel: RPC:   566 __rpc_execute flags=0x680
Feb 11 11:39:37 wn007 kernel: RPC:   566 call_start nfs4 proc NULL
(sync)
Feb 11 11:39:37 wn007 kernel: RPC:   566 call_reserve (status 0)
Feb 11 11:39:37 wn007 kernel: BUG: unable to handle kernel NULL pointer
dereference at (null)
Feb 11 11:39:37 wn007 kernel: IP: [<(null)>] (null)
Feb 11 11:39:37 wn007 kernel: PGD 0 
Feb 11 11:39:37 wn007 kernel: Oops: 0010 [#1] SMP 
Feb 11 11:39:37 wn007 kernel: last sysfs file:
/sys/module/sunrpc/initstate
Feb 11 11:39:37 wn007 kernel: CPU 14 
Feb 11 11:39:37 wn007 kernel: Modules linked in: xprtrdma(U) 8021q garp
stp llc mptctl mptbase nfs lockd fscache auth_rpcgss nfs_acl sunrpc
smbus(U) ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state
nf_conntrack ip6table_filter ip6_tables rdma_ucm(U) rdma_cm(U) iw_cm(U)
ib_addr(U) ib_srp(U) scsi_transport_srp(U) scsi_tgt ib_ipoib(U)
ib_cm(U) ib_usa(U) ib_uverbs(U) ib_umad(U) iw_nes(U) libcrc32c
iw_cxgb4(U) cxgb4(U) ipv6 iw_cxgb3(U) cxgb3(U) mdio kcopy(U) ib_qib(U)
mlx4_en(U) mlx4_ib(U) ib_sa(U) mlx4_core(U) ib_mthca(U) xfs exportfs
ipmi_devintf ipmi_si ipmi_msghandler iTCO_wdt iTCO_vendor_support
ib_mad(U) ib_core(U) compat(U) sb_edac edac_core lpc_ich mfd_core
shpchp i2c_i801 sg nvidia(P)(U) igb dca i2c_algo_bit i2c_core ptp
pps_core ext4 jbd2 mbcache sd_mod crc_t10dif megasr(P)(U) wmi dm_mirror
dm_region_hash dm_log dm_mod [last unloaded: scsi_wait_scan]
Feb 11 11:39:37 wn007 kernel: 
Feb 11 11:39:37 wn007 kernel: Pid: 4948, comm: mount.nfs Tainted: P    
       ---------------    2.6.32-504.8.1.el6.x86_64 #1 FUJITSU PRIMERGY
CX270 S2/D3196
Feb 11 11:39:37 wn007 kernel: RIP: 0010:[<0000000000000000>] 
 [<(null)>] (null)
Feb 11 11:39:37 wn007 kernel: RSP: 0018:ffff88206610d780  EFLAGS:
00010246
Feb 11 11:39:37 wn007 kernel: RAX: ffffffffa128f900 RBX:
ffff882041f01e80 RCX: 00000000000011fb
Feb 11 11:39:37 wn007 kernel: RDX: 0000000000000000 RSI:
ffff882041f01e80 RDI: ffff88205b5a4000
Feb 11 11:39:37 wn007 kernel: RBP: ffff88206610d7a8 R08:
00000000000735a7 R09: 00000000fffffffe
Feb 11 11:39:37 wn007 kernel: R10: 0000000000000000 R11:
0000000000000001 R12: ffff88205b5a4000
Feb 11 11:39:37 wn007 kernel: R13: 0000000000000000 R14:
0000000000000000 R15: ffffffffa12454a0
Feb 11 11:39:37 wn007 kernel: FS:  00002ba010f75b20(0000)
GS:ffff8810b8900000(0000) knlGS:0000000000000000
Feb 11 11:39:37 wn007 kernel: CS:  0010 DS: 0000 ES: 0000 CR0:
000000008005003b
Feb 11 11:39:37 wn007 kernel: CR2: 0000000000000000 CR3:
0000002065096000 CR4: 00000000001407e0
Feb 11 11:39:37 wn007 kernel: DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
Feb 11 11:39:37 wn007 kernel: DR3: 0000000000000000 DR6:
00000000ffff0ff0 DR7: 0000000000000400
Feb 11 11:39:37 wn007 kernel: Process mount.nfs (pid: 4948, threadinfo
ffff88206610c000, task ffff882064967500)
Feb 11 11:39:37 wn007 kernel: Stack:
Feb 11 11:39:37 wn007 kernel: ffffffffa1248bf3 ffffffffa12658e0
ffff882041f01e80 ffff882041f01ef0
Feb 11 11:39:37 wn007 kernel: <d> 0000000000000000 ffff88206610d7c8
ffffffffa12454d4 ffff882041f01e80
Feb 11 11:39:37 wn007 kernel: <d> ffff882041f01e80 ffff88206610d838
ffffffffa12508e7 ffff88206610d838
Feb 11 11:39:37 wn007 kernel: Call Trace:
Feb 11 11:39:37 wn007 kernel: [<ffffffffa1248bf3>] ?
xprt_reserve+0x73/0xd0 [sunrpc]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa12454d4>]
call_reserve+0x34/0x60 [sunrpc]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa12508e7>]
__rpc_execute+0x77/0x350 [sunrpc]
Feb 11 11:39:37 wn007 kernel: [<ffffffff815293df>] ? printk+0x41/0x4a
Feb 11 11:39:37 wn007 kernel: [<ffffffff8109e987>] ?
bit_waitqueue+0x17/0xd0
Feb 11 11:39:37 wn007 kernel: [<ffffffffa1250c21>]
rpc_execute+0x61/0xa0 [sunrpc]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa1247465>]
rpc_run_task+0x75/0x90 [sunrpc]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa1247582>]
rpc_call_sync+0x42/0x70 [sunrpc]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa1247602>] rpc_ping+0x52/0x70
[sunrpc]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa1247f78>]
rpc_create+0x458/0x5b0 [sunrpc]
Feb 11 11:39:37 wn007 kernel: [<ffffffff810a4c2f>] ? up+0x2f/0x50
Feb 11 11:39:37 wn007 kernel: [<ffffffffa12a0cbb>]
nfs_create_rpc_client+0xcb/0x110 [nfs]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa0f57025>] ?
__fscache_acquire_cookie+0x65/0x2d0 [fscache]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa12a0ea8>]
nfs4_init_client+0x68/0x210 [nfs]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa12a167a>]
nfs_get_client+0x4ca/0x5a0 [nfs]
Feb 11 11:39:37 wn007 kernel: [<ffffffff815293df>] ? printk+0x41/0x4a
Feb 11 11:39:37 wn007 kernel: [<ffffffffa12a17ae>]
nfs4_set_client+0x5e/0xe0 [nfs]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa12a24db>]
nfs4_create_server+0xbb/0x330 [nfs]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa12aea60>]
nfs4_remote_get_sb+0x80/0x200 [nfs]
Feb 11 11:39:37 wn007 kernel: [<ffffffff811909bb>]
vfs_kern_mount+0x7b/0x1b0
Feb 11 11:39:37 wn007 kernel: [<ffffffffa12aee45>]
nfs_do_root_mount+0x95/0xe0 [nfs]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa12af2b2>]
nfs4_try_mount+0x52/0xd0 [nfs]
Feb 11 11:39:37 wn007 kernel: [<ffffffffa12b008a>]
nfs_get_sb+0x43a/0x880 [nfs]
Feb 11 11:39:37 wn007 kernel: [<ffffffff811909bb>]
vfs_kern_mount+0x7b/0x1b0
Feb 11 11:39:37 wn007 kernel: [<ffffffff81190b62>]
do_kern_mount+0x52/0x130
Feb 11 11:39:37 wn007 kernel: [<ffffffff811b270b>] do_mount+0x2fb/0x930
Feb 11 11:39:37 wn007 kernel: [<ffffffff811b03f2>] ?
copy_mount_options+0xf2/0x1a0
Feb 11 11:39:37 wn007 kernel: [<ffffffff811b2dd0>] sys_mount+0x90/0xe0
Feb 11 11:39:37 wn007 kernel: [<ffffffff8100b072>]
system_call_fastpath+0x16/0x1b
Feb 11 11:39:37 wn007 kernel: Code:  Bad RIP value.
Feb 11 11:39:37 wn007 kernel: RIP  [<(null)>] (null)
Feb 11 11:39:37 wn007 kernel: RSP <ffff88206610d780>
Feb 11 11:39:37 wn007 kernel: CR2: 0000000000000000
Feb 11 11:39:37 wn007 kernel: ---[ end trace 28c8ef194d572ced ]---


