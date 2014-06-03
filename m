Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:18434 "EHLO
	ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934040AbaFCViU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2014 17:38:20 -0400
Date: Wed, 4 Jun 2014 07:38:02 +1000
From: Dave Chinner <david@fromorbit.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>,
        "Joseph S. Myers" <joseph@codesourcery.com>,
        linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
        john.stultz@linaro.org, hch@infradead.org, tglx@linutronix.de,
        geert@linux-m68k.org, lftan@altera.com, linux-fsdevel@vger.kernel.org,
        ceph-devel@vger.kernel.org, cluster-devel@redhat.com, coda@cs.cmu.edu,
        codalist@telemann.coda.cs.cmu.edu, fuse-devel@lists.sourceforge.net,
        linux-afs@lists.infradead.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        linux-scsi@vger.kernel.org, logfs@logfs.org,
        ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org,
        samba-technical@lists.samba.org, xfs@oss.sgi.com
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
Message-ID: <20140603213802.GH14410@dastard>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de>
 <7175692.dpgYFMbTaP@wuerfel>
 <538CF346.2070504@zytor.com>
 <5011138.W0gbOc20Qp@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5011138.W0gbOc20Qp@wuerfel>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 03, 2014 at 04:22:19PM +0200, Arnd Bergmann wrote:
> On Monday 02 June 2014 14:57:26 H. Peter Anvin wrote:
> > On 06/02/2014 12:55 PM, Arnd Bergmann wrote:
> The possible uses I can see for non-ktime_t types in the kernel are:
> * inodes need 96 bit timestamps to represent the full range of values
>   that can be stored in a file system, you made a convincing argument
>   for that. Almost everything else can fit into 64 bit on a 32-bit
>   kernel, in theory also on a 64-bit kernel if we want that.

Just ot be pedantic, inodes don't *need* 96 bit timestamps - some
filesystems can *support up to* 96 bit timestamps. If the kernel
only supports 64 bit timestamps and that's all the kernel can
represent, then the upper bits of the 96 bit on-disk inode
timestamps simply remain zero.

If you move the filesystem between kernels with different time
ranges, then the filesystem needs to be able to tell the kernel what
it's supported range is.  This is where having the VFS limit the
range of supported timestamps is important: the limit is the
min(kernel range, filesystem range). This allows the filesystems
to be indepenent of the kernel time representation, and the kernel
to be independent of the physical filesystem time encoding....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
