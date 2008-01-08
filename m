From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: Re: [NFS] [PATCH] nfs4, special files, and set/listxattr asymmetry
Date: Tue, 8 Jan 2008 16:47:15 -0500
Message-ID: <200801082147.m08LlF3D023364@agora.fsl.cs.sunysb.edu>
References: <20080108182038.GJ22155@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:53854 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751371AbYAHVrm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 16:47:42 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCMIO-0000Av-Hu
	for linux-nfs@vger.kernel.org; Wed, 09 Jan 2008 08:47:40 +1100
In-reply-to: Your message of "Tue, 08 Jan 2008 13:20:38 EST."
	<20080108182038.GJ22155@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In message <20080108182038.GJ22155@fieldses.org>, "J. Bruce Fields" writes:
> On Mon, Jan 07, 2008 at 10:34:04PM -0500, Trond Myklebust wrote:
> > 
> > On Mon, 2008-01-07 at 22:14 -0500, Erez Zadok wrote:
> > > Trond, I've discovered an asymmetry in how nfs4 (in v2.6.24-rc7) handles
> > > listxattr vs. setxattr for special files.  I caught this with Unionfs when
> > > testing a copyup of a character device from a readonly nfs4 mount to a
> > > writable nfs4 mount.
> > > 
> > > nfs4_setxattr returns -EPERM if the inode isn't a regular file or a (sticky)
> > > dir.  However, nfs4_listxattr returns XATTR_NAME_NFSV4_ACL (16 bytes,
> > > "system.nfs4_acl") regardless of the type of the inode.  So during copyup, I
> > > can ->listxattr fine from the source inode, but I get EPERM trying to
> > > ->setxattr on the destination branch of of the copyup.  (I already handle
> > > the case when copying-up from a f/s which supports xattr's to one which
> > > doesn't, but when both file systems are the same and mounted the same, there
> > > typically should not be difference).
> 
> I do wonder about relying on this, though.  The user.* attributes may
> work that way, but I don't know if there are any rules you can count on
> for the system.* or other xattrs--is there any guarantee a particular
> system.* attribute couldn't be readonly, for example?
> 
> --b.

A few months ago I looked into the issue of xattrs and copyup in more
detail, when I was tracking a problem for a user using an SE-linux enabled
livecd with unionfs.  I didn't realize before then that selinux made such a
heavy use of xattrs.  After tracking down the code maze I found out that the
list of xattrs being defined/used depends on your overall security mode and
global security ops.

Anyway, xattrs can be used for security reasons, and really any semantics
could be attached to them.  So in Unionfs I take the conservative approach:
if unionfs is compiled with xattr support, then during copyup I try to copy
the xattrs too (if any exist).  If unionfs fails to copyup the xattrs, then
I abort the copyup.  I figured it's safer to abort the copyup (which is
typically initiated when trying to modify a file on a readonly
branch/media), than to potentially open up a security hole by giving a
copied-up file more permissions than its source file may have had.  This
policy has so far worked for unionfs, at least for those users who use
xattrs/selinux, and in my limited testing.  But maybe I've got to rethink
it?

NFS in some sense shares some common traits with a stackable file system, in
that it has three "layers": client -> server -> backing-store f/s.  I'm
curious how does nfs/d handle xattrs (and selinux's use of them)?  Does the
client depend on having xattr support of any sort?  Does the server depend
on having xattr support in the export f/s?  How do you handle mixes of those
when one of the three layers has xattr support and another doesn't?

Thanks,
Erez.

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

