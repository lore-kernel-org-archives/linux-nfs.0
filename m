Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36926 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751563AbaDYKsH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Apr 2014 06:48:07 -0400
Date: Fri, 25 Apr 2014 06:48:03 -0400
To: Ben Greear <greearb@candelatech.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: Crash in 3.14.0+ (plus hacks)
Message-ID: <20140425104803.GD22295@fieldses.org>
References: <5346D22A.10102@candelatech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5346D22A.10102@candelatech.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 10, 2014 at 10:17:30AM -0700, Ben Greear wrote:
> This could be related to some changes I made to nfs, but in case the
> problem is obvious, here's the stack trace.

There's also a report here:

	https://bugzilla.kernel.org/show_bug.cgi?id=74721

While I'm travelling, I'm cc'ing Christoph in case this might be a
consequence of his recent ACL cleanup?

--b.

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
> 	const struct posix_acl_entry *pa, *pe;
> 	umode_t mode = 0;
> 	int not_equiv = 0;
> 
> 	BUG_ON((unsigned long)(acl) < 4000);
> 
> 
> [root@ice-si-dmz ~]# uname -a
> Linux ice-si-dmz 3.14.0+ #16 SMP PREEMPT Thu Apr 10 08:53:30 PDT 2014 x86_64 x86_64 x86_64 GNU/Linux
> 
> 
> kernel BUG at /mnt/sda/home/greearb/git/linux-3.14.dev.y/fs/posix_acl.c:249!
> invalid opcode: 0000 [#1] PREEMPT SMP
> Modules linked in: iptable_raw xt_CT ip6table_filter ip6_tables
> ebtable_nat ebtables 8021q mrp garp nf_nat_ipv4 nf_nat bridge stp
> llc fuse macvlan pktgen iscsi_tcp libiscsi_tcp libiscsi
> scsi_transport_iscsi nfsd lockd nfs_acl auth_rpcgss oid_registry
> sunrpc ipv6 kvm uinput ppdev e1000e parport_pc i5k_amb i5000_edac
> parport edac_core microcode iTCO_wdt gpio_ich i2c_i801
> iTCO_vendor_support lpc_ich ioatdma ptp dca pcspkr pps_core shpchp
> floppy radeon ttm drm_kms_helper drm i2c_algo_bit i2c_core hwmon
> [last unloaded: iptable_nat]
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
> Code: 34 c5 18 00 00 00 48 63 f6 e8 26 12 f8 ff 48 85 c0 74 df c7 00
> 01 00 00 00 5d c3 31 c0 c3 55 48 81 ff 9f 0f 00 00 48 89 e5 77 02
> <0f> 0b 8b 47 10 48 8d 4f 14 31 d2 4c 8d 44 c7 14 31 c0 eb 66 66
> RIP  [<ffffffff811e4426>] posix_acl_equiv_mode+0xd/0xa7
>  RSP <ffff88021189dcc8>
> ---[ end trace b5a8a6a2f0ff3fab ]---
> 
> 
> Thanks,
> Ben
> 
> -- 
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
