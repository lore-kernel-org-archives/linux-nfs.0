Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail05.adl6.internode.on.net ([150.101.137.143]:6918 "EHLO
        ipmail05.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752545AbcIKXKl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Sep 2016 19:10:41 -0400
Date: Mon, 12 Sep 2016 09:10:37 +1000
From: Dave Chinner <david@fromorbit.com>
To: Eryu Guan <eguan@redhat.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, fstests@vger.kernel.org,
        linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v2 1/4] generic/377: Add copy to new file test
Message-ID: <20160911231037.GI22388@dastard>
References: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
 <20160907195619.25914-2-Anna.Schumaker@Netapp.com>
 <20160909062136.GY27776@eguan.usersys.redhat.com>
 <20160909062925.GC9312@birch.djwong.org>
 <20160909070146.GZ27776@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160909070146.GZ27776@eguan.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 09, 2016 at 03:01:46PM +0800, Eryu Guan wrote:
> On Thu, Sep 08, 2016 at 11:29:25PM -0700, Darrick J. Wong wrote:
> > > > +
> > > > +_require_xfs_io_command "copy_range"
> > > 
> > > Do we need to test the support status on kernel side? e.g. what happens
> > > if filesystems have no "copy_file_range" implemented? Seems
> > > copy_file_range falls back to splice in this case, but I'm not sure. If
> > > so I think it's OK to have no kernel side detection.
> > 
> > But... it's a totally new syscall, so _require_io_command should actually try
> > calling it so that we can _notrun on old kernels.
> 
> The only reason that I think it's OK to check xfs_io support only is
> that the "copy_range" subcommand won't be even compiled in xfs_io if
> kernel has no copy_file_range syscall support.

It's not uncommon to have an xfs_io that will support a new syscall
or syscall flags by directly coding the support when it's
not found by the configure script. e.g. io/prealloc.c support for
all the different fallocate flags, regardless of whether the
underlying kernel or userspace headers support them.

> But yeah, I agree that calling it and see how kernel handles it would be
> the best option, like how we handle falloc, fpunch in
> _require_xfs_io_command.

Which we do for precisely the reason above. :P

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
