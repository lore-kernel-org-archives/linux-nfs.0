From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: locking bug
Date: Fri, 10 Dec 2004 14:34:32 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0412101428350.21479@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcsPK-0002P9-JY
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 13:34:34 -0800
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CcsPJ-0003RD-QP
	for nfs@lists.sourceforge.net; Fri, 10 Dec 2004 13:34:34 -0800
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id iBALYWYv023778
	for <nfs@lists.sourceforge.net>; Fri, 10 Dec 2004 14:34:32 -0700
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id iBALYWgR023774
	for <nfs@lists.sourceforge.net>; Fri, 10 Dec 2004 14:34:32 -0700
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


is this a known bug?


~/eg/c here is an NFS mounted dir...


   jib:~/eg/c > uname -a
   Linux jib.ngdc.noaa.gov 2.4.21-20.0.1.ELsmp #1 SMP Wed Nov 24 20:34:01 EST 2004 i686 i686 i386 GNU/Linux

   jib:~/eg/c > ./a.out
   fd <3>
   locking <foobar> => ret <0>
   (sleeping...)



   carp:~/eg/c > uname -a
   Linux carp.ngdc.noaa.gov 2.4.21-20.0.1.ELsmp #1 SMP Wed Nov 24 20:34:01 EST 2004 i686 i686 i386 GNU/Linux

   carp:~/eg/c > ./a.out
   fd <3>
   locking <foobar> => ret <0>
   (sleeping...)



   carp:~/eg/c > cat a.c
   #include <stdlib.h>
   #include <stdio.h>
   #include <sys/types.h>
   #include <sys/stat.h>
   #include <fcntl.h>
   int
   main (argc, argv)
        int argc;
        char **argv;
   {
     struct flock flock;
     char *path;
     int fd, fd2;
     int ret;

     path = argv[1] == NULL ? "foobar" : argv[1];

   /* open file, creating if does not exist, and lock it */
     fd = open (path, O_RDWR);
     if (fd == -1)
       {
         fd = open (path, O_RDWR | O_CREAT);
       }
     printf ("fd <%d>\n", fd);

     flock.l_type = F_WRLCK;
     flock.l_whence = SEEK_SET;
     flock.l_start = 0;
     flock.l_len = 0;

     ret = fcntl (fd, F_SETLK, &flock);
     printf ("locking <%s> => ret <%d>\n", path, ret);

   /* slurp file - this causes the bug */
     fd2 = open (path, O_RDONLY);
     while (read (fd2, &ret, sizeof (int)));
     close (fd2);

   /* getch */
     (void) getc (stdin);
     return (EXIT_SUCCESS);
   }


summary:

   * process on host 0 opens file, locks it, and read it in using separate file
     handle.  it then sleeps holding lock.

   * process on host 1 attempting the exact same sequence (and so expecting to
     find the file locked) is able to obtain the lock.

   * if the file is not slurped this code acts as it's supposed to - process on
     host 1 cannot obtain lock


is this known?  if not should i report here or to redhat?

kind regards.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
