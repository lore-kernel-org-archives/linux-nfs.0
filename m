From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [BUG] kNFSd may get a freeing inode.
Date: Wed, 18 Sep 2002 16:09:13 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020918.160913.73658160.taka@valinux.co.jp>
References: <20020917.170156.35804958.taka@valinux.co.jp>
	<15752.7496.463707.865953@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: viro@math.psu.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17rZ5b-0008Fg-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 00:17:35 -0700
To: neilb@cse.unsw.edu.au
In-Reply-To: <15752.7496.463707.865953@notabene.cse.unsw.edu.au>
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

> > This is a big problem.
> > 
> > kNFSd might get inode which is just freeing.
> > We know inodes under freeing(I_FREEING) are not on the inode-hash.
> ....
> > What is the best way to avoid this situation?
> > We shold keep freeing inodes the hash?
> 
> I think you are right.
> If knfsd (or a filesystem's ->get_dentry) calls iget just as
> iput_final is being called, the iget will fail to find the inode (it
> is dropped from the hash before unlocking inode_lock) and so will call
> ->read_inode, possibly before generic_delete_inode has called
> ->delete_inode, and so will get an apparently valid inode just before
> that inode actually gets destroyed.
> 
> The only solution I can see is, as you say, keeping it on the hash
> table a bit longer.
> 
> Al,  can you see any problem with this patch which should, I think,
> close the race?

There would be some problems.

1) knfsd can get a freeing inode which will be destroyed soon,
   so that knfsd may access unknown memory.
   find_inode() should be fixed to not get a freeing inode

2) Just after calling op->delete_inode(inode) or clear_inode(inode),
   others can create a new inode which have the same inode-number
   even if old one is still on the hash.

3) Some code assumes inodes on the hash are valid.
   I found __mark_inode_dirty() assumes this and may move freeing
   inodes on the dirty-inode-list.
   __mark_inode_dirty() should check i_state flag instead of i_hash.

Any others?


Thank you,
Hirokazu Takahashi.


-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
