From: Stuart Anderson <anderson@ligo.caltech.edu>
Subject: kernel Oops in rpc.mountd
Date: Mon, 7 Feb 2005 11:15:24 -0800
Message-ID: <200502071915.j17JFO7N007650@m27.ligo.caltech.edu>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyEM3-0003pI-3Q
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 11:15:27 -0800
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CyEM1-0002pU-NI
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 11:15:27 -0800
Received: from m27.ligo.caltech.edu (m27 [131.215.115.127])
	by acrux.ligo.caltech.edu (8.12.11/8.12.11) with ESMTP id j17JEhsM009682
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Mon, 7 Feb 2005 11:14:43 -0800 (PST)
Received: (from anderson@localhost)
	by m27.ligo.caltech.edu (8.12.8/8.12.8/Submit) id j17JFO7N007650
	for nfs@lists.sourceforge.net; Mon, 7 Feb 2005 11:15:24 -0800
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

A dual-Xeon FC3 machine just crashed with the following kernel Oops in
rpc.mounted.  Any ideas on how to debug this?

kernel-smp-2.6.10-1.760_FC3
kernel-utils-2.4-13.1.49_FC3
nfs-utils-1.0.6-44
portmap-4.0-63

I am getting about 1 kernel crash per day on a cluster of 290 such boxes
with different kernel Oops messages.  I do not always get the syslog message,
but perhaps this one has enough information to track it down.

Thanks.


Feb  6 21:49:44 node77 kernel: Unable to handle kernel paging request at virtual address 00100104
Feb  6 21:49:44 node77 kernel:  printing eip:
Feb  6 21:49:44 node77 kernel: f8a5179e
Feb  6 21:49:44 node77 kernel: *pde = 369c0001
Feb  6 21:49:44 node77 kernel: Oops: 0000 [#1]
Feb  6 21:49:44 node77 kernel: SMP
Feb  6 21:49:44 node77 kernel: Modules linked in: nfsd exportfs md5 ipv6 nfs lockd sunrpc dm_mod video button battery ac uhci_hcd hw_random i2c_i801 i2c_core e1000 floppy ext3 jbd
Feb  6 21:49:44 node77 kernel: CPU:    2
Feb  6 21:49:44 node77 kernel: EIP:    0060:[<f8a5179e>]    Not tainted VLI
Feb  6 21:49:44 node77 kernel: EFLAGS: 00010206   (2.6.10-1.760_FC3smp)
Feb  6 21:49:44 node77 kernel: EIP is at cache_clean+0xe6/0x1b7 [sunrpc]
Feb  6 21:49:44 node77 kernel: eax: dff05000   ebx: 00100100   ecx: 0000008f   edx: f8a62fa0
Feb  6 21:49:44 node77 kernel: esi: cf874180   edi: 00000000   ebp: f6c5bef4   esp: f6c5bec8
Feb  6 21:49:44 node77 kernel: ds: 007b   es: 007b   ss: 0068
Feb  6 21:49:44 node77 kernel: Process rpc.mountd (pid: 3620, threadinfo=f6c5b000 task=f6ad5a60)
Feb  6 21:49:44 node77 kernel: Stack: df941140 c232c680 42070880 f8a518bc f8a4f6ec f6c5bf02 0000000a 0000000e
Feb  6 21:49:44 node77 kernel:        00000001 000000c8 f6c5bf58 f8a65f69 37303131 31373537 00003438 00166995
Feb  6 21:49:44 node77 kernel:        000081a4 00000001 00000000 00000000 00000000 00000000 00000000 00000098
Feb  6 21:49:44 node77 kernel: Call Trace:
Feb  6 21:49:44 node77 kernel:  [<f8a518bc>] cache_flush+0x1a/0x3b [sunrpc]
Feb  6 21:49:44 node77 kernel:  [<f8a4f6ec>] ip_map_parse+0x18b/0x19a [sunrpc]
Feb  6 21:49:44 node77 kernel:  [<f8a4f561>] ip_map_parse+0x0/0x19a [sunrpc]
Feb  6 21:49:44 node77 kernel:  [<f8a51e4a>] cache_write+0x8d/0xa7 [sunrpc]
Feb  6 21:49:44 node77 kernel:  [<c0152424>] vfs_write+0xb6/0xe2
Feb  6 21:49:44 node77 kernel:  [<c01524ee>] sys_write+0x3c/0x62
Feb  6 21:49:44 node77 kernel:  [<c0103c97>] syscall_call+0x7/0xb
Feb  6 21:49:44 node77 kernel: Code: f8 0f 8d e5 00 00 00 8d 42 08 e8 4d a5 86 c7 a1 00 4f a6 f8 8b 50 04 a1 04 4f a6 f8 8d 34 82 8b 1e 85 db 74 74 8b 15 00 4f a6 f8 <8b> 43 04 39 42 34 7e 04 40 89 42 34 8b 43 04 3b 05 10 1d 41 c0


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
