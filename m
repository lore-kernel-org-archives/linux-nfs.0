Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30873 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbcEATwa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 May 2016 15:52:30 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Cannot use NFS with linux-next 20160429
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAOMZO5D9dTFRbT0CMOdM3aGb1cLd+n8udQQH0K=onZ7Z-4onmw@mail.gmail.com>
Date: Sun, 1 May 2016 15:52:19 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <13CA7D80-3F3D-4D92-9E52-1434BD8047DE@oracle.com>
References: <CAOMZO5D9dTFRbT0CMOdM3aGb1cLd+n8udQQH0K=onZ7Z-4onmw@mail.gmail.com>
To: Fabio Estevam <festevam@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Fabio-

> On Apr 29, 2016, at 7:18 PM, Fabio Estevam <festevam@gmail.com> wrote:
> 
> Hi,
> 
> NFS is not working on a imx6q-sabresd board running linux-next 20160429:
> 
> [   15.753317]   #0: wm8962-audio
> [   15.759437] Root-NFS: no NFS server address

At a glance, that looks like the NFSROOT mount options are
invalid? First, confirm what is specified on the kernel
cmdline.

I'm not aware of any recent changes to NFSROOT. Often
these NFSROOT problems turn out to be related to churn in
the underlying Ethernet drivers or the generic code that
handles mounting the root filesystem at boot time.

Thus a second suggestion would be to use "git bisect".


