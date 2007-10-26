From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Oops when mounting with krb5i flavor on
	linux-2.6.23-rc9-CITI_NFS4_ALL-1
Date: Fri, 26 Oct 2007 16:24:37 +0200
Message-ID: <4721F8A5.3080804@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: nfsv4 <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Hi,

Running 2.6.23-rc9-CITI_NFS4_ALL-1 on one Intel X86_64 bi-ways machine acting
as client and having AIX as server, if I do a NFSV4 mounting on linux
using the krb5i flavor get the following Oops during the mount:

kernel: Unable to handle kernel NULL pointer dereference at 0000000000000020
RIP:
kernel:  [<ffffffff805b06a6>] g_token_size+0x1/0x15
kernel: PGD 62f27067 PUD 7698f067 PMD 0
kernel: Oops: 0000 [1] SMP
kernel: CPU 1
kernel: Modules linked in: hidp hid rfcomm l2cap bluetooth cpufreq_ondemand
acpi_cpufreq dm_mirror dm_multipath dm_mod
backlight parport_pc lp parport nvram i2c_i801 i2c_core
kernel: Pid: 3111, comm: mount.nfs4 Not tainted 2.6.23-rc9-CITI_NFS4_ALL-1 #6
kernel: RIP: 0010:[<ffffffff805b06a6>]  [<ffffffff805b06a6>]
g_token_size+0x1/0x15
kernel: RSP: 0018:ffff810060ca5578  EFLAGS: 00010246
kernel: RAX: 000000004721a1e4 RBX: 0000000000000020 RCX: 0000000000000000
kernel: RDX: ffff810060ca5648 RSI: 0000000000000016 RDI: 0000000000000020
kernel: RBP: ffff810060ca5648 R08: ffff810060ca55f8 R09: ffff81007e984300
kernel: R10: ffff810062be9d80 R11: ffffffff805b36a8 R12: 0000000000000000
kernel: R13: ffff810060ca55f8 R14: 000000004721a1e4 R15: ffff81007e984300
kernel: FS:  00002b68e7eaa6f0(0000) GS:ffff81007f86aac0(0000)
knlGS:0000000000000000
kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
kernel: CR2: 0000000000000020 CR3: 0000000061160000 CR4: 00000000000006e0
kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
kernel: Process mount.nfs4 (pid: 3111, threadinfo ffff810060ca4000, task
ffff8100786010c0)
kernel: Stack:  0000000000000020 ffffffff805b3700 0000000000000000
ffff810060ca5598
kernel:  ffff810060ca55e8 0000000000000282 ffff81006f0d73c0 ffffffff805b8573
kernel:  ffff810060ca55f8 ffff810062ade048 ffff810060d7e000 ffff810062ade044
kernel: Call Trace:
kernel:  [<ffffffff805b3700>] gss_get_mic_kerberos+0x58/0x164
kernel:  [<ffffffff805b8573>] _spin_lock_irqsave+0x9/0xe
kernel:  [<ffffffff805afff0>] gss_marshal+0x134/0x19c
kernel:  [<ffffffff8032a2a1>] nfs4_xdr_enc_lookup_root+0x0/0x71
kernel:  [<ffffffff8059c4c8>] call_transmit+0x18b/0x23a
kernel:  [<ffffffff805a27d0>] __rpc_execute+0x7d/0x240
kernel:  [<ffffffff8059cce3>] rpc_do_run_task+0x89/0xa6
kernel:  [<ffffffff8023503c>] __group_send_sig_info+0x80/0x8b
kernel:  [<ffffffff8059cd63>] rpc_call_sync+0x19/0x32
kernel:  [<ffffffff803224e1>] nfs4_proc_get_root+0x83/0xca
kernel:  [<ffffffff803124cd>] nfs4_path_walk+0x71/0x24f
kernel:  [<ffffffff805ac025>] rpc_populate+0x159/0x1a8
kernel:  [<ffffffff8029212a>] mntput_no_expire+0x1c/0x97
kernel:  [<ffffffff805ad1e7>] rpc_mkdir+0x1eb/0x256
kernel:  [<ffffffff8029853e>] simple_pin_fs+0x89/0xad
kernel:  [<ffffffff8059c0cc>] rpc_register_client+0x10/0x3f
kernel:  [<ffffffff8059d1c9>] rpc_clone_client+0x101/0x152
kernel:  [<ffffffff8030e454>] nfs4_create_server+0x21b/0x38b
kernel:  [<ffffffff802621ba>] strndup_user+0x51/0x77
kernel:  [<ffffffff80316244>] nfs4_get_sb+0x377/0x4a8
kernel:  [<ffffffff8025cee5>] __alloc_pages+0x71/0x2d3
kernel:  [<ffffffff8027f4bc>] vfs_kern_mount+0x93/0x123
kernel:  [<ffffffff8027f59b>] do_kern_mount+0x43/0xdd
kernel:  [<ffffffff80293710>] do_mount+0x697/0x70b
kernel:  [<ffffffff8026586a>] handle_mm_fault+0x724/0x757
kernel:  [<ffffffff80539fcd>] ip_output+0x2ca/0x311
kernel:  [<ffffffff805b8573>] _spin_lock_irqsave+0x9/0xe
kernel:  [<ffffffff8040f128>] __up_read+0x13/0x8a
kernel:  [<ffffffff805ba4a1>] do_page_fault+0x461/0x7d1
kernel:  [<ffffffff805485b6>] tcp_transmit_skb+0x699/0x6d6
kernel:  [<ffffffff802626f3>] zone_statistics+0x3f/0x60
kernel:  [<ffffffff80291f50>] copy_mount_options+0xce/0x126
kernel:  [<ffffffff8029380e>] sys_mount+0x8a/0xcd
kernel:  [<ffffffff8020bb5e>] system_call+0x7e/0x83
kernel:

More at:
------------------------------------------------------------- 
Bug: 
  http://bugzilla.linux-nfs.org/show_bug.cgi?id=154  

Regards

-- 
-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic 
Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- 
