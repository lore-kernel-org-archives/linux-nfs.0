From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patches] nfsd-affecting part of vfs queue
Date: Wed, 22 Apr 2009 21:59:16 -0400
Message-ID: <20090423015916.GA16694@fieldses.org>
References: <E1LwNkj-0004WL-AW@ZenIV.linux.org.uk> <20090422213415.GJ9541@fieldses.org> <20090422230039.GQ8633@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:48365 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751512AbZDWB7Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 21:59:24 -0400
In-Reply-To: <20090422230039.GQ8633@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2009 at 12:00:39AM +0100, Al Viro wrote:
> On Wed, Apr 22, 2009 at 05:34:15PM -0400, J. Bruce Fields wrote:
> > On Tue, Apr 21, 2009 at 09:43:41PM +0000, Al Viro wrote:
> > > 
> > > Fix for out-order dput() vs. mntput() (in nfsd_cross_mnt()) plus
> > > several "switch to passing struct path *" ones.  Comments would
> > > be welcome...
> > > 
> > > Entire queue is on git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git/
> > > in "untested".
> > 
> > I haven't tested them, but otherwise they look like fine.  Shall queue
> > them in the nfsd tree?
> 
> Several patches later in VFS queue depend on those, so I'm definitely keeping
> them in there; might make sense to duplicate in nfsd tree as well to avoid
> inter-tree dependencies.  Hell knows, git will cope with that just fine,
> so linux-next will be OK with that, but -mm used to have problems with such
> things, IIRC.

OK.  I'll just ignore them unless it becomes a problem.

I did boot your tree above (c65d9c93...) and run a test or two without
seeing any obvious problem.  Feel free to add an

	Acked-by: J. Bruce Fields <bfields@citi.umich.edu>

--b.
