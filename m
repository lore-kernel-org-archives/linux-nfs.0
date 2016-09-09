Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36112 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752079AbcIIHBs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 03:01:48 -0400
Date: Fri, 9 Sep 2016 15:01:46 +0800
From: Eryu Guan <eguan@redhat.com>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, fstests@vger.kernel.org,
        linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v2 1/4] generic/377: Add copy to new file test
Message-ID: <20160909070146.GZ27776@eguan.usersys.redhat.com>
References: <20160907195619.25914-1-Anna.Schumaker@Netapp.com>
 <20160907195619.25914-2-Anna.Schumaker@Netapp.com>
 <20160909062136.GY27776@eguan.usersys.redhat.com>
 <20160909062925.GC9312@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160909062925.GC9312@birch.djwong.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 08, 2016 at 11:29:25PM -0700, Darrick J. Wong wrote:
> > > +
> > > +_require_xfs_io_command "copy_range"
> > 
> > Do we need to test the support status on kernel side? e.g. what happens
> > if filesystems have no "copy_file_range" implemented? Seems
> > copy_file_range falls back to splice in this case, but I'm not sure. If
> > so I think it's OK to have no kernel side detection.
> 
> But... it's a totally new syscall, so _require_io_command should actually try
> calling it so that we can _notrun on old kernels.

The only reason that I think it's OK to check xfs_io support only is
that the "copy_range" subcommand won't be even compiled in xfs_io if
kernel has no copy_file_range syscall support.

But yeah, I agree that calling it and see how kernel handles it would be
the best option, like how we handle falloc, fpunch in
_require_xfs_io_command.

Thanks,
Eryu
