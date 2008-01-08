From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] nfs4, special files, and set/listxattr asymmetry
Date: Tue, 8 Jan 2008 13:20:38 -0500
Message-ID: <20080108182038.GJ22155@fieldses.org>
References: <200801080314.m083EVbb011378@agora.fsl.cs.sunysb.edu>
	<1199763245.21371.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54879 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbYAHVrJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 16:47:09 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCMHr-0000Aj-Iw
	for linux-nfs@vger.kernel.org; Wed, 09 Jan 2008 08:47:07 +1100
In-Reply-To: <1199763245.21371.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 07, 2008 at 10:34:04PM -0500, Trond Myklebust wrote:
> 
> On Mon, 2008-01-07 at 22:14 -0500, Erez Zadok wrote:
> > Trond, I've discovered an asymmetry in how nfs4 (in v2.6.24-rc7) handles
> > listxattr vs. setxattr for special files.  I caught this with Unionfs when
> > testing a copyup of a character device from a readonly nfs4 mount to a
> > writable nfs4 mount.
> > 
> > nfs4_setxattr returns -EPERM if the inode isn't a regular file or a (sticky)
> > dir.  However, nfs4_listxattr returns XATTR_NAME_NFSV4_ACL (16 bytes,
> > "system.nfs4_acl") regardless of the type of the inode.  So during copyup, I
> > can ->listxattr fine from the source inode, but I get EPERM trying to
> > ->setxattr on the destination branch of of the copyup.  (I already handle
> > the case when copying-up from a f/s which supports xattr's to one which
> > doesn't, but when both file systems are the same and mounted the same, there
> > typically should not be difference).

I do wonder about relying on this, though.  The user.* attributes may
work that way, but I don't know if there are any rules you can count on
for the system.* or other xattrs--is there any guarantee a particular
system.* attribute couldn't be readonly, for example?

--b.

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

