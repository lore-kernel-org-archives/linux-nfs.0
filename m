Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.windriver.com ([147.11.1.11]:54753 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932456Ab2C2BIt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Mar 2012 21:08:49 -0400
Date: Wed, 28 Mar 2012 21:08:48 -0400
From: Paul Gortmaker <paul.gortmaker@windriver.com>
To: <linux-next@vger.kernel.org>
CC: <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
Subject: linux-next: triage for March 28, 2012
Message-ID: <20120329010847.GA9041@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS breakage spans all arch and took out about 10 builds.  I am
not listing them individually.

With Thursday's build underway already by sfr, note that we are
looking at possibly only one or two more 3.4 linux-next builds.

New breakage since last report:
	<all>:nfsd-configs (nfsd4_cld_block undefined)
		(http://marc.info/?l=linux-next&m=133298119824129&w=2)

Randconfig fails that may or may not be new (by their very nature):
	i386: (hub.c: undefined reference to `usb_speed_string')
		(http://kisskb.ellerman.id.au/kisskb/buildresult/5990666/)

Builds that are fixed since last report:
	ia64:defconfig
	ARM:rpc_defconfig
	ARM:omap2plus_defconfig

The following have fixes posted for quite some time now, but the fixes
haven't yet been integrated.  Please have a look at these, as it would
be nice to have them in tree before wk2 of the merge window closes.
	ARM:magician_defconfig
	ARM:collie_defconfig
	ARM:iop32x_defconfig,iop33x_defconfig
	ARM:em_x270_defconfig
	AVR32:defconfig


Note: The randconfig fails are only listed once and not tracked
in the below listing.

            ------------------------------------------------

Latest results at:
	http://kisskb.ellerman.id.au/kisskb/branch/9/

Failures as of March 28th, 2012:
================================

AM33:asb2303_defconfig,asb2364_defconfig
	when:	Mar 15
	why:	cc1: error: unrecognized command line option '-mmem-funcs'
	status:	Possible fix from TonyB sent for review.
	fix:	http://marc.info/?l=linux-kernel&m=133185020313818&w=2
	ref:	http://kisskb.ellerman.id.au/kisskb/buildresult/5878400/
----------------

ARM:cm_x2xx_defconfig
	when:	Mar 19
	why:	it8152.c: redefinition of 'dma_set_coherent_mask'
	status:	bisected and reported (PaulG)
	fix:
	ref:	http://marc.info/?l=linux-next&m=133226851818586&w=2

ARM:netx_defconfig,pnx4008_defconfig 
	when:	Mar 14
	why:	net/core/pktgen.c: can't find a register in class 'GENERAL_REGS'
	status:	
	fix:	
	ref:	http://kisskb.ellerman.id.au/kisskb/buildresult/5869486/
	ref:	https://lkml.org/lkml/2012/3/13/670

ARM:collie_defconfig
	when:	Feb 14
	why:	locomolcd.c: error: 'sa1100fb_lcd_power' undeclared
	status:	fixed (PaulG) - pending integration
	fix:	http://marc.info/?l=linux-next&m=133105157730749&w=2
	ref:

ARM:iop32x_defconfig,iop33x_defconfig
	when:	Nov 23
	why:	restart.c: implicit declaration of function 'soft_restart'
	status:	fixed (PaulG) - pending integration
	fix:	http://lists.infradead.org/pipermail/linux-arm-kernel/2012-January/081461.html
	fix:	https://lkml.org/lkml/2012/3/14/253
	ref:

ARM:ixp4xx_defconfig
	when:	Oct 26
	why:	gpio.h: implicit declaration of function '__gpio_get_value'
	status:	fixed (Imre Kaloz) - but possibly needs rework?
	fix:	https://lkml.org/lkml/2012/2/8/288
	ref:	https://lkml.org/lkml/2012/2/8/287

ARM:magician_defconfig
	when:	Feb 13
	why:	magician.c: unknown field 'dev' specified in initializer
	status:	fixed (PaulG) - pending integration
	fix:	http://marc.info/?l=linux-arm-kernel&m=133124258707457&w=2
	ref:	http://marc.info/?l=linux-next&m=133106325903524&w=2

ARM:em_x270_defconfig
	when:	Feb 14
	why:	em-x270.c: unknown field 'dev' specified in initializer
	status:	 fixed (PaulG) - pending integration
	fix:	http://www.spinics.net/lists/arm-kernel/msg164012.html
	ref:	http://www.spinics.net/lists/arm-kernel/msg163135.html

ARM:raumfeld_defconfig
	when:	Nov 23
	why:	eeti_ts.c: implicit declaration of function 'irq_to_gpio'
	status:	perhaps broken since 2010?  See ref below.
	fix:	
	ref:	http://www.gossamer-threads.com/lists/linux/kernel/1291618?do=post_view_threaded#1291618

ARM:arm-allnoconfig
	when:	forever
	why:	not supported
	status:	nothing pending, but patches accepted
	fix:	n/a
	ref:	https://lkml.org/lkml/2009/4/30/105
	ref:	http://lists.infradead.org/pipermail/linux-arm-kernel/2012-January/081218.html
----------------

AVR32:defconfig
	when:	Mar 18
	why:	board.h: atmel_nand.h: No such file or directory
	status:	reported/fixed (PaulG)
	fix:	http://marc.info/?l=linux-arm-kernel&m=133239363802517&w=2
	ref:	http://kisskb.ellerman.id.au/kisskb/buildresult/5917107/

AVR32:allnoconfig
	when:	May 26 2010, 20:49
	why:	at32_map_usart: undefined reference to `atmel_default_console_device'
	status:
	fix:
	ref:
---------------

bfin:***all-builds***
	when:	Mar 26
	why:	bfin-uclinux-ld: L1 data A overflow!
	status:	unknown, binutils issue?
	fix:
	ref:	http://kisskb.ellerman.id.au/kisskb/buildresult/5981475/
---------------

cris:***all-builds***
	when:	Mar 25, 22:05
	why:	include/linux/types.h:25: error expected ... before 'ino_t'
	status:	
	fix:	
	ref:	
----------------

crisv32:***all-builds***
	when:	Mar 25, 22:05
	why:	include/linux/types.h:25: error expected ... before 'ino_t'
	status:	
	fix:	
	ref:	
----------------

frv:defconfig
	when:	Mar 15
	why:	arch/frv/kernel/head.S operand out of range
	status:
	fix:
	ref:	http://kisskb.ellerman.id.au/kisskb/buildresult/5884666/
----------------

h8300:defconfig
	when:	Mar 15
	why:	time.c: implicit declaration of function 'get_irq_regs'
	why:	also seems gcc suffers an ICE
	status:	ICE bug lodged with gcc folks (TonyB)
	fix:
	ref:	http://gcc.gnu.org/bugzilla/show_bug.cgi?id=52598
	ref:	http://kisskb.ellerman.id.au/kisskb/buildresult/5884668/
----------------

i386:allmodconfig
	when:	Mar 8, 20:41
	why:	ERROR: "mdfld_set_brightness" [drivers/gpu/drm/gma500/gma500_gfx.ko] undefined!
	status:	
	fix:
	ref:	https://lkml.org/lkml/2012/3/24/122
	ref:	http://kisskb.ellerman.id.au/kisskb/buildresult/5878506/
----------------

m32r:m32700ut.smp_defconfig
	when:	Mar 15
	why:	No rule to make target `arch/m32r/boot/compressed/vmlinux.bin
	status:
	fix:
	ref:	http://kisskb.ellerman.id.au/kisskb/buildresult/5884670/
----------------

m68k:sun3_defconfig,m68k_defconfig
	when:	Mar 26
	why:	sun3_NCR5380.c: static decl of 'sun3scsi_proc_info' follows non-static
	status:	
	fix:	
	ref:	http://marc.info/?l=linux-next&m=133279244817422&w=2

m68k:allmodconfig
	when:	Mar 16
	why:	persistent_ram.c: implicit declaration of 'memblock_reserve'
	status:	
	fix:	
	ref:	http://kisskb.ellerman.id.au/kisskb/buildresult/5884324/
	ref:	http://www.spinics.net/lists/linux-next/msg19343.html
----------------

mips:allmodconfig
	when:
	why:	driver_pci_host.c: implicit declaration of function 'pcibios_enable_device'
	status: one of many fixes mips needs...
	fix:	http://marc.info/?l=linux-wireless&m=133272031621916&w=2
	ref:	http://patchwork.ozlabs.org/patch/148614/
	ref:	http://kisskb.ellerman.id.au/kisskb/buildresult/5807000/
----------------

parisc:allmodconfig
	when:
	why:	include/linux/log2.h: implicit declaration of function 'fls'
	status:	reported by PaulG, WIP by David Howells 
	fix:
	ref:	https://lkml.org/lkml/2012/2/29/409
	ref:	https://lkml.org/lkml/2012/3/6/228

parisc64:a500_defconfig 
	when:
	why:	include/linux/log2.h: implicit declaration of function 'fls'
	status:	reported by PaulG, WIP by David Howells 
	fix:
	ref:	https://lkml.org/lkml/2012/2/29/409
	ref:	https://lkml.org/lkml/2012/3/6/228
------------------

powerpc:allyesconfig
	when:	May 18 2009, 22:11
	why:	fat ass kernel with everything simply won't link
	status:	need to fix build config to ignore the final link
	fix:	
	ref:	http://kisskb.ellerman.id.au/kisskb/buildresult/5806793/
------------------

sh4:***all-builds***
	when:	Feb 24, 17:38
	why:	include/linux/log2.h: implicit declaration of function 'fls'
	status:	reported by PaulG, WIP by David Howells 
	fix:
	ref:	https://lkml.org/lkml/2012/2/29/409
	ref:	https://lkml.org/lkml/2012/3/6/228
------------------

um:um-defconfig
	when:	Sep 16 2010, 01:28
	why:	os-Linux/start_up.c: error: 'PTRACE_SETOPTIONS' undeclared
	status:	clearly broken forever, so does anyone care?
	fix:	
	ref:	http://kisskb.ellerman.id.au/kisskb/target/2979/
