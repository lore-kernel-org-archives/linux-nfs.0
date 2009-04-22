From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [patches] nfsd-affecting part of vfs queue
Date: Thu, 23 Apr 2009 00:00:39 +0100
Message-ID: <20090422230039.GQ8633@ZenIV.linux.org.uk>
References: <E1LwNkj-0004WL-AW@ZenIV.linux.org.uk> <20090422213415.GJ9541@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46053 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbZDVXAk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 19:00:40 -0400
In-Reply-To: <20090422213415.GJ9541@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 22, 2009 at 05:34:15PM -0400, J. Bruce Fields wrote:
> On Tue, Apr 21, 2009 at 09:43:41PM +0000, Al Viro wrote:
> > 
> > Fix for out-order dput() vs. mntput() (in nfsd_cross_mnt()) plus
> > several "switch to passing struct path *" ones.  Comments would
> > be welcome...
> > 
> > Entire queue is on git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git/
> > in "untested".
> 
> I haven't tested them, but otherwise they look like fine.  Shall queue
> them in the nfsd tree?

Several patches later in VFS queue depend on those, so I'm definitely keeping
them in there; might make sense to duplicate in nfsd tree as well to avoid
inter-tree dependencies.  Hell knows, git will cope with that just fine,
so linux-next will be OK with that, but -mm used to have problems with such
things, IIRC.
