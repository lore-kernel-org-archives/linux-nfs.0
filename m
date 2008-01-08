From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [NFS] [PATCH] nfs4, special files, and set/listxattr asymmetry
Date: Mon, 07 Jan 2008 22:34:04 -0500
Message-ID: <1199763245.21371.6.camel@heimdal.trondhjem.org>
References: <200801080314.m083EVbb011378@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	"Dr. J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54319 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752777AbYAHDfJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jan 2008 22:35:09 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JC5F4-0006Vn-Q4
	for linux-nfs@vger.kernel.org; Tue, 08 Jan 2008 14:35:06 +1100
In-Reply-To: <200801080314.m083EVbb011378-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2008-01-07 at 22:14 -0500, Erez Zadok wrote:
> Trond, I've discovered an asymmetry in how nfs4 (in v2.6.24-rc7) handles
> listxattr vs. setxattr for special files.  I caught this with Unionfs when
> testing a copyup of a character device from a readonly nfs4 mount to a
> writable nfs4 mount.
> 
> nfs4_setxattr returns -EPERM if the inode isn't a regular file or a (sticky)
> dir.  However, nfs4_listxattr returns XATTR_NAME_NFSV4_ACL (16 bytes,
> "system.nfs4_acl") regardless of the type of the inode.  So during copyup, I
> can ->listxattr fine from the source inode, but I get EPERM trying to
> ->setxattr on the destination branch of of the copyup.  (I already handle
> the case when copying-up from a f/s which supports xattr's to one which
> doesn't, but when both file systems are the same and mounted the same, there
> typically should not be difference).
> 
> Assuming that the original intent of the EPERM check in nfs4_setxattr was to
> prevent setting xattrs over nfs4 for non-files/dirs, then I "fixed" this by
> adding a similar check in nfs4_listxattr, which returns an empty xattr list
> for those.  I've included a patch below for your consideration/review.

I can see no reason in the RFC why you shouldn't be able to set an NFSv4
ACL on a special file. AFAICS this is a bug in the nfs4_setxattr code,
which is probably due to some improper cut n' pasting from the posix acl
code.

Bruce?

Cheers
  Trond

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

