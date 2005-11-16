From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Re: Odd errors and bad performance -- NFS/MD/centOS 4
Date: Wed, 16 Nov 2005 11:58:14 -0500 (EST)
Message-ID: <Pine.LNX.4.62.0511161151090.806@chaos.egr.duke.edu>
References: <Pine.LNX.4.62.0511151326270.806@chaos.egr.duke.edu>
 <17274.28176.342907.560389@cse.unsw.edu.au> <Pine.LNX.4.62.0511160625450.9734@chaos.egr.duke.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EcQc3-0001vG-OV
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 08:58:23 -0800
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EcQby-0006Px-Av
	for nfs@lists.sourceforge.net; Wed, 16 Nov 2005 08:58:23 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <Pine.LNX.4.62.0511160625450.9734@chaos.egr.duke.edu>
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

On Wed, 16 Nov 2005 at 8:45am, Joshua Baker-LePain wrote

> On Wed, 16 Nov 2005 at 10:24am, Neil Brown wrote

>> Writing to NFS usually is slow as the server has to commit everything
>> to disk before returning.  You can try 'data=journal' as a mount
>> option.  It sometimes makes NFS writes faster, but it might make local
>> writes slower.
>
> These systems are pure file servers, so local performance is of no concern. 
> I'll give data=journal a shot.  Thanks!

data=journal was actually worse than the default data=ordered, while 
data=writeback was slightly better (but not enough, in my mind, to justify 
using it).  I guess I just expected to see the CPUs maxed out if disk were 
the bottleneck on a software RAID system.

Thanks again.

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
