From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Sun, 03 Aug 2008 09:39:51 +0100
Message-ID: <1217752791.2500.9.camel@shinybook.infradead.org>
References: <76bd70e30807311753m2785c6d3kd82edd1fe8b5f8b7@mail.gmail.com>
	 <1217552437.3719.30.camel@shinybook.infradead.org>
	 <76bd70e30807311831p771d0f1eia3e303bd84919422@mail.gmail.com>
	 <1217597759.3454.356.camel@pmac.infradead.org>
	 <1217598976.3454.359.camel@pmac.infradead.org>
	 <76bd70e30808010905j3010a6bfy534c068a662d348d@mail.gmail.com>
	 <1217607571.3454.417.camel@pmac.infradead.org>
	 <76bd70e30808011047u3cd0a56cg3b2d62e01afed014@mail.gmail.com>
	 <20080802182644.GE30454@fieldses.org>
	 <1217709752.2500.5.camel@shinybook.infradead.org>
	 <20080802213337.GA2833@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: chucklever@gmail.com, viro@zeniv.linux.org.uk,
	Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:57871 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752536AbYHCIkB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2008 04:40:01 -0400
In-Reply-To: <20080802213337.GA2833@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2008-08-02 at 17:33 -0400, J. Bruce Fields wrote:
> On Sat, Aug 02, 2008 at 09:42:32PM +0100, David Woodhouse wrote:
> > On Sat, 2008-08-02 at 14:26 -0400, J. Bruce Fields wrote:
> > > Could you add a readdirplus vfs operation which took a flag indicating
> > > how much extra information you're going to need?
> > 
> > Actually, if we're screwing with readdir then xfs would like to know how
> > much it's going to be asked to read, rather than just have the filldir
> > callback return zero when it's done.
> 
> OK.
> 
> > > The three cases where readdir can be called are:
> > >         - ordinary readdir, for which the existing filldir_t provides
> > >           all the information needed.
> > >         - nfsv3 readdirplus, where the only additional information
> > >           needed is whether there's a mountpoint.
> > 
> > It also wants a file handle.
> 
> Oops, right.
> 
> > For which I think it just needs
> > i_generation in addition to the information it already has.
> 
> Typically, right, though the filesystem's allowed some choice about what
> exactly it wants to use in the filehandle.  I don't know how the various
> filesystems are actually using that in practice.

That's OK. If we do ->lookup_fh() and they're making their own, they can
put what they like in it.

> > >         - nfsv4 readdir, where we may need all the stat info, acls,
> > >           etc., etc.
> > 
> > We _might_, but most of the time we won't. It might be OK to fall back
> > to the existing double-buffer hack for the cases where we _do_ need that
> > extra information.
> 
> How bad is the "double-buffer hack" anyway?  Rather than have this as a
> fallback case that's rarely used (hence rarely tested), it might be
> simpler just to use it for everything if we're going to use it at all.

It's certainly a good enough answer for now, which is why I've posted
the patches to do exactly that.

And yes, I have wondered the same myself, since realising that we'll
need a full lookup for some NFSv4 clients anyway. Or maybe the full
->lookup_locked(), perhaps...

-- 
dwmw2

