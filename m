From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: poor locking performance
Date: Thu, 17 Jun 2004 11:38:25 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406171131420.31212@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bb0qI-0007H8-Dw
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 10:38:26 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1Bb0qI-0007S5-2l
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 10:38:26 -0700
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id i5HHcPKh000368
	for <nfs@lists.sourceforge.net>; Thu, 17 Jun 2004 11:38:25 -0600
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id i5HHcPtB000364
	for <nfs@lists.sourceforge.net>; Thu, 17 Jun 2004 11:38:25 -0600
To: nfs@lists.sourceforge.net
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


i have a test i've been running which essentially has n processes competing to
add to an ordered list on disk.  the queue resides on an nfs filesystem.  i
use this to test a lockfile library i've written, but also for testing other
network locking methods.  i've tried my test using fcntl based locks and have
noticed some interesting patterns:  each node grabs the lock, adds to the
queue, releases the lock, and sleeps for a second or two.  iff the list is
ever unsorted or corrupt a lock error has occured.  the time at which the lock
was obtained and the node that obtained it are actually noted in the queue
entry, so i'm able to gather stats on how successful various nodes are at
grabbing the lock.  when using fctnl based locks i see the following pattern
regardless of the load on the nodes:  the distribution is fairly random at
times, but punctuated by stretches where a single node will obtain the lock
many, many (1000 or more) time in a row.  all nodes are competing equally.  it
appears that, at some point, the nfs server recognizizes that it might be
starving someone else (which it is) and it yield the lock to another process.
my question is this:  what characteristic of the locking algorithim might
cause this behaviour?  is it tunable?

btw.  i'm happy to post the code for anyone interested.  it's written in pure
ruby and is only about 100 lines or so.  you'll need ruby > 1.8.0 to run it.
let me know if interested.

cheers.

-a
--
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it; and a weed grows, even though we do
| not love it. --Dogen
===============================================================================


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
