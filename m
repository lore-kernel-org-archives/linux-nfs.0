From: Jan Bruvoll <jan@bruvoll.com>
Subject: Performance problems with high number of clients
Date: Thu, 22 Jul 2004 21:53:42 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <41002956.2080103@bruvoll.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BnkZl-0000Dy-IM
	for nfs@lists.sourceforge.net; Thu, 22 Jul 2004 13:54:01 -0700
Received: from homer.brvl.com ([213.61.99.172])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BnkZl-0000jA-3Y
	for nfs@lists.sourceforge.net; Thu, 22 Jul 2004 13:54:01 -0700
Received: from 144.red-80-58-247.pooles.rima-tde.net ([80.58.247.144] helo=[10.211.14.180])
	by homer.brvl.com with asmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BnkZc-00026Y-Mx
	for nfs@lists.sourceforge.net; Thu, 22 Jul 2004 22:53:52 +0200
To: NFS mailling list <nfs@lists.sourceforge.net>
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

Dear List,

I am having problems with a site served by a NFS server cluster/pair, 
and I hope you could please have a quick look at this and give me a few 
pointers on what to look for. I'm not extremely experienced when it 
comes to NFS tuning, and frankly I don't quite know where to begin now.

Specs:
2 servers (Dual Xeon 3Ghz 2Gb ram, 3Ware RAID5, Gentoo kernel 2.4.26 r6) 
connected with DRBD and heartbeat to do auto fail-over.
Clients: 10 relatively heavily laden web servers (1 mill. PVs total per 
day), using a simple file based locking mechanism for newly generated 
content (which leads to a steady flow of file creations and deletions)

The problem only occurs when the most active NFS mount is added (where 
the locking mechanism is used), where the server load increases to about 
~7, response goes down the drain, however the CPUs are apparently 
98-100% idle. In this situation, I'm not able to mount/unmount anything 
-> RPC timeouts.

If only the other mounts are set up, ie ~60 relatively inactive mounts, 
there are no problems.

I've done some crude transfer speed testing: I've created a 500Mb file 
that I for load testing make a copy of using rsync. Ie. all numbers 
below are tested using simultaneous reads and writes.

hdparm -Tt /dev/sda: 39Mb/s
Direct to file system (read + write): 12 Mb/s sustained
Onto DRBD file system (read + write): 10 Mb/s sustained
Over NFS (read + write): 3.6 Mb/s

The network between test client and server is 100Mb/s. I guess the raw 
throughput is ok, however I can't quite understand why everything hangs 
up when I add the final mount. Any help would be greatly appreciated.

PS. I should of course also add that the current, main NFS server, an 
old single PIII/650 with kernel 2.4.17, has no problems -at all- with 
the same load.

Best regards
Jan



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
