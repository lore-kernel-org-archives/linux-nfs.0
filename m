From: Arun Sharma <arun.sharma@intel.com>
Subject: VFS: Busy inodes after unmount on 2 way SMP
Date: Thu, 11 Sep 2003 17:11:40 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F610F3C.5040704@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xbaD-00067g-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Sep 2003 17:14:41 -0700
Received: from fmr04.intel.com ([143.183.121.6] helo=caduceus.sc.intel.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19xbaD-0000OZ-FY
	for nfs@lists.sourceforge.net; Thu, 11 Sep 2003 17:14:41 -0700
To: autofs@linux.kernel.org
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


We've seen a few "VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day.." messages on a dual processor NFS client. Here's the use case:

- Due to network load issues, the NFS server becomes unreachable for some time
- The automounter tries to expire the mount
- The unmount finds a couple of busy inodes. Putting some debug printks shows that typically two inodes are busy i.e. have inode->i_count == 1. But they don't have any waiters on inode->i_wait. Further, the inodes that are busy are
/mnt/foo     -> autofs mount point
/mnt/foo/bar -> bar is a symbolic link

It's not clear if this is a NFS issue or a autofs issue, but it's seen often with autofs. Are there any known race conditions that have been fixed after 2.4.20 ? The two calls I'm worried about are:

fs/autofs/root.c:305:    d_instantiate(dentry, iget(dir->i_sb,ent->ino));
fs/autofs/root.c:416:    d_instantiate(dentry, iget(dir->i_sb,ino));

    -Arun




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
