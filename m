From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 000 of 5] Introduction
Date: Mon, 12 Sep 2005 16:25:38 +1000
Message-ID: <20050912162037.1825.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EEhlH-0005MB-9s
	for nfs@lists.sourceforge.net; Sun, 11 Sep 2005 23:25:51 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EEhlF-0000SL-Vo
	for nfs@lists.sourceforge.net; Sun, 11 Sep 2005 23:25:51 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Following are 5 patches for knfsd suitable for immediate inclusion
in 2.6.14-rc
There are either code cleanups, or bug fixes.
4 From Bruce Fields, one from me.

(and my 'From:' address is different from the 'Signed-off-by:' address,
so as to get through the subscriber-only nfs@lists.sourceforge.net list..
I wonder if I am going to pay for that :-)

NeilBrown


 [PATCH kNFSd 001 of 5] nfsd4: printk reduction
 [PATCH kNFSd 002 of 5] nfsd4: move replay_owner
 [PATCH kNFSd 003 of 5] nfsd4: fix open seqid incrementing in lock
 [PATCH kNFSd 004 of 5] nfsd4: fix setclientid unlock of unlocked state lock
 [PATCH kNFSd 005 of 5] Code cleanups in callbacks in svcsock.


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
