From: Harrison Xing <harrison@mountainviewdata.com>
Subject: Bad Irix nfs client write performance
Date: Thu, 13 Jun 2002 21:27:10 +0800 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0206132123130.1288-100000@harris.cn.mvd>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from namodn.com ([209.0.100.50] helo=srv.dmz.us.mvd)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17IUSG-0006AL-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Jun 2002 06:16:00 -0700
Received: from harris.cn.mvd (unknown [210.72.245.13])
	by srv.dmz.us.mvd (Postfix) with ESMTP id 26E2AB759
	for <nfs@lists.sourceforge.net>; Thu, 13 Jun 2002 06:15:58 -0700 (PDT)
To: <nfs@lists.sourceforge.net>
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

Hi,

I'm using a Linux nfs server(kernel 2.4.5).  The write performance of Irix nfs 
client is poor.  The throuput of copying a big file to the Linux nfs server
from the Irix client is about 0.8 MBytes/sec, while the throughput of reading
files from the Linux nfs server is 6.x MBytes/sec.  Are there any ideas what
causes the problem?  Thanks.

-- 
Best Regards,
Harrison


_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas - http://devcon.sprintpcs.com/adp/index.cfm?source=osdntextlink

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
