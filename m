From: Jared Proudfoot <jproudfo@FootPrints.net>
Subject: Mounting > 2TB via NFS?
Date: Wed, 10 Jul 2002 12:04:48 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0207101129390.24725-100000@ashi.FootPrints.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ashi.footprints.net ([204.239.179.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17SMlk-0006r7-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Jul 2002 12:04:56 -0700
Received: from jproudfo (helo=localhost)
	by ashi.FootPrints.net with local-esmtp (Exim 3.34 #1)
	id 17SMld-0006jM-00
	for nfs@lists.sourceforge.net; Wed, 10 Jul 2002 12:04:49 -0700
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



Greetings,

Perhaps this isn't the right list to post this question on.  If so, please 
let me know.

I want to NFS export a filesystem from a Solaris machine to a Linux CPU
farm (running stock mix of Redhat 7.x).  The filesystem we are exporting
is over 2 TB in size.

There is some concern that the Linux boxes will not support mounting a 
filesystem larger than 2 TB in size, due to a kernel limitation.

It is my understanding that Linux can not mount local filesystems that 
are more than 2 TB in size, but is the same true for remote NFS 
filesystems?  Does the same kernel limitation effect both NFS and local 
filesystems?

I am not subscribed to this mailing list, so if you could reply to me 
directly, I would appreciate it.


Thanks in advance,

Jared Proudfoot

-- 
Jared Proudfoot
E-mail: jproudfo@FootPrints.net
Home Page: http://jared.proudfoot.ca/




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Two, two, TWO treats in one.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
