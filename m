From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Strange delays on NFS server (with piccies)
Date: Fri, 27 Aug 2004 11:22:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16686.36060.57143.407464@cse.unsw.edu.au>
References: <4119FB15.7010205@stams.strath.ac.uk>
	<411A17F2.2060203@RedHat.com>
	<411A448D.3080205@stams.strath.ac.uk>
	<20040811164135.GA11101@suse.de>
	<411B8987.1030609@stams.strath.ac.uk>
	<411CD601.1080308@RedHat.com>
	<4120AB46.1080606@stams.strath.ac.uk>
	<16683.8588.18082.190876@cse.unsw.edu.au>
	<412DC316.6080709@stams.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0VS2-0000pA-Ag
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 18:22:46 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C0VS0-000091-LE
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 18:22:46 -0700
To: Ian Thurlbeck <ian@stams.strath.ac.uk>
In-Reply-To: message from Ian Thurlbeck on Thursday August 26
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

On Thursday August 26, ian@stams.strath.ac.uk wrote:
> 
> Neil, and others
> 
> I've gathered some useful data (I hope) on the problem. I ran a variant 
> of Neil's script for 2.4 kernel for most of a day (9.30-15.00).

It's odd....

The data doesn't show much variation in nfs ops/second during the two
incidents you zoom in on, though you would expect that if the NFS
server were slow to respond, you would see a drop in requests (as nfsd
threads are blocked, and the clients would stop sending while waiting
for the server, at least a bit).

There are other periods of high disc writes (such as 6400:6800) where
there is a matching rise in NFS requests.  Presumably some client is
doing a lot of writing.
Do these correlate with subjective pauses too?

And the "vmstat" output shows "free" memory plummeting to 1/16th of
was it was during the quite time.  It is not surprising that this
causes lots of write activity.  This is accompanied by a sudden growth
in "cache", which seems to suggest (unless I'm misunderstanding what
"cache" and "free" mean, which isn't impossible) that lots of data was
suddenly written.  As it doesn't seem to correlate with NFS activity,
is looks like some local program on the server is suddenly writing out
lots of data and swamping the filesystem.

The "top" output doesn't seem to match any significant write traffic.

Can you get some process listings that correlate with the sudden drop
in "free" shown by vmstat and see what is happening?

> 
> PS: How big are these "wsect" counts in /proc/partitions in terms of
> bytes ?

1 sectors should be 512 bytes.

NeilBrown


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
