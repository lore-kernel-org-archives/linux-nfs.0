From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [PATCH] kNFSd BKL removal - fixes and refines
Date: Wed, 24 Apr 2002 11:04:18 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020424.110418.24330578.taka@valinux.co.jp>
References: <20020423.165021.35667389.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 170CAI-0004PR-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 19:05:50 -0700
Received: from localhost (gw1.valinux.co.jp [202.221.173.98])
	by sv1.valinux.co.jp (Postfix) with ESMTP id EBE6D70021
	for <nfs@lists.sourceforge.net>; Wed, 24 Apr 2002 11:05:45 +0900 (JST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20020423.165021.35667389.taka@valinux.co.jp>
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

Hello,

taka> Hi Neil,
taka> 
taka> This is a patch making your "kNFSd BKL removal code" better.
taka> Could you check it and merge to your next patch ?
taka> 
taka> ftp://ftp.valinux.co.jp/pub/people/taka/tune/2.5.8/va06-knfsd_smp-2.5.8.patch
taka> 
taka> 1. Fix some problems that kNFSd might Oops potentially when it turns
taka>    a NFS file-handle into a dentry.
taka> 
taka>     - The dentry child should be checked whether it is alive or dead 
taka>       in nfsd_findparent() or kNFSd might use a DEAD inode,
taka>       I mean the child might have been moved to another directory and
taka>       someone might try to remove the parent.

Sorry. following statement is my fault.
Please ignore it.

taka>     - kNFSd may refer NULL pointer in nfsd_findparent() when
taka>       child->d_inode->i_op->lookup() can't find ".." , as following
taka>       "if statement" -- if (!pdentry) -- is wrong.

	    
taka>     - We should grab the i_sem all the time in splice() or the dentry
taka>       parent might be removed between nfsd_get_name() and d_splice().
taka> 
taka>    I guess 2.4.18 also have the same problems.
taka> 
taka> 2. Remove the BKL in find_fh_dentry() as much as we can.
taka> 3. The statics info of nfsd and rpc should be accessed atomically.
taka> 4. Grab the spinlock while we copy the readahead info in nfsd_read();
taka> 5. The referrence count of readahead cache (p_count) should be 
taka>    increment or decrement atomically.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
