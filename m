From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: NFS using too much memory on diskless system
Date: Thu, 24 Feb 2005 08:17:09 -0500
Message-ID: <20050224131709.GA6093@ti64.telemetry-investments.com>
References: <BAY101-F38CA29432DA94D86024AD3BD640@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4Irs-0005gn-2u
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 05:17:24 -0800
Received: from 209-166-240-202.cust.walrus.com ([209.166.240.202] helo=ti41.telemetry-investments.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D4Irq-0001aM-Mv
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 05:17:24 -0800
To: Gareth Glaccum <verycoldpenguin@hotmail.com>
In-Reply-To: <BAY101-F38CA29432DA94D86024AD3BD640@phx.gbl>
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

On Thu, Feb 24, 2005 at 12:19:15PM +0000, Gareth Glaccum wrote:
> To recreate the problem, the following command took the machine out in less 
> than 3 seconds dd if=/dev/zero of=/mnt/NFSMOUNT bs=1024k count=4000 The 
> machine has 4GB of memory and is using around 300Mb for its OS all told.
> Is there some way of limiting the NFS cache size like there used to be in 
> the 2.4 kernel? (see section B7 of the nfs FAQ I believe)
 
There was definitely a known issue with NFS write-throttling back in early 2.6.
Andrew Morton had an "nfs-write-throttling.patch" in the -mm series for a while;
I'm not sure when it was merged.  Perhaps try a recent mainline kernel, or
dig out the patch(es) and see whether they apply to your SuSE kernel.

Regards,

	Bill Rugolsky


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
