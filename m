From: David Albrecht <david.albrecht@vslib.cz>
Subject: How to remove record of mounted nfs filesystem from kernel?
Date: Wed, 6 Apr 2005 22:42:46 +0200 (CEST)
Message-ID: <Pine.LNX.4.56L0.0504062226460.9467@ns.galaxy>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJHMU-0003nm-Dn
	for nfs@lists.sourceforge.net; Wed, 06 Apr 2005 13:42:54 -0700
Received: from bubo.vslib.cz ([147.230.16.1])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DJHMS-0005Ps-Uv
	for nfs@lists.sourceforge.net; Wed, 06 Apr 2005 13:42:54 -0700
Received: from b505b.kolej.vslib.cz (b505b.kolej.vslib.cz [147.230.154.62])
	by bubo.vslib.cz (Postfix) with ESMTP id 985845F40A
	for <nfs@lists.sourceforge.net>; Wed,  6 Apr 2005 22:42:46 +0200 (CEST)
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

I have following problem. One of my computers, yola (10.0.0.2) crashed. 
Yola served as nfsd server and exported directory /stuff/movies in to the 
network. This directory was mounted on valtr (10.0.0.1), but it was not 
unmounted befor crash.
So on valtr there was (still is) record in /proc/mounts

10.0.0.2:/stuff/movies /stuff/movies2 nfs rw,v3,rsize=8192,wsize=8192,hard,udp,lock,addr=10.0.0.2 0 0

which tells the directory is still mounted on /stuff/movies2

Any attempt to access this directory hangs and concludes in 

D    Uninterruptible sleep (usually IO)

status of that process.
"Any attempt" means everything i still tryed, so:

valtr@root: umount [-f][-l] /stuff/movies2
	hangs

Is there any way how to tell kernel, this directory is unmounted? Exept 
restar.

Thanks


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
