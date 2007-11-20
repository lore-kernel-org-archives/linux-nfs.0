From: Andy Whitcroft <apw-26w3C0LaAnFg9hUCZPvPmw@public.gmane.org>
Subject: Re: [NFS] mm snapshot broken-out-2007-11-20-01-45.tar.gz -- powerpc
	panic
Date: Tue, 20 Nov 2007 14:46:59 +0000
Message-ID: <20071120144659.GC12066__1156.30810983038$1195570123$gmane$org@shadowen.org>
References: <200711200953.lAK9qxjO030444@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
To: akpm@linux-foundation.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuUNY-00042V-R0
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 06:47:12 -0800
Received: from hellhawk.shadowen.org ([80.68.90.175])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IuUNd-0003Ur-Pl
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 06:47:14 -0800
In-Reply-To: <200711200953.lAK9qxjO030444-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

I have one powerpc machine which managed to compile this snapshot!  It
paniced on boot as below, might be nfs so copied them.  General results
are popping out on TKO.

-apw

Freeing initrd memory: 1224k freed
Installing knfsd (copyright (C) 1996 okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org).
Unable to handle kernel paging request for data at address 0x00000050
Faulting instruction address: 0xc000000000113b64
Oops: Kernel access of bad area, sig: 11 [#1]
SMP NR_CPUS=32 NUMA pSeries
Modules linked in:
NIP: c000000000113b64 LR: c000000000113b44 CTR: 0000000000000000
REGS: C00000077E0679D0 TRAP: 0300   Not tainted  (2.6.24-rc3-mm1-autokern1)
MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 24004044  XER: 20000000
DAR: 0000000000000050, DSISR: 0000000040000000
TASK = C00000077E062000[1] 'swapper' THREAD: C00000077E064000 CPU: 0
GPR00: 0000000000000000 c00000077e067c50 c0000000006c5650 0000000000000001 
GPR04: c00000077e625bdc 0000000000000005 c000000000501ad4 c000000000731d18 
GPR08: 0000000000000000 0000000000000000 c00000077e625b40 0000000000000001 
GPR12: 0000000024004044 c0000000005fd000 0000000000000000 0000000000000000 
GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000 
GPR20: 4000000003a00000 0000000004300000 0000000003fb94a8 0000000000132000 
GPR24: 0000000003fb9718 0000000000000000 c0000000005b6e70 0000000000000000 
GPR28: 0000000000000005 c00000077e625b40 c000000000652e48 c00000077e625c50 
NIP [c000000000113b64] .remove_proc_entry+0xac/0x234
LR [c000000000113b44] .remove_proc_entry+0x8c/0x234
Call Trace:
[c00000077e067c50] [c000000000113b44] .remove_proc_entry+0x8c/0x234 (unreliable)
[c00000077e067d10] [c00000000048bf28] .cache_unregister+0x108/0x1b4
[c00000077e067d90] [c0000000001ca988] .nfsd_export_shutdown+0x50/0xa4
[c00000077e067e10] [c0000000005a712c] .init_nfsd+0x108/0x13c
[c00000077e067ea0] [c000000000582438] .kernel_init+0x224/0x3fc
[c00000077e067f90] [c000000000026204] .kernel_thread+0x4c/0x68
Instruction dump:
e8bf0000 e8810090 7f83e378 4bfffd25 2f830000 419e0018 ebbf0000 e81d0050 
f81f0000 38000000 f81d0050 e93f0000 <e8090050> 3be90050 2fa00000 409effc4 
Kernel panic - not syncing: Attempted to kill init!

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

