From: "Gilliam, PaulX J" <paulx.j.gilliam@intel.com>
Subject: section mismatches warning while building linux-pnfs-8f0f795
 (latestest) - should I be concerned?
Date: Fri, 30 Jul 2010 10:57:30 -0700
Message-ID: <0A97A441BFADC74EA1E299A79C69DF9213F0E65FA0@orsmsx504.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:20872 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932793Ab0G3R5n convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jul 2010 13:57:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I got the latest from Benny's git and ran into these warnings when building.  But they don't seem to be coming from any NFS code.  Should I be worried?  What is a "Section mismatch"?

Thanks for any help you can give a newbee like me.

-=# Paul Gilliam #=-

Edited typescript:

[root@FC12a linux-pnfs-latest]# make CONFIG_DEBUG_SECTION_MISMATCH=y
  CHK     include/linux/version.h
  CHK     include/generated/utsrelease.h
  HOSTCC  scripts/basic/fixdep
------- 8< -------
  LD      drivers/char/built-in.o
WARNING: drivers/char/built-in.o(.data+0x4740): Section mismatch in reference from the variable hvc_con_driver to the function .init.text:hvc_console_setup()
The variable hvc_con_driver references
the function __init hvc_console_setup()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
------- 8< -------
  LD [M]  drivers/scsi/mpt2sas/mpt2sas.o
WARNING: drivers/scsi/mpt2sas/mpt2sas.o(.text+0xc844): Section mismatch in reference from the function _scsih_pci_error_detected() to the function .devexit.text:_scsih_remove()
The function _scsih_pci_error_detected() references a function in an exit section.
Often the function _scsih_remove() has valid usage outside the exit section
and the fix is to remove the __devexit annotation of _scsih_remove.
------- 8< -------
  LD [M]  drivers/video/via/viafb.o
WARNING: drivers/video/via/viafb.o(.devinit.text+0xa91): Section mismatch in reference from the function via_pci_probe() to the function .devexit.text:via_pci_teardown_mmio.clone.2()
The function __devinit via_pci_probe() references
a function __devexit via_pci_teardown_mmio.clone.2().
This is often seen when error handling in the init function
uses functionality in the exit path.
The fix is often to remove the __devexit annotation of
via_pci_teardown_mmio.clone.2() so it may be used outside an exit section.
------- 8< -------
  LD      drivers/video/built-in.o
WARNING: drivers/video/built-in.o(.devinit.text+0x502): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x510): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x517): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x51d): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x52e): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x57d): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x598): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x675): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x68e): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x6a6): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x6ac): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x6ce): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x6e7): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x706): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x713): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x719): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x721): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x72c): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x73b): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x741): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x747): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x74d): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x75a): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x787): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x79a): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x7a2): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x7a8): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x7c4): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x7cb): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x7d2): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x7d9): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x7ea): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x7f7): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x7fd): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x803): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x811): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x817): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x824): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x835): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x83e): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x867): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/video/built-in.o(.devinit.text+0x8fe): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.
------- 8< -------
  LD      drivers/built-in.o
WARNING: drivers/built-in.o(.devinit.text+0x32cb): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x32d9): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x32e0): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x32e6): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x32f7): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3346): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3361): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x343e): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3457): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x346f): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3475): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3497): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x34b0): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x34cf): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x34dc): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x34e2): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x34ea): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x34f5): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3504): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x350a): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3510): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3516): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3523): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3550): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3563): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x356b): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3571): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x358d): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3594): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x359b): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x35a2): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x35b3): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x35c0): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x35c6): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x35cc): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x35da): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x35e0): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x35ed): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x35fe): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3607): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x3630): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/built-in.o(.devinit.text+0x36c7): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: drivers/built-in.o(.data+0xf670): Section mismatch in reference from the variable hvc_con_driver to the function .init.text:hvc_console_setup()
The variable hvc_con_driver references
the function __init hvc_console_setup()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
------- 8< -------
  LD      arch/x86/pci/built-in.o
WARNING: arch/x86/pci/built-in.o(.text+0xf53): Section mismatch in reference from the function pcibios_scan_specific_bus() to the function .devinit.text:pci_scan_bus_on_node()
The function pcibios_scan_specific_bus() references
the function __devinit pci_scan_bus_on_node().
This is often because pcibios_scan_specific_bus lacks a __devinit
annotation or the annotation of pci_scan_bus_on_node is wrong.
------- 8< -------
  LD      vmlinux.o
  MODPOST vmlinux.o
