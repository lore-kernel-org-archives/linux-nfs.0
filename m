From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: debugging hanging locks
Date: Mon, 16 Aug 2004 17:47:19 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408161741020.5649@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BwrGB-0002gs-Ft
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 16:51:27 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BwrDX-0004K0-PC
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 16:51:27 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1BwrDT-00062d-Hp
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 16:48:42 -0700
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id i7GNlKkx007160
	for <nfs@lists.sourceforge.net>; Mon, 16 Aug 2004 17:47:20 -0600
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id i7GNlJdj007156
	for <nfs@lists.sourceforge.net>; Mon, 16 Aug 2004 17:47:20 -0600
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


i have a job distribution api which relies on an nfs mounted sqlite database.
associated with the database is an 'extra' lockfile - an empty file (db.lock)
used to apply a write/read lock before accessing the database, which has it's
own locking too.  all locking is, of course, fcntl based.  this works great
and hums along merrily for weeks.  however, now for the second time, every
thing sometimes hangs with no process being able to get the lock.  each time
i've taken all the daemons down and confirmed that no process is holding the
lock (has the file open actually) using /sbin/fuser.  still, no process will
be able to get the lock.  the only solution is to

   mv db.lock tmp
   mv tmp db.lock

which, i imagine, leaves some phantom process/lock hanging around with the old
file handle.  my questions are

   - what could cause this type of random hanging

   - how does one tell, on server, who has what locks

   - has anyone else seen this sort of problem? and, if so, what is the fix?

kind regards.

-a
--
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it;
| and a weed grows, even though we do not love it. 
|   --Dogen
===============================================================================


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
