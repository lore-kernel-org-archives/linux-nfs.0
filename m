Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:40974 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852Ab3AUNMz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 08:12:55 -0500
Date: Mon, 21 Jan 2013 13:06:07 +0000
From: Alex Bligh <alex@alex.org.uk>
Reply-To: Alex Bligh <alex@alex.org.uk>
To: linux-nfs@vger.kernel.org
cc: Alex Bligh <alex@alex.org.uk>
Subject: Fatal crash with NFS, AIO & tcp retransmit
Message-ID: <93D3AE9B4990994B2BCA75A9@Ximines.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm trying to resolve a fatal bug that happens with Linux 3.2.0-32-generic
(Ubuntu variant of 3.2), and the magic combination of
1. NFSv4
2. AIO from Qemu
3. Xen with upstream qemu DM
4. QCOW plus backing file.

The background is here:
  http://lists.xen.org/archives/html/xen-devel/2012-12/msg01154.html
It is completely replicable on different NFS client hardware. We've
tried other kernels to no avail.

The bug is quite nasty in that dom0 crashes fatally due to a VM action.

Within the link, you'll see references to an issue found by Ian Campbell
a while ago, which turned out to be an NFS issue independent of Xen but
apparently not in NFS4. The links are:
 http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=640941
 http://marc.info/?l=linux-nfs&m=122424132729720&w=2

In essence, my understanding of what appears to be happening (which
may be entirely wrong) is:
1. Xen 4.2 HVM domU VM has a PV disk driver
2. domU writes a page
3. Xen maps domU's page into dom0's VM space
4. Xen asks Qemu (userspace) to write a page
5. Qemu's disk (and backing file for the disk) are on NFSv4
6. Qemu uses AIO to write the page to NFS
7. AIO claims the page write is complete
8. Qemu marks the write as complete
9. Xen unmaps the page from dom0's VM space
10. Apparently, the write is not actually complete at this
    point
11. TCP retransmit is triggered (not quite sure why, possibly
    due to slow filer)
12. TCP goes to resend the page, and finds it's not in dom0
    memory.
13. Bang

The Xen folks think this is nothing to do with either Xen or QEMU, and
believe the problem is AIO on NFS. The links to earlier investigations
suggest this is/was true, but not for NFSv4, and was fixed. An NFSv4 case
may have been missed.

Against this explanation:
a) it does not happen in KVM (again with QEMU doing AIO to
   NFS) - though here the page mapping fanciness doesn't
   happen as KVM VMs share the same memory space as the kernel
   as I understand it.
b) it does not happen on Xen without a QEMU backing file (though
   that may be just what's necessary timing wise to trigger
   the race condition).

Any insight you have would be appreciated.

Specifically, the question I'd ask is as follows. Is it correct behaviour
that Linux+NFSv4 marks an AIO request completed when all the relevant data
may have been sent by TCP but not yet ACK'd? If so, how is Linux meant to
deal with retransmits? Are the pages referenced by the TCP stack meant to
be marked COW or something? What is meant to happen if those pages get
removed from the memory map entirely?

As an aside, we're looking for someone to fix this (and things like it) on
a contract basis. Contact me off list if interested.

-- 
Alex Bligh


Kernel 3.2.0-32-generic on an x86_64

