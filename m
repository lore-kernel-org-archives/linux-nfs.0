From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: file system read locks
Date: Fri, 20 Aug 2004 10:15:43 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408200943020.6148@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0408200907020.6148@harp.ngdc.noaa.gov>
 <20040820153921.GB6861@suse.de>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ByC3Q-000445-Pu
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 09:15:48 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1ByC3P-0000gM-9c
	for nfs@lists.sourceforge.net; Fri, 20 Aug 2004 09:15:48 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040820153921.GB6861@suse.de>
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

On Fri, 20 Aug 2004, Olaf Kirch wrote:

> On Fri, Aug 20, 2004 at 09:08:15AM -0600, Ara.T.Howard wrote:
>> i have a perfectly functioning filesystem based write lock algorithim
>> (link(2)).
>
> Except that these FS based approaches don't support blocking; you
> always have to poll.

yes - yet my filesystem locks give much, much, much better performance than
lockd does when the lock is under heavy contention.  the algorithim is a
glorified poll but works really well:

it is controled by these configurable values:

   poll_attempts :

     how many rapid attempts we'll make in a row

   min_poll_time :

     minimum amount of time we'll sleep between rapid 'polling' attempts

   max_poll_time :

     maximum amount of time we'll sleep between rapid 'polling' attempts

   min_sleep_time :

     minimum amount of time we'll sleep between sessions of rapid 'polling'
     attempts

   max_sleep_time :

     maximum amount of time we'll sleep between sessions of rapid 'polling'
     attempts


   sleep_time and sleep_inc start at min_sleep_time.

   to get the lock the link is attempted rapidly poll_attempts times, sleeping a
   random number between min_poll_time and max_poll_time.  these values are
   typically something like 16, 0.01 and 0.10 repsectively.

   if not success and sleep_time < max_sleep_time, increment sleep_time by
   sleep_inc and sleep that much before retrying.  if not success and sleep_time
   >= max_sleep_time decrement sleep_time by sleep_inc and sleep that much before
   >retrying.

in otherwords, there is a repeating cycle of attempts of grab the lock.  the
initial phase of the cycle has the requester backing off - being patient.
however the requester eventually become impatient and starts waiting less time
untill the minimum is reaached, he become patient again, and the cycle
repeats.  each 'attempt' is actually a bunch of attempts rapidly in
succession.  you can picture a sine wave puncuated with dots where many rapid
polling atempts are made at closely spaced but random intervals separated by
periods of fluctuating timeouts.

i'm very happy with this algorithim as it seems to provide very very good
performance under heavy loads.  i've tested with 30 nodes all competing to
update a file and see min, max, and avg sleep times of about 0, 2, and 2
seconds respectively.  when i repeat the test using lockd is see min, max, and
avg of about 0, 300, and 30 respectively.  so perhaps polling is not that bad!
;-)

i've not read the locking code, but the performance seems to indicate long
timeouts which never change (plateau) - so when requesters make a single
timeout they will wait a very, very long time to get the lock if it's under
heavy contention since, chances are, it will be held when they next ask and
then sleep for the same long time again.  like i said, i routinely see
timeouts in my test of 300, even 900 seconds.  this is using 30 nodes
competing to do a .2 second update to a file!

> Take a directory X. If the directory exists and is empty, the lock is not
> taken by anyone. To take a read lock, create a file in that directory.  To
> take a write lock, remove the directory.

just to clarify (we assert that mkdir AND rmdir are atomic and report the
correct error code on clients) and

   def read_lock dir
     begin
       FileUtils.touch "#{ dir }/#{ hostname }.#{ pid }"
       true
     rescue Errno::ENOENT
       false
     end
   end

   def write_lock dir
     begin
       Dir.rmdir dir
     rescue Errno::ENOTEMPTY
       false
     end
   end

what gothca are there?  for instance when using link(2) you cannot trust the
return codes and then must use stat - do similar problems exist?  for which
nfs impls do you think this might work?

thanks a __lot__ for the ideas, i have been wondering how to do read locks for
a while - should've thought about how semaphores work for while and might have
come up with this myself but i was hung up thinking in terms of link!  i will
begin implementing your ideas in a LockDirectory class and add it to my
LockFile package (algorithim attributed to you!).  my package, which has both
ruby api and command line tools can be found at

   http://raa.ruby-lang.org/project/lockfile/

though the download server will be down today.  i'd be happy for any testers!

> Olaf Kirch     |  The Hardware Gods hate me.

me too - i'm burning out disks at the rate of once per week! ;-)

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