WARNING: vmlinux.o(.text+0x39454f): Section mismatch in reference from the function pcibios_scan_specific_bus() to the function .devinit.text:pci_scan_bus_on_node()
The function pcibios_scan_specific_bus() references
the function __devinit pci_scan_bus_on_node().
This is often because pcibios_scan_specific_bus lacks a __devinit
annotation or the annotation of pci_scan_bus_on_node is wrong.

WARNING: vmlinux.o(.devinit.text+0x3647): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3655): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x365c): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3662): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3673): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x36c2): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x36dd): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x37ba): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x37d3): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x37eb): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x37f1): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3813): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x382c): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x384b): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3858): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x385e): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3866): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3871): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3880): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3886): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x388c): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3892): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x389f): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x38cc): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x38df): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x38e7): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x38ed): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3909): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3910): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3917): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x391e): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x392f): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x393c): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3942): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3948): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_defined
The function __devinit efifb_probe() references
a variable __initdata efifb_defined.
If efifb_defined is only used by efifb_probe then
annotate efifb_defined with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3956): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x395c): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3969): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x397a): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3983): Section mismatch in reference from the function efifb_probe() to the (unknown reference) .init.data:(unknown)
The function __devinit efifb_probe() references
a (unknown reference) __initdata (unknown).
If (unknown) is only used by efifb_probe then
annotate (unknown) with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x39ac): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: vmlinux.o(.devinit.text+0x3a43): Section mismatch in reference from the function efifb_probe() to the variable .init.data:efifb_fix
The function __devinit efifb_probe() references
a variable __initdata efifb_fix.
If efifb_fix is only used by efifb_probe then
annotate efifb_fix with a matching annotation.

WARNING: vmlinux.o(.data+0x47db0): Section mismatch in reference from the variable hvc_con_driver to the function .init.text:hvc_console_setup()
The variable hvc_con_driver references
the function __init hvc_console_setup()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,
------- 8< -------
  MODPOST 2021 modules
WARNING: drivers/net/irda/smsc-ircc2.o(.data+0x28): Section mismatch in reference from the variable smsc_ircc_pnp_driver to the function .init.text:smsc_ircc_pnp_probe()
The variable smsc_ircc_pnp_driver references
the function __init smsc_ircc_pnp_probe()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,

WARNING: drivers/platform/x86/wmi.o(.data+0xb0): Section mismatch in reference from the variable acpi_wmi_driver to the function .init.text:acpi_wmi_add()
The variable acpi_wmi_driver references
the function __init acpi_wmi_add()
If the reference is valid then annotate the
variable with __init* or __refdata (see linux/init.h) or name the variable:
*_template, *_timer, *_sht, *_ops, *_probe, *_probe_one, *_console,

WARNING: drivers/scsi/mpt2sas/mpt2sas.o(.text+0xc844): Section mismatch in reference from the function _scsih_pci_error_detected() to the function .devexit.text:_scsih_remove()
The function _scsih_pci_error_detected() references a function in an exit section.
Often the function _scsih_remove() has valid usage outside the exit section
and the fix is to remove the __devexit annotation of _scsih_remove.

WARNING: drivers/video/via/viafb.o(.devinit.text+0xa91): Section mismatch in reference from the function via_pci_probe() to the function .devexit.text:via_pci_teardown_mmio.clone.2()
The function __devinit via_pci_probe() references
a function __devexit via_pci_teardown_mmio.clone.2().
This is often seen when error handling in the init function
uses functionality in the exit path.
The fix is often to remove the __devexit annotation of
via_pci_teardown_mmio.clone.2() so it may be used outside an exit section.
------- 8< -------
  IHEX    firmware/yam/9600.bin
[root@FC12a linux-pnfs-latest]# make modules
  CHK     include/linux/version.h
------- 8< -------
  MODPOST 2018 modules
WARNING: modpost: Found 4 section mismatch(es).
To see full details build your kernel with:
'make CONFIG_DEBUG_SECTION_MISMATCH=y
------- 8< -------

