From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: [PATCH] kNFSd BKL removal - fixes and refines
Date: Tue, 23 Apr 2002 16:50:21 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020423.165021.35667389.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zv5X-0006F2-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 00:51:47 -0700
Received: from localhost (gw1.valinux.co.jp [202.221.173.98])
	by sv1.valinux.co.jp (Postfix) with ESMTP id 5DEF87001F
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 16:51:44 +0900 (JST)
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

Hi Neil,

This is a patch making your "kNFSd BKL removal code" better.
Could you check it and merge to your next patch ?

ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.8/va06-knfsd_smp-2.5.8.patch

1. Fix some problems that kNFSd might Oops potentially when it turns
   a NFS file-handle into a dentry.

    - The dentry child should be checked whether it is alive or dead 
      in nfsd_findparent() or kNFSd might use a DEAD inode,
      I mean the child might have been moved to another directory and
      someone might try to remove the parent.
    - kNFSd may refer NULL pointer in nfsd_findparent() when
      child->d_inode->i_op->lookup() can't find ".." , as following
      "if statement" -- if (!pdentry) -- is wrong.
    - We should grab the i_sem all the time in splice() or the dentry
      parent might be removed between nfsd_get_name() and d_splice().

   I guess 2.4.18 also have the same problems.

2. Remove the BKL in find_fh_dentry() as much as we can.
3. The statics info of nfsd and rpc should be accessed atomically.
4. Grab the spinlock while we copy the readahead info in nfsd_read();
5. The referrence count of readahead cache (p_count) should be 
   increment or decrement atomically.


And a following is another patch to increase the number of readahead cache
with a hash table.

ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.8/va07-knfsd-ra_hash-2.5.8.patch


Thank you,
Hirokazu Takahashi.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
