From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] NFS - Fix for Infinite loop during syncing
Date: Mon, 13 Dec 2004 15:23:34 -0500
Message-ID: <41BDFA46.7070403@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000606010605090402030807"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CdwfC-0004Pl-DJ
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 12:19:22 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CdwfA-0005Jl-2t
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 12:19:21 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id iBDKJ864010620
	for <nfs@lists.sourceforge.net>; Mon, 13 Dec 2004 15:19:08 -0500
Received: from [192.168.62.4] (vpn83-130.boston.redhat.com [172.16.83.130])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id iBDKJ6r13803
	for <nfs@lists.sourceforge.net>; Mon, 13 Dec 2004 15:19:07 -0500
To: nfs@lists.sourceforge.net
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

This is a multi-part message in MIME format.
--------------000606010605090402030807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


It was brought to my attention that following series of events
would cause an infinite loop in the 2.4 nfs kernels.

1) Mount the fileystem with acregmin=1,acregmax=1 from two clients.
2) On client 1, create a process that continuously writes to a file.
3) On client 2, remove that file that is being written
4) On client 1, interrupted out of the writing process (which is failing
     with ESTALEs) and type sync

The sync process loops in wait_on_locked(), when called from
sync_inodes_sb(), since the "broken" inode can not be cleared
from the locked inode list.

This patch sets the NFS_INO_STALE bit in write path (via
nfs_writeback_done) which breaks the inode is early enough to
stop it from being added to the that list.

Comments?

steved.


--------------000606010605090402030807
Content-Type: text/plain;
 name="linux-2.4.28-nfs-syncloop.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.28-nfs-syncloop.patch"

--- linux-2.4.28/fs/nfs/write.c.orig	2004-04-14 09:05:40.000000000 -0400
+++ linux-2.4.28/fs/nfs/write.c	2004-12-13 14:23:55.000000000 -0500
@@ -1073,6 +1073,9 @@ nfs_writeback_done(struct rpc_task *task
 			SetPageError(page);
 			if (req->wb_file)
 				req->wb_file->f_error = task->tk_status;
+			if (task->tk_status == -ESTALE)
+				NFS_FLAGS(inode) |= NFS_INO_STALE;
+
 			nfs_inode_remove_request(req);
 			dprintk(", error = %d\n", task->tk_status);
 			goto next;

--------------000606010605090402030807--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
