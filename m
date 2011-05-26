From: Johan Hovold <jhovold@gmail.com>
Subject: Oops in dput/nfs_lookup_revalidate
Date: Thu, 26 May 2011 16:16:08 +0200
Message-ID: <20110526141608.GA10371@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:60079 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932495Ab1EZOQN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 10:16:13 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I keep hitting the Oops below on 2.6.39 (arm/AM35xx) using nfsroot.
Note that the board boots most of the time. Any suggestions as to what
might be going on?

Thanks,
Johan


[   10.777496] Unable to handle kernel NULL pointer dereference at virtual address 00000000
[   10.785888] pgd = cfbac000
[   10.788696] [00000000] *pgd=8fb29831, *pte=00000000, *ppte=00000000
[   10.795196] Internal error: Oops: 817 [#1] PREEMPT
[   10.800140] last sysfs file: /sys/kernel/uevent_seqnum
[   10.805419] Modules linked in:
[   10.808593] CPU: 0    Tainted: G        W    (2.6.39+ #100)
[   10.814361] PC is at dput+0x30/0x1e0
[   10.818023] LR is at dput+0x24/0x1e0
[   10.821716] pc : [<c00d8d74>]    lr : [<c00d8d68>]    psr: 60000013
[   10.821746] sp : cfb93de8  ip : cfb93de8  fp : cfb93e6c
[   10.833557] r10: cfb93ebc  r9 : cf431c00  r8 : 00100100
[   10.838928] r7 : 00200200  r6 : cfb92000  r5 : cf440ac0  r4 : cf431c00
[   10.845672] r3 : 00000000  r2 : cfb92000  r1 : 00000000  r0 : 00000001
[   10.852386] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
[   10.859741] Control: 10c5387d  Table: 8fbac019  DAC: 00000015
[   10.865661] Process ldconfig (pid: 189, stack limit = 0xcfb922f0)
[   10.871948] Stack: (0xcfb93de8 to 0xcfb94000)
[   10.876434] 3de0:                   cf9bcc00 cf440ac0 cf4ab480 cfb93ef8 cf4bed28 c012c800
[   10.884857] 3e00: c03e8ac0 cfb93f78 cf4ab480 00000001 00000001 cfb93ef8 cfb92000 cf431c00
[   10.893310] 3e20: cfb93ebc c00cf5cc cfb93f00 cf9ec480 cfb93ef8 0000002f cec25009 cfb93f78
[   10.901733] 3e40: cfb93ef8 00000000 cfb93ebc cfb92000 00000000 cf431c00 00000024 c00d19a4
[   10.910156] 3e60: cfb93f78 cf9ec480 cf431c00 cf440ac0 c00d0378 cfb93ebc cfb93ef8 00000000
[   10.918609] 3e80: cec25000 cfb92000 cfb92000 cec25000 cfb93f78 c00d2cdc cfb93ec4 0000029e
[   10.927032] 3ea0: cf9bec00 0000029e cec25000 cfb93f0c 000000d0 c00d2128 00000074 00000002
[   10.935455] 3ec0: c03d9a78 00000000 fffffffe cfb93f78 00000001 ffffff9c cec25000 cfb93ef8
[   10.943908] 3ee0: cfb92000 cec25000 bef5ea7c c00d307c 00000041 cf875888 cf9ec480 cf431c00
[   10.952331] 3f00: 12150b6a 00000011 cec25009 cf9ec480 cf42d680 cf440ac0 00000101 00000000
[   10.960754] 3f20: 00000000 00000000 00000040 0000000c 0000012c cf875880 00000004 cfa3bc00
[   10.969207] 3f40: bef5ea7c cfb93f50 c00ddd8c 00000001 00000000 cf9bf380 00000001 00000000
[   10.977630] 3f60: 00000000 ffffff9c 00000004 c00c4204 00000001 00000044 00000000 00000000
[   10.986053] 3f80: 00000024 00000100 fa200000 004d4760 00000008 bef5eb58 00000005 c0033d44
[   10.994506] 3fa0: 00000000 c0033bc0 004d4760 00000008 bef5eb58 00000000 000001b6 000001b6
[   11.002929] 3fc0: 004d4760 00000008 bef5eb58 00000005 bef5eb58 bef5eb58 bef5fc60 bef5ea7c
[   11.011352] 3fe0: 004d4760 bef5ea20 00019084 0002b47c 60000010 bef5eb58 00000000 00000000
[   11.019805] [<c00d8d74>] (dput+0x30/0x1e0) from [<c012c800>] (nfs_lookup_revalidate+0x2e8/0x490)
[   11.028900] [<c012c800>] (nfs_lookup_revalidate+0x2e8/0x490) from [<c00cf5cc>] (do_lookup+0x194/0x240)
[   11.038513] [<c00cf5cc>] (do_lookup+0x194/0x240) from [<c00d19a4>] (do_last+0x194/0x734)
[   11.046844] [<c00d19a4>] (do_last+0x194/0x734) from [<c00d2cdc>] (path_openat+0xc0/0x380)
[   11.055297] [<c00d2cdc>] (path_openat+0xc0/0x380) from [<c00d307c>] (do_filp_open+0x30/0x7c)
[   11.063995] [<c00d307c>] (do_filp_open+0x30/0x7c) from [<c00c4204>] (do_sys_open+0xe0/0x17c)
[   11.072723] [<c00c4204>] (do_sys_open+0xe0/0x17c) from [<c0033bc0>] (ret_fast_syscall+0x0/0x30)
[   11.081695] Code: ebfde2a6 e594304c e3530000 1a000001 (e5833000) 
[   11.088043] ---[ end trace 1b75b31a2719ed1e ]---
[   11.092803] note: ldconfig[189] exited with preempt_count 1
[   11.098663] BUG: scheduling while atomic: ldconfig/189/0x40000002
[   11.104949] Modules linked in:
[   11.108154] [<c0038428>] (unwind_backtrace+0x0/0xec) from [<c02d4a64>] (schedule+0x5c/0x440)
[   11.116912] [<c02d4a64>] (schedule+0x5c/0x440) from [<c0051910>] (__cond_resched+0x18/0x24)
[   11.125579] [<c0051910>] (__cond_resched+0x18/0x24) from [<c02d4fcc>] (_cond_resched+0x30/0x40)
[   11.134613] [<c02d4fcc>] (_cond_resched+0x30/0x40) from [<c00b257c>] (unmap_vmas+0x6f4/0x7b0)
[   11.143432] [<c00b257c>] (unmap_vmas+0x6f4/0x7b0) from [<c00b4e94>] (exit_mmap+0x108/0x270)
[   11.152099] [<c00b4e94>] (exit_mmap+0x108/0x270) from [<c00553ac>] (mmput+0x38/0x10c)
[   11.160217] [<c00553ac>] (mmput+0x38/0x10c) from [<c00592f4>] (exit_mm+0x160/0x168)
[   11.168151] [<c00592f4>] (exit_mm+0x160/0x168) from [<c005acec>] (do_exit+0x1c8/0x650)
[   11.176330] [<c005acec>] (do_exit+0x1c8/0x650) from [<c0036e68>] (die+0x29c/0x2d8)
[   11.184173] [<c0036e68>] (die+0x29c/0x2d8) from [<c003a344>] (__do_kernel_fault+0x64/0x84)
[   11.192749] [<c003a344>] (__do_kernel_fault+0x64/0x84) from [<c003a5c8>] (do_page_fault+0x264/0x284)
[   11.202209] [<c003a5c8>] (do_page_fault+0x264/0x284) from [<c002e2b8>] (do_DataAbort+0x34/0x98)
[   11.211212] [<c002e2b8>] (do_DataAbort+0x34/0x98) from [<c0033610>] (__dabt_svc+0x70/0xa0)
[   11.219757] Exception stack(0xcfb93da0 to 0xcfb93de8)
[   11.225006] 3da0: 00000001 00000000 cfb92000 00000000 cf431c00 cf440ac0 cfb92000 00200200
[   11.233459] 3dc0: 00100100 cf431c00 cfb93ebc cfb93e6c cfb93de8 cfb93de8 c00d8d68 c00d8d74
[   11.241912] 3de0: 60000013 ffffffff
[   11.245544] [<c0033610>] (__dabt_svc+0x70/0xa0) from [<c00d8d74>] (dput+0x30/0x1e0)
[   11.253479] [<c00d8d74>] (dput+0x30/0x1e0) from [<c012c800>] (nfs_lookup_revalidate+0x2e8/0x490)
[   11.262573] [<c012c800>] (nfs_lookup_revalidate+0x2e8/0x490) from [<c00cf5cc>] (do_lookup+0x194/0x240)
[   11.272216] [<c00cf5cc>] (do_lookup+0x194/0x240) from [<c00d19a4>] (do_last+0x194/0x734)
[   11.280609] [<c00d19a4>] (do_last+0x194/0x734) from [<c00d2cdc>] (path_openat+0xc0/0x380)
[   11.289062] [<c00d2cdc>] (path_openat+0xc0/0x380) from [<c00d307c>] (do_filp_open+0x30/0x7c)
[   11.297821] [<c00d307c>] (do_filp_open+0x30/0x7c) from [<c00c4204>] (do_sys_open+0xe0/0x17c)
[   11.306549] [<c00c4204>] (do_sys_open+0xe0/0x17c) from [<c0033bc0>] (ret_fast_syscall+0x0/0x30)


objdump:

c00d8d44 <dput> (File Offset: 0xd8d44):
c00d8d44:	e92d41f0 	push	{r4, r5, r6, r7, r8, lr}
c00d8d48:	e2504000 	subs	r4, r0, #0	; 0x0
c00d8d4c:	08bd81f0 	popeq	{r4, r5, r6, r7, r8, pc}
c00d8d50:	e3cd6d7f 	bic	r6, sp, #8128	; 0x1fc0
c00d8d54:	e59f81bc 	ldr	r8, [pc, #444]	; c00d8f18 <dput+0x1d4> (File Offset: 0xd8f18)
c00d8d58:	e59f71bc 	ldr	r7, [pc, #444]	; c00d8f1c <dput+0x1d8> (File Offset: 0xd8f1c)
c00d8d5c:	e3c6603f 	bic	r6, r6, #63	; 0x3f
c00d8d60:	e3a00001 	mov	r0, #1	; 0x1
c00d8d64:	ebfde2a6 	bl	c0051804 <add_preempt_count> (File Offset: 0x51804)
c00d8d68:	e594304c 	ldr	r3, [r4, #76]
c00d8d6c:	e3530000 	cmp	r3, #0	; 0x0
c00d8d70:	1a000001 	bne	c00d8d7c <dput+0x38> (File Offset: 0xd8d7c)
c00d8d74:	e5833000 	str	r3, [r3]
c00d8d78:	eafffffd 	b	c00d8d74 <dput+0x30> (File Offset: 0xd8d74)
c00d8d7c:	e3530001 	cmp	r3, #1	; 0x1
c00d8d80:	8a00002c 	bhi	c00d8e38 <dput+0xf4> (File Offset: 0xd8e38)
c00d8d84:	e5943000 	ldr	r3, [r4]
c00d8d88:	e3130902 	tst	r3, #32768	; 0x8000