[ 1416.992402] BUG: unable to handle kernel paging request at
ffff88073fee6e00
[ 1416.992902] IP: [<ffffffff81318e2b>] memcpy+0xb/0x120
[ 1416.993244] PGD 1c06067 PUD 7ec73067 PMD 7ee73067 PTE 0
[ 1416.993985] Oops: 0000 [#1] SMP
[ 1416.994433] CPU 4
[ 1416.994587] Modules linked in: xt_physdev xen_pciback xen_netback
xen_blkback xen_gntalloc xen_gntdev xen_evtchn xenfs veth ip6t_LOG
nf_conntrack_ipv6 nf_
defrag_ipv6 ip6table_filter ip6_tables ipt_LOG xt_limit xt_state
xt_tcpudp nf_conntrack_netlink nfnetlink ebt_ip ebtable_filter
iptable_mangle ipt_MASQUERADE
iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4
iptable_filter ip_tables ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad
ib_core ib_addr iscsi_tcp
libiscsi_tcp libiscsi scsi_transport_iscsi ebtable_broute ebtables
x_tables dcdbas psmouse serio_raw amd64_edac_mod usbhid hid edac_core
sp5100_tco i2c_piix
4 edac_mce_amd fam15h_power k10temp igb bnx2 acpi_power_meter mac_hid
dm_multipath bridge 8021q garp stp ixgbe dca mdio nfsd nfs lockd fscache
auth_rpcgss nf
s_acl sunrpc [last unloaded: scsi_transport_iscsi]
[ 1417.005011]
[ 1417.005011] Pid: 0, comm: swapper/4 Tainted: G ÂÂÂÂÂÂÂW
3.2.0-32-generic #51-Ubuntu Dell Inc. PowerEdge R715/0C5MMK
[ 1417.005011] RIP: e030:[<ffffffff81318e2b>] Â[<ffffffff81318e2b>]
memcpy+0xb/0x120
[ 1417.005011] RSP: e02b:ffff880060083b08 ÂEFLAGS: 00010246
[ 1417.005011] RAX: ffff88001e12c9e4 RBX: 0000000000000210 RCX:
0000000000000040
[ 1417.005011] RDX: 0000000000000000 RSI: ffff88073fee6e00 RDI:
ffff88001e12c9e4
[ 1417.005011] RBP: ffff880060083b70 R08: 00000000000002e8 R09:
0000000000000200
[ 1417.005011] R10: ffff88001e12c9e4 R11: 0000000000000280 R12:
00000000000000e8
[ 1417.005011] R13: ffff88004b014c00 R14: ffff88004b532000 R15:
0000000000000001
[ 1417.005011] FS: Â00007f1a99089700(0000) GS:ffff880060080000(0000)
knlGS:0000000000000000
[ 1417.005011] CS: Âe033 DS: 002b ES: 002b CR0: 000000008005003b
[ 1417.005011] CR2: ffff88073fee6e00 CR3: 0000000015d22000 CR4:
0000000000040660
[ 1417.005011] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[ 1417.005011] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[ 1417.005011] Process swapper/4 (pid: 0, threadinfo ffff88004b532000,
task ffff88004b538000)
[ 1417.005011] Stack:
[ 1417.005011] Âffffffff81532c0e 0000000000000000 ffff8800000002e8
ffff880000000200
[ 1417.005011] Âffff88001e12c9e4 0000000000000200 ffff88004b533fd8
ffff880060083ba0
[ 1417.005011] Âffff88004b015800 ffff88004b014c00 ffff88001b142000
00000000000000fc
[ 1417.005011] Call Trace:
[ 1417.005011] Â<IRQ>
[ 1417.005011] Â[<ffffffff81532c0e>] ? skb_copy_bits+0x16e/0x2c0
[ 1417.005011] Â[<ffffffff8153463a>] skb_copy+0x8a/0xb0
[ 1417.005011] Â[<ffffffff8154b517>] neigh_probe+0x37/0x80
[ 1417.005011] Â[<ffffffff8154b9db>] __neigh_event_send+0xbb/0x210
[ 1417.005011] Â[<ffffffff8154bc73>] neigh_resolve_output+0x143/0x1f0
[ 1417.005011] Â[<ffffffff8156dde5>] ? nf_hook_slow+0x75/0x150
[ 1417.005011] Â[<ffffffff8157a510>] ? ip_fragment+0x810/0x810
[ 1417.005011] Â[<ffffffff8157a68e>] ip_finish_output+0x17e/0x2f0
[ 1417.005011] Â[<ffffffff81533ddb>] ? __alloc_skb+0x4b/0x240
[ 1417.005011] Â[<ffffffff8157b1e8>] ip_output+0x98/0xa0
[ 1417.005011] Â[<ffffffff8157a8a4>] ? __ip_local_out+0xa4/0xb0
[ 1417.005011] Â[<ffffffff8157a8d9>] ip_local_out+0x29/0x30
[ 1417.005011] Â[<ffffffff8157aa3c>] ip_queue_xmit+0x15c/0x410
[ 1417.005011] Â[<ffffffff81595840>] ? tcp_retransmit_timer+0x440/0x440
[ 1417.005011] Â[<ffffffff81592c69>] tcp_transmit_skb+0x359/0x580
[ 1417.005011] Â[<ffffffff81593be1>] tcp_retransmit_skb+0x171/0x310
[ 1417.005011] Â[<ffffffff8159561b>] tcp_retransmit_timer+0x21b/0x440
[ 1417.005011] Â[<ffffffff81595928>] tcp_write_timer+0xe8/0x110
[ 1417.005011] Â[<ffffffff81595840>] ? tcp_retransmit_timer+0x440/0x440
[ 1417.005011] Â[<ffffffff81075d36>] call_timer_fn+0x46/0x160
[ 1417.005011] Â[<ffffffff81595840>] ? tcp_retransmit_timer+0x440/0x440
[ 1417.005011] Â[<ffffffff81077682>] run_timer_softirq+0x132/0x2a0
[ 1417.005011] Â[<ffffffff8106e5d8>] __do_softirq+0xa8/0x210
[ 1417.005011] Â[<ffffffff813a94b7>] ? __xen_evtchn_do_upcall+0x207/0x250
[ 1417.005011] Â[<ffffffff816656ac>] call_softirq+0x1c/0x30
[ 1417.005011] Â[<ffffffff81015305>] do_softirq+0x65/0xa0
[ 1417.005011] Â[<ffffffff8106e9be>] irq_exit+0x8e/0xb0
[ 1417.005011] Â[<ffffffff813ab595>] xen_evtchn_do_upcall+0x35/0x50
[ 1417.005011] Â[<ffffffff816656fe>] xen_do_hypervisor_callback+0x1e/0x30
[ 1417.005011] Â<EOI>
[ 1417.005011] Â[<ffffffff810013aa>] ? hypercall_page+0x3aa/0x1000
[ 1417.005011] Â[<ffffffff810013aa>] ? hypercall_page+0x3aa/0x1000
[ 1417.005011] Â[<ffffffff8100a2d0>] ? xen_safe_halt+0x10/0x20
[ 1417.005011] Â[<ffffffff8101b983>] ? default_idle+0x53/0x1d0
[ 1417.005011] Â[<ffffffff81012236>] ? cpu_idle+0xd6/0x120
[ 1417.005011] Â[<ffffffff8100ab29>] ? xen_irq_enable_direct_reloc+0x4/0x4
[ 1417.005011] Â[<ffffffff8163369c>] ? cpu_bringup_and_idle+0xe/0x10
[ 1417.005011] Code: 58 48 2b 43 50 88 43 4e 48 83 c4 08 5b 5d c3 90 e8
1b fe ff ff eb e6 90 90 90 90 90 90 90 90 90 48 89 f8 89 d1 c1 e9 03 83
e2 07 <f3> 48 a5 89 d1 f3 a4 c3 20 48 83 ea 20 4c 8b 06 4c 8b 4e 08 4c
[ 1417.005011] RIP Â[<ffffffff81318e2b>] memcpy+0xb/0x120
[ 1417.005011] ÂRSP <ffff880060083b08>
[ 1417.005011] CR2: ffff88073fee6e00
[ 1417.005011] ---[ end trace ae4e7f56ea0665fe ]---
[ 1417.005011] Kernel panic - not syncing: Fatal exception in interrupt
[ 1417.005011] Pid: 0, comm: swapper/4 Tainted: G ÂÂÂÂÂD W
3.2.0-32-generic #51-Ubuntu
[ 1417.005011] Call Trace:
[ 1417.005011] Â<IRQ> Â[<ffffffff81642197>] panic+0x91/0x1a4
[ 1417.005011] Â[<ffffffff8165c01a>] oops_end+0xea/0xf0
[ 1417.005011] Â[<ffffffff81641027>] no_context+0x150/0x15d
[ 1417.005011] Â[<ffffffff816411fd>] __bad_area_nosemaphore+0x1c9/0x1e8
[ 1417.005011] Â[<ffffffff81640835>] ? pte_offset_kernel+0x13/0x3c
[ 1417.005011] Â[<ffffffff8164122f>] bad_area_nosemaphore+0x13/0x15
[ 1417.005011] Â[<ffffffff8165ec36>] do_page_fault+0x426/0x520
[ 1417.005011] Â[<ffffffff8165b0ce>] ? _raw_spin_lock_irqsave+0x2e/0x40
[ 1417.005011] Â[<ffffffff81059d8a>] ? get_nohz_timer_target+0x5a/0xc0
[ 1417.005011] Â[<ffffffff8165b04e>] ? 
_raw_spin_unlock_irqrestore+0x1e/0x30
[ 1417.005011] Â[<ffffffff81077f93>] ? mod_timer_pending+0x113/0x240
[ 1417.005011] Â[<ffffffffa0317f34>] ? __nf_ct_refresh_acct+0xd4/0x100
[nf_conntrack]
[ 1417.005011] Â[<ffffffff8165b5b5>] page_fault+0x25/0x30
[ 1417.005011] Â[<ffffffff81318e2b>] ? memcpy+0xb/0x120
[ 1417.005011] Â[<ffffffff81532c0e>] ? skb_copy_bits+0x16e/0x2c0
[ 1417.005011] Â[<ffffffff8153463a>] skb_copy+0x8a/0xb0
[ 1417.005011] Â[<ffffffff8154b517>] neigh_probe+0x37/0x80
[ 1417.005011] Â[<ffffffff8154b9db>] __neigh_event_send+0xbb/0x210
[ 1417.005011] Â[<ffffffff8154bc73>] neigh_resolve_output+0x143/0x1f0
[ 1417.005011] Â[<ffffffff8156dde5>] ? nf_hook_slow+0x75/0x150
[ 1417.005011] Â[<ffffffff8157a510>] ? ip_fragment+0x810/0x810
[ 1417.005011] Â[<ffffffff8157a68e>] ip_finish_output+0x17e/0x2f0
[ 1417.005011] Â[<ffffffff81533ddb>] ? __alloc_skb+0x4b/0x240
[ 1417.005011] Â[<ffffffff8157b1e8>] ip_output+0x98/0xa0
[ 1417.005011] Â[<ffffffff8157a8a4>] ? __ip_local_out+0xa4/0xb0
[ 1417.005011] Â[<ffffffff8157a8d9>] ip_local_out+0x29/0x30
[ 1417.005011] Â[<ffffffff8157aa3c>] ip_queue_xmit+0x15c/0x410
[ 1417.005011] Â[<ffffffff81595840>] ? tcp_retransmit_timer+0x440/0x440
[ 1417.005011] Â[<ffffffff81592c69>] tcp_transmit_skb+0x359/0x580
[ 1417.005011] Â[<ffffffff81593be1>] tcp_retransmit_skb+0x171/0x310
[ 1417.005011] Â[<ffffffff8159561b>] tcp_retransmit_timer+0x21b/0x440
[ 1417.005011] Â[<ffffffff81595928>] tcp_write_timer+0xe8/0x110
[ 1417.005011] Â[<ffffffff81595840>] ? tcp_retransmit_timer+0x440/0x440
[ 1417.005011] Â[<ffffffff81075d36>] call_timer_fn+0x46/0x160
[ 1417.005011] Â[<ffffffff81595840>] ? tcp_retransmit_timer+0x440/0x440
[ 1417.005011] Â[<ffffffff81077682>] run_timer_softirq+0x132/0x2a0
[ 1417.005011] Â[<ffffffff8106e5d8>] __do_softirq+0xa8/0x210
[ 1417.005011] Â[<ffffffff813a94b7>] ? __xen_evtchn_do_upcall+0x207/0x250
[ 1417.005011] Â[<ffffffff816656ac>] call_softirq+0x1c/0x30
[ 1417.005011] Â[<ffffffff81015305>] do_softirq+0x65/0xa0
[ 1417.005011] Â[<ffffffff8106e9be>] irq_exit+0x8e/0xb0
[ 1417.005011] Â[<ffffffff813ab595>] xen_evtchn_do_upcall+0x35/0x50
[ 1417.005011] Â[<ffffffff816656fe>] xen_do_hypervisor_callback+0x1e/0x30
[ 1417.005011] Â<EOI> Â[<ffffffff810013aa>] ? hypercall_page+0x3aa/0x1000
[ 1417.005011] Â[<ffffffff810013aa>] ? hypercall_page+0x3aa/0x1000
[ 1417.005011] Â[<ffffffff8100a2d0>] ? xen_safe_halt+0x10/0x20
[ 1417.005011] Â[<ffffffff8101b983>] ? default_idle+0x53/0x1d0
[ 1417.005011] Â[<ffffffff81012236>] ? cpu_idle+0xd6/0x120
[ 1417.005011] Â[<ffffffff8100ab29>] ? xen_irq_enable_direct_reloc+0x4/0x4
[ 1417.005011] Â[<ffffffff8163369c>] ? cpu_bringup_and_idle+0xe/0x10
(XEN) Domain 0 crashed: 'noreboot' set - not rebooting.

