Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vint.altlinux.org ([194.107.17.35]:37395 "EHLO
	vint.altlinux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732Ab2FKSRV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jun 2012 14:17:21 -0400
Received: from imap.altlinux.org (imap.altlinux.org [194.107.17.38])
	by vint.altlinux.org (Postfix) with ESMTP id D9CB13F80011
	for <linux-nfs@vger.kernel.org>; Mon, 11 Jun 2012 18:07:24 +0000 (UTC)
To: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 regression, kernel BUG at fs/nfsd/nfs4state.c:1044!
References: <20120610090342.GA5076@cucamonga.audible.transient.net>
From: Sergey Bolshakov <sbolshakov@altlinux.ru>
Date: Mon, 11 Jun 2012 22:07:23 +0400
In-Reply-To: <20120610090342.GA5076@cucamonga.audible.transient.net> (Jamie Heilman's message of "Sun, 10 Jun 2012 09:03:42 +0000")
Message-ID: <m37gvd3ep0.fsf@hammer.lioka.obninsk.ru>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=


Same here, although i do not even need to shutdown client,
oops on server takes place just within minutes after mounting
via v4 on sole client:

--=-=-=
Content-Disposition: inline; filename=oops

------------[ cut here ]------------
kernel BUG at fs/nfsd/nfs4state.c:1044!
Internal error: Oops - BUG: 0 [#1] ARM
Modules linked in: nfsd nfs lockd auth_rpcgss nfs_acl autofs4 sunrpc iptable_filter ip_tables x_tables dm_mod ehci_hcd usbcore f75111 usb_common e1000 ext4 mbcache jbd2 sata_vsc libata sd_mod scsi_mod
CPU: 0    Not tainted  (3.4.0-iop32x-alt1 #1)
PC is at expire_client+0x15c/0x16c [nfsd]
LR is at flush_workqueue+0x320/0x330
pc : [<bf2e2c7c>]    lr : [<c002bcd8>]    psr: 60000013
sp : df26bf30  ip : df268044  fp : dc473e05
r10: 0000009a  r9 : c03f3d00  r8 : dfacc000
r7 : df26bf48  r6 : df26bf48  r5 : dfacc010  r4 : dfacc000
r3 : 00000000  r2 : dfacc280  r1 : dfacc280  r0 : df26bf48
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 0000397f  Table: bfabc000  DAC: 00000017
Process kworker/u:3 (pid: 497, stack limit = 0xdf26a278)
Stack: (0xdf26bf30 to 0xdf26c000)
bf20:                                     df26bf30 df26bf30 df073400 0000005a
bf40: 4fd35d85 bf2e372c df26bf48 df26bf48 df229000 dc473e00 bf2e35e8 00000000
bf60: bf2eefb0 c03f3d00 0000009a c002b0e8 df229000 df229000 c03f3b80 df26a000
bf80: df229010 c03ed007 c03f3d00 00000001 c03d321c c002cd20 df229000 df07bb00
bfa0: a0000013 df269f18 df229000 df26bfd4 c002cb3c 00000000 00000000 00000000
bfc0: 00000000 c00304e4 c00096a4 00000000 df229000 00000000 df26bfd8 df26bfd8
bfe0: 00000000 df269f18 c003045c c00096a4 00000013 c00096a4 00000000 00000000
[<bf2e2c7c>] (expire_client+0x15c/0x16c [nfsd]) from [<bf2e372c>] (laundromat_main+0x144/0x26c [nfsd])
[<bf2e372c>] (laundromat_main+0x144/0x26c [nfsd]) from [<c002b0e8>] (process_one_work+0x244/0x3f8)
[<c002b0e8>] (process_one_work+0x244/0x3f8) from [<c002cd20>] (worker_thread+0x1e4/0x314)
[<c002cd20>] (worker_thread+0x1e4/0x314) from [<c00304e4>] (kthread+0x88/0x94)
[<c00304e4>] (kthread+0x88/0x94) from [<c00096a4>] (kernel_thread_exit+0x0/0x8)
Code: 1afffff3 e5943300 e3530000 1a000000 (e7f001f2)
---[ end trace df220aa7c4aab192 ]---
Unable to handle kernel paging request at virtual address fffffffc
pgd = c0004000
[fffffffc] *pgd=bfffe821, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#2] ARM
Modules linked in: nfsd nfs lockd auth_rpcgss nfs_acl autofs4 sunrpc iptable_filter ip_tables x_tables dm_mod ehci_hcd usbcore f75111 usb_common e1000 ext4 mbcache jbd2 sata_vsc libata sd_mod scsi_mod
CPU: 0    Tainted: G      D       (3.4.0-iop32x-alt1 #1)
PC is at kthread_data+0x4/0xc
LR is at wq_worker_sleeping+0xc/0xb4
pc : [<c00306d4>]    lr : [<c002ceb0>]    psr: 20000093
sp : df26bd30  ip : 00000000  fp : df26bdb4
r10: c028a1e8  r9 : df07bbf8  r8 : df07bc74
r7 : 00000001  r6 : df26a000  r5 : c03d38a8  r4 : 00000000
r3 : 00000000  r2 : df800160  r1 : 00000000  r0 : df07bb00
Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 0000397f  Table: bfabc000  DAC: 00000015
Process kworker/u:3 (pid: 497, stack limit = 0xdf26a278)
Stack: (0xdf26bd30 to 0xdf26c000)
bd20:                                     df07bb00 c028144c 00000000 00373934
bd40: df07bb30 df10a3e0 c001848c 00001374 df10a3e0 c001848c 00001374 c03d0ca0
bd60: c03ee054 c00ac270 c03ee04c df07bb00 df145540 00000001 df07bb00 c00184bc
bd80: 04208064 df10a3e0 00000000 c03f7c60 df26bd90 df07bb00 00000001 df26bdbc
bda0: 00000001 00000001 df07bbf8 00000001 df07baf8 c0019bc0 c0282168 df26bdbc
bdc0: df26bdbc df07bc40 df26bddc df26bea8 df26a000 df07bb00 00000001 00000000
bde0: c0282168 0000009a dc473e05 c000bea4 df26a278 0000000b df26bea8 bf2e2c7c
be00: 070001f0 df26bedc dfacc000 c0008364 00000006 00000000 00000004 00000000
be20: 00030001 bf2e2c7c 4328ac7d 00000153 00000001 20000013 df34a000 df263400
be40: 00000000 00000000 ded1455c 7fffffff 7fffffff df26a000 00000002 00000000
be60: c03f3d00 00000000 df26bee4 c0280398 df07bb30 df07af30 df07bb00 df07af00
be80: c03d3d10 c03d38a8 df07bb30 c003e890 c03d38a8 7fffffff bf2e2c80 60000013
bea0: ffffffff c0282168 df26bf48 dfacc280 dfacc280 00000000 dfacc000 dfacc010
bec0: df26bf48 df26bf48 dfacc000 c03f3d00 0000009a dc473e05 df268044 df26bf30
bee0: c002bcd8 bf2e2c7c 60000013 ffffffff df26beec 00000000 00000000 df26befc
bf00: df26befc 00000000 df26befc df26befc dc473e05 dfacc000 dfacc010 df26bf48
bf20: df26bf48 dfacc000 0000009a bf2e2bd4 df26bf30 df26bf30 df073400 0000005a
bf40: 4fd35d85 bf2e372c df26bf48 df26bf48 df229000 dc473e00 bf2e35e8 00000000
bf60: bf2eefb0 c03f3d00 0000009a c002b0e8 df229000 df229000 c03f3b80 df26a000
bf80: df229010 c03ed007 c03f3d00 00000001 c03d321c c002cd20 df229000 df07bb00
bfa0: a0000013 df269f18 df229000 df26bfd4 c002cb3c 00000000 00000000 00000000
bfc0: 00000000 c00304e4 c00096a4 00000000 df229000 00000001 df26bfd8 df26bfd8
bfe0: 00000000 df269f18 c003045c c00096a4 00000013 c00096a4 00000000 00000000
[<c00306d4>] (kthread_data+0x4/0xc) from [<c002ceb0>] (wq_worker_sleeping+0xc/0xb4)
[<c002ceb0>] (wq_worker_sleeping+0xc/0xb4) from [<c028144c>] (__schedule+0xd0/0x3d0)
[<c028144c>] (__schedule+0xd0/0x3d0) from [<c0019bc0>] (do_exit+0x6f4/0x72c)
[<c0019bc0>] (do_exit+0x6f4/0x72c) from [<c000bea4>] (die+0x1d8/0x208)
[<c000bea4>] (die+0x1d8/0x208) from [<c0008364>] (do_undefinstr+0x160/0x180)
[<c0008364>] (do_undefinstr+0x160/0x180) from [<c0282168>] (__und_svc+0x48/0x60)
Exception stack(0xdf26bea8 to 0xdf26bef0)
bea0:                   df26bf48 dfacc280 dfacc280 00000000 dfacc000 dfacc010
bec0: df26bf48 df26bf48 dfacc000 c03f3d00 0000009a dc473e05 df268044 df26bf30
bee0: c002bcd8 bf2e2c7c 60000013 ffffffff
[<c0282168>] (__und_svc+0x48/0x60) from [<bf2e2c7c>] (expire_client+0x15c/0x16c [nfsd])
[<bf2e2c7c>] (expire_client+0x15c/0x16c [nfsd]) from [<bf2e372c>] (laundromat_main+0x144/0x26c [nfsd])
[<bf2e372c>] (laundromat_main+0x144/0x26c [nfsd]) from [<c002b0e8>] (process_one_work+0x244/0x3f8)
[<c002b0e8>] (process_one_work+0x244/0x3f8) from [<c002cd20>] (worker_thread+0x1e4/0x314)
[<c002cd20>] (worker_thread+0x1e4/0x314) from [<c00304e4>] (kthread+0x88/0x94)
[<c00304e4>] (kthread+0x88/0x94) from [<c00096a4>] (kernel_thread_exit+0x0/0x8)
Code: c03f3fa8 c02899c4 c0289018 e5903148 (e5130004)
---[ end trace df220aa7c4aab193 ]---
Fixing recursive fault but reboot is needed!
Unable to handle kernel paging request at virtual address fffffffc
pgd = c0004000
[fffffffc] *pgd=bfffe821, *pte=00000000, *ppte=00000000
Internal error: Oops: 17 [#3] ARM
Modules linked in: nfsd nfs lockd auth_rpcgss nfs_acl autofs4 sunrpc iptable_filter ip_tables x_tables dm_mod ehci_hcd usbcore f75111 usb_common e1000 ext4 mbcache jbd2 sata_vsc libata sd_mod scsi_mod
CPU: 0    Tainted: G      D       (3.4.0-iop32x-alt1 #1)
PC is at kthread_data+0x4/0xc
LR is at wq_worker_sleeping+0xc/0xb4
pc : [<c00306d4>]    lr : [<c002ceb0>]    psr: 20000093
sp : df26bac8  ip : c03ee554  fp : df26bb4c
r10: c028a1e8  r9 : 00000028  r8 : df07bc74
r7 : 00000001  r6 : df26a000  r5 : c03d38a8  r4 : 00000000
r3 : 00000000  r2 : df800160  r1 : 00000000  r0 : df07bb00
Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 0000397f  Table: bfabc000  DAC: 00000015
Process kworker/u:3 (pid: 497, stack limit = 0xdf26a278)
Stack: (0xdf26bac8 to 0xdf26c000)
bac0:                   df07bb00 c028144c 60000013 c00171f4 00000001 60000013
bae0: 00000001 c03f29e4 00000001 c001bca0 00000000 c03d5d54 00000000 ffffffff
bb00: 00000001 00ffffff 00000000 df07bb00 0000000b df07bb00 00000001 00000017
bb20: 00000028 00000017 df26bdb4 df07bb00 0000000b df07bb00 00000001 00000017
bb40: 00000028 00000017 df26bdb4 c00195e4 00000028 00000017 00000001 c033d206
bb60: df26bb74 df26bce8 df26a000 df07bb00 00000001 00000017 00000028 00000017
bb80: df26bdb4 c000bea4 df26a278 0000000b fffffffc 00000017 00000000 df26bce8
bba0: 00000000 c0010074 df26bce8 00000007 fffffffc df07bb00 00000000 c02838b8
bbc0: 00000000 00000000 0a91b739 00000000 14303a9d c03d38a8 df07bb30 df366720
bbe0: df07bb00 df3b6f00 c03d3d10 c03d38a8 df26bc24 c003e8b0 c03d38a8 c028a1e8
bc00: 00000000 00000000 00000001 00000000 00000000 c003aa2c df3b6f00 df3b6f00
bc20: df26bc3c 00000017 00000007 fffffffc df26bce8 c03ce104 df07bbf8 c028a1e8
bc40: df26bdb4 c00083b4 00000002 df26bc6c df26bd49 c0176344 00000000 00000000
bc60: c03d38a8 dc60e630 00000000 00343937 dc60e630 ffffffff ffffffff df580a80
bc80: df580a80 000057da df26a000 00000000 df580a80 c00885c4 df26bc98 df26bc98
bca0: df581364 df5812e0 df5812e0 df580a80 df580a80 df26bd30 df26bd49 c03d38f0
bcc0: df07bb30 00000001 c03d38a8 00000001 c00306d4 20000093 ffffffff df26bd1c
bce0: df07bc74 c0282078 df07bb00 00000000 df800160 00000000 00000000 c03d38a8
bd00: df26a000 00000001 df07bc74 df07bbf8 c028a1e8 df26bdb4 00000000 df26bd30
bd20: c002ceb0 c00306d4 20000093 ffffffff df07bb00 c028144c 00000000 00373934
bd40: df07bb30 df10a3e0 c001848c 00001374 df10a3e0 c001848c 00001374 c03d0ca0
bd60: c03ee054 c00ac270 c03ee04c df07bb00 df145540 00000001 df07bb00 c00184bc
bd80: 04208064 df10a3e0 00000000 c03f7c60 df26bd90 df07bb00 00000001 df26bdbc
bda0: 00000001 00000001 df07bbf8 00000001 df07baf8 c0019bc0 c0282168 df26bdbc
bdc0: df26bdbc df07bc40 df26bddc df26bea8 df26a000 df07bb00 00000001 00000000
bde0: c0282168 0000009a dc473e05 c000bea4 df26a278 0000000b df26bea8 bf2e2c7c
be00: 070001f0 df26bedc dfacc000 c0008364 00000006 00000000 00000004 00000000
be20: 00030001 bf2e2c7c 4328ac7d 00000153 00000001 20000013 df34a000 df263400
be40: 00000000 00000000 ded1455c 7fffffff 7fffffff df26a000 00000002 00000000
be60: c03f3d00 00000000 df26bee4 c0280398 df07bb30 df07af30 df07bb00 df07af00
be80: c03d3d10 c03d38a8 df07bb30 c003e890 c03d38a8 7fffffff bf2e2c80 60000013
bea0: ffffffff c0282168 df26bf48 dfacc280 dfacc280 00000000 dfacc000 dfacc010
bec0: df26bf48 df26bf48 dfacc000 c03f3d00 0000009a dc473e05 df268044 df26bf30
bee0: c002bcd8 bf2e2c7c 60000013 ffffffff df26beec 00000000 00000000 df26befc
bf00: df26befc 00000000 df26befc df26befc dc473e05 dfacc000 dfacc010 df26bf48
bf20: df26bf48 dfacc000 0000009a bf2e2bd4 df26bf30 df26bf30 df073400 0000005a
bf40: 4fd35d85 bf2e372c df26bf48 df26bf48 df229000 dc473e00 bf2e35e8 00000000
bf60: bf2eefb0 c03f3d00 0000009a c002b0e8 df229000 df229000 c03f3b80 df26a000
bf80: df229010 c03ed007 c03f3d00 00000001 c03d321c c002cd20 df229000 df07bb00
bfa0: a0000013 df269f18 df229000 df26bfd4 c002cb3c 00000000 00000000 00000000
bfc0: 00000000 c00304e4 c00096a4 00000000 df229000 00000001 df26bfd8 df26bfd8
bfe0: 00000000 df269f18 c003045c c00096a4 00000013 c00096a4 00000000 00000000
[<c00306d4>] (kthread_data+0x4/0xc) from [<c002ceb0>] (wq_worker_sleeping+0xc/0xb4)
[<c002ceb0>] (wq_worker_sleeping+0xc/0xb4) from [<c028144c>] (__schedule+0xd0/0x3d0)
[<c028144c>] (__schedule+0xd0/0x3d0) from [<c00195e4>] (do_exit+0x118/0x72c)
[<c00195e4>] (do_exit+0x118/0x72c) from [<c000bea4>] (die+0x1d8/0x208)
[<c000bea4>] (die+0x1d8/0x208) from [<c0010074>] (__do_kernel_fault+0x64/0x88)
[<c0010074>] (__do_kernel_fault+0x64/0x88) from [<c02838b8>] (do_page_fault+0x35c/0x384)
[<c02838b8>] (do_page_fault+0x35c/0x384) from [<c00083b4>] (do_DataAbort+0x30/0x98)
[<c00083b4>] (do_DataAbort+0x30/0x98) from [<c0282078>] (__dabt_svc+0x38/0x60)
Exception stack(0xdf26bce8 to 0xdf26bd30)
bce0:                   df07bb00 00000000 df800160 00000000 00000000 c03d38a8
bd00: df26a000 00000001 df07bc74 df07bbf8 c028a1e8 df26bdb4 00000000 df26bd30
bd20: c002ceb0 c00306d4 20000093 ffffffff
[<c0282078>] (__dabt_svc+0x38/0x60) from [<c00306d4>] (kthread_data+0x4/0xc)
[<c00306d4>] (kthread_data+0x4/0xc) from [<c002ceb0>] (wq_worker_sleeping+0xc/0xb4)
[<c002ceb0>] (wq_worker_sleeping+0xc/0xb4) from [<c028144c>] (__schedule+0xd0/0x3d0)
[<c028144c>] (__schedule+0xd0/0x3d0) from [<c0019bc0>] (do_exit+0x6f4/0x72c)
[<c0019bc0>] (do_exit+0x6f4/0x72c) from [<c000bea4>] (die+0x1d8/0x208)
[<c000bea4>] (die+0x1d8/0x208) from [<c0008364>] (do_undefinstr+0x160/0x180)
[<c0008364>] (do_undefinstr+0x160/0x180) from [<c0282168>] (__und_svc+0x48/0x60)
Exception stack(0xdf26bea8 to 0xdf26bef0)
bea0:                   df26bf48 dfacc280 dfacc280 00000000 dfacc000 dfacc010
bec0: df26bf48 df26bf48 dfacc000 c03f3d00 0000009a dc473e05 df268044 df26bf30
bee0: c002bcd8 bf2e2c7c 60000013 ffffffff
[<c0282168>] (__und_svc+0x48/0x60) from [<bf2e2c7c>] (expire_client+0x15c/0x16c [nfsd])
[<bf2e2c7c>] (expire_client+0x15c/0x16c [nfsd]) from [<bf2e372c>] (laundromat_main+0x144/0x26c [nfsd])
[<bf2e372c>] (laundromat_main+0x144/0x26c [nfsd]) from [<c002b0e8>] (process_one_work+0x244/0x3f8)
[<c002b0e8>] (process_one_work+0x244/0x3f8) from [<c002cd20>] (worker_thread+0x1e4/0x314)
[<c002cd20>] (worker_thread+0x1e4/0x314) from [<c00304e4>] (kthread+0x88/0x94)
[<c00304e4>] (kthread+0x88/0x94) from [<c00096a4>] (kernel_thread_exit+0x0/0x8)
Code: c03f3fa8 c02899c4 c0289018 e5903148 (e5130004)
---[ end trace df220aa7c4aab194 ]---

--=-=-=


-- 

--=-=-=--
