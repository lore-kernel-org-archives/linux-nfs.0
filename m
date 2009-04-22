From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/5] Safer nfsd_cross_mnt()
Date: Wed, 22 Apr 2009 20:17:19 +0100
Message-ID: <20090422191719.GN8633@ZenIV.linux.org.uk>
References: <E1LwNkj-0004WN-AZ@ZenIV.linux.org.uk> <20090422180641.GB9541@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39965 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbZDVTRU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 15:17:20 -0400
In-Reply-To: <20090422180641.GB9541@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 22, 2009 at 02:06:41PM -0400, J. Bruce Fields wrote:
> On Tue, Apr 21, 2009 at 09:43:41PM +0000, Al Viro wrote:
> > 
> > AFAICS, we have a subtle bug there: if we have crossed mountpoint
> > *and* it got mount --move'd away, we'll be holding only one
> > reference to fs containing dentry - exp->ex_path.mnt.  IOW, we
> > ought to dput() before exp_put().
> 
> OK.  So a dentry of its own doesn't hold any reference on its
> filesystem?

Nope.  That's why you want vfsmount or superblock reference.
And export *does* contain vfsmount reference, so everything's fine,
provided that you drop them in the right order.
