From: Tom McNeal <trmcneal@attbi.com>
Subject: Linux release of nfs-utils version 1.0.1
Date: Fri, 19 Jul 2002 17:22:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <21521.170953247$1027124573@news.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc02.attbi.com ([204.127.202.62])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17VhxN-0004Ma-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Jul 2002 17:18:45 -0700
To: NFS maillist <nfs@lists.sourceforge.net>,
 	NFS V4 <nfsv4-wg@sunroof.eng.sun.com>
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

The latest release of the nfs utils package has just been posted
on https://sourceforge.net/projects/nfs/

The last version of the package was posted last September, so there
are quite a few fixes in it.  The one which you may notice right
away is that synchronous IO is now a default export characteristic,
falling in line with all other vendors of NFS.  In order to ease
the transition, a warning will be posted if you do not specify either
"sync" or "async" in the export list.  This removes a possible 
source of undetected data corruption, as detailed in the NFS howtos.

Speaking of the howtos, the latest versions of them have been sent
to the LDP, so they should be posted sometime next week.

Finally, if you are interested, I have published the client based
test package I used for testing the utils, which contains a GUI 
interface, and includes Connectathon, FSX, Bonnie++, and IOzone, 
among other things.  The package was originally developed by
Bruce Blinn and Adrian Drzewiecki at the Mission Critical Linux
West Coast Office.  I received permission from the owners of the
assets of MCLX to post the package, after removing all parts 
related to the MCLX cluster software.  You can find it at 
https://sourceforge.net/projects/nfstestmatrix

One final note - I was not the only tester; Engineers at Red Hat
and IBM, among others, were involved in the testing, so my Intel
based UP machines were not the only ones exercising it.

Regards -

Tom McNeal

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