> [   15.763649] VFS: Unable to mount root fs via NFS, trying floppy.
> [   15.774223] VFS: Cannot open root device "nfs" or
> unknown-block(2,0): error -6
> [   15.781540] Please append a correct "root=" boot option; here are
> the available partitions:
> [   15.790145] 0100           65536 ram0  (driver?)
> [   15.794837] 0101           65536 ram1  (driver?)
> [   15.799576] 0102           65536 ram2  (driver?)
> [   15.804262] 0103           65536 ram3  (driver?)
> [   15.809023] 0104           65536 ram4  (driver?)
> [   15.813710] 0105           65536 ram5  (driver?)
> [   15.818392] 0106           65536 ram6  (driver?)
> [   15.823121] 0107           65536 ram7  (driver?)
> [   15.827804] 0108           65536 ram8  (driver?)
> [   15.832531] 0109           65536 ram9  (driver?)
> [   15.837213] 010a           65536 ram10  (driver?)
> [   15.841989] 010b           65536 ram11  (driver?)
> [   15.846729] 010c           65536 ram12  (driver?)
> [   15.851491] 010d           65536 ram13  (driver?)
> [   15.856228] 010e           65536 ram14  (driver?)
> [   15.860992] 010f           65536 ram15  (driver?)
> [   15.865742] 1f00            4096 mtdblock0  (driver?)
> [   15.870853] b300         3872256 mmcblk1  driver: mmcblk
> [   15.876199] b308         7757824 mmcblk2  driver: mmcblk
> [   15.881570] b320             128 mmcblk2rpmb  (driver?)
> [   15.886830] b318            1024 mmcblk2boot1  (driver?)
> [   15.892201] b310            1024 mmcblk2boot0  (driver?)
> [   15.897541] Kernel panic - not syncing: VFS: Unable to mount root
> fs on unknown-block(2,0)
> [   15.905978] CPU0: stopping
> [   15.908704] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
> 4.6.0-rc5-next-20160429 #349
> [   15.916284] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
> [   15.922818] Backtrace:
> [   15.925316] [<c010b6f8>] (dump_backtrace) from [<c010b894>]
> (show_stack+0x18/0x1c)
> [   15.932893]  r6:60000193 r5:ffffffff r4:00000000 r3:00000000
> [   15.938649] [<c010b87c>] (show_stack) from [<c03df190>]
> (dump_stack+0xb0/0xe8)
> [   15.945889] [<c03df0e0>] (dump_stack) from [<c010edec>]
> (handle_IPI+0x174/0x1a4)
> [   15.953292]  r8:c0d01f08 r7:c0c746ec r6:00000000 r5:c0d02b10
> r4:00000000 r3:c0d05e80
> [   15.961147] [<c010ec78>] (handle_IPI) from [<c0101618>]
> (gic_handle_irq+0x8c/0x9c)
> [   15.968722]  r8:c0d21f80 r7:c0d02c58 r6:c0d01f08 r5:f400010c
> r4:f4000100 r3:00000c04
> [   15.976573] [<c010158c>] (gic_handle_irq) from [<c010c4b8>]
> (__irq_svc+0x58/0x78)
> [   15.984065] Exception stack(0xc0d01f08 to 0xc0d01f50)
> [   15.989129] 1f00:                   00000001 00000001 00000000
> c011b920 00000000 c0d02984
> [   15.997318] 1f20: 00000000 00000000 c0c757b8 c0d029d8 c0d029d0
> c0d01f64 c0d01f28 c0d01f58
> [   16.005505] 1f40: c016d120 c01089e0 20000013 ffffffff
> [   16.010563]  r10:c0d029d0 r9:c0d029d8 r8:c0c757b8 r7:c0d01f3c
> r6:ffffffff r5:20000013
> [   16.018495]  r4:c01089e0 r3:c0d05e80
> [   16.022130] [<c01089b8>] (arch_cpu_idle) from [<c01661a0>]
> (default_idle_call+0x28/0x38)
> [   16.030236] [<c0166178>] (default_idle_call) from [<c0166378>]
> (cpu_startup_entry+0x1c8/0x24c)
> [   16.038864] [<c01661b0>] (cpu_startup_entry) from [<c08edd78>]
> (rest_init+0x12c/0x16c)
> [   16.046788]  r7:c0c5da48 r3:00000000
> [   16.050417] [<c08edc4c>] (rest_init) from [<c0c00cbc>]
> (start_kernel+0x340/0x3b0)
> [   16.057906]  r5:ffffffff r4:c0d6e050
> [   16.061532] [<c0c0097c>] (start_kernel) from [<1000807c>] (0x1000807c)
> [   16.068067]  r10:00000000 r8:1000406a r7:c0d0780c r6:c0c5da44
> r5:c0d0296c r4:c0d6e294
> [   16.076002] CPU2: stopping
> [   16.078725] CPU: 2 PID: 0 Comm: swapper/2 Not tainted
> 4.6.0-rc5-next-20160429 #349
> [   16.086302] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
> [   16.092836] Backtrace:
> [   16.095320] [<c010b6f8>] (dump_backtrace) from [<c010b894>]
> (show_stack+0x18/0x1c)
> [   16.102897]  r6:60000193 r5:ffffffff r4:00000000 r3:00000000
> [   16.108646] [<c010b87c>] (show_stack) from [<c03df190>]
> (dump_stack+0xb0/0xe8)
> [   16.115883] [<c03df0e0>] (dump_stack) from [<c010edec>]
> (handle_IPI+0x174/0x1a4)
> [   16.123286]  r8:ef0a5f58 r7:c0c746ec r6:00000000 r5:c0d02b10
> r4:00000002 r3:ef0a8000
> [   16.131138] [<c010ec78>] (handle_IPI) from [<c0101618>]
> (gic_handle_irq+0x8c/0x9c)
> [   16.138713]  r8:c0d21f80 r7:c0d02c58 r6:ef0a5f58 r5:f400010c
> r4:f4000100 r3:00000c04
> [   16.146562] [<c010158c>] (gic_handle_irq) from [<c010c4b8>]
> (__irq_svc+0x58/0x78)
> [   16.154052] Exception stack(0xef0a5f58 to 0xef0a5fa0)
> [   16.159112] 5f40:
>    00000001 00000001
> [   16.167301] 5f60: 00000000 c011b920 00000000 c0d02984 00000000
> 00000000 c0c757b8 c0d029d8
> [   16.175489] 5f80: c0d029d0 ef0a5fb4 ef0a5f78 ef0a5fa8 c016d120
> c01089e0 20000013 ffffffff
> [   16.183672]  r10:c0d029d0 r9:c0d029d8 r8:c0c757b8 r7:ef0a5f8c
> r6:ffffffff r5:20000013
> [   16.191601]  r4:c01089e0 r3:ef0a8000
> [   16.195230] [<c01089b8>] (arch_cpu_idle) from [<c01661a0>]
> (default_idle_call+0x28/0x38)
> [   16.203334] [<c0166178>] (default_idle_call) from [<c0166378>]
> (cpu_startup_entry+0x1c8/0x24c)
> [   16.211959] [<c01661b0>] (cpu_startup_entry) from [<c010ea14>]
> (secondary_start_kernel+0x130/0x154)
> [   16.221010]  r7:c0d6e388 r3:00000004
> [   16.224633] [<c010e8e4>] (secondary_start_kernel) from [<101016cc>]
> (0x101016cc)
> [   16.232035]  r5:00000051 r4:3f08806a
> [   16.235656] CPU1: stopping
> [   16.238378] CPU: 1 PID: 0 Comm: swapper/1 Not tainted
> 4.6.0-rc5-next-20160429 #349
> [   16.245954] Hardware name: Freescale i.MX6 Quad/DualLite (Device Tree)
> [   16.252487] Backtrace:
> [   16.254970] [<c010b6f8>] (dump_backtrace) from [<c010b894>]
> (show_stack+0x18/0x1c)
> [   16.262545]  r6:60000193 r5:ffffffff r4:00000000 r3:00000000
> [   16.268291] [<c010b87c>] (show_stack) from [<c03df190>]
> (dump_stack+0xb0/0xe8)
> [   16.275529] [<c03df0e0>] (dump_stack) from [<c010edec>]
> (handle_IPI+0x174/0x1a4)
> [   16.282931]  r8:ef0a3f58 r7:c0c746ec r6:00000000 r5:c0d02b10
> r4:00000001 r3:ef076c00
> [   16.290777] [<c010ec78>] (handle_IPI) from [<c0101618>]
> (gic_handle_irq+0x8c/0x9c)
> [   16.298353]  r8:c0d21f80 r7:c0d02c58 r6:ef0a3f58 r5:f400010c
> r4:f4000100 r3:00000c04
> [   16.306199] [<c010158c>] (gic_handle_irq) from [<c010c4b8>]
> (__irq_svc+0x58/0x78)
> [   16.313688] Exception stack(0xef0a3f58 to 0xef0a3fa0)
> [   16.318747] 3f40:
>    00000001 00000001
> [   16.326935] 3f60: 00000000 c011b920 00000000 c0d02984 00000000
> 00000000 c0c757b8 c0d029d8
> [   16.335123] 3f80: c0d029d0 ef0a3fb4 ef0a3f78 ef0a3fa8 c016d120
> c01089e0 20000013 ffffffff
> [   16.343304]  r10:c0d029d0 r9:c0d029d8 r8:c0c757b8 r7:ef0a3f8c
> r6:ffffffff r5:20000013
> [   16.351230]  r4:c01089e0 r3:ef076c00
> [   16.354856] [<c01089b8>] (arch_cpu_idle) from [<c01661a0>]
> (default_idle_call+0x28/0x38)
> [   16.362961] [<c0166178>] (default_idle_call) from [<c0166378>]
> (cpu_startup_entry+0x1c8/0x24c)
> [   16.371585] [<c01661b0>] (cpu_startup_entry) from [<c010ea14>]
> (secondary_start_kernel+0x130/0x154)
> [   16.380635]  r7:c0d6e388 r3:00000002
> [   16.384256] [<c010e8e4>] (secondary_start_kernel) from [<101016cc>]
> (0x101016cc)
> [   16.391657]  r5:00000051 r4:3f08806a
> [   16.395300] ---[ end Kernel panic - not syncing: VFS: Unable to
> mount root fs on unknown-block(2,0)
> 
> Any ideas? Thanks
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



