From: Jens Beyer <jbe@webde.de>
Subject: nfsd triggered (?) kernel BUG at fs/inode:1057
Date: Fri, 21 Apr 2006 11:58:32 +0200
Message-ID: <20060421095832.GA15203@pcnocjb.dlan.cinetic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FWsPP-0004wD-1A
	for nfs@lists.sourceforge.net; Fri, 21 Apr 2006 02:58:39 -0700
Received: from mailgate01.web.de ([217.72.192.251])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FWsPO-0001Nd-HV
	for nfs@lists.sourceforge.net; Fri, 21 Apr 2006 02:58:39 -0700
Received: from pcnocjb.int.cinetic.de (pcnocjb.int.cinetic.de [172.17.73.12])
	by mailgate01.web.de (Postfix) with ESMTP id 3F00D281078
	for <nfs@lists.sourceforge.net>; Fri, 21 Apr 2006 11:58:32 +0200 (CEST)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Hi,

I am currently trying to investigate a BUG wich occured on one of 
our nfs-servers last night; I am not sure if this is more NFS-related 
or rather a problem of the underlaying filesystem (XFS). Could you 
give me some advice on it?

The System is an HP DL360g4, SLES9 with an vanilla Kernel + drbd 
+ qlogic-drivers serving NFS files from FC-attached SATA-raids. Locally, 
the filesystem  as still accessible after the BUG occured but all 
nfs-clients hung within few minutes. Later, the (local) unmount of 
the filesystem failed (then the node was stonith', so no further 
investigation possible).

Thanks,
Jens

Apr 21 01:10:19 store03 kernel: [293568.899931] ------------[ cut here ]------------
Apr 21 01:10:19 store03 kernel: [293568.899942] kernel BUG at fs/inode.c:1057!
Apr 21 01:10:19 store03 kernel: [293568.899947] invalid operand: 0000 [#1]
Apr 21 01:10:19 store03 kernel: [293568.899951] SMP 
Apr 21 01:10:19 store03 kernel: [293568.899956] Modules linked in: nfs nfsd lockd nfs_acl sunrpc xfs exportfs softdog floppy nvram autofs4 e1000 piix tg3 md_mod dm_mod drbd ide_cd cdrom ide_core sg sd_mod qla2400 qla2xxx_conf qla2xxx firmware_class
Apr 21 01:10:19 store03 kernel: [293568.899993] CPU:    1
Apr 21 01:10:19 store03 kernel: [293568.899995] EIP:    0060:[<c017b0e1>]    Not tainted VLI
Apr 21 01:10:19 store03 kernel: [293568.899997] EFLAGS: 00010202   (2.6.15.6-QLw) 
Apr 21 01:10:19 store03 kernel: [293568.900009] EIP is at generic_delete_inode+0xd6/0x139
Apr 21 01:10:19 store03 kernel: [293568.900013] eax: c4bd57b8   ebx: 00000000   ecx: 00000003   edx: d989a7b0
Apr 21 01:10:19 store03 kernel: [293568.900017] esi: d989a614   edi: 00000000   ebp: cbddf714   esp: edd3be90
Apr 21 01:10:19 store03 kernel: [293568.900021] ds: 007b   es: 007b   ss: 0068
Apr 21 01:10:19 store03 kernel: [293568.900025] Process nfsd (pid: 17691, threadinfo=edd3a000 task=ed92c580)
Apr 21 01:10:19 store03 kernel: [293568.900028] Stack: d989a614 00000000 00000000 d989a614 cbddf70c c017b327 d989a614 c031a690 
Apr 21 01:10:19 store03 kernel: [293568.900038]        d989a614 c0179457 d989a614 00000400 00000000 00000000 00000000 e525e9dc 
Apr 21 01:10:19 store03 kernel: [293568.900047]        cbddf70c ffffc000 c0171265 cbddf70c cbddf70c 00000000 cbddf70c d9c04a04 
Apr 21 01:10:19 store03 kernel: [293568.900057] Call Trace:
Apr 21 01:10:19 store03 kernel: [293568.900063]  [<c017b327>] iput+0x5f/0x7a
Apr 21 01:10:19 store03 kernel: [293568.900070]  [<c0179457>] d_delete+0xfe/0x13c
Apr 21 01:10:19 store03 kernel: [293568.900076]  [<c0171265>] vfs_unlink+0x18b/0x1bc
Apr 21 01:10:19 store03 kernel: [293568.900083]  [<f0ea78ec>] nfsd_unlink+0x16f/0x261 [nfsd]
Apr 21 01:10:19 store03 kernel: [293568.900098]  [<f0eae14a>] nfsd3_proc_remove+0x8a/0xc4 [nfsd]
Apr 21 01:10:19 store03 kernel: [293568.900112]  [<f0ea1751>] nfsd_dispatch+0x13a/0x20d [nfsd]
Apr 21 01:10:19 store03 kernel: [293568.900123]  [<fbdb6f09>] svc_process+0x278/0x65f [sunrpc]
Apr 21 01:10:19 store03 kernel: [293568.900145]  [<f0ea1478>] nfsd+0x1ba/0x359 [nfsd]
Apr 21 01:10:19 store03 kernel: [293568.900164]  [<f0ea12be>] nfsd+0x0/0x359 [nfsd]
Apr 21 01:10:19 store03 kernel: [293568.900180]  [<c0101139>] kernel_thread_helper+0x5/0xb
Apr 21 01:10:19 store03 kernel: [293568.900190] Code: 89 50 04 c7 06 00 00 00 00 c7 46 04 00 00 00 00 b8 90 a6 31 c0 e8 0c 32 14 00 89 34 24 e8 97 05 00 00 83 be 9c 01 00 00 20 74 08 <0f> 0b 21 04 cf c1 2d c0 89 74 24 18 83 c4 0c 5b 5e e9 7c ed ff 



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
