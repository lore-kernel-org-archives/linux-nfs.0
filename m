From: Jani Averbach <jaa@jaa.iki.fi>
Subject: [BUG] 2.6.8-rc4 + nfsd: Unable to handle kernel NULL pointer dereference
Date: Thu, 12 Aug 2004 20:57:04 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040813025704.GA32305@jaa.iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvSFd-0001dF-Nz
	for nfs@lists.sourceforge.net; Thu, 12 Aug 2004 19:57:05 -0700
Received: from dsl081-100-231.den1.dsl.speakeasy.net ([64.81.100.231] helo=hal9000.jaa.iki.fi)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BvSFd-0006Ma-BE
	for nfs@lists.sourceforge.net; Thu, 12 Aug 2004 19:57:05 -0700
To: nfs@lists.sourceforge.net
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


I narrowed this down to the 2.6.8rc4, 2.6.8rc3 works ok. And this
happens (on server) every time, when thin client tried mount root-fs
from server.

BR, Jani

On 2004-08-10 12:32-0600, Jani Averbach wrote:
> 
> Hello,
> 
> I tried 2.6.8-rc4 and found following, 2.6.6 and 2.6.7 are fine:
> 
> <1>Unable to handle kernel NULL pointer dereference at
> 0000000000000003 RIP: <ffffffff801e6cce>{nfssvc_decode_readargs+238}
> PML4 77661067 PGD 7778f067 PMD 78ad8067 PTE 0
> Oops: 0000 [4] SMP
> CPU 0
> Pid: 3436, comm: nfsd Not tainted 2.6.8-rc4
> RIP: 0010:[<ffffffff801e6cce>]
> <ffffffff801e6cce>{nfssvc_decode_readargs+238}
> RSP: 0018:000001007dd9fe68  EFLAGS: 00010206
> RAX: 0000000000000000 RBX: 000001007fc19400 RCX: 000001007fc18c90
> RDX: 00000000ffff8488 RSI: 000001007fc4b6ac RDI: 00000000ffff7488
> RBP: 000001007fc18c00 R08: 000000000000000a R09: 0000000000000009
> R10: 0000010000000000 R11: 6db6db6db6db6db7 R12: 000001007fc4b680
> R13: 000001007dd2b014 R14: ffffffff803bb5a0 R15: 000001007fc19468
> FS:  0000002a980ab060(0000) GS:ffffffff804ae6c0(0000)
> knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000000000000003 CR3: 0000000000101000 CR4: 00000000000006e0
> Process nfsd (pid: 3436, threadinfo 000001007dd9e000, task
> 000001007782c0f0)
> Stack: 000001007fc19400 ffffffff803bb2f0 ffffffff803bb2f0
> ffffffff801ddd00
>        000001007fc19468 000001007fc19400 000001007fc194a0
> ffffffff803bb2f0
>        000001007dd2b014 ffffffff80345a99
> Call Trace:<ffffffff801ddd00>{nfsd_dispatch+128}
> <ffffffff80345a99>{svc_process+937}
>        <ffffffff801dd8b0>{nfsd+0} <ffffffff801ddae4>{nfsd+564}
>        <ffffffff8012d811>{schedule_tail+17}
> <ffffffff8010f887>{child_rip+8}
>        <ffffffff801dd8b0>{nfsd+0} <ffffffff801dd8b0>{nfsd+0}
>        <ffffffff8010f87f>{child_rip+0}
> 
> Code: 48 0f b6 50 03 48 8b 14 d5 00 28 48 80 48 2b 82 c8 03 00 00
> RIP <ffffffff801e6cce>{nfssvc_decode_readargs+238} RSP
> <000001007dd9fe68>
> CR2: 0000000000000003
> 
> This is two way amd64 server which is serving couple of thin clients over nfs.
> 
> Linux HAL9000 2.6.6 #1 SMP Sat May 15 08:11:53 MDT 2004 x86_64 5 GNU/Linux
> 
> Gnu C                  3.3.3
> Gnu make               3.80
> binutils               2.15.90.0.1.1
> util-linux             2.12
> mount                  2.12
> module-init-tools      3.0
> e2fsprogs              1.35
> nfs-utils              1.0.6
> Linux C Library        2.3.2
> Dynamic linker (ldd)   2.3.2
> Procps                 3.2.1
> Net-tools              1.60
> Kbd                    1.12
> Sh-utils               5.2.1
> 
> 
> BR, Jani
> 

-- 
Jani Averbach


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
