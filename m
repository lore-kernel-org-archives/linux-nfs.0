From: Ion Badulescu <lists@news.cs.columbia.edu>
Subject: Re: VFS: Busy inodes after unmount on 2 way SMP
Date: Fri, 12 Sep 2003 19:33:37 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200309122333.h8CNXbW09877@moisil.badula.org>
References: <3F610F3C.5040704@intel.com>
Cc: nfs@lists.sourceforge.net, autofs@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xxQ8-0007Av-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Sep 2003 16:33:44 -0700
Received: from ool-43524450.dyn.optonline.net ([67.82.68.80] helo=buggy.badula.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 19xxQ8-0001AN-Ba
	for nfs@lists.sourceforge.net; Fri, 12 Sep 2003 16:33:44 -0700
To: Arun Sharma <arun.sharma@intel.com>
In-Reply-To: <3F610F3C.5040704@intel.com>
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

On Thu, 11 Sep 2003 17:11:40 -0700, Arun Sharma <arun.sharma@intel.com> wrote:

> We've seen a few "VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day.." messages on a dual processor NFS client. Here's the use case:
> 
> - Due to network load issues, the NFS server becomes unreachable for some time
> - The automounter tries to expire the mount
> - The unmount finds a couple of busy inodes. Putting some debug printks shows that typically two inodes are busy i.e. have inode->i_count == 1. But they don't have any waiters on inode->i_wait. Further, the inodes that are busy are
> /mnt/foo     -> autofs mount point
> /mnt/foo/bar -> bar is a symbolic link
> 
> It's not clear if this is a NFS issue or a autofs issue, but it's seen often with autofs. Are there any known race conditions that have been fixed after 2.4.20 ? The two calls I'm worried about are:
> 
> fs/autofs/root.c:305:    d_instantiate(dentry, iget(dir->i_sb,ent->ino));
> fs/autofs/root.c:416:    d_instantiate(dentry, iget(dir->i_sb,ino));

I don't know if it's the same issue, but I've seen it many many times 
while testing amd's autofs functionality. It occurs when a non-empty 
autofs filesystem is unmounted, e.g. if it has some leftover 
subdirectories from previous mounts. Therefore I'd say it's quite 
clearly an autofs issue, at least in my case.

Do you see it when shutting down the automounter, or in other cases as 
well?

Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
