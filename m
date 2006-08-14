From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Kernel oops (NLM?)
Date: Mon, 14 Aug 2006 10:33:47 -0400
Message-ID: <1155566027.5664.56.camel@localhost>
References: <Pine.LNX.4.62.0608140949350.23888@office2.c1.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCdWP-0006hk-C3
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 07:34:29 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GCdWO-00067W-Gi
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 07:34:30 -0700
To: Allard Hoeve <allard@byte.nl>
In-Reply-To: <Pine.LNX.4.62.0608140949350.23888@office2.c1.internal>
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

On Mon, 2006-08-14 at 10:01 +0200, Allard Hoeve wrote:
> Hello all,
> 
> Some time ago, I encountered a kernel oops that resulted in a crashed lock 
> daemon. nfsd never stopped working, but all client lock requests stalled.
> 
> The machine is a PowerEdge 2850 and had a vanilla 2.6.16.13 kernel 
> running.

I'd suggest upgrading. We've eliminated a lot of races in NLM since
then, and have (among other things) completely removed the codepath that
appears to have Oopsed below.

Cheers,
  Trond

> I'm not sure how to debug this, so I thought I might just send it to you.
> 
> If you need any more information, please ask. I'm on the list.
> 
> Regards,
> 
> Allard Hoeve
> 
> PS: Kernel config attached
> 
> 
> 
> Unable to handle kernel paging request at virtual address 6e6f6974
>   printing eip:
> c0176469
> *pde = 00000000
> Oops: 0000 [#1]
> SMP
> Modules linked in: nfsd ipv6 shpchp pci_hotplug ehci_hcd uhci_hcd usbcore 
> ide_cd cdrom
> CPU:    0
> EIP:    0060:[<c0176469>]    Not tainted VLI
> EFLAGS: 00010246   (2.6.16.13-byte #2)
> EIP is at posix_locks_deadlock+0x3b/0x5e
> eax: 00000000   ebx: 6e6f6974   ecx: f7fb74b8   edx: 00000000
> esi: f7fb74b8   edi: f73622b8   ebp: f7362200   esp: f7247efc
> ds: 007b   es: 007b   ss: 0068
> Process lockd (pid: 2478, threadinfo=f7246000 task=f7d89030)
> Stack: <0>f77634c8 f7fb74b8 f7fb74b8 f7362600 f7362224 c022446d f73622b8 f7fb74b8
>         00000000 d22430c0 f7362224 f7362200 00000000 c0229148 f7735400 f7247f40
>         f7477c00 f73622b8 f7362200 f7362600 f7735400 f7735464 c02293a9 f7735400
> Call Trace:
>   [<c022446d>] nlmsvc_lock+0x9a/0x414
>   [<c0229148>] nlm4svc_retrieve_args+0x7c/0xe9
>   [<c02293a9>] nlm4svc_proc_lock+0xe2/0x13d
>   [<c045ce98>] svc_process+0x3f0/0x684
>   [<c0223a6a>] lockd+0x133/0x23a
>   [<c0223937>] lockd+0x0/0x23a
>   [<c0101141>] kernel_thread_helper+0x5/0xb
> Code: 24 04 89 3c 24 e8 f7 fa ff ff 85 c0 75 39 8b 1d 5c 47 4e c0 eb 15 8d 
> 43 fc 89 74 24 04 89 04 24 e8 dc fa ff ff 85 c0 75 19 8b 1b <8b> 03 0f 18 
> 00 90 81 fb 5c 47 4e c0 75 dd 31 c0 83 c4 08 5b 5e
>   <4>lockd_down: lockd failed to exit, clearing pid
> ------------------------------------------------------------------------- Using Tomcat but need to do more? Need to support web services, security? Get stuff done quickly with pre-integrated technology to make your job easier Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
