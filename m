From: Stuart Anderson <anderson@ligo.caltech.edu>
Subject: Re: kernel Oops in rpc.mountd
Date: Mon, 7 Feb 2005 20:03:48 -0800
Message-ID: <200502080403.j1843mxO011918@m27.ligo.caltech.edu>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyMbT-0000hu-U0
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 20:03:55 -0800
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CyMbR-0002ri-A6
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 20:03:55 -0800
To: neilb@cse.unsw.edu.au
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

I just had a physically different node Oops with an identical stack trace
in rpc.mountd:

Feb  7 17:23:10 node48 kernel: Unable to handle kernel paging request at virtual address 00100104
Feb  7 17:23:10 node48 kernel:  printing eip:
Feb  7 17:23:10 node48 kernel: f8a6179e
Feb  7 17:23:10 node48 kernel: *pde = 02288001
Feb  7 17:23:10 node48 kernel: Oops: 0000 [#1]
Feb  7 17:23:10 node48 kernel: SMP
Feb  7 17:23:10 node48 kernel: Modules linked in: nfsd exportfs md5 ipv6 nfs lockd sunrpc dm_mod video button battery ac uhci_hcd hw_random i2c_i801 i2c_core e1000 floppy ext3 jbd
Feb  7 17:23:10 node48 kernel: CPU:    1
Feb  7 17:23:10 node48 kernel: EIP:    0060:[<f8a6179e>]    Not tainted VLI
Feb  7 17:23:10 node48 kernel: EFLAGS: 00010206   (2.6.10-1.760_FC3smp)
Feb  7 17:23:10 node48 kernel: EIP is at cache_clean+0xe6/0x1b7 [sunrpc]
Feb  7 17:23:10 node48 kernel: eax: e76f2000   ebx: 00100100   ecx: 0000000b   edx: f8a72fa0
Feb  7 17:23:10 node48 kernel: esi: f4df9940   edi: 00000000   ebp: f6b19ef4   esp: f6b19ec8
Feb  7 17:23:10 node48 kernel: ds: 007b   es: 007b   ss: 0068
Feb  7 17:23:10 node48 kernel: Process rpc.mountd (pid: 4013, threadinfo=f6b19000 task=f7cf0540)
Feb  7 17:23:10 node48 kernel: Stack: f4cd7200 f5a9c580 42081b86 f8a618bc f8a5f6ec f6b19f02 0000000a 0000000e
Feb  7 17:23:10 node48 kernel:        00000001 00000023 f6b19f58 f8a75f68 37303131 35373238 00003039 0002bd64
Feb  7 17:23:10 node48 kernel:        000081a4 00000001 00000000 00000000 00000000 00000000 00000000 00000098
Feb  7 17:23:10 node48 kernel: Call Trace:
Feb  7 17:23:10 node48 kernel:  [<f8a618bc>] cache_flush+0x1a/0x3b [sunrpc]
Feb  7 17:23:10 node48 kernel:  [<f8a5f6ec>] ip_map_parse+0x18b/0x19a [sunrpc]
Feb  7 17:23:10 node48 kernel:  [<f8a5f561>] ip_map_parse+0x0/0x19a [sunrpc]
Feb  7 17:23:10 node48 kernel:  [<f8a61e4a>] cache_write+0x8d/0xa7 [sunrpc]
Feb  7 17:23:10 node48 kernel:  [<c0152424>] vfs_write+0xb6/0xe2
Feb  7 17:23:10 node48 kernel:  [<c01524ee>] sys_write+0x3c/0x62
Feb  7 17:23:10 node48 kernel:  [<c0103c97>] syscall_call+0x7/0xb
Feb  7 17:23:10 node48 kernel: Code: f8 0f 8d e5 00 00 00 8d 42 08 e8 4d a5 85 c7 a1 00 4f a7 f8 8b 50 04 a1 04 4f a7 f8 8d 34 82 8b 1e 85 db 74 74 8b 15 00 4f a7 f8 <8b> 43 04 39 42 34 7e 04 40 89 42 34 8b 43 04 3b 05 10 1d 41 c0

According to Neil Brown:
> On Monday February 7, anderson@ligo.caltech.edu wrote:
> > A dual-Xeon FC3 machine just crashed with the following kernel Oops in
> > rpc.mounted.  Any ideas on how to debug this?
> >
> > kernel-smp-2.6.10-1.760_FC3
> > kernel-utils-2.4-13.1.49_FC3
> > nfs-utils-1.0.6-44
> > portmap-4.0-63
> >
> > I am getting about 1 kernel crash per day on a cluster of 290 such boxes
> > with different kernel Oops messages.  I do not always get the syslog message,
> > but perhaps this one has enough information to track it down.
> >
> > Thanks.
> >
> >
> > Feb  6 21:49:44 node77 kernel: Unable to handle kernel paging request at virtual address 00100104
>                                                                                            ^^^^^^^^
> ...
> > Feb  6 21:49:44 node77 kernel: eax: dff05000   ebx: 00100100   ecx: 0000008f   edx: f8a62fa0
>                                                  ^^^^^^^^^^^^^
> > Feb  6 21:49:44 node77 kernel: esi: cf874180   edi: 00000000   ebp: f6c5bef4   esp: f6c5bec8
>
>
> Looks like two flipped bits in memory.  Do you have ECC RAM? Is it
> enabled?
> What does memtest86 report?
>
> NeilBrown
>


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
