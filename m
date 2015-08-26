Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:45388 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752946AbbHZB76 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 21:59:58 -0400
Date: Wed, 26 Aug 2015 11:59:43 +1000
From: Dave Chinner <david@fromorbit.com>
To: Peng Tao <tao.peng@primarydata.com>
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>, bfields@fieldses.org,
        Jeff Layton <jeff.layton@primarydata.com>, linux-btrfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH RFC 01/11] vfs: pull btrfs clone API to vfs layer
Message-ID: <20150826015943.GZ3902@dastard>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
 <1440516829-116041-2-git-send-email-tao.peng@primarydata.com>
 <20150826015034.GY3902@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150826015034.GY3902@dastard>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 11:50:34AM +1000, Dave Chinner wrote:
> On Tue, Aug 25, 2015 at 11:33:39PM +0800, Peng Tao wrote:
> > Now that a few file systems are adding clone functionality, namingly
> > btrfs, NFS (later in the series) and XFS
> > (ttp://oss.sgi.com/archives/xfs/2015-06/msg00407.html), it makes sense
> > to pull the ioctl to common code.
> > 
> > Add vfs_file_clone_range() helper and .clone_range file operation interface
> > to allow underlying filesystems to clone between regular files.
> > 
> > The change in do_vfs_ioctl() is defered to next patch where btrfs
> > .clone_range is added, just so that we don't break btrfs CLONE ioctl
> > with this patch.
> > 
> > Cc: linux-btrfs@vger.kernel.org
> > Cc: linux-fsdevel@vger.kernel.org
> 
> Can you please cc the entire patch series to linux-fsdevel?
> 
> Spraying random patches from a larger series to different lists is
> not very nice - I can't really comment on this patch because I have
> no idea what context it is being proposed in, what the problem being
> solved is, how it is being used by existing filesystems, how it will
> be used by your new changes, etc.
> 
> You may have explained all this in patch 0 for the series, but
> that hasn't been cc'd to linux-fsdevel....

Also, proposed test infrastructure for the clone_range functionality
that Darrick is working on for XFS (and to validate existing btrfs
functionality):

http://oss.sgi.com/archives/xfs/2015-06/msg00479.html

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
