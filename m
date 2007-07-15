From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/3] Fix up NFS sillyrename code
Date: Sat, 14 Jul 2007 20:06:39 -0400
Message-ID: <1184457999.20296.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>,
	"Mr. Trond Myklebust" <Trond.Myklebust@netapp.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9s5g-0003EH-49
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 17:36:01 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I9s5j-0008Py-I7
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 17:36:03 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The following patchset cleans up the NFS asynchronous delete code by
getting rid of the global lists, and attaching the delete data directly
to the dentry that was sillyrenamed.

The cleanup also fixes up a couple of bugs:

      * Fix the race with shrink_dcache_for_umount_subtree(): instead of
        storing pointers to dentries, we only store the inode of the
        parent directory.
      * Don't delete the file if the inode is stale.

Cheers
  Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
