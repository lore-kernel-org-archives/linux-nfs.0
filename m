From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: more on silly names
Date: Sat, 4 Sep 2004 16:27:14 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0409041610230.17016@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C3j1O-0007d4-CD
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 15:28:34 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C3j1H-0008SK-Ip
	for nfs@lists.sourceforge.net; Sat, 04 Sep 2004 15:28:30 -0700
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


i think i've found the cause of the sillnames appearing in my directory:
for transaction sqlite aquires a lock, writes changes first to a db-journal
file, then to the actual db, closes the journal, unlinks the journal, and
releases the lock.  this sequence should not create a silly file, but seems
to do so:

   here's a snaphshot of my system in action:

      yacht:~/shared > new q
      total 4432
      -rw-rw-rw-    1 cfadmin  cfadmin      1023 Aug 29 08:55 db.schema
      drwxrwxrwx   11 cfadmin  11113        4096 Sep  4 15:43 ..
      -rw-rw-rw-    1 cfadmin  cfadmin   4441088 Sep  4 15:44 db
      -rw-------    1 cfadmin  cfadmin     21692 Sep  4 15:44 .nfs0091c0d400001089
      -rw-rw-rw-    1 cfadmin  cfadmin         0 Sep  4 15:44 lock
      -rw-------    1 cfadmin  cfadmin     15500 Sep  4 15:44 .nfs0091c0d7000011c2
      -rw-r--r--    1 cfadmin  cfadmin         0 Sep  4 15:44 trout.ngdc.noaa.gov.22069.lock.w
      -rw-r--r--    1 cfadmin  cfadmin         0 Sep  4 15:44 mahi.ngdc.noaa.gov.31335.waiting.w
      -rw-------    1 cfadmin  cfadmin     15500 Sep  4 15:44 db-journal
      -rw-------    1 cfadmin  cfadmin      8276 Sep  4 15:44 .nfs0091c0d500001270
      drwxrwxrwx    2 cfadmin  cfadmin      4096 Sep  4 15:44 .

   you can see that the files
      .nfs0091c0d7000011c2
   and
      db-journal
   are (almost positively) the same.

running an strace on the code i see that the file is always closed before it
is unlinked, and it is never opened without first aquiring a write lock.  so
silly names should not be appearing right (ignoring inode caching)?  in the
strace i'll see

   open("/dmsp/moby-1-1/ahoward/shared/eg/ruby/rq/rq-0.1.3/q/db", O_RDWR|O_CREAT|O_LARGEFILE, 0644) = 6

   ...

   fcntl64(6, F_SETLK64, {type=F_WRLCK, whence=SEEK_SET, start=0, len=0}, 0xbffe0520) = 0
   access("/dmsp/moby-1-1/ahoward/shared/eg/ruby/rq/rq-0.1.3/q/db-journal", F_OK) = -1 ENOENT (No such file or directory)
   open("/dmsp/moby-1-1/ahoward/shared/eg/ruby/rq/rq-0.1.3/q/db-journal", O_RDWR|O_CREAT|O_EXCL|O_LARGEFILE, 0600) = 8

   ...

   close(8)                                = 0

   ...

   unlink("/dmsp/moby-1-1/ahoward/shared/eg/ruby/rq/rq-0.1.3/q/db-journal") = 0

   ...

   fcntl64(6, F_SETLK64, {type=F_UNLCK, whence=SEEK_SET, start=0, len=0}, 0xbffe04c0) = 0

my theory is that the client causes the sillyname itself - perhaps the close
is deferred and the unlink gets sent before it?  in any case there is a
bugette here.  the code runs totally fine - which further supports the idea
that the problem occurs at the close/unlink boundry since the client would
never access the file after that.  does any of this make sense?  i simply do
not understand the nfs protocal enough to suggest a workaround to the sqlite
developers.  perhaps doing trying to stat the db-journal file after unlinking
it or some action to invalidate the inode cache before unlinkin it?  any way
to force the close to commit?

thanks for any insights.

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
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
