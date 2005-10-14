From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 000 of 4] Introduction
Date: Fri, 14 Oct 2005 12:23:06 +1000
Message-ID: <20051014122041.11376.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQFE3-0006RX-8J
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 19:23:15 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EQFE0-0004Xn-SQ
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 19:23:15 -0700
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

4 patches for kNFSd in 2.6

I might have sent the first one already, so if it conflicts, just drop it.

Patch '3' should replace
  knfsd-allowing-rpcnfsd-to-setting-of-the-port-transport-and-version-the-server-will-use.patch
which contains some elements that are still under discussion.

Thanks,
NeilBrown


 [PATCH kNFSd 001 of 4] fix setattr-on-symlink error return
 [PATCH kNFSd 002 of 4] Restore functionality to read from file in /proc/fs/nfsd/
 [PATCH kNFSd 003 of 4] Allow run-time selection of NFS versions to export
 [PATCH kNFSd 004 of 4] Fix some minor sign problems in nfsd/xdr


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
