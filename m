From: Neil Brown <neilb@suse.de>
Subject: Re: Confused about BUG_ON in rpcb_getport_async
Date: Thu, 14 Aug 2008 12:26:59 +1000
Message-ID: <18595.38899.266212.237798@notabene.brown>
References: <18592.62730.840231.108375@notabene.brown>
	<1218573178.7253.31.camel@localhost>
	<18595.29231.61262.220929@notabene.brown>
	<1218672609.9042.86.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54474 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751763AbYHNC1I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2008 22:27:08 -0400
In-Reply-To: message from Trond Myklebust on Wednesday August 13
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wednesday August 13, trond.myklebust@fys.uio.no wrote:
> On Thu, 2008-08-14 at 09:45 +1000, Neil Brown wrote:
> > Just to confirm,  you are saying that the current BUG_ON is indeed
> > wrong, and the fact that it fires does not imply any real bug.
> > It should be removed.  Possibly a BUG_ON could be put somewhere else
> > to catch incorrect behaviour.
> > 
> > Is that correct?
> 
> Yes.

Thanks.

> 
> > I now have multiple people for whom this BUG_ON has fired.
> 
> Could you send us a trace? AFAIK it shouldn't really be happening...

https://bugzilla.novell.com/show_bug.cgi?id=415607
contains
Aug  7 09:55:42 copperhead klogd: ------------[ cut here ]------------
Aug  7 09:55:42 copperhead klogd: kernel BUG at net/sunrpc/rpcb_clnt.c:290!
Aug  7 09:55:42 copperhead klogd: invalid opcode: 0000 [1] SMP
Aug  7 09:55:42 copperhead klogd: last sysfs file: /sys/devices/system/cpu/cpu3/cache/index2/shared_cpu_map
Aug  7 09:55:42 copperhead klogd: CPU 3
Aug  7 09:55:42 copperhead klogd: Modules linked in: lp parport_pc ppdev
parport nls_utf8 nfs lockd nfs_acl sunrpc autofs4 binfmt_misc iptable_filter
ip_tables ip6table_filter ip6_tables x_tables ipv6 bonding microcode
firmware_class fuse loop dm_mod rtc_cmos iTCO_wdt sg shpchp rtc_core i2c_i801
iTCO_vendor_support rtc_lib floppy container i2c_core i5000_edac usb_storage
sr_mod pci_hotplug button cdrom joydev e1000e edac_core usbhid hid ff_memless
ehci_hcd uhci_hcd sd_mod usbcore edd ext3 mbcache jbd fan ata_piix ahci libata
dock 3w_9xxx scsi_mod thermal processor [last unloaded: parport_pc]
Aug  7 09:55:42 copperhead klogd: Pid: 14342, comm: xauth Tainted: G        N 2.6.25.11-0.1-default #1
Aug  7 09:55:42 copperhead klogd: RIP: 0010:[<ffffffff883ad55a>] [<ffffffff883ad55a>] :sunrpc:rpcb_getport_async+0x66/0x460
Aug  7 09:55:42 copperhead klogd: RSP: 0018:ffff810110cff938  EFLAGS: 00010287
Aug  7 09:55:42 copperhead klogd: RAX: ffffffff883d11d0 RBX: ffff81022c8d5c00 RCX: 0000000000000001
Aug  7 09:55:42 copperhead klogd: RDX: 0000000000000000 RSI: ffff81010a543e40 RDI: ffff81010a543e40
Aug  7 09:55:42 copperhead klogd: RBP: ffff810110cffa58 R08: ffff81010a543f28 R09: 0000000000000001
Aug  7 09:55:42 copperhead klogd: R10: ffff810001031280 R11: ffff810110cffc18 R12: ffff81018b047800
Aug  7 09:55:42 copperhead klogd: R13: ffff81018b047800 R14: ffff81010a543e40 R15: ffff810229d40800
Aug  7 09:55:42 copperhead klogd: FS:  00007fb4bd7ed6f0(0000) GS:ffff81022f1037c0(0000) knlGS:0000000000000000
Aug  7 09:55:42 copperhead klogd: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
Aug  7 09:55:42 copperhead klogd: CR2: 00007f3992dfcf00 CR3: 00000001d4601000 CR4: 00000000000006e0
Aug  7 09:55:42 copperhead klogd: DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
Aug  7 09:55:42 copperhead klogd: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Aug  7 09:55:42 copperhead klogd: Process xauth (pid: 14342, threadinfo ffff810110cfe000, task ffff810116954080)
Aug  7 09:55:42 copperhead klogd: Stack:  0000000000000246 ffff81022ad67370 ffff810110cff978 0000000000000246
Aug  7 09:55:42 copperhead klogd:  0000000000011200 ffff81022ad67340 ffff810110cff9a8 ffff810110cff9c0
Aug  7 09:55:42 copperhead klogd:  ffff810110cff988 ffffffff80276757 ffff810110cffa08 ffffffff8027685a
Aug  7 09:55:42 copperhead klogd: Call Trace: Aug  7 09:55:42 copperhead klogd:  [<ffffffff883a018b>] :sunrpc:call_bind+0x6f/0x74
Aug  7 09:55:42 copperhead klogd:  [<ffffffff883a72d9>] :sunrpc:__rpc_execute+0x86/0x246
Aug  7 09:55:42 copperhead klogd:  [<ffffffff883a751e>] :sunrpc:rpc_execute+0x85/0x8e
Aug  7 09:55:42 copperhead klogd:  [<ffffffff883a14a5>] :sunrpc:rpc_run_task+0x52/0x5a
Aug  7 09:55:42 copperhead klogd:  [<ffffffff883a1598>] :sunrpc:rpc_call_sync+0x3f/0x5d
Aug  7 09:55:42 copperhead klogd:  [<ffffffff8840c0bb>] :nfs:nfs3_rpc_wrapper+0x22/0x5c
Aug  7 09:55:42 copperhead klogd:  [<ffffffff8840c5b5>] :nfs:nfs3_proc_access+0xf3/0x15e
Aug  7 09:55:42 copperhead klogd:  [<ffffffff883ffde0>] :nfs:nfs_do_access+0x173/0x341
Aug  7 09:55:42 copperhead klogd:  [<ffffffff884000a3>] :nfs:nfs_permission+0xf5/0x166
Aug  7 09:55:42 copperhead klogd:  [<ffffffff802a7497>] permission+0xc7/0x118
Aug  7 09:55:42 copperhead klogd:  [<ffffffff802a7bbc>] lookup_hash+0x21/0x43
Aug  7 09:55:42 copperhead klogd:  [<ffffffff802ab6d8>] open_namei+0xe8/0x6a0
Aug  7 09:55:42 copperhead klogd:  [<ffffffff8029ec5b>] do_filp_open+0x28/0x4b
Aug  7 09:55:42 copperhead klogd:  [<ffffffff8029eccf>] do_sys_open+0x51/0xd2
Aug  7 09:55:42 copperhead klogd:  [<ffffffff8029ed79>] sys_open+0x1b/0x1d
Aug  7 09:55:42 copperhead klogd:  [<ffffffff8020bffa>] system_call_after_swapgs+0x8a/0x8f
Aug  7 09:55:42 copperhead klogd: DWARF2 unwinder stuck at system_call_after_swapgs+0x8a/0x8f
Aug  7 09:55:42 copperhead klogd:
Aug  7 09:55:42 copperhead klogd: Leftover inexact backtrace:
Aug  7 09:55:42 copperhead klogd:
Aug  7 09:55:42 copperhead syslog-ng[2774]: last message repeated 2 times
Aug  7 09:55:42 copperhead klogd: Code: 3b 88 44 8b 4b 44 44 8b 43 40 48 c7 c7
57 74 3b 88 48 8b 4b 50 89 04 24 31 c0 e8 ed 24 0a f8 4c 8b bb e8 00 00 00 49
39 df 74 04 <0f> 0b eb fe 49 8d 85 78 02 00 00 48 89 85 f8 fe ff ff f0 0f ba
Aug  7 09:55:42 copperhead klogd: RIP  [<ffffffff883ad55a>] :sunrpc:rpcb_getport_async+0x66/0x460
Aug  7 09:55:42 copperhead klogd:  RSP <ffff810110cff938>
Aug  7 09:55:42 copperhead klogd: ---[ end trace 4b516acb183486f8 ]---

Kernel was
   Linux copperhead 2.6.25.11-0.1-default #1 SMP 2008-07-13 20:48:28 +0200 x86_64 x86_64 x86_64 GNU/Linux

NeilBrown
