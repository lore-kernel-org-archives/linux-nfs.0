From: "Steven N. Hirsch" <shirsch@adelphia.net>
Subject: 2.4.19-pre5-ac3 NFS problems
Date: Sun, 7 Apr 2002 13:05:42 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0204071301260.3017-100000@atx.fast.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Received: from smtprelay9.dc2.adelphia.net ([64.8.50.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uFzh-0005va-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Apr 2002 09:58:21 -0700
Received: from atx.fast.net ([24.50.57.192]) by
          smtprelay9.dc2.adelphia.net (Netscape Messaging Server 4.15)
          with ESMTP id GU7JC902.73M for <nfs@lists.sourceforge.net>; Sun,
          7 Apr 2002 13:02:33 -0400
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

All,

I'm not sure exactly what has been integrated into Alan's pre5-ac3 kernel,
but there are serious problems with NFS over TCP.  Twice in a row I've had
locked processes on the client when attempting to lock a mail spool on the
server.  Required reboot on both ends to clear :-(.

FWIW, I had been running for almost a month prior with 2.4.19-pre2 + 
Trond's 2.4.18_NFS_ALL using NFS over TCP and saw no problems.  I moved to 
the new kernel ONLY on the server.  After reverting back, all seems stable 
again.

What is the current status of the various 2.4.x patches floating around?  

Steve



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
