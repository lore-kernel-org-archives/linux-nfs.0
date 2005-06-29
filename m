From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: More Stale NFS handles
Date: Wed, 29 Jun 2005 16:50:56 -0400
Message-ID: <20050629205056.GB29952@ti64.telemetry-investments.com>
References: <449CA531-2B73-458E-B632-B1E159637115@jhu.edu> <1120076887.8751.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eiwe Lingefors <eiwe@jhu.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DnjWT-0003c7-1V
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 13:51:05 -0700
Received: from 209-166-240-202.cust.walrus.com ([209.166.240.202] helo=ti41.telemetry-investments.com)
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DnjWR-0006qS-Ud
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 13:51:05 -0700
To: Kris Vassallo <kris@linuxcertified.com>
In-Reply-To: <1120076887.8751.34.camel@localhost.localdomain>
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

On Wed, Jun 29, 2005 at 01:28:07PM -0700, Kris Vassallo wrote:
> I was using ext3, upgraded to core 3 from core 1 and had the exact same
> problems. What did it for me, until someone fixes this problem, was to
> turn off journaling (so basically its back to ext2). Since reverting
> back to ext 2 the problem has gone away. Now this is going to be a huge
> problem if the machine crashes because fscking a 1.5 TB disk array is
> going to suck! I experimented with the way the journaling gets done
> (data goes to disk first or journal first) and I wasn't able to fix the
> problem. 
> 
> Aaaaaaargh! 
> I just thought I would share my ongoing battle story, hopefully someone
> will figure out what's causing this and will come up with a fix.

We're you using ext3 directory indexing? [Look for feature "dir_index" on
the "Filesystem features:" line in "/sbin/tune2fs -l <device>" output.]

If so, was the following patch in the kernel that you were using?

   http://marc.theaimsgroup.com/?l=ext2-devel&m=111568753527230&w=2

Regards,

	Bill Rugolsky


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
