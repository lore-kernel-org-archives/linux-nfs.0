From: Allen Day <allenday@ucla.edu>
Subject: RE: e1000 intel driver bug (which impacts nfs)
Date: Sun, 22 Sep 2002 13:54:33 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0209221340270.24548-100000@kermit.1-up.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from c-24-130-166-161.we.client2.attbi.com ([24.130.166.161] helo=kermit.1-up.net)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17tDaw-0002ZH-00
	for <nfs@lists.sourceforge.net>; Sun, 22 Sep 2002 13:44:46 -0700
Received: from localhost (allenday@localhost)
	by kermit.1-up.net (8.11.6/8.11.6) with ESMTP id g8MKsXE24620
	for <nfs@lists.sourceforge.net>; Sun, 22 Sep 2002 13:54:33 -0700
To: nfs@lists.sourceforge.net
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

I found this thread describing NFS hanging with the Intel E1000 gigabit 
ethernet adapter, and was wondering if any more progress has been made on 
the problem.

I'm using a Redhat 7.3 2.4.18-3smp kernel, nfs-utils-0.3.3-5, on a dual 
Xeon 1.8GHz / 4GB / SuperMicro P4DP6.

The symptoms I'm experiencing are that the NFS server behaves fine for a 
few hours, then mounts are no longer available from it.  Trying to mount 
using a remote host or localhost as the NFS client gives an error in 
dmesg: "nfs: task xxxx can't get a request slot".  It isn't possible to 
stop NFS via its init.d script, or even to get the machine to respond to 
a 'shutdown' -- the only way I've been able to temporarily solve the 
problem is to push the reset button on the box.

It may also be worth mentioning that once I notice the NFS problem has 
started, I can no longer do a 'df' without making the terminal hang.  
Also, the NFS share isn't very small... it's about 450GB.

Any idea what's going on here?  Am I looking at an E1000 driver problem or 
an NFS problem?

-Allen



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
