From: Thomas =?iso-8859-1?Q?Lang=E5s?= <tlan@stud.ntnu.no>
Subject: NFS shares becoming disabled
Date: Wed, 9 Oct 2002 12:21:48 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021009102148.GD26096@stud.ntnu.no>
Reply-To: nfs@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from due.stud.ntnu.no ([129.241.56.71])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zDzk-0002bA-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 03:23:12 -0700
Received: from localhost (localhost [127.0.0.1])
	by due.stud.ntnu.no (Postfix) with ESMTP id 9661512B20F
	for <nfs@lists.sourceforge.net>; Wed,  9 Oct 2002 12:21:49 +0200 (CEST)
Received: from ozelot.stud.ntnu.no (ozelot.stud.ntnu.no [129.241.56.185])
	by due.stud.ntnu.no (Postfix) with ESMTP id C5B0012B1D5
	for <nfs@lists.sourceforge.net>; Wed,  9 Oct 2002 12:21:48 +0200 (CEST)
Received: (from tlan@localhost)
	by ozelot.stud.ntnu.no (8.11.6/8.10.0.Beta12) id g99ALmW07642
	for nfs@lists.sourceforge.net; Wed, 9 Oct 2002 12:21:48 +0200
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

If you have a box with two (or more, maybe) shares exported, and one of theese
shares "dies", the other share will also become unavailable to the nfs clients
that tries to or has mounted any of theese shares.

We've seen this twice now, with our fileservers (each fileservers have two
disks mounted over fiberchannel). If one of those disks "die", ie. server
loose connectivity, both shares becomes unavailable to the nfs clients.

Why?  (It should only be the affected share that becomes unavailable, since
we locally can do whatever we want on the other disk that's still mounted).

-- 
Thomas


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
