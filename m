Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:38248 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754461AbaDKTSp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Apr 2014 15:18:45 -0400
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id s3BJIi7l031038
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 11 Apr 2014 12:18:44 -0700
Message-ID: <53484012.6020207@candelatech.com>
Date: Fri, 11 Apr 2014 12:18:42 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Crash in 3.14.0+ (plus hacks)
References: <5346D22A.10102@candelatech.com>
In-Reply-To: <5346D22A.10102@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/10/2014 10:17 AM, Ben Greear wrote:
> This could be related to some changes I made to nfs, but in case the
> problem is obvious, here's the stack trace.

Easily reproducible on Fedora 14 with stock kernel.  We do not see the
problem on Fedora 17.  Maybe F-14 is missing some user-space tool that
sets acls and kernel cannot deal with that properly?

We will be happy to test patches.....


BUG: unable to handle kernel NULL pointer dereference at 0000000000000010
IP: [<ffffffff811e415c>] posix_acl_equiv_mode+0x1/0x9c
PGD 0
Oops: 0000 [#1] PREEMPT SMP
Modules linked in: ip6table_filter ip6_tables ebtable_nat ebtables ipt_MASQUERADE iptable_nat 8021q mrp garp iptable_raw xt_CT nf_nat_ipv4 nf_nat bridge stp llc
fuse macvlan pktgen iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi nfsd lockd nfs_acl auth_rpcgss oid_registry sunrpc ipv6 kvm uinput i5k_amb i5000_edac
e1000e iTCO_wdt gpio_ich edac_core iTCO_vendor_support lpc_ich ppdev pcspkr ptp parport_pc parport shpchp i2c_i801 ioatdma dca microcode pps_core floppy radeon
ttm drm_kms_helper drm i2c_algo_bit i2c_core hwmon [last unloaded: iptable_nat]
CPU: 1 PID: 1942 Comm: nfsd Tainted: G         C   3.14.0 #1
Hardware name: Supermicro X7DBU/X7DBU, BIOS 2.1 06/23/2008
task: ffff8800be01a150 ti: ffff8800be118000 task.ti: ffff8800be118000
RIP: 0010:[<ffffffff811e415c>]  [<ffffffff811e415c>] posix_acl_equiv_mode+0x1/0x9c
RSP: 0018:ffff8800be119cc8  EFLAGS: 00010246
RAX: ffffffff81617040 RBX: 0000000000000000 RCX: 0000000000000004
RDX: 0000000000008000 RSI: ffff8802244cece8 RDI: 0000000000000000
RBP: ffff8800be119cf8 R08: 0000000000000004 R09: 0000000000000000
R10: ffffffff811b6567 R11: ffff8802244ced70 R12: ffff8802244cece8
R13: 0000000000008000 R14: ffff8800be6fa000 R15: 000000000000001c
FS:  0000000000000000(0000) GS:ffff88022fc40000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000010 CR3: 00000000ca525000 CR4: 00000000000007e0
Stack:
 ffff8800be119cf8 ffffffff811e4e66 ffffffff81617040 ffff8800be5fc000
 ffff8800be5fd000 ffff8802244cece8 ffff8800be119d38 ffffffffa07a7b2f
 ffff8800be119d38 ffff8800be6fa000 ffff8800be6fa000 ffffffffa07bf790
Call Trace:
 [<ffffffff811e4e66>] ? simple_set_acl+0x26/0x5f
 [<ffffffffa07a7b2f>] nfsd3_proc_setacl+0xbf/0x154 [nfsd]
 [<ffffffffa079ba8e>] nfsd_dispatch+0x99/0x153 [nfsd]
 [<ffffffffa072faf7>] svc_process_common+0x293/0x3e0 [sunrpc]
 [<ffffffffa07306b3>] svc_process+0xf2/0x10f [sunrpc]
 [<ffffffffa079b5f2>] nfsd+0xc8/0x121 [nfsd]
 [<ffffffffa079b52a>] ? nfsd_destroy+0x63/0x63 [nfsd]
 [<ffffffff810dd251>] kthread+0xc4/0xcc
 [<ffffffff810dd18d>] ? __kthread_parkme+0x5c/0x5c
 [<ffffffff815da58c>] ret_from_fork+0x7c/0xb0
 [<ffffffff810dd18d>] ? __kthread_parkme+0x5c/0x5c
Code: 09 b8 08 00 00 00 eb 02 31 c0 48 83 c2 08 4c 39 c2 0f 82 67 ff ff ff 83 f8 01 19 c0 f7 d0 83 e0 ea eb 05 b8 ea ff ff ff 5d c3 55 <8b> 47 10 48 8d 4f 14 31
d2 48 89 e5 4c 8d 44 c7 14 31 c0 eb 66
RIP  [<ffffffff811e415c>] posix_acl_equiv_mode+0x1/0x9c
 RSP <ffff8800be119cc8>
CR2: 0000000000000010
---[ end trace b80122b904746713 ]---

> 
> I instrumented the code to add the BUG_ON below, and it hits.  Something is
> sending NULL or close to it into the posix_acl_equiv_mode method.
> 
> /*
>  * Returns 0 if the acl can be exactly represented in the traditional
>  * file mode permission bits, or else 1. Returns -E... on error.
>  */
> int
> posix_acl_equiv_mode(const struct posix_acl *acl, umode_t *mode_p)
> {
>     const struct posix_acl_entry *pa, *pe;
>     umode_t mode = 0;
>     int not_equiv = 0;
> 
>     BUG_ON((unsigned long)(acl) < 4000);
> 
> 
> [root@ice-si-dmz ~]# uname -a
> Linux ice-si-dmz 3.14.0+ #16 SMP PREEMPT Thu Apr 10 08:53:30 PDT 2014 x86_64 x86_64 x86_64 GNU/Linux
> 
> 
> kernel BUG at /mnt/sda/home/greearb/git/linux-3.14.dev.y/fs/posix_acl.c:249!
> invalid opcode: 0000 [#1] PREEMPT SMP
> Modules linked in: iptable_raw xt_CT ip6table_filter ip6_tables ebtable_nat ebtables 8021q mrp garp nf_nat_ipv4 nf_nat bridge stp llc fuse macvlan pktgen
> iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi nfsd lockd nfs_acl auth_rpcgss oid_registry sunrpc ipv6 kvm uinput ppdev e1000e parport_pc i5k_amb
> i5000_edac parport edac_core microcode iTCO_wdt gpio_ich i2c_i801 iTCO_vendor_support lpc_ich ioatdma ptp dca pcspkr pps_core shpchp floppy radeon ttm
> drm_kms_helper drm i2c_algo_bit i2c_core hwmon [last unloaded: iptable_nat]
> CPU: 5 PID: 1945 Comm: nfsd Tainted: G         C O 3.14.0+ #16
> Hardware name: Supermicro X7DBU/X7DBU, BIOS 2.1 06/23/2008
> task: ffff880211f9a150 ti: ffff88021189c000 task.ti: ffff88021189c000
> RIP: 0010:[<ffffffff811e4426>]  [<ffffffff811e4426>] posix_acl_equiv_mode+0xd/0xa7
> RSP: 0018:ffff88021189dcc8  EFLAGS: 00010293
> RAX: ffffffff811e4ea7 RBX: 0000000000000000 RCX: 0000000000000004
> RDX: 0000000000008000 RSI: ffff880223de3268 RDI: 0000000000000000
> RBP: ffff88021189dcc8 R08: 0000000000000004 R09: 0000000000000000
> R10: ffffffff811b65c3 R11: ffff880223de32f0 R12: ffff880223de3268
> R13: 0000000000008000 R14: ffff880211c7e000 R15: 000000000000001c
> FS:  0000000000000000(0000) GS:ffff88022fd40000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: ffffffffff600400 CR3: 0000000211b04000 CR4: 00000000000007e0
> Stack:
>  ffff88021189dcf8 ffffffff811e4ecd ffffffff811e4ea7 ffff880211fa0000
>  ffff880211fa1000 ffff880223de3268 ffff88021189dd38 ffffffffa07f0b67
>  ffff88021189dd38 ffff880211c7e000 ffff880211c7e000 ffffffffa0808940
> Call Trace:
>  [<ffffffff811e4ecd>] simple_set_acl+0x26/0x5f
>  [<ffffffff811e4ea7>] ? posix_acl_fix_xattr_to_user+0x38/0x38
>  [<ffffffffa07f0b67>] nfsd3_proc_setacl+0xef/0x18c [nfsd]
>  [<ffffffffa07e4a8e>] nfsd_dispatch+0x99/0x153 [nfsd]
>  [<ffffffffa0778aff>] svc_process_common+0x293/0x3e0 [sunrpc]
>  [<ffffffffa07796bb>] svc_process+0xf2/0x10f [sunrpc]
>  [<ffffffffa07e45f2>] nfsd+0xc8/0x121 [nfsd]
>  [<ffffffffa07e452a>] ? nfsd_destroy+0x63/0x63 [nfsd]
>  [<ffffffff810dd251>] kthread+0xc4/0xcc
>  [<ffffffff810dd18d>] ? __kthread_parkme+0x5c/0x5c
>  [<ffffffff815dabcc>] ret_from_fork+0x7c/0xb0
>  [<ffffffff810dd18d>] ? __kthread_parkme+0x5c/0x5c
> Code: 34 c5 18 00 00 00 48 63 f6 e8 26 12 f8 ff 48 85 c0 74 df c7 00 01 00 00 00 5d c3 31 c0 c3 55 48 81 ff 9f 0f 00 00 48 89 e5 77 02 <0f> 0b 8b 47 10 48 8d 4f
> 14 31 d2 4c 8d 44 c7 14 31 c0 eb 66 66
> RIP  [<ffffffff811e4426>] posix_acl_equiv_mode+0xd/0xa7
>  RSP <ffff88021189dcc8>
> ---[ end trace b5a8a6a2f0ff3fab ]---
> 
> 
> Thanks,
> Ben
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

