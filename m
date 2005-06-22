From: Hugh Caley <Hugh_Caley@affymetrix.com>
Subject: How many nfsd's can I run?
Date: Tue, 21 Jun 2005 19:02:04 -0700
Message-ID: <42B8C69C.6010302@affymetrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DkuZ5-0005II-KU
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 19:02:07 -0700
Received: from firewall.neomorphic.com ([205.217.46.68] helo=roma.ev.affymetrix.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DkuZ4-0000NM-8l
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 19:02:07 -0700
Received: from [10.82.12.54] (puglia.ev.affymetrix.com [10.82.12.54])
	by roma.ev.affymetrix.com (8.11.6/8.11.6) with ESMTP id j5M224g28915
	for <nfs@lists.sourceforge.net>; Tue, 21 Jun 2005 19:02:04 -0700
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

Often when a cluster run (100+ nodes) is started my NFS server will get 
very slow; users with their home directories on the server will lock up 
for short periods, and the load average crawls higher.

The output of cat /proc/net/rpc/nfsd:

th 125 264502 142948.997 38666.037 22620.179 16494.577 10072.689 
5700.113 2623.322 1094.785 474.752 1900.536

This would seem to mean that my nfsd threads are runnning at 100% for 
much of the time, meaning I need more nfsd's, correct?  But is there a 
limit to the amount of nfsd's I should run?  I had had it as high as 150 
at one time, but it seemed to me this made the server less stable.  
There may have been other reasons for this, however.

Anyway I have since doubled the ram on the server (to 8 gig).  Machine 
is a dual Xeon 2.6 Ghz machine running Fedora Core 2, kernel version 
2.6.10-1.771_FC2smp, gigabit ethernet.  Can I run more nfsd's, or should 
I be looking for other problems?

Hugh

-- 
Hugh Caley | Unix Systems Administrator | CIS
AFFYMETRIX, INC. | 6550 Vallejo St. Ste 100 | Emeryville, CA 94608
Tel: 510-428-8537 | Hugh_Caley@affymetrix.com



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
