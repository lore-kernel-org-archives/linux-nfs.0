From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: reliable reading
Date: Mon, 28 Jun 2004 09:13:29 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0406280901350.3356@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bexp5-0007WA-70
	for nfs@lists.sourceforge.net; Mon, 28 Jun 2004 08:13:31 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1Bexp3-0004PB-LD
	for nfs@lists.sourceforge.net; Mon, 28 Jun 2004 08:13:29 -0700
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id i5SFDTon003610
	for <nfs@lists.sourceforge.net>; Mon, 28 Jun 2004 09:13:29 -0600
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id i5SFDTrf003606
	for <nfs@lists.sourceforge.net>; Mon, 28 Jun 2004 09:13:29 -0600
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


nfs'rs-

i'm in the middle of implementing a job distribution mechanism that uses an
nfs mounted work queue.  obviously clients serialize their access to this
queue using locking.  i'm using the double lock technique of lockfile + fcntl
lock on lockfile.  the code implements crude transactions using the following
logic:

   obtain_lock

   read_queue

   do_work_with_queue

   if changes_were_made
     copy queue, backup
     err = write queue
     if err
       copy backup, queue
     end
   end

   release_lock

in otherwords, all or none wholesale replacement of queue.  in order for this
sort of thing to work i need to be able to do a few things:

   - reliable lock (done)
   - reliable read
   - reliable write

now, i undertand the word 'reliable' is subjective here when we're talking
about networking but the inode caching of nfs makes the read/write bit more
that little problematic.  my questions are:

   - what is the 'safest' way read the most recent contents of an nfs mounted
     file accounting for attribute caching?

   - same question but for writing

i am not concerned with speed since the cost of accessing the queue is grossly
outweighed by the time to execute a job taken from it in almost all cases - i
simply want to make the absolutely most reliable read/write __possible__.  i
am open to mount option suggestions but want to make the code reliable even in
the face of the most aggressive attribute caching - if possible.

thanks in advance for any suggestions.

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
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
