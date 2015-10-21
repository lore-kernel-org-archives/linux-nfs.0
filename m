Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51416 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754932AbbJUU1Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Oct 2015 16:27:24 -0400
Date: Wed, 21 Oct 2015 16:27:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Hans-Peter Budek <peter.budek@gmx.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS related bug in 3.14.54
Message-ID: <20151021202722.GA28748@fieldses.org>
References: <562775EE.1060208@gmx.de>
 <20151021153428.GA27929@fieldses.org>
 <5627E554.1050901@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5627E554.1050901@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 21, 2015 at 09:19:48PM +0200, Hans-Peter Budek wrote:
> J. Bruce Fields wrote:
> > On Wed, Oct 21, 2015 at 01:24:30PM +0200, Hans-Peter Budek wrote:
> >> A diskless station which mounts my NFS server as root device
> >> (nolock,nfsvers=3,vers=3)causes a kernel bug on my server:
> > 
> > I don't have the bandwidth to handle all bugs myself, would you mind
> > resending this with a cc: to linux-nfs@vger.kernel.org?
> > 
> > Doesn't ring any bells off the top of my head.
> > 
> > I'd also be curious to know whether this is reproduceable (e.g., if it
> > happens every (or most) times you boot this client, and whether there
> > was some previous kernel version where this didn't happen (so, did this
> > just start happening on an upgrade of your server's kernel).
> 
> I checked this about 10 times. This happend every time with a similar kernel
> log. The contents of some registers and the stack was slightly different but
> the call trace and the dereference of 0x8 remained the same.
> I had to reboot my server each time because it doesn't respond to nfs mount
> requests after the trap.
> The previous kernel version was 3.14.35 which seems to work.

Between 3.14.35 and 3.14.54 I don't see any interesting changes in
fs/nfsd or net/sunrpc.

Given where it happened this could be due to a networking change.

Unless someone comes up with a better idea, another option may just be
to a search by bisection between those two versions.

--b.

