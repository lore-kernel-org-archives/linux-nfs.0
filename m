From: Andrew Schretter <schrett@math.duke.edu>
Subject: RPC: Unable to allocate resbuf from cache!
Date: Mon, 25 Mar 2002 11:17:58 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200203251617.g2PGHwZ19460@roma.math.duke.edu>
Mime-Version: 1.0
Received: from augustus.math.duke.edu ([152.3.25.8] helo=math.duke.edu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16pXAY-0001iC-00
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 08:18:03 -0800
Received: from roma.math.duke.edu (roma [152.3.25.13])
	by math.duke.edu (8.11.6/8.11.6) with ESMTP id g2PGHwg01254
	for <nfs@lists.sourceforge.net>; Mon, 25 Mar 2002 11:17:58 -0500
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

I've been testing out a new server with a Gigabit Netgear Network
adapter running 2.4.18 with Trond's NFS_ALL patch.  The clients are all on 
100Mb/s connections running 2.4.17 and mounting via TCP with rsize/wsize of 
16k. 

Everything appears to be working okay but on the server I've been getting
a endless amount of RPC warnings :

RPC: Unable to allocate resbuf from cache!

Is this something to be concerned about?  Is there a setting to change
to reduce the number of warnings?

Andrew Schretter
Systems Programmer, Duke University
Dept. of Mathematics (919) 660-2866





_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
