From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: kernel Oops in rpc.mountd
Date: Tue, 8 Feb 2005 10:21:37 +1100
Message-ID: <16903.63489.218836.52210@cse.unsw.edu.au>
References: <200502071915.j17JFO7N007650@m27.ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyICR-0004pX-Et
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 15:21:47 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CyICP-00084D-Vq
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 15:21:47 -0800
To: Stuart Anderson <anderson@ligo.caltech.edu>
In-Reply-To: message from Stuart Anderson on Monday February 7
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

On Monday February 7, anderson@ligo.caltech.edu wrote:
> A dual-Xeon FC3 machine just crashed with the following kernel Oops in
> rpc.mounted.  Any ideas on how to debug this?
> 
> kernel-smp-2.6.10-1.760_FC3
> kernel-utils-2.4-13.1.49_FC3
> nfs-utils-1.0.6-44
> portmap-4.0-63
> 
> I am getting about 1 kernel crash per day on a cluster of 290 such boxes
> with different kernel Oops messages.  I do not always get the syslog message,
> but perhaps this one has enough information to track it down.
> 
> Thanks.
> 
> 
> Feb  6 21:49:44 node77 kernel: Unable to handle kernel paging request at virtual address 00100104
                                                                                           ^^^^^^^^
...
> Feb  6 21:49:44 node77 kernel: eax: dff05000   ebx: 00100100   ecx: 0000008f   edx: f8a62fa0
                                                 ^^^^^^^^^^^^^
> Feb  6 21:49:44 node77 kernel: esi: cf874180   edi: 00000000   ebp: f6c5bef4   esp: f6c5bec8


Looks like two flipped bits in memory.  Do you have ECC RAM? Is it
enabled?
What does memtest86 report?

NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
