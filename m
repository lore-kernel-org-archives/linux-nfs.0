From: Greg Boehnlein <damin@nacs.net>
Subject: Journaling FileSystems w/ NFS
Date: Fri, 20 Sep 2002 11:48:28 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0209201145290.16674-100000@node1.nacs.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from node1.nacs.net ([207.166.192.33])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sQ18-0002KA-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 08:48:30 -0700
Received: from localhost (damin@localhost)
	by node1.nacs.net (8.11.6/8.11.6) with ESMTP id g8KFmSi17080
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 11:48:28 -0400
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Hello,
	Can someone point me to a FAQ on which is the best solution for
running a Journalized Filesystem with NFS support under Linux? We've tried
deploying JFS with RedHat 7.3 and NFS and have run into problems. From my
investigation, it appears that XFS is our best option for running NFS with
+2gig file size support.

-- 
    Vice President of N2Net, a New Age Consulting Service, Inc. Company
         http://www.n2net.net Where everything clicks into place!
                             KP-216-121-ST





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
