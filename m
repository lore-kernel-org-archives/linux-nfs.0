From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] nfs4, special files, and set/listxattr asymmetry
Date: Tue, 8 Jan 2008 16:57:37 -0500
Message-ID: <20080108215736.GP22155@fieldses.org>
References: <20080108182038.GJ22155@fieldses.org>
	<200801082147.m08LlF3D023364@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	nfs@lists.sourceforge.net
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:53824 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480AbYAHV5q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 16:57:46 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCMS8-0000By-Dm
	for linux-nfs@vger.kernel.org; Wed, 09 Jan 2008 08:57:44 +1100
In-Reply-To: <200801082147.m08LlF3D023364-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 08, 2008 at 04:47:15PM -0500, Erez Zadok wrote:
> A few months ago I looked into the issue of xattrs and copyup in more
> detail, when I was tracking a problem for a user using an SE-linux enabled
> livecd with unionfs.  I didn't realize before then that selinux made such a
> heavy use of xattrs.  After tracking down the code maze I found out that the
> list of xattrs being defined/used depends on your overall security mode and
> global security ops.
> 
> Anyway, xattrs can be used for security reasons, and really any semantics
> could be attached to them.  So in Unionfs I take the conservative approach:
> if unionfs is compiled with xattr support, then during copyup I try to copy
> the xattrs too (if any exist).  If unionfs fails to copyup the xattrs, then
> I abort the copyup.  I figured it's safer to abort the copyup (which is
> typically initiated when trying to modify a file on a readonly
> branch/media), than to potentially open up a security hole by giving a
> copied-up file more permissions than its source file may have had.  This
> policy has so far worked for unionfs, at least for those users who use
> xattrs/selinux, and in my limited testing.  But maybe I've got to rethink
> it?
> 
> NFS in some sense shares some common traits with a stackable file system, in
> that it has three "layers": client -> server -> backing-store f/s.  I'm
> curious how does nfs/d handle xattrs (and selinux's use of them)?  Does the
> client depend on having xattr support of any sort?  Does the server depend
> on having xattr support in the export f/s?  How do you handle mixes of those
> when one of the three layers has xattr support and another doesn't?

We ignore xattr's entirely for now.  The labeled nfs people (mailing
list at labeled-nfs@linux-nfs.org) have plans to address the selinux
case, but I haven't really followed that.

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

