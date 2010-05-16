From: Martin Vogt <vogt@itwm.fraunhofer.de>
Subject: Re: permission denied with >= ~2.6.25
Date: Sun, 16 May 2010 19:52:13 +0200
Message-ID: <20100516175213.GA9225@lts032.itwm.fhg.de>
References: <4BE7ED5D.90801@itwm.fraunhofer.de> <4BE93940.5070804@itwm.fraunhofer.de> <4BED1E44.4020708@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:45092 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754210Ab0EPRwQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 13:52:16 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id o4GHqERM019500
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:52:14 +0200
Received: from mail2.itwm.fhg.de ([131.246.191.79]:41032)
	by itwm2.itwm.fhg.de with esmtps (TLSv1:DES-CBC3-SHA:168)
	(/C=DE/ST=Rheinland-Pfalz/L=Kaiserslautern/O=Fraunhofer ITWM/OU=SLG/CN=mail2.itwm.fhg.de)(verified=1)
	 (Exim 4.66 #1)
	id 1ODi0c-0006ci-8S
	for linux-nfs@vger.kernel.org; Sun, 16 May 2010 19:52:14 +0200
In-Reply-To: <4BED1E44.4020708@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 14, 2010 at 11:56:20AM +0200, Martin Vogt wrote:
> 
> > Hello,
> >
> > I tested 2.6.34-rc7 now and it has the problem too.
> > Then I checked 2.6.24.7 which has the problem,
> > but 2.6.23.1 looks fine.
>

Hello,

2.6.23.1 down to 2.6.20.1 has the same problem and 2.6.16.<vendor> too.

But its seems that, the older the kernel gets, the
longer it takes that the EPERM or EIO appears. 

For example: 2.6.34-rc7 is really quick ;-) 

But now I have no more ideas for debugging.

regards,

Martin

PS: here a two more straces:


1:
==
13037 open("Kernel-pxe2-1.JGD9NGERWJ/arch/ppc/syslib/pci_auto.c.tmp",  
O_RDWR|O_CREAT|O_EXCL, 0666) = 6
13037 read(5, "/*\n * arch/ppc/syslib/pci_auto.c"..., 16384) = 12365
13037 write(6, "/*\n * arch/ppc/syslib/pci_auto.c"..., 4096) = 4096
13037 write(6, ",\n\t\t\tcurrent_bus,\n\t\t\tpci_devfn,\n"..., 4096) = 4096
13037 write(6, "e behind a\n\t * P2P bridge in a s"..., 4096) = 4096
13037 read(5, "", 16384)                = 0  
13037 close(5)                          = 0
13037 write(6, "_devfn,\n\t\t\t\t\t\tPCI_LATENCY_TIMER,"..., 77) = 77
13037 close(6)                          = 0
13037 rename("Kernel-pxe2-1.JGD9NGERWJ/arch/ppc/syslib/pci_auto.c.tmp",
"Kernel-pxe2-1.JGD9NGERWJ/arch/ppc/syslib/pci_auto.c") = 0
13037 rename("Kernel-pxe2-1.JGD9NGERWJ/arch/ppc/syslib/.svn/tmp/text-base/pci_auto.c.svn-base",
"Kernel-pxe2-1.JGD9NGERWJ/arch/ppc/sysli
b/.svn/text-base/pci_auto.c.svn-base") = 0
13037 lstat("Kernel-pxe2-1.JGD9NGERWJ/arch/ppc/syslib/.svn/text-base/pci_auto.c.svn-base",
{st_mode=S_IFREG|0666, st_size=12365, ...}) =
 0
13037 chmod("Kernel-pxe2-1.JGD9NGERWJ/arch/ppc/syslib/.svn/text-base/pci_auto.c.svn-base",
0444) = -1 EACCES (Permission denied)
^^^^^^^^^^^^^^^^^
Here

13037 fcntl(3, F_GETFL)                 = 0x2 (flags O_RDWR)
13037 fcntl(3, F_SETFL, O_RDWR|O_NONBLOCK) = 0
13037 write(3, "( failure ( ( 155009 55:In direc"..., 423) = 423

2:  
==
13048 open("Kernel-pxe2-1.5MzYLADYdV/arch/ppc/kernel/traps.c.tmp",
O_RDWR|O_CREAT|O_EXCL, 0666) = 6
13048 read(5, "/*\n *  arch/ppc/kernel/traps.c\n "..., 16384) = 16384
13048 write(6, "/*\n *  arch/ppc/kernel/traps.c\n "..., 4096) = 4096
13048 write(6, "ble.\n * Note that the 601 only t"..., 4096) = 4096
13048 write(6, "CSR_IMPE)\n\t\t\tprintk(\"Machine Che"..., 4096) = 4096
13048 read(5, ", bug->file,\n\t\t       bug->line "..., 16384) = 9123
13048 write(6, "\t\t0x7c0007fe\n\n#define INST_STRIN"..., 4096) = 4096
13048 write(6, ", bug->file,\n\t\t       bug->line "..., 4096) = 4096
13048 write(6, "if (!user_mode(regs)) {\n\t\tdebugg"..., 4096) = 4096
13048 read(5, "", 16384)                = 0
13048 close(5)                          = 0
13048 write(6, "UND)) {\n\t\tcode = FPE_FLTUND;\n\t\ts"..., 931) = 931 
13048 close(6)                          = 0
13048 rename("Kernel-pxe2-1.5MzYLADYdV/arch/ppc/kernel/traps.c.tmp",  
"Kernel-pxe2-1.5MzYLADYdV/arch/ppc/kernel/traps.c") = 0
13048 rename("Kernel-pxe2-1.5MzYLADYdV/arch/ppc/kernel/.svn/tmp/text-base/traps.c.svn-base",
"Kernel-pxe2-1.5MzYLADYdV/arch/ppc/kernel/.svn/text-base/traps.c.svn-base") = 0
13048 lstat("Kernel-pxe2-1.5MzYLADYdV/arch/ppc/kernel/.svn/text-base/traps.c.svn-base",
0x7fff57f65820) = -1 EACCES (Permission denied)
^^^^^^^^^^^^^^^
Here
13048 fcntl(3, F_GETFL)                 = 0x2 (flags O_RDWR)
13048 fcntl(3, F_SETFL, O_RDWR|O_NONBLOCK) = 0
13048 write(3, "( failure ( ( 155009 55:In direc"..., 420) = 420

