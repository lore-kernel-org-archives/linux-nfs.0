From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: client side - application level 'dead' lock detection
Date: Mon, 23 Aug 2004 09:18:11 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408230757340.7569@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BzGaM-0001yh-3w
	for nfs@lists.sourceforge.net; Mon, 23 Aug 2004 08:18:14 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BzGaL-0001QP-Bx
	for nfs@lists.sourceforge.net; Mon, 23 Aug 2004 08:18:13 -0700
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id i7NFIBJ0007999
	for <nfs@lists.sourceforge.net>; Mon, 23 Aug 2004 09:18:11 -0600
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id i7NFIBJc007995
	for <nfs@lists.sourceforge.net>; Mon, 23 Aug 2004 09:18:11 -0600
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


nfs gurus-

i have an application which does alot of byte range locking on an nfs mounted
file.  twice now, i've seen a 'dead' lock appear on our nfs server - a lock
held by a non-existent pid.  none of the processes in question have been dying
unexpectedly (or exiting at all actually) and also have not been shut down
uncleanly using kill -9, for instance.  basically a dead lock simply appears
after some length of time during long periods of successful locking and file
useage - at this point after about 3 weeks of 24/7 lock usage.  the file is
never corrupt and i have found that i can clear the dead locks using

   mv locked locked.tmp
   mv locked.tmp locked

of course, this still leaves a lock on SOME file on the server, but not my
file.

discovering this i've been thinking of a way to determine via my application
WHEN this situation has arisen and to automatically recover from it.  here is
my algorithim so far, it attempts to make the determination that

   "i cannot get the lock AND no one else has it"

upon finding this, automatic recovery of the system is attempted.

i'd appreciate any insight as to it's effectiveness taking into account the
subtleties of real world nfs behaviour.  the following
pre-conditions/assumptions/definitions apply:

   - a lockd impl that works, excepting for the occasional 'dead' lock existing
     on the server which prevents all clients from obtaining any new locks

   - non-blocking lock types do not block, even in the presence of such locks

   - moving a file out of the way, and back again, clears such 'dead' locks
     (they may still exist on the server, but clients will be able to lock the
     'new' file)

   - the 'file in question' is the file under heavy usage/locking

   - a monitor file will be used along side the file in question.  this file is
     simply a zero length file that all applications will use in addition to
     the file in question.

   - a recovery file is simply an empty file using mark the time of lock
     recovery

   - a 'refresher' thread is one which simply loops touching a file and
     sleeping.  technically this could be either a thread or process so long as
     it does not go to sleep when it's process issues a blocking operation
     (like fcntl).

   - an auto-recovering lockfile library which uses link(2), it is atomic, safe
     over nfs, and contains no bugs ( ;-) ) - exists (i have an impl).


here is the algorithim

   0.
      attempt to apply a non-blocking lock of type write/read to the monitor
      file

   1.
     a. monitor lock success

       start a refresher thread for the monitor file and attempt to apply a
       non-blocking lock of type write/read (same lock as the one on the
       monitor file) to the file in question - this should always succeed; iff
       it does not raise an error, the algorithim, or something else, has
       failed.

       having aquired both locks, call the callback for the file in question
       and, when it is complete,  kill the refresher thread, unlock the file in
       question, and unlock the monitor file.

       if estale is encoutered during 1.a.  sleep and retry on 0.

     b. monitor lock failure

       iff the monitor file is stale (mtime < now - max_age)

         some process must have died uncleanly while holding the lock (or the
         network/cpu has become very slow for that client) - we attempt
         recovery:

           mark recovery_start_time

           create an nfs safe lockfile to serialize recovery among clients.
           this is a blocking operation.

             iff recovery file exists and is newer than recovery_start_time

               someone else has recovered, sleep and retry on 0.

             else recovery file is older than recovery_start_time or does not
             exist

               recover:

                 for file in (monitor file_in_question)
                   mv file file.tmp && mv file.tmp file
                 end

                 (note that this could cause estale in some other client - but
                 they are prepared to deal with this condition)

               touch recovery file

             rm lockfile

             sleep and retry on 0.

       else monitor file is not stale

         some other process must have the lock (it's refresher thread is
         running) sleep and retry on 0.



thanks in advance for any inputs/critiques.



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
