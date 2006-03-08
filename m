From: Bas van der Vlies <basv@sara.nl>
Subject: Re: NFSD crashes with oops
Date: Wed, 08 Mar 2006 16:01:52 +0100
Message-ID: <440EF1E0.1030705@sara.nl>
References: <5F4E2391-4553-4A5A-8A92-1033CE717267@sara.nl> <440EE57B.2090804@sara.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FH0Au-0001af-TG
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 07:02:04 -0800
Received: from surfboard.ka.sara.nl ([145.100.6.3])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FH0Au-0008AI-Gv
	for nfs@lists.sourceforge.net; Wed, 08 Mar 2006 07:02:04 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <440EE57B.2090804@sara.nl>
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

Our FS-nodes are SMP systems with 2 CPU's

Bas van der Vlies wrote:
> 
> Bas van der Vlies wrote:
>> At our side we have an 4 node GFS cluster. The nodes act as an 
>> NFS-server to +/- 640 nodes.
>>
> 
> Just upgraded to 2.6.16-rc5 and still nfsd crashes. With more debug 
> output. So some code is fixed in this release. Nfsd crashes instead
> of 128 we now have 127, nfsd still runing now.
> 
> == Crash Output ==
> Unable to handle kernel NULL pointer dereference at virtual address 
> 00000038
>  printing eip:
> f89a4be3
> *pde = 37809001
> *pte = 00000000
> Oops: 0000 [#1]
> SMP
> Modules linked in: lock_dlm dlm cman dm_round_robin dm_multipath sg 
> ide_floppy ide_cd cdrom qla2xxx siimage piix e1000 gfs lock_harness dm_mod
> CPU:    0
> EIP:    0060:[<f89a4be3>]    Tainted: GF     VLI
> EFLAGS: 00010246   (2.6.16-rc5-sara3 #1)
> EIP is at gfs_create+0x6f/0x153 [gfs]
> eax: 00000000   ebx: ffffffef   ecx: f27d0d98   edx: ffffffef
> esi: f2f84690   edi: f8b93000   ebp: f34a5e98   esp: f34a5e20
> ds: 007b   es: 007b   ss: 0068
> Process nfsd (pid: 8973, threadinfo=f34a4000 task=f3462a70)
> Stack: <0>f092a530 00000001 f34a5e48 00000000 f34a5e84 f89a6628 f34a5e48 
> ee1fc324 00000003 00000000 f34a5e48 f34a5e48 00000000 f3462a70 00000003 
> f34a5e5c f34a5e5c f27d0d98 f3462a70 00000001 00000020 00000000 000000c2 
> 00000000
> Call Trace:
>  [<c0103599>] show_stack_log_lvl+0xad/0xb5
>  [<c01036db>] show_registers+0x10d/0x176
>  [<c01038ad>] die+0xf2/0x16d
>  [<c010f668>] do_page_fault+0x3dd/0x57a
>  [<c010322f>] error_code+0x4f/0x54
>  [<c01585f2>] vfs_create+0x6a/0xa7
>  [<c0195e1c>] nfsd_create_v3+0x2b1/0x48a
>  [<c019af2f>] nfsd3_proc_create+0x116/0x123
>  [<c019229f>] nfsd_dispatch+0xbe/0x17f
>  [<c02e0a52>] svc_process+0x381/0x5c7
>  [<c019208c>] nfsd+0x18d/0x2e2
>  [<c0100ed9>] kernel_thread_helper+0x5/0xb
> Code: 94 50 8b 45 0c ff 75 10 83 c0 1c 6a 01 89 45 88 50 8d 45 c4 50 e8 
> 70 08 ff ff 83 c4 14 89 c3 85 c0 74 4883 f8 ef 75 33 8b 45 14 <80> 78 38 
> 00 78 2a 8d 45 94 50 8d 45 c4 6a 00 ff 75 88 50 e8 3c
>  BUG: nfsd/8973, lock held at task exit time!
>  [ee1fc398] {inode_init_once}
> .. held by:              nfsd: 8973 [f3462a70, 115]
> ... acquired at:               nfsd_create_v3+0x127/0x48a
> 
> 


-- 
--
********************************************************************
*                                                                  *
*  Bas van der Vlies                     e-mail: basv@sara.nl      *
*  SARA - Academic Computing Services    phone:  +31 20 592 8012   *
*  Kruislaan 415                         fax:    +31 20 6683167    *
*  1098 SJ Amsterdam                                               *
*                                                                  *
********************************************************************


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
