From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: extremely bad locking performance on 2.4.21-15.0.4.EL
Date: Mon, 16 Aug 2004 15:17:38 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408161440170.4655@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bwovz-0001Cr-Po
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 14:22:27 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BworW-0003UC-Hc
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 14:22:26 -0700
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id i7GLHcOX005620
	for <nfs@lists.sourceforge.net>; Mon, 16 Aug 2004 15:17:38 -0600
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id i7GLHcw5005616
	for <nfs@lists.sourceforge.net>; Mon, 16 Aug 2004 15:17:38 -0600
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


we have the latest EL release (2.4.21-15.0.4.EL) on all of our boxes - clients
and servers.  since upgrading last week i am seeing bizarre slow downs in many
i/o related operations: one of those is fcntl.

if one compiles and runs the following program in an nfs mounted directory

   #include <stdlib.h>
   #include <stdio.h>
   #include <sys/types.h>
   #include <sys/stat.h>
   #include <fcntl.h>
   #include <unistd.h>
   #include <time.h>

   int
   main (argc, argv)
        int argc;
        char **argv;
   {
     int fd;
     int ret;
     char buf[1024];
     struct tm;
     time_t t;
     char *ct;
     fd = open (__FILE__, O_RDWR);
     while (1)
       {
         ret = lockf (fd, F_LOCK, 0);
         if (ret != 0)
           {
             return 1;
           }
         t = time (&t);
         ret = lockf (fd, F_ULOCK, 0);
         fprintf (stdout, "lockf @ %s", ctime (&t));
         if (ret != 0)
           {
             return 1;
           }
         usleep (argc > 1 ? strtol (argv[1], NULL, 10) : 1L);
       }
     return 0;
   }


and runs it from two nodes the output will be something like


   lockf @ Mon Aug 16 15:07:01 2004
   ...
   lockf @ Mon Aug 16 15:07:01 2004
   lockf @ Mon Aug 16 15:07:01 2004
   lockf @ Mon Aug 16 15:07:31 2004
   lockf @ Mon Aug 16 15:08:01 2004

in otherwords the nodes will get the lock at a very rapid rate and then
experience a 30s timeout... is this normal?


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
