From: Olaf Kirch <okir@suse.de>
Subject: Re: ReasmFails increases / NFS performance on Linux Cluster
Date: Tue, 17 Aug 2004 10:05:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040817080523.GA17099@suse.de>
References: <Pine.LNX.4.58.0408160851520.24272@chaos.egr.duke.edu> <005f01c483d4$b6fa9f40$6701a8c0@psyche1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: 'Joshua Baker-LePain' <jlb17@duke.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BwzAX-00022v-2P
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 01:18:09 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1Bwz3s-00066R-W5
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 01:18:08 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1Bwz3s-00059O-3k
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 01:11:16 -0700
To: Patrice Seyed <apseyed@bu.edu>
In-Reply-To: <005f01c483d4$b6fa9f40$6701a8c0@psyche1>
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

On Mon, Aug 16, 2004 at 05:05:09PM -0400, Patrice Seyed wrote:
> You don't have enough threads.  That 2nd number (after the number of 
> threads) should be as close to zero as possible -- that's the number of 
> times all threads have been busy when a request came in.  IIRC, you have 
> plenty of memory on the server -- crank up the number of threads and you 
> should see some difference.

Not necessarily. We're talking about nfsd threads hung in a COMMIT call -
these can take over a second, and will block all WRITE calls to the same
file for the entire duration. So a single client doing write-behind can
easily tie up 8 or more server threads.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
