From: Andrew Schretter <schrett@math.duke.edu>
Subject: 2.4.10-pre10 RPC changes problem
Date: Mon, 1 Jul 2002 09:38:23 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207011338.g61DcNM26138@roma.math.duke.edu>
Mime-Version: 1.0
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from augustus.math.duke.edu ([152.3.25.8] helo=math.duke.edu)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17P1Np-0004kZ-00
	for <nfs@lists.sourceforge.net>; Mon, 01 Jul 2002 06:38:25 -0700
Received: from roma.math.duke.edu (roma [152.3.25.13])
	by math.duke.edu (8.11.6/8.11.6) with ESMTP id g61Dbv717776
	for <nfs@lists.sourceforge.net>; Mon, 1 Jul 2002 09:37:57 -0400
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

Trond,
I too am having some problems with the recent RPC fixes, my kernels have 
unresolved symbols in sunrpc.o, namely kmap_prot and kmap_rte which I tracked 
down to the recent inclusion of pagemap.h in xdr.c (from 
linux-2.4.19-01-fix_kmap1.dif) and the fact that I have HIGHMEM defined. 

I've been looking it over for the last 2 days and haven't been able
to figure out exactly how to fix the problem.  I suppose that you
probably don't have HIGHMEM enable in your kernel config or maybe
I'm just missing something.

Thanks,

Andrew Schretter
Systems Programmer, Duke University
Dept. of Mathematics (919) 660-2866







-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
