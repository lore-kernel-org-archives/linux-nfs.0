From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [GIT] Please pull NFS updates...
Date: Sun, 25 Jun 2006 12:28:21 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0606251218500.3747@g5.osdl.org>
References: <1151232744.13127.40.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FuaHl-0007r8-I9
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 12:28:45 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1FuaHl-0000hZ-In
	for nfs@lists.sourceforge.net; Sun, 25 Jun 2006 12:28:45 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1151232744.13127.40.camel@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net



On Sun, 25 Jun 2006, Trond Myklebust wrote:
> 
> Please pull from the repository at
> 
>    git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git

This is broken.

	  CC      fs/nfs/nfs2xdr.o
	In file included from fs/nfs/nfs2xdr.c:28:
	fs/nfs/internal.h:7: error: redefinition of 'struct nfs_clone_mount'
	fs/nfs/internal.h:99: error: redefinition of 'nfs4_path'
	fs/nfs/internal.h:99: error: previous definition of 'nfs4_path' was here
	fs/nfs/internal.h:113: error: redefinition of 'nfs_devname'
	fs/nfs/internal.h:113: error: previous definition of 'nfs_devname' was here
	fs/nfs/internal.h:122: error: redefinition of 'nfs_block_bits'
	fs/nfs/internal.h:122: error: previous definition of 'nfs_block_bits' was here
	fs/nfs/internal.h:141: error: redefinition of 'nfs_calc_block_size'
	fs/nfs/internal.h:141: error: previous definition of 'nfs_calc_block_size' was here
	fs/nfs/internal.h:151: error: redefinition of 'nfs_block_size'
	fs/nfs/internal.h:151: error: previous definition of 'nfs_block_size' was here
	fs/nfs/internal.h:165: error: redefinition of 'nfs_super_set_maxbytes'
	fs/nfs/internal.h:165: error: previous definition of 'nfs_super_set_maxbytes' was here
	fs/nfs/internal.h:175: error: redefinition of 'valid_ipaddr4'
	fs/nfs/internal.h:175: error: previous definition of 'valid_ipaddr4' was here
	make[2]: *** [fs/nfs/nfs2xdr.o] Error 1
	make[1]: *** [fs/nfs] Error 2
	make: *** [fs] Error 2

Looks like a merge error, causing that "internal.h" file to be included
twice. 

Alternatively, you're applying patches without "--fuzz=0", which allowed
Andrew's "git-nfs-build-fixes" patch to be applied wice.

In either case, it came from your tree, and had apparently never even
been compile-tested. 

Tssk, tssk..

		Linus

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
