From: Tom McNeal <trmcneal@attbi.com>
Subject: Utils package testing
Date: Tue, 11 Jun 2002 09:33:40 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D062664.C93B7399@attbi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc51.attbi.com ([204.127.198.38])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17HoXh-0006ra-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Jun 2002 09:30:49 -0700
Received: from attbi.com ([12.234.31.73]) by rwcrmhc51.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with ESMTP
          id <20020611163043.OSHS11426.rwcrmhc51.attbi.com@attbi.com>
          for <nfs@lists.sourceforge.net>; Tue, 11 Jun 2002 16:30:43 +0000
To: NFS maillist <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi -

I've finished testing the latest utils package, nfs-utils-1-0-1-pre8,
both with udp and tcp mounts to the server, in both a 2.4.18 standard
and patched (Trond's NFS_ALL patch) environment, and it is ready to
go as far as I am concerned.  The difference between pre7 and pre8
was simply a warning message in exports.c, so any testing being
done on MP platforms (by those of you who have access to them)
need not be repeated.

A couple of questions have come up in my testing, which may have
to be addressed elsewhere, but are not related to the package:

 - Does locking take a much longer time in ext3 file systems,
   or in the patched environment?   In the patched kernel, 
   exporting ext3, the connectathon lock tests seemed to take
   up to 10x as long, but that was over many hours, with a big
   load.  When run just once with the other connectathon tests,
   it didn't seem so different.  

 - The client net statistics in /proc/net/rpc/nfs seems to remain
   at 0 regardless of the activity and regardless of the kernel.
   I'm going to start browsing through the kernel code to see 
   if there is something obvious, but maybe someone knows about
   this already.  I didn't see anything in the mailing list.

Anyway, as soon as we hear results of MP testing, I'd say its
ready to ship.

Tom

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas - http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
