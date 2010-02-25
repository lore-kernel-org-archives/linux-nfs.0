From: Anton Starikov <ant.starikov@gmail.com>
Subject: NFS bug with  2.6.18-164.11.1.el5 kernel
Date: Thu, 25 Feb 2010 23:35:27 +0100
Message-ID: <0D307444-5CDB-42BB-B8CD-7C37165946B4@gmail.com>
Mime-Version: 1.0 (Apple Message framework v1077)
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:59822 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934251Ab0BYWfh convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Feb 2010 17:35:37 -0500
Received: by wwf26 with SMTP id 26so2242161wwf.19
        for <linux-nfs@vger.kernel.org>; Thu, 25 Feb 2010 14:35:34 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Below my logs obtained on centos 5.4 with kernel 2.6.18-164.11.1.el5 when I ask OpenMPI+BLCR to load checkpoint snapshot from NFS share. 

General layout is next: host is diskless with nfsroot over NFSv3, /home/* auto-mounted via NFSv4, 
and checkpoint directory (where BLCR snapshot is) mounted via NFSv3 (because over NFS4 it kills system even faster). 

CentOS 5.4 / kernel 2.6.18-164.11.1.el5
NFS servier is OpenSolaris.
BLCR-0.8.2+OpenMPI-1.4.1 (if it does matter).


Although checkpoint snapshot is on NFSv3 (on NFSv4 at kills system in different way), during restore of processes BLCR try to open some files on /home/user share which is on NFSv4.

Practically, for last couple of years I'm regularly trying to implement config with diskless hosts where /home/* folders will be automounted over NFSv4 (to have proper ACL and attrs), and all what I see:

1) you can't have root on NFS4 (although you can move idmap to initrd and mount NFS4 as root, you always get after some time hanging system, or system with broken idmapping), so you have to use NFS3 for root. And, obviously, NFS4 root isn't desirable, if you take into account idmapping, which means that on server you really need to create corespondent UIDs for all system/service UIDs you have on the clients and have to keep it synchronized. 

2) root over NFSv3 and mounts over NFSv4 can't coexist together. At least in real combat systems. There always some different bugs in different places which prevents this config from working. I tried at least 15 different versions of kernels in range 2.6.16-2.6.31, from different distros and vanilla kernels, but never managed to get it working stable. 

Will it ever work?

Anton.


----------- 0d [user.notice] -----------: [cut here ] --------- [please bite here ] ---------
Kernel 0d [user.notice] Kernel: BUG at fs/nfs/nfs4xdr.c:872
invalid 0d [user.notice] invalid: opcode: 0000 [1] 
SMP 0d [user.notice] SMP: 
 0d [user.notice] : 
last 0d [user.notice] last: sysfs file: /devices/system/cpu/cpu15/topology/physical_package_id
CPU 0d [user.notice] CPU: 12 
 0d [user.notice] : 
Modules 0d [user.notice] Modules: linked in:
blcr(U) 0d [user.notice] blcr(U): 
blcr_imports(U) 0d [user.notice] blcr_imports(U): 
netconsole 0d [user.notice] netconsole: 
autofs4 0d [user.notice] autofs4: 
testmgr_cipher 0d [user.notice] testmgr_cipher: 
testmgr 0d [user.notice] testmgr: 
aead 0d [user.notice] aead: 
crypto_blkcipher 0d [user.notice] crypto_blkcipher: 
crypto_algapi 0d [user.notice] crypto_algapi: 
des 0d [user.notice] des: 
ip_conntrack_netbios_ns 0d [user.notice] ip_conntrack_netbios_ns: 
ipt_REJECT 0d [user.notice] ipt_REJECT: 
xt_state 0d [user.notice] xt_state: 
ip_conntrack 0d [user.notice] ip_conntrack: 
nfnetlink 0d [user.notice] nfnetlink: 
iptable_filter 0d [user.notice] iptable_filter: 
ip_tables 0d [user.notice] ip_tables: 
ip6t_REJECT 0d [user.notice] ip6t_REJECT: 
xt_tcpudp 0d [user.notice] xt_tcpudp: 
ip6table_filter 0d [user.notice] ip6table_filter: 
ip6_tables 0d [user.notice] ip6_tables: 
x_tables 0d [user.notice] x_tables: 
rdma_ucm(U) 0d [user.notice] rdma_ucm(U): 
ib_ucm(U) 0d [user.notice] ib_ucm(U): 
ib_sdp(U) 0d [user.notice] ib_sdp(U): 
rdma_cm(U) 0d [user.notice] rdma_cm(U): 
iw_cm(U) 0d [user.notice] iw_cm(U): 
ib_addr(U) 0d [user.notice] ib_addr(U):
ib_ipoib(U) 0d [user.notice] ib_ipoib(U): 
ipoib_helper(U) 0d [user.notice] ipoib_helper(U): 
ib_cm(U) 0d [user.notice] ib_cm(U): 
ib_sa(U) 0d [user.notice] ib_sa(U): 
ib_uverbs(U) 0d [user.notice] ib_uverbs(U): 
ib_umad(U) 0d [user.notice] ib_umad(U): 
iw_nes(U) 0d [user.notice] iw_nes(U): 
iw_cxgb3(U) 0d [user.notice] iw_cxgb3(U): 
cxgb3(U) 0d [user.notice] cxgb3(U): 
ib_qib(U) 0d [user.notice] ib_qib(U): 
dca 0d [user.notice] dca: 
mlx4_en(U) 0d [user.notice] mlx4_en(U): 
mlx4_ib(U) 0d [user.notice] mlx4_ib(U): 
ib_mthca(U) 0d [user.notice] ib_mthca(U): 
ib_mad(U) 0d [user.notice] ib_mad(U): 
ib_core(U) 0d [user.notice] ib_core(U): 
dm_mirror 0d [user.notice] dm_mirror: 
dm_log 0d [user.notice] dm_log: 
dm_multipath 0d [user.notice] dm_multipath: 
scsi_dh 0d [user.notice] scsi_dh: 
dm_mod 0d [user.notice] dm_mod: 
video 0d [user.notice] video: 
hwmon 0d [user.notice] hwmon: 
backlight 0d [user.notice] backlight: 
sbs 0d [user.notice] sbs: 
i2c_ec 0d [user.notice] i2c_ec: 
button 0d [user.notice] button: 
battery 0d [user.notice] battery: 
asus_acpi 0d [user.notice] asus_acpi: 
acpi_memhotplug 0d [user.notice] acpi_memhotplug: 
ac 0d [user.notice] ac: 
parport_pc 0d [user.notice] parport_pc: 
lp 0d [user.notice] lp: 
parport 0d [user.notice] parport: 
joydev 0d [user.notice] joydev: 
sr_mod 0d [user.notice] sr_mod:
cdrom 0d [user.notice] cdrom: 
sd_mod 0d [user.notice] sd_mod: 
sg 0d [user.notice] sg: 
mptsas 0d [user.notice] mptsas: 
mlx4_core(U) 0d [user.notice] mlx4_core(U): 
mptscsih 0d [user.notice] mptscsih: 
pcspkr 0d [user.notice] pcspkr: 
mptbase 0d [user.notice] mptbase: 
scsi_transport_sas 0d [user.notice] scsi_transport_sas: 
i2c_nforce2 0d [user.notice] i2c_nforce2: 
i2c_core 0d [user.notice] i2c_core: 
serio_raw 0d [user.notice] serio_raw: 
usb_storage 0d [user.notice] usb_storage: 
scsi_mod 0d [user.notice] scsi_mod: 
shpchp 0d [user.notice] shpchp: 
bnx2 0d [user.notice] bnx2: 
e1000 0d [user.notice] e1000: 
tg3 0d [user.notice] tg3: 
nfs 0d [user.notice] nfs: 
lockd 0d [user.notice] lockd: 
ipv6 0d [user.notice] ipv6: 
fscache 0d [user.notice] fscache: 
nfs_acl 0d [user.notice] nfs_acl: 
rpcsec_gss_krb5 0d [user.notice] rpcsec_gss_krb5: 
auth_rpcgss 0d [user.notice] auth_rpcgss: 
xfrm_nalgo 0d [user.notice] xfrm_nalgo: 
crypto_api 0d [user.notice] crypto_api: 
sunrpc 0d [user.notice] sunrpc: 
uhci_hcd 0d [user.notice] uhci_hcd: 
ohci_hcd 0d [user.notice] ohci_hcd: 
ehci_hcd 0d [user.notice] ehci_hcd: 
 0d [user.notice] : 
Pid 0d [user.notice] Pid: 6821, comm: vasp Tainted: G      2.6.18-164.11.1.el5 #1
RIP 0d [user.notice] RIP: 0010:[<ffffffff881554ff>]
 0d [user.notice] [<ffffffff881554ff>]: :nfs:encode_share_access+0x6d/0x82
RSP 0d [user.notice] RSP: 0018:ffff81041d0677b8  EFLAGS: 00010297
RAX 0d [user.notice] RAX: 00000000ffffffff RBX: ffff81041c0910a8 RCX: ffff81041c0910a8
RDX 0d [user.notice] RDX: 0000000000000008 RSI: 0000000000000008 RDI: ffff81041d067808
RBP 0d [user.notice] RBP: 0000000000000080 R08: ffff81041c09109c R09: 0000000000000009
R10 0d [user.notice] R10: ffff810415c9ce00 R11: ffffffff88158d4f R12: ffff81041d067808
R13 0d [user.notice] R13: ffff810417c4ea68 R14: ffff81041d067ab8 R15: ffff810426afa000
FS 0d [user.notice] FS:  00002b6e05f681c0(0000) GS:ffff81010e957240(0000) knlGS:0000000000000000
CS 0d [user.notice] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
CR2 0d [user.notice] CR2: 0000003192a03080 CR3: 0000000417712000 CR4: 00000000000006e0
Process 0d [user.notice] Process: vasp (pid: 6821, threadinfo ffff81041d066000, task ffff81042689c100)
Stack 0d [user.notice] Stack: 
ffffffffffffffff 0d [user.notice] ffffffffffffffff: 
ffff81041c0910a0 0d [user.notice] ffff81041c0910a0: 
ffff810426be2408 0d [user.notice] ffff810426be2408: 
ffffffff881589ff 0d [user.notice] ffffffff881589ff: 
 0d [user.notice] : 
0000000000000000 0d [user.notice] 0000000000000000: 
ffff810417c4ea68 0d [user.notice] ffff810417c4ea68: 
ffff810426be2408 0d [user.notice] ffff810426be2408: 
ffffffff88158d4f 0d [user.notice] ffffffff88158d4f: 
 0d [user.notice] : 
ffff810417c4ea68 0d [user.notice] ffff810417c4ea68: 
ffffffff88158dbc 0d [user.notice] ffffffff88158dbc: 
ffff81041c0910b0 0d [user.notice] ffff81041c0910b0: 
ffff810417c4ea70 0d [user.notice] ffff810417c4ea70: 
 0d [user.notice] : 
Call 0d [user.notice] Call: Trace:
 0d [user.notice] [<ffffffff881589ff>]: :nfs:encode_open+0x66/0x33e
 0d [user.notice] [<ffffffff88158d4f>]: :ac+0x0/0xac
 0d [user.notice] [<ffffffff88158dbc>]: :nfs:nfs4_xdr_enc_open+0x6d/0xac
 0d [user.notice] [<ffffffff88158d4f>]: :nfs:nfs4_xdr_enc_open+0x0/0xac
 0d [user.notice] [<ffffffff880313f0>]: :sunrpc:call_transmit+0x1bc/0x222
 0d [user.notice] [<ffffffff880369c1>]: :sunrpc:__rpc_execute+0x92/0x24e
 0d [user.notice] [<ffffffff88036bd4>]: :sunrpc:rpc_run_task+0x37/0x3f
 0d [user.notice] [<ffffffff881501b1>]: :nfs:_nfs4_proc_open+0x50/0x1aa
 0d [user.notice] [<ffffffff881510c3>]: :nfs:nfs4_do_open+0xc2/0x1dd
 0d [user.notice] [<ffffffff88152a89>]: :nfs:nfs4_proc_create+0x7f/0x1b2
 0d [user.notice] [<ffffffff8012827c>]: avc_has_perm+0x46/0x58
 0d [user.notice] [<ffffffff8813d18a>]: :nfs:nfs_create+0x91/0x103
 0d [user.notice] [<ffffffff8003a593>]: vfs_create+0xe6/0x158
 0d [user.notice] [<ffffffff887e5d16>]: :blcr:cr_mknod+0x19f/0x2b8
 0d [user.notice] [<ffffffff887e5ee0>]: :blcr:cr_filp_mknod+0x30/0x12e
 0d [user.notice] [<ffffffff887e629a>]: :blcr:cr_uread+0x40/0x91
 0d [user.notice] [<ffffffff887e6e20>]: :blcr:cr_mkunlinked+0x47/0x14d
 0d [user.notice] [<ffffffff887eaea1>]: :blcr:cr_restore_open_file+0x195/0x332
 0d [user.notice] [<ffffffff887ec9d7>]: :blcr:cr_rstrt_child+0x1354/0x1de2
 0d [user.notice] [<ffffffff8008ac96>]: __wake_up_common+0x3e/0x68
 0d [user.notice] [<ffffffff8008c86c>]: default_wake_function+0x0/0xe
 0d [user.notice] [<ffffffff800646f9>]: __down_failed+0x35/0x3a
 0d [user.notice] [<ffffffff800421b6>]: do_ioctl+0x55/0x6b
 0d [user.notice] [<ffffffff80030293>]: vfs_ioctl+0x457/0x4b9
 0d [user.notice] [<ffffffff8004c843>]: sys_ioctl+0x59/0x78
 0d [user.notice] [<ffffffff8005d28d>]: tracesys+0xd5/0xe0
 0d [user.notice] : 
 0d [user.notice] : 
Code 0d [user.notice] Code: 
0f 0d [user.notice] 0f: 
0b 0d [user.notice] 0b: 
68 0d [user.notice] 68: 
50 0d [user.notice] 50: 
2a 0d [user.notice] 2a: 
16 0d [user.notice] 16: 
88 0d [user.notice] 88: 
c2 0d [user.notice] c2: 
68 0d [user.notice] 68: 
03 0d [user.notice] 03: 
c7 0d [user.notice] c7:
03 0d [user.notice] 03: 
00 0d [user.notice] 00: 
00 0d [user.notice] 00: 
00 0d [user.notice] 00: 
00 0d [user.notice] 00: 
41 0d [user.notice] 41: 
5a 0d [user.notice] 5a: 
5b 0d [user.notice] 5b: 
5d 0d [user.notice] 5d: 
 0d [user.notice] : 
RIP 0d [user.notice] RIP: 
 0d [user.notice] [<ffffffff881554ff>]: :nfs:encode_share_access+0x6d/0x82
RSP 0d [user.notice] RSP: <ffff81041d0677b8>
 0d [user.notice] : 
kernel 03 [kern.err] kernel: last message repeated 2 times
kernel 04 [kern.warning] kernel: ----------- [cut here ] --------- [please bite here ] 