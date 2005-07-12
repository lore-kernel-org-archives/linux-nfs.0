From: Hugh Caley <hcaley@plasmabat.com>
Subject: Re: Performance Difference Between Linux NFS Server and Netapp
Date: Tue, 12 Jul 2005 11:19:58 -0700
Message-ID: <42D409CE.9020204@plasmabat.com>
References: <EXCHG2003ZbLAX3cf3e00000023@EXCHG2003.microtech-ks.com> <Pine.LNX.4.58.0507121229150.4766@chaos.egr.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Roger Heflin <rheflin@atipa.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsPMn-0006jd-Bg
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 11:20:25 -0700
Received: from firewall.neomorphic.com ([205.217.46.68] helo=roma.ev.affymetrix.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DsPMm-0007bV-1O
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 11:20:25 -0700
To: Joshua Baker-LePain <jlb17@duke.edu>
In-Reply-To: <Pine.LNX.4.58.0507121229150.4766@chaos.egr.duke.edu>
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

The Atabeast is an ATA-raid array, but as far as the server knows it is 
a 2 Gb fibre-attached SCSI disk.  I get 800-900 Mb/sec sequential writes 
using ext3; with Reiser or JFS it is much faster.

Regardless, I don't think this is very relevant.   My only point was 
that the disk subsystem is capable of much better performance than I'm 
currently seeing over NFS.  300 Mb/sec seems slow to me when I have a 
Dual-2.6 Ghz Linux box running kernel 2.6.10 (Fedora core 2) attached to 
a 10 disk RAID5, and the box is doing nothing else but serving this 
single NFS server.

Hugh

Joshua Baker-LePain wrote:

>On Tue, 12 Jul 2005 at 11:24am, Roger Heflin wrote
>
>  
>
>>2000mbit/second is a rate that no ide disk subsystem
>>will obtain, so double check your local performance, 
>>    
>>
>
>I have a 3ware based server that begs to differ with you -- over 150MB/s 
>writing, over 300MB/s reading.  That's on a software RAID0 stripe across 2 
>12 port controllers, with each controller doing hardware RAID5.
>
>  
>
>>You will need to use a test larger than the ram size of 
>>the machine to get a realistic rate, at least 2x, and
>>probably 4x, and maybe both just to see how things fall
>>over.
>>    
>>
>
>Absolutely.
>
>  
>


-- 
"Take off your pants and get in the reptile tank." - Joe Rogan, Fear Factor 
Hugh Caley hcaley@plasmabat.com



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
