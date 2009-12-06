From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: nfs4 doesn't reflect inode->i_blocks immediately?
Date: Sat, 5 Dec 2009 22:44:35 -0500
Message-ID: <200912060344.nB63iZnU032368@agora.fsl.cs.sunysb.edu>
Cc: linux-fsdevel@vger.kernel.org
To: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In vanilla 2.6.32, I mount nfs4 on localhost: /n/export is the exported
point; /n/lower is the client-side mount point.  I tried these two commands
in rapid succession:

# cp /bin/ls /n/lower/ls ; stat /bin/ls /n/lower/ls /n/export/ls
  File: `/bin/ls'
  Size: 93560     	Blocks: 192        IO Block: 4096   regular file
Device: 301h/769d	Inode: 98160       Links: 1
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2009-12-05 18:14:30.000000000 -0500
Modify: 2007-10-31 09:13:32.000000000 -0400
Change: 2008-03-23 18:02:54.000000000 -0400
  File: `/n/lower/ls'
  Size: 93560     	Blocks: 0          IO Block: 262144 regular file
Device: fh/15d	Inode: 212599      Links: 1
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (  100/   users)
Access: 2009-12-05 22:35:53.000000000 -0500
Modify: 2009-12-05 22:35:53.000000000 -0500
Change: 2009-12-05 22:35:53.000000000 -0500
  File: `/n/export/ls'
  Size: 93560     	Blocks: 192        IO Block: 4096   regular file
Device: 301h/769d	Inode: 212599      Links: 1
Access: (0755/-rwxr-xr-x)  Uid: (    0/    root)   Gid: (  100/   users)
Access: 2009-12-05 22:35:53.000000000 -0500
Modify: 2009-12-05 22:35:53.000000000 -0500
Change: 2009-12-05 22:35:53.000000000 -0500

The NFS server sees the inode size/blocks correctly; the NFS client,
OTOH, only sees the inode size correctly.  If I wait a few seconds, then the
client's inode size and blocks become correct.  I can easily reproduce
this.  It doesn't happen with nfs2/3, only nfs4.

So, why this discrepancy?  Why does i_size become immdiately correct while
i_blocks takes a few seconds.  This is messing up my regression suites which
run on top of nfs4.  Plus, doesn't this violate some posix spec?

Thanks,
Erez.
