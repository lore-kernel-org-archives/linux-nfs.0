From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/5] Safer nfsd_cross_mnt()
Date: Wed, 22 Apr 2009 15:20:23 -0400
Message-ID: <20090422192023.GE9541@fieldses.org>
References: <E1LwNkj-0004WN-AZ@ZenIV.linux.org.uk> <20090422180641.GB9541@fieldses.org> <20090422191719.GN8633@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:51475 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753026AbZDVTUa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 15:20:30 -0400
In-Reply-To: <20090422191719.GN8633@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 22, 2009 at 08:17:19PM +0100, Al Viro wrote:
> On Wed, Apr 22, 2009 at 02:06:41PM -0400, J. Bruce Fields wrote:
> > On Tue, Apr 21, 2009 at 09:43:41PM +0000, Al Viro wrote:
> > > 
> > > AFAICS, we have a subtle bug there: if we have crossed mountpoint
> > > *and* it got mount --move'd away, we'll be holding only one
> > > reference to fs containing dentry - exp->ex_path.mnt.  IOW, we
> > > ought to dput() before exp_put().
> > 
> > OK.  So a dentry of its own doesn't hold any reference on its
> > filesystem?
> 
> Nope.  That's why you want vfsmount or superblock reference.
> And export *does* contain vfsmount reference, so everything's fine,
> provided that you drop them in the right order.

Got it, thanks.

--b.
