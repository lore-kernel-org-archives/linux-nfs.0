From: Stuart Anderson <sba@srl.caltech.edu>
Subject: Re: kernel Oops in rpc.mountd
Date: Mon, 7 Feb 2005 16:29:32 -0800 (PST)
Message-ID: <200502080029.QAA15462@jelly.caltech.edu>
References: <16903.63489.218836.52210@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Stuart Anderson <anderson@ligo.caltech.edu>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyJG6-0007F7-P0
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 16:29:38 -0800
Received: from lodur.srl.caltech.edu ([131.215.120.1])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CyJG5-0005w6-B2
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 16:29:38 -0800
In-Reply-To: <16903.63489.218836.52210@cse.unsw.edu.au> "from Neil Brown at Feb
 8, 2005 10:21:37 am"
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Yes.

> enabled?

Yes.

> What does memtest86 report?

I have not run it recently, but we ran it for 72 hours on all 290 nodes about
a year ago without any errors. The current round of kernel Oops are happening
on different nodes, so either most of the memory is experience a sudden
end-of-life accelerated failure rate or there is a software bug in the
newer kernel.

It looks like I have it narrowed down to one user application, but it
can run for up to a day before crashing, and it is always on a different
node/hardware, so I think it is a software bug in the kernel.

The 290 nodes cross mount each others internal IDE drives with ext3 shared
via NFS v3.


We will probably try and downgrade the kernel, but I am open to other
suggestions.

Thanks.

-- 
Stuart Anderson  sba@srl.caltech.edu  http://www.srl.caltech.edu/personnel/sba


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
