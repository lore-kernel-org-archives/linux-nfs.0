From: "Gareth Glaccum" <verycoldpenguin@hotmail.com>
Subject: NFS using too much memory on diskless system
Date: Thu, 24 Feb 2005 12:19:15 +0000
Message-ID: <BAY101-F38CA29432DA94D86024AD3BD640@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4Hyh-0003Q9-JM
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 04:20:23 -0800
Received: from bay101-f38.bay101.hotmail.com ([64.4.56.48] helo=hotmail.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D4Hyg-0007xr-4j
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 04:20:23 -0800
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
I have a diskless system built and am having weird issues with the way NFS 
client is working. I am using SLES 9.0 with the stock kernel (2.6.5-7.111-30 
I think from memory).
I have mounted an NFS partition from another machine without any issues. 
However, when I use anything to write to the partition (for example, see 
later) the system uses memory to cache the files as I am mounted over GbE.
However, the machine is not limiting the memory used at all. In fact, it is 
using so much it is crashing the machine or causing other programs to be 
OOM'd.

To recreate the problem, the following command took the machine out in less 
than 3 seconds dd if=/dev/zero of=/mnt/NFSMOUNT bs=1024k count=4000 The 
machine has 4GB of memory and is using around 300Mb for its OS all told.
Is there some way of limiting the NFS cache size like there used to be in 
the 2.4 kernel? (see section B7 of the nfs FAQ I believe)

Any ideas gratefully received,
Gareth

_________________________________________________________________
It's fast, it's easy and it's free. Get MSN Messenger today! 
http://www.msn.co.uk/messenger



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
