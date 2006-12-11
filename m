From: Jens Beyer <jbe@webde.de>
Subject: Re: nfsd triggered (?) kernel BUG at fs/inode:1057
Date: Mon, 11 Dec 2006 11:12:08 +0100
Message-ID: <20061211101208.GA23500@pcnocjb.dlan.cinetic.de>
References: <20060421095832.GA15203@pcnocjb.dlan.cinetic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gti90-0002Wt-0F
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 02:12:22 -0800
Received: from mailgate02.web.de ([217.72.192.252])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gti8z-0007AI-KU
	for nfs@lists.sourceforge.net; Mon, 11 Dec 2006 02:12:23 -0800
Received: from web.de by mailgate02.web.de (Postfix) with ESMTP id
	699B71557A0D for <nfs@lists.sourceforge.net>;
	Mon, 11 Dec 2006 11:12:08 +0100 (CET) (R101)
To: nfs@lists.sourceforge.net
In-Reply-To: <20060421095832.GA15203@pcnocjb.dlan.cinetic.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Hi,

though we cant trigger this bug by intent, it occurs about every 2-3 Weeks;
we recently updated to a newer Kernel (2.6.17.13) and still get it:

Anyone ideas how to fix (or debug) it ?

Thanks in advance,
Jens


Dec 10 19:48:29 store03 kernel: [4667487.554000] ------------[ cut here ]------------
Dec 10 19:48:29 store03 kernel: [4667487.554000] kernel BUG at fs/inode.c:1053!
Dec 10 19:48:29 store03 kernel: [4667487.554000] invalid opcode: 0000 [#1]
Dec 10 19:48:29 store03 kernel: [4667487.554000] SMP 
Dec 10 19:48:29 store03 kernel: [4667487.554000] Modules linked in: nfs nfsd exportfs lockd nfs_acl sunrpc xfs softdog floppy nvram autofs4 e1000 piix tg3 md_mod dm_mod d
rbd ide_cd cdrom ide_core sg sd_mod qla2400 qla2xxx_conf qla2xxx firmware_class
Dec 10 19:48:29 store03 kernel: [4667487.554000] CPU:    1
Dec 10 19:48:29 store03 kernel: [4667487.554000] EIP:    0060:[<c017d70e>]    Not tainted VLI
Dec 10 19:48:29 store03 kernel: [4667487.554000] EFLAGS: 00010202   (2.6.17.13-QLw #1) 
Dec 10 19:48:29 store03 kernel: [4667487.554000] EIP is at generic_delete_inode+0x11d/0x134
Dec 10 19:48:29 store03 kernel: [4667487.555000] eax: c4663748   ebx: 00000000   ecx: 00000003   edx: dae51340
Dec 10 19:48:29 store03 kernel: [4667487.555000] esi: dae511ac   edi: e987ef30   ebp: ffffc000   esp: eca27e94
Dec 10 19:48:29 store03 kernel: [4667487.555000] ds: 007b   es: 007b   ss: 0068
Dec 10 19:48:29 store03 kernel: [4667487.555000] Process nfsd (pid: 16525, threadinfo=eca26000 task=eb036030)
Dec 10 19:48:29 store03 kernel: [4667487.555000] Stack: dae511ac 00000000 00000000 dae511ac e987ef28 c017d908 dae511ac c031e568 
Dec 10 19:48:29 store03 kernel: [4667487.555000]        00000000 c017bbae dae511ac 00000003 00000000 fffffff0 00000000 d7dfb3ac 
Dec 10 19:48:29 store03 kernel: [4667487.555000]        e987ef28 c01739ae e987ef28 e987ef28 00000000 e987ef28 eb23c8f8 eb037604 
Dec 10 19:48:29 store03 kernel: [4667487.555000] Call Trace:
Dec 10 19:48:29 store03 kernel: [4667487.555000]  <c017d908> iput+0x5f/0x79  <c017bbae> d_delete+0xb5/0xee
Dec 10 19:48:29 store03 kernel: [4667487.555000]  <c01739ae> vfs_unlink+0xc2/0xd3  <fbead541> nfsd_unlink+0x128/0x252 [nfsd]
Dec 10 19:48:29 store03 kernel: [4667487.555000]  <fbeb3304> nfsd3_proc_remove+0x8a/0xc4 [nfsd]  <fbea77c1> nfsd_dispatch+0x13a/0x20d [nfsd]
Dec 10 19:48:29 store03 kernel: [4667487.555000]  <fbe673e5> svc_process+0x2bf/0x6da [sunrpc]  <c0103614> apic_timer_interrupt+0x1c/0x24
Dec 10 19:48:29 store03 kernel: [4667487.555000]  <fbea74e8> nfsd+0x1ba/0x359 [nfsd]  <fbea732e> nfsd+0x0/0x359 [nfsd]
Dec 10 19:48:29 store03 kernel: [4667487.555000]  <c010107d> kernel_thread_helper+0x5/0xb 
Dec 10 19:48:29 store03 kernel: [4667487.555000] Code: 00 00 00 00 89 04 24 e8 64 d1 fc ff 89 34 24 e8 d3 f0 ff ff eb 86 8b 40 24 c7 44 24 04 ff ff ff ff 89 34 24 ff 10 e9 6c ff ff ff <0f> 0b 1d 04 00 19 2e c0 eb ab 0f 0b 41 00 2e 0d 2e c0 e9 43 ff 
Dec 10 19:48:29 store03 kernel: [4667487.555000] EIP: [<c017d70e>] generic_delete_inode+0x11d/0x134 SS:ESP 0068:eca27e94


On Fri, Apr 21, 2006 at 11:58:32AM +0200, Jens Beyer wrote:
> 
> Hi,
> 
> I am currently trying to investigate a BUG wich occured on one of 
> our nfs-servers last night; I am not sure if this is more NFS-related 
> or rather a problem of the underlaying filesystem (XFS). Could you 
> give me some advice on it?
> 
> The System is an HP DL360g4, SLES9 with an vanilla Kernel + drbd 
> + qlogic-drivers serving NFS files from FC-attached SATA-raids. Locally, 
> the filesystem  as still accessible after the BUG occured but all 
> nfs-clients hung within few minutes. Later, the (local) unmount of 
> the filesystem failed (then the node was stonith', so no further 
> investigation possible).
> 
> Thanks,
> Jens
> 
> Apr 21 01:10:19 store03 kernel: [293568.899931] ------------[ cut here ]------------
> Apr 21 01:10:19 store03 kernel: [293568.899942] kernel BUG at fs/inode.c:1057!
> Apr 21 01:10:19 store03 kernel: [293568.899947] invalid operand: 0000 [#1]
> Apr 21 01:10:19 store03 kernel: [293568.899951] SMP 
> Apr 21 01:10:19 store03 kernel: [293568.899956] Modules linked in: nfs nfsd lockd nfs_acl sunrpc xfs exportfs softdog floppy nvram autofs4 e1000 piix tg3 md_mod dm_mod drbd ide_cd cdrom ide_core sg sd_mod qla2400 qla2xxx_conf qla2xxx firmware_class
> Apr 21 01:10:19 store03 kernel: [293568.899993] CPU:    1
> Apr 21 01:10:19 store03 kernel: [293568.899995] EIP:    0060:[<c017b0e1>]    Not tainted VLI
> Apr 21 01:10:19 store03 kernel: [293568.899997] EFLAGS: 00010202   (2.6.15.6-QLw) 
> Apr 21 01:10:19 store03 kernel: [293568.900009] EIP is at generic_delete_inode+0xd6/0x139
> Apr 21 01:10:19 store03 kernel: [293568.900013] eax: c4bd57b8   ebx: 00000000   ecx: 00000003   edx: d989a7b0
> Apr 21 01:10:19 store03 kernel: [293568.900017] esi: d989a614   edi: 00000000   ebp: cbddf714   esp: edd3be90
> Apr 21 01:10:19 store03 kernel: [293568.900021] ds: 007b   es: 007b   ss: 0068
> Apr 21 01:10:19 store03 kernel: [293568.900025] Process nfsd (pid: 17691, threadinfo=edd3a000 task=ed92c580)
> Apr 21 01:10:19 store03 kernel: [293568.900028] Stack: d989a614 00000000 00000000 d989a614 cbddf70c c017b327 d989a614 c031a690 
> Apr 21 01:10:19 store03 kernel: [293568.900038]        d989a614 c0179457 d989a614 00000400 00000000 00000000 00000000 e525e9dc 
> Apr 21 01:10:19 store03 kernel: [293568.900047]        cbddf70c ffffc000 c0171265 cbddf70c cbddf70c 00000000 cbddf70c d9c04a04 
> Apr 21 01:10:19 store03 kernel: [293568.900057] Call Trace:
> Apr 21 01:10:19 store03 kernel: [293568.900063]  [<c017b327>] iput+0x5f/0x7a
> Apr 21 01:10:19 store03 kernel: [293568.900070]  [<c0179457>] d_delete+0xfe/0x13c
> Apr 21 01:10:19 store03 kernel: [293568.900076]  [<c0171265>] vfs_unlink+0x18b/0x1bc
> Apr 21 01:10:19 store03 kernel: [293568.900083]  [<f0ea78ec>] nfsd_unlink+0x16f/0x261 [nfsd]
> Apr 21 01:10:19 store03 kernel: [293568.900098]  [<f0eae14a>] nfsd3_proc_remove+0x8a/0xc4 [nfsd]
> Apr 21 01:10:19 store03 kernel: [293568.900112]  [<f0ea1751>] nfsd_dispatch+0x13a/0x20d [nfsd]
> Apr 21 01:10:19 store03 kernel: [293568.900123]  [<fbdb6f09>] svc_process+0x278/0x65f [sunrpc]
> Apr 21 01:10:19 store03 kernel: [293568.900145]  [<f0ea1478>] nfsd+0x1ba/0x359 [nfsd]
> Apr 21 01:10:19 store03 kernel: [293568.900164]  [<f0ea12be>] nfsd+0x0/0x359 [nfsd]
> Apr 21 01:10:19 store03 kernel: [293568.900180]  [<c0101139>] kernel_thread_helper+0x5/0xb
> Apr 21 01:10:19 store03 kernel: [293568.900190] Code: 89 50 04 c7 06 00 00 00 00 c7 46 04 00 00 00 00 b8 90 a6 31 c0 e8 0c 32 14 00 89 34 24 e8 97 05 00 00 83 be 9c 01 00 00 20 74 08 <0f> 0b 21 04 cf c1 2d c0 89 74 24 18 83 c4 0c 5b 5e e9 7c ed ff 
> 

-- 
Dr. Jens Beyer
IT-Systemarchitekt

Schlund & Partner AG
Brauerstrasse 48 - D-76135 Karlsruhe
Tel. +49-721-91374-4245
jens.beyer@webde.de - http://web.de

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
