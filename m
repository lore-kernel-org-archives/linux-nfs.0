From: Raphael Clifford <clifford@genomes.rockefeller.edu>
Subject: redhat 2.4.18-5 client huge slowdown
Date: Tue, 09 Jul 2002 15:19:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D2B373E.2030602@genomes.rockefeller.edu>
References: <E17S0Jk-0006ZT-00@usw-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.rockefeller.edu ([129.85.1.21])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17S0Vy-0004HU-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Jul 2002 12:19:11 -0700
Received: from genomes.rockefeller.edu (austen.rockefeller.edu [129.85.52.113])
	by mail.rockefeller.edu (8.12.5/8.12.5) with ESMTP id g69JJ1Us015547
	for <nfs@lists.sourceforge.net>; Tue, 9 Jul 2002 15:19:02 -0400 (EDT)
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

I was wondering if everyone else is experiencing huge nfs write 
slowdowns using redhat kernel 2.4.18-5 (as opposed to 2.4.18-4).  I am 
using a Sun Solaris machine as the server and following mount options.

rw,rsize=32768,wsize=32768,nfsvers=3,proto=tcp

I understand that both 2.4.18-4 and 2.4.18-5 default to 'sync' but as 
the slow down is between those versions so that shouldn't make any 
difference.  I also understand that there were a lot of nfs client 
"fixes" in 2.4.18-5 so I assume they have caused this problem.

The linux machine is a dual 500 MHz if that makes any difference.

Cheers,
Raphael



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Stuff, things, and much much more.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