> 
> Cheers,
> Peter
> > 
> > --b.
> > 
> >>
> >> Oct 21 12:44:34 falco kernel: [64002.882741] NFSD: the nfsdcld client tracking
> >> upcall will be removed in 3.10. Please transition to using nfsdcltrack.
> >> Oct 21 12:46:34 falco kernel: [64123.231017] NFSD: Unable to end grace period: -110
> >> ...
> >> Oct 21 13:00:12 falco kernel: [64941.364757] BUG: unable to handle kernel NULL
> >> pointer dereference at 0000000000000008
> >> Oct 21 13:00:12 falco kernel: [64941.364782] IP: [<ffffffff812de742>]
> >> skb_copy_and_csum_datagram_iovec+0x22/0x110
> >> Oct 21 13:00:12 falco kernel: [64941.364804] PGD 3d321067 PUD d9915067 PMD 0
> >> Oct 21 13:00:12 falco kernel: [64941.364819] Oops: 0000 [#1] SMP
> >> Oct 21 13:00:12 falco kernel: [64941.364831] Modules linked in: nfsd auth_rpcgss
> >> oid_registry nfs_acl lockd sunrpc ipv6 sg usb_storage ahci libahci rtc_cmos
> >> floppy evdev coretemp it87 hwmon_vid hwmon i2c_i801 acpi_cpufreq processor r8169
> >> mii pcspkr usbhid xhci_hcd uhci_hcd ehci_pci ehci_hcd usbcore usb_common
> >> rr2310_00(PO)
> >> Oct 21 13:00:12 falco kernel: [64941.364933] CPU: 0 PID: 23000 Comm: nfsd
> >> Tainted: P           O 3.14.54 #7
> >> Oct 21 13:00:12 falco kernel: [64941.364948] Hardware name: Gigabyte Technology
> >> Co., Ltd. EP35C-DS3R/EP35C-DS3R, BIOS F3 07/17/2008
> >> Oct 21 13:00:12 falco kernel: [64941.364966] task: ffff8801fe3fb170 ti:
> >> ffff88003cd84000 task.ti: ffff88003cd84000
> >> Oct 21 13:00:12 falco kernel: [64941.364982] RIP: 0010:[<ffffffff812de742>]
> >> [<ffffffff812de742>] skb_copy_and_csum_datagram_iovec+0x22/0x110
> >> Oct 21 13:00:12 falco kernel: [64941.365005] RSP: 0018:ffff88003cd85bd0  EFLAGS:
> >> 00010202
> >> Oct 21 13:00:12 falco kernel: [64941.365016] RAX: 0000000000000000 RBX:
> >> ffff8800e5e31880 RCX: 00000000000004f8
> >> Oct 21 13:00:12 falco kernel: [64941.365031] RDX: 0000000000000000 RSI:
> >> 0000000000001088 RDI: ffff8800d98e9e00
> >> Oct 21 13:00:12 falco kernel: [64941.365046] RBP: 0000000000000008 R08:
> >> 0000000000000000 R09: 00000000744d8bb2
> >> Oct 21 13:00:12 falco kernel: [64941.365108] R10: 00000000000004c0 R11:
> >> 0000000000000005 R12: ffff8800d98e9e00
> >> Oct 21 13:00:12 falco kernel: [64941.365171] R13: 0000000000001080 R14:
> >> 0000000000001080 R15: ffff8800d98e9e00
> >> Oct 21 13:00:12 falco kernel: [64941.365233] FS:  0000000000000000(0000)
> >> GS:ffff880213c00000(0000) knlGS:0000000000000000
> >> Oct 21 13:00:12 falco kernel: [64941.365344] CS:  0010 DS: 0000 ES: 0000 CR0:
> >> 000000008005003b
> >> Oct 21 13:00:12 falco kernel: [64941.365403] CR2: 0000000000000008 CR3:
> >> 00000000d80dd000 CR4: 00000000000007f0
> >> Oct 21 13:00:12 falco kernel: [64941.365465] Stack:
> >> Oct 21 13:00:12 falco kernel: [64941.365517]  ffff8800d98e9e00 ffffffff812d7f3d
> >> ffff8800e5e31880 ffff88003cd85dc8
> >> Oct 21 13:00:12 falco kernel: [64941.365632]  0000000000000000 0000000000000000
> >> 0000000000001080 ffffffff81331f82
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  0000004213c0c130 0000000000000002
> >> ffff8800e5e318f0 ffff880208ee4028
> >> Oct 21 13:00:12 falco kernel: [64941.365740] Call Trace:
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff812d7f3d>] ?
> >> skb_checksum+0x1d/0x30
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff81331f82>] ?
> >> udp_recvmsg+0x1e2/0x350
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff8133c028>] ?
> >> inet_recvmsg+0x48/0x80
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff812cf802>] ?
> >> sock_recvmsg+0x72/0x90
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff81042811>] ?
> >> lock_timer_base.isra.31+0x21/0x50
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff812cf850>] ?
> >> kernel_recvmsg+0x30/0x40
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffffa01c29a4>] ?
> >> svc_udp_recvfrom+0x84/0x3e0 [sunrpc]
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff81042cca>] ?
> >> del_timer_sync+0x4a/0x60
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff81371fbf>] ?
> >> schedule_timeout+0x12f/0x1d0
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffffa01ce231>] ?
> >> svc_recv+0x961/0x970 [sunrpc]
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff8105d240>] ?
> >> wake_up_process+0x30/0x30
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffffa021f66d>] ?
> >> nfsd+0x9d/0x120 [nfsd]
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffffa021f5d0>] ?
> >> nfsd_destroy+0x70/0x70 [nfsd]
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff810535f8>] ?
> >> kthread+0xb8/0xd0
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff81053540>] ?
> >> kthread_create_on_node+0x170/0x170
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff8137b258>] ?
> >> ret_from_fork+0x58/0x90
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  [<ffffffff81053540>] ?
> >> kthread_create_on_node+0x170/0x170
> >> Oct 21 13:00:12 falco kernel: [64941.365740] Code: a5 fe ff ff 0f 1f 44 00 00 41
> >> 56 31 c0 41 55 41 54 49 89 fc 55 89 f5 53 48 83 ec 10 8b 77 68 41 89 f5 41 29 ed
> >> 0f 84 88 00 00 00 <48> 8b 42 08 48 89 d3 48 85 c0 75 0f 66 90 48 83 c3 10 48 8b 43
> >> Oct 21 13:00:12 falco kernel: [64941.365740] RIP  [<ffffffff812de742>]
> >> skb_copy_and_csum_datagram_iovec+0x22/0x110
> >> Oct 21 13:00:12 falco kernel: [64941.365740]  RSP <ffff88003cd85bd0>
> >> Oct 21 13:00:12 falco kernel: [64941.365740] CR2: 0000000000000008
> >> Oct 21 13:00:12 falco kernel: [64941.367743] ---[ end trace 874f0a58b4dbd906 ]---
> >>
> >> Cheers,
> >> Peter
> > 
