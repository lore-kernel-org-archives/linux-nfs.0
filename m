Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41361 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041Ab3CKSTs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Mar 2013 14:19:48 -0400
Date: Mon, 11 Mar 2013 14:19:45 -0400
To: Mark Jackson <mpfj-list@mimc.co.uk>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
        Trond.Myklebust@netapp.com
Subject: Re: 3v9.0-rc2 oops on NFS mount
Message-ID: <20130311181945.GD30618@fieldses.org>
References: <513DCBD6.6010704@mimc.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <513DCBD6.6010704@mimc.co.uk>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 11, 2013 at 12:19:34PM +0000, Mark Jackson wrote:
> I'm getting a repeatable oops when mounting my rootfs over nfs:-

Known, and being worked on (but you can probably ignore it).

--b.

> 
> [    4.639415] =====================================
> [    4.644361] [ BUG: swapper/1 still has locks held! ]
> [    4.649617] 3.9.0-rc2-dirty #137 Not tainted
> [    4.654089] -------------------------------------
> [    4.659039] 1 lock held by swapper/1:
> [    4.662877]  #0:  (&type->s_umount_key#13/1){+.+.+.}, at: [<c00c9528>] sget+0x1a8/0x41c
> [    4.671349]
> [    4.671349] stack backtrace:
> [    4.675976] [<c00190c0>] (unwind_backtrace+0x0/0xf8) from [<c039f1ac>] (rpc_wait_bit_killable+0x90/0xc4)
> [    4.685953] [<c039f1ac>] (rpc_wait_bit_killable+0x90/0xc4) from [<c03ff6f0>] (__wait_on_bit+0x74/0xbc)
> [    4.695740] [<c03ff6f0>] (__wait_on_bit+0x74/0xbc) from [<c03ff8e8>] (out_of_line_wait_on_bit+0x80/0x88)
> [    4.705712] [<c03ff8e8>] (out_of_line_wait_on_bit+0x80/0x88) from [<c039fc58>] (__rpc_execute+0x1dc/0x2b0)
> [    4.715855] [<c039fc58>] (__rpc_execute+0x1dc/0x2b0) from [<c0399644>] (rpc_run_task+0x98/0xa4)
> [    4.724972] [<c0399644>] (rpc_run_task+0x98/0xa4) from [<c0399704>] (rpc_call_sync+0x4c/0xb4)
> [    4.733934] [<c0399704>] (rpc_call_sync+0x4c/0xb4) from [<c015f60c>] (nfs_proc_get_root+0x50/0x130)
> [    4.743445] [<c015f60c>] (nfs_proc_get_root+0x50/0x130) from [<c015219c>] (nfs_get_root+0x58/0x190)
> [    4.752954] [<c015219c>] (nfs_get_root+0x58/0x190) from [<c015717c>] (nfs_fs_mount_common+0x98/0x158)
> [    4.762632] [<c015717c>] (nfs_fs_mount_common+0x98/0x158) from [<c015742c>] (nfs_try_mount+0x150/0x20c)
> [    4.772504] [<c015742c>] (nfs_try_mount+0x150/0x20c) from [<c0156d40>] (nfs_fs_mount+0x3a4/0x5c8)
> [    4.781829] [<c0156d40>] (nfs_fs_mount+0x3a4/0x5c8) from [<c00ca648>] (mount_fs+0x44/0x17c)
> [    4.790611] [<c00ca648>] (mount_fs+0x44/0x17c) from [<c00e2528>] (vfs_kern_mount+0x4c/0xc0)
> [    4.799389] [<c00e2528>] (vfs_kern_mount+0x4c/0xc0) from [<c00e3c28>] (do_mount+0x704/0x878)
> [    4.808252] [<c00e3c28>] (do_mount+0x704/0x878) from [<c00e3e20>] (sys_mount+0x84/0xb8)
> [    4.816674] [<c00e3e20>] (sys_mount+0x84/0xb8) from [<c051abc8>] (do_mount_root+0x20/0xac)
> [    4.825347] [<c051abc8>] (do_mount_root+0x20/0xac) from [<c051afb8>] (mount_root+0x50/0xf4)
> [    4.834126] [<c051afb8>] (mount_root+0x50/0xf4) from [<c051b1bc>] (prepare_namespace+0x160/0x1c4)
> [    4.843449] [<c051b1bc>] (prepare_namespace+0x160/0x1c4) from [<c051aa58>] (kernel_init_freeable+0x168/0x1ac)
> [    4.853875] [<c051aa58>] (kernel_init_freeable+0x168/0x1ac) from [<c03fdf70>] (kernel_init+0x8/0xe4)
> [    4.863486] [<c03fdf70>] (kernel_init+0x8/0xe4) from [<c0013870>] (ret_from_fork+0x14/0x24)
> 
> Below is my full boot log.
> 
> Regards
> Mark JACKSON
> ---
> [    0.000000] Booting Linux on physical CPU 0x0
> [    0.000000] Linux version 3.9.0-rc2-dirty (mpfj@mpfj-nanobone) (gcc version 4.5.4 (Buildroot 2012.11) ) #137 Mon Mar 11 12:17:01 GMT 2013
> [    0.000000] CPU: ARMv7 Processor [413fc082] revision 2 (ARMv7), cr=10c53c7d
> [    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
> [    0.000000] Machine: Generic AM33XX (Flattened Device Tree), model: Newflow AM335x NanoBone
> [    0.000000] Memory policy: ECC disabled, Data cache writeback
> [    0.000000] CPU: All CPU(s) started in SVC mode.
> [    0.000000] AM335X ES1.0 (neon )
> [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64768
> [    0.000000] Kernel command line: root=/dev/nfs nfsroot=10.0.0.100:/tftpboot/nanobone/rootfs rw ip=10.0.101.111::10.0.0.100:::eth0:off console=ttyO0,115200
> [    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
> [    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
> [    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
> [    0.000000] __ex_table already sorted, skipping sort
> [    0.000000] Memory: 255MB = 255MB total
> [    0.000000] Memory: 247768k/247768k available, 14376k reserved, 0K highmem
> [    0.000000] Virtual kernel memory layout:
> [    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
> [    0.000000]     fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
> [    0.000000]     vmalloc : 0xd0800000 - 0xff000000   ( 744 MB)
> [    0.000000]     lowmem  : 0xc0000000 - 0xd0000000   ( 256 MB)
> [    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
> [    0.000000]       .text : 0xc0008000 - 0xc0519488   (5190 kB)
> [    0.000000]       .init : 0xc051a000 - 0xc054bffc   ( 200 kB)
> [    0.000000]       .data : 0xc054c000 - 0xc059d460   ( 326 kB)
> [    0.000000]        .bss : 0xc059d460 - 0xc0ac2250   (5268 kB)
> [    0.000000] NR_IRQS:16 nr_irqs:16 16
> [    0.000000] IRQ: Found an INTC at 0xfa200000 (revision 5.0) with 128 interrupts
> [    0.000000] Total of 128 interrupts on 1 active controller
> [    0.000000] OMAP clockevent source: GPTIMER1 at 26000000 Hz
> [    0.000000] sched_clock: 32 bits at 26MHz, resolution 38ns, wraps every 165191ms
> [    0.000000] OMAP clocksource: GPTIMER2 at 26000000 Hz
> [    0.000000] Console: colour dummy device 80x30
> [    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
> [    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
> [    0.000000] ... MAX_LOCK_DEPTH:          48
> [    0.000000] ... MAX_LOCKDEP_KEYS:        8191
> [    0.000000] ... CLASSHASH_SIZE:          4096
> [    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
> [    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
> [    0.000000] ... CHAINHASH_SIZE:          16384
> [    0.000000]  memory used by lock dependency info: 3695 kB
> [    0.000000]  per task-struct memory footprint: 1152 bytes
> [    0.000842] Calibrating delay loop... 476.77 BogoMIPS (lpj=2383872)
> [    0.119752] pid_max: default: 32768 minimum: 301
> [    0.120035] Security Framework initialized
> [    0.120144] Mount-cache hash table entries: 512
> [    0.130260] CPU: Testing write buffer coherency: ok
> [    0.131524] Setting up static identity map for 0xc0402a58 - 0xc0402ab0
> [    0.134890] devtmpfs: initialized
> [    0.196471] pinctrl core: initialized pinctrl subsystem
> [    0.201696] regulator-dummy: no parameters
> [    0.203892] NET: Registered protocol family 16
> [    0.204627] DMA: preallocated 256 KiB pool for atomic coherent allocations
> [    0.223282] OMAP GPIO hardware version 0.1
> [    0.245158] omap-gpmc gpmc.3: could not find pctldev for node /pinmux@44e10800/gpmc_pins, deferring probe
> [    0.245209] platform gpmc.3: Driver omap-gpmc requests probe deferral
> [    0.245267] No ATAGs?
> [    0.245281] hw-breakpoint: debug architecture 0x4 unsupported.
> [    0.283247] bio: create slab <bio-0> at 0
> [    0.348271] omap-dma-engine omap-dma-engine: OMAP DMA engine driver
> [    0.354695] usbcore: registered new interface driver usbfs
> [    0.355112] usbcore: registered new interface driver hub
> [    0.355755] usbcore: registered new device driver usb
> [    0.356692] omap_i2c 44e0b000.i2c: could not find pctldev for node /pinmux@44e10800/i2c1_pins, deferring probe
> [    0.356740] platform 44e0b000.i2c: Driver omap_i2c requests probe deferral
> [    0.363967] cfg80211: Calling CRDA to update world regulatory domain
> [    0.365584] Switching to clocksource gp_timer
> [    0.413223] NET: Registered protocol family 2
> [    0.414842] TCP established hash table entries: 2048 (order: 2, 16384 bytes)
> [    0.415047] TCP bind hash table entries: 2048 (order: 4, 73728 bytes)
> [    0.416082] TCP: Hash tables configured (established 2048 bind 2048)
> [    0.416324] TCP: reno registered
> [    0.416354] UDP hash table entries: 256 (order: 2, 20480 bytes)
> [    0.416612] UDP-Lite hash table entries: 256 (order: 2, 20480 bytes)
> [    0.417406] NET: Registered protocol family 1
> [    0.418630] RPC: Registered named UNIX socket transport module.
> [    0.418651] RPC: Registered udp transport module.
> [    0.418662] RPC: Registered tcp transport module.
> [    0.418673] RPC: Registered tcp NFSv4.1 backchannel transport module.
> [    0.419511] NetWinder Floating Point Emulator V0.97 (double precision)
> [    0.419948] CPU PMU: probing PMU on CPU 0
> [    0.419974] hw perfevents: enabled with ARMv7 Cortex-A8 PMU driver, 5 counters available
> [    0.432199] msgmni has been set to 483
> [    0.436507] io scheduler noop registered
> [    0.436531] io scheduler deadline registered
> [    0.436600] io scheduler cfq registered (default)
> [    0.437646] pinctrl-single 44e10800.pinmux: 142 pins at pa f9e10800 size 568
> [    0.439278] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
> [    0.446371] 44e09000.serial: ttyO0 at MMIO 0x44e09000 (irq = 88) is a OMAP UART0
> [    0.985168] console [ttyO0] enabled
> [    0.991322] 48022000.serial: ttyO1 at MMIO 0x48022000 (irq = 89) is a OMAP UART1
> [    1.000862] 48024000.serial: ttyO2 at MMIO 0x48024000 (irq = 90) is a OMAP UART2
> [    1.010255] 481a6000.serial: ttyO3 at MMIO 0x481a6000 (irq = 60) is a OMAP UART3
> [    1.019583] 481a8000.serial: ttyO4 at MMIO 0x481a8000 (irq = 61) is a OMAP UART4
> [    1.028982] 481aa000.serial: ttyO5 at MMIO 0x481aa000 (irq = 62) is a OMAP UART5
> [    1.063082] brd: module loaded
> [    1.081912] loop: module loaded
> [    1.088659] Generic platform RAM MTD, (c) 2004 Simtec Electronics
> [    1.099563] usbcore: registered new interface driver rt2800usb
> [    1.106180] usbcore: registered new interface driver asix
> [    1.112257] usbcore: registered new interface driver cdc_ether
> [    1.118836] usbcore: registered new interface driver smsc95xx
> [    1.125288] usbcore: registered new interface driver net1080
> [    1.131675] usbcore: registered new interface driver cdc_subset
> [    1.138334] usbcore: registered new interface driver zaurus
> [    1.144590] usbcore: registered new interface driver cdc_ncm
> [    1.152425] usbcore: registered new interface driver cdc_wdm
> [    1.158895] usbcore: registered new interface driver usbtest
> [    1.165282] i2c /dev entries driver
> [    1.172345] omap_wdt: OMAP Watchdog Timer Rev 0x01: initial timeout 60 sec
> [    1.180845] omap_cpufreq_init: unable to get MPU regulator
> [    1.189798] usbcore: registered new interface driver usbhid
> [    1.195760] usbhid: USB HID core driver
> [    1.200907] oprofile: using arm/armv7
> [    1.205496] TCP: cubic registered
> [    1.209054] Initializing XFRM netlink socket
> [    1.213644] NET: Registered protocol family 17
> [    1.218429] NET: Registered protocol family 15
> [    1.223535] Key type dns_resolver registered
> [    1.228137] VFP support v0.3: implementor 41 architecture 3 part 30 variant c rev 3
> [    1.236260] ThumbEE CPU extension supported.
> [    1.244885] omap-gpmc gpmc.3: GPMC revision 6.0
> [    1.250283]  (null): Cannot request GPMC CS
> [    1.259382] omap_i2c 44e0b000.i2c: bus 0 rev0.11 at 400 kHz
> [    1.266219] mcp230xx: probe of 0-0020 failed with error -22
> [    1.277234] DCDC1: at 1800 mV
> [    1.282523] vdd_mpu: 925 <--> 1325 mV at 3300 mV
> [    1.289601] vdd_core: 925 <--> 1150 mV at 1100 mV
> [    1.296532] LDO1: at 1800 mV
> [    1.301568] LDO2: at 3300 mV
> [    1.306584] LDO3: at 1800 mV
> [    1.311590] LDO4: at 2800 mV
> [    1.316384] tps65217 0-0024: TPS65217 ID 0x7 version 1.1
> [    1.322822] at24 0-0053: 256 byte 24c02 EEPROM, writable, 8 bytes/write
> [    1.333387] rtc-ds1307 0-0068: rtc core: registered ds1307 as rtc0
> [    1.339982] rtc-ds1307 0-0068: 56 bytes nvram
> [    1.405747] davinci_mdio 4a101000.mdio: davinci mdio revision 1.6
> [    1.412162] davinci_mdio 4a101000.mdio: detected phy mask fffffffc
> [    1.421603] libphy: 4a101000.mdio: probed
> [    1.425906] davinci_mdio 4a101000.mdio: phy[0]: device 4a101000.mdio:00, driver SMSC LAN8710/LAN8720
> [    1.435485] davinci_mdio 4a101000.mdio: phy[1]: device 4a101000.mdio:01, driver SMSC LAN8710/LAN8720
> [    1.445472] Random MACID = a2:34:49:64:e5:bc
> [    1.453900] rtc-ds1307 0-0068: setting system clock to 2013-03-11 12:16:42 UTC (1363004202)
> [    1.464955] net eth0: initializing cpsw version 1.12 (0)
> [    1.472908] net eth0: phy found : id is : 0x7c0f1
> [    1.478430] net eth0: phy found : id is : 0x7c0f1
> [    4.546293] libphy: 4a101000.mdio:00 - Link is Up - 100/Full
> [    4.585705] IP-Config: Guessing netmask 255.0.0.0
> [    4.591054] IP-Config: Complete:
> [    4.594452]      device=eth0, hwaddr=a2:34:49:64:e5:bc, ipaddr=10.0.101.111, mask=255.0.0.0, gw=10.0.0.100
> [    4.604619]      host=10.0.101.111, domain=, nis-domain=(none)
> [    4.610761]      bootserver=255.255.255.255, rootserver=10.0.0.100, rootpath=
> [    4.639415] =====================================
> [    4.644361] [ BUG: swapper/1 still has locks held! ]
> [    4.649617] 3.9.0-rc2-dirty #137 Not tainted
> [    4.654089] -------------------------------------
> [    4.659039] 1 lock held by swapper/1:
> [    4.662877]  #0:  (&type->s_umount_key#13/1){+.+.+.}, at: [<c00c9528>] sget+0x1a8/0x41c
> [    4.671349]
> [    4.671349] stack backtrace:
> [    4.675976] [<c00190c0>] (unwind_backtrace+0x0/0xf8) from [<c039f1ac>] (rpc_wait_bit_killable+0x90/0xc4)
> [    4.685953] [<c039f1ac>] (rpc_wait_bit_killable+0x90/0xc4) from [<c03ff6f0>] (__wait_on_bit+0x74/0xbc)
> [    4.695740] [<c03ff6f0>] (__wait_on_bit+0x74/0xbc) from [<c03ff8e8>] (out_of_line_wait_on_bit+0x80/0x88)
> [    4.705712] [<c03ff8e8>] (out_of_line_wait_on_bit+0x80/0x88) from [<c039fc58>] (__rpc_execute+0x1dc/0x2b0)
> [    4.715855] [<c039fc58>] (__rpc_execute+0x1dc/0x2b0) from [<c0399644>] (rpc_run_task+0x98/0xa4)
> [    4.724972] [<c0399644>] (rpc_run_task+0x98/0xa4) from [<c0399704>] (rpc_call_sync+0x4c/0xb4)
> [    4.733934] [<c0399704>] (rpc_call_sync+0x4c/0xb4) from [<c015f60c>] (nfs_proc_get_root+0x50/0x130)
> [    4.743445] [<c015f60c>] (nfs_proc_get_root+0x50/0x130) from [<c015219c>] (nfs_get_root+0x58/0x190)
> [    4.752954] [<c015219c>] (nfs_get_root+0x58/0x190) from [<c015717c>] (nfs_fs_mount_common+0x98/0x158)
> [    4.762632] [<c015717c>] (nfs_fs_mount_common+0x98/0x158) from [<c015742c>] (nfs_try_mount+0x150/0x20c)
> [    4.772504] [<c015742c>] (nfs_try_mount+0x150/0x20c) from [<c0156d40>] (nfs_fs_mount+0x3a4/0x5c8)
> [    4.781829] [<c0156d40>] (nfs_fs_mount+0x3a4/0x5c8) from [<c00ca648>] (mount_fs+0x44/0x17c)
> [    4.790611] [<c00ca648>] (mount_fs+0x44/0x17c) from [<c00e2528>] (vfs_kern_mount+0x4c/0xc0)
> [    4.799389] [<c00e2528>] (vfs_kern_mount+0x4c/0xc0) from [<c00e3c28>] (do_mount+0x704/0x878)
> [    4.808252] [<c00e3c28>] (do_mount+0x704/0x878) from [<c00e3e20>] (sys_mount+0x84/0xb8)
> [    4.816674] [<c00e3e20>] (sys_mount+0x84/0xb8) from [<c051abc8>] (do_mount_root+0x20/0xac)
> [    4.825347] [<c051abc8>] (do_mount_root+0x20/0xac) from [<c051afb8>] (mount_root+0x50/0xf4)
> [    4.834126] [<c051afb8>] (mount_root+0x50/0xf4) from [<c051b1bc>] (prepare_namespace+0x160/0x1c4)
> [    4.843449] [<c051b1bc>] (prepare_namespace+0x160/0x1c4) from [<c051aa58>] (kernel_init_freeable+0x168/0x1ac)
> [    4.853875] [<c051aa58>] (kernel_init_freeable+0x168/0x1ac) from [<c03fdf70>] (kernel_init+0x8/0xe4)
> [    4.863486] [<c03fdf70>] (kernel_init+0x8/0xe4) from [<c0013870>] (ret_from_fork+0x14/0x24)
> [    4.873467] VFS: Mounted root (nfs filesystem) on device 0:12.
> [    4.880835] devtmpfs: mounted
> [    4.884351] Freeing init memory: 196K
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
