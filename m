From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [BUG] kNFSd may get a freeing inode.
Date: Tue, 17 Sep 2002 17:01:56 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020917.170156.35804958.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rDQv-0002jm-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 01:10:09 -0700
Received: from localhost (gw1.valinux.co.jp [202.221.173.98])
	by sv1.valinux.co.jp (Postfix) with ESMTP id 8B4D370020
	for <nfs@lists.sourceforge.net>; Tue, 17 Sep 2002 17:10:07 +0900 (JST)
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

Hello,

This is a big problem.

kNFSd might get inode which is just freeing.
We know inodes under freeing(I_FREEING) are not on the inode-hash.

Please suppose kNFSd calls iget() against freeing inodes.
It might cause weird problem as iget() calls get_new_inode() if the
inode isn't on the hash.

It would never happen on local filesysmtem as no one can
lookup freeing dentries or inodes while NFSd try to get a inode
with inode-number directly.

What is the best way to avoid this situation?
We shold keep freeing inodes the hash?

Thank you,
Hirokazu Takahashi.


-------------------------------------------------------
Sponsored by: AMD - Your access to the experts on Hammer Technology! 
Open Source & Linux Developers, register now for the AMD Developer 
Symposium. Code: EX8664 http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
