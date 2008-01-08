From: Dave Quigley <dpquigl@tycho.nsa.gov>
Subject: Re: [NFS] [PATCH] nfs4, special files, and set/listxattr asymmetry
Date: Tue, 08 Jan 2008 17:05:35 -0500
Message-ID: <1199829935.8434.75.camel@moss-terrapins.epoch.ncsc.mil>
References: <20080108182038.GJ22155@fieldses.org>
	<200801082147.m08LlF3D023364@agora.fsl.cs.sunysb.edu>
	<20080108215736.GP22155@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:38365 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753492AbYAHWmO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 17:42:14 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCN99-0000J5-OR
	for linux-nfs@vger.kernel.org; Wed, 09 Jan 2008 09:42:11 +1100
In-Reply-To: <20080108215736.GP22155@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-01-08 at 16:57 -0500, J. Bruce Fields wrote:
> On Tue, Jan 08, 2008 at 04:47:15PM -0500, Erez Zadok wrote:
> > A few months ago I looked into the issue of xattrs and copyup in more
> > detail, when I was tracking a problem for a user using an SE-linux enabled
> > livecd with unionfs.  I didn't realize before then that selinux made such a
> > heavy use of xattrs.  After tracking down the code maze I found out that the
> > list of xattrs being defined/used depends on your overall security mode and
> > global security ops.
> > 
> > Anyway, xattrs can be used for security reasons, and really any semantics
> > could be attached to them.  So in Unionfs I take the conservative approach:
> > if unionfs is compiled with xattr support, then during copyup I try to copy
> > the xattrs too (if any exist).  If unionfs fails to copyup the xattrs, then
> > I abort the copyup.  I figured it's safer to abort the copyup (which is
> > typically initiated when trying to modify a file on a readonly
> > branch/media), than to potentially open up a security hole by giving a
> > copied-up file more permissions than its source file may have had.  This
> > policy has so far worked for unionfs, at least for those users who use
> > xattrs/selinux, and in my limited testing.  But maybe I've got to rethink
> > it?
> > 
> > NFS in some sense shares some common traits with a stackable file system, in
> > that it has three "layers": client -> server -> backing-store f/s.  I'm
> > curious how does nfs/d handle xattrs (and selinux's use of them)?  Does the
> > client depend on having xattr support of any sort?  Does the server depend
> > on having xattr support in the export f/s?  How do you handle mixes of those
> > when one of the three layers has xattr support and another doesn't?
> 
> We ignore xattr's entirely for now.  The labeled nfs people (mailing
> list at labeled-nfs@linux-nfs.org) have plans to address the selinux
> case, but I haven't really followed that.
> 
> --b.
> 
> -------------------------------------------------------------------------
> Check out the new SourceForge.net Marketplace.
> It's the best place to buy or sell services for
> just about anything Open Source.
> http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> _______________________________________________
> Please note that nfs@lists.sourceforge.net is being discontinued.
> Please subscribe to linux-nfs@vger.kernel.org instead.
>     http://vger.kernel.org/vger-lists.html#linux-nfs

xattrs are only the local Linux representation of a MAC attribute. For
the purpose of interoperability we can't assume xattrs considering NFSv4
doesn't contain them in the specification. We considered the named
attributes but they fall short concerning file labeling. Instead we are
working on adding another recommended attribute to the NFSv4
specification to handle an opaque security label. For your purposes you
can continue to think of them as extended attributes since that is the
interface that Linux has chosen for security attributes. However, I
don't see this functionality making its way into Linux any time soon
since it will require a change to the NFSv4 standard and they are
wrapping up the NFSv4.1 specification. I can't say how long it will be
before NFSv4.2 starts up. Maybe future events will cause that to happen
sooner than later.

Dave


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

