From: David Dougall <davidd@et.byu.edu>
Subject: reduce rsize/wsize or tcp nfs server
Date: Mon, 30 Sep 2002 15:34:30 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0209301531210.17566-100000@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from postal2.et.byu.edu ([128.187.122.132])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17w8BW-0001Ee-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Sep 2002 14:34:34 -0700
Received: (from root@localhost)
	by postal2.et.byu.edu (8.9.3 (PHNE_25184)/8.9.3) id PAA26655
	for nfs@lists.sourceforge.net; Mon, 30 Sep 2002 15:35:00 -0600 (MDT)
Received: from lewis (lewis.et.byu.edu [128.187.112.50])
	by postal2.et.byu.edu (8.9.3 (PHNE_25184)/8.9.3) with ESMTP id PAA26595
	for <nfs@lists.sourceforge.net>; Mon, 30 Sep 2002 15:34:59 -0600 (MDT)
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

If I have a mixed network: some 100Mbit, 10Mbit, 1Gbit, etc.
Is it wiser to set my wsize/rsize to 1024 to reduce retransmissions or to
use tcp protocol for nfs?
If I should use tcp, what is needed to get that into the linux nfs server?
Is it still very experimental, our could it be trusted in a production
environment?
Thanks for any help.
--David Dougall



______________________________________
Inflex Virus Scanner - installed on mailserver for domain @et.byu.edu
Queries to: postmaster@et.byu.edu


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
