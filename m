Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.kundenserver.de ([212.227.17.13]:62051 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753776AbaFDPGQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 11:06:16 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
Date: Wed, 4 Jun 2014 17:03:47 +0200
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
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <5011138.W0gbOc20Qp@wuerfel> <20140603213802.GH14410@dastard>
In-Reply-To: <20140603213802.GH14410@dastard>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201406041703.47592.arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday 03 June 2014, Dave Chinner wrote:
> On Tue, Jun 03, 2014 at 04:22:19PM +0200, Arnd Bergmann wrote:
> > On Monday 02 June 2014 14:57:26 H. Peter Anvin wrote:
> > > On 06/02/2014 12:55 PM, Arnd Bergmann wrote:
> > The possible uses I can see for non-ktime_t types in the kernel are:
> > * inodes need 96 bit timestamps to represent the full range of values
> >   that can be stored in a file system, you made a convincing argument
> >   for that. Almost everything else can fit into 64 bit on a 32-bit
> >   kernel, in theory also on a 64-bit kernel if we want that.
> 
> Just ot be pedantic, inodes don't need 96 bit timestamps - some
> filesystems can *support up to* 96 bit timestamps. If the kernel
> only supports 64 bit timestamps and that's all the kernel can
> represent, then the upper bits of the 96 bit on-disk inode
> timestamps simply remain zero.

I meant the reverse: since we have file systems that can store
96-bit timestamps when using 64-bit kernels, we need to extend
32-bit kernels to have the same internal representation so we
can actually read those file systems correctly.

> If you move the filesystem between kernels with different time
> ranges, then the filesystem needs to be able to tell the kernel what
> it's supported range is.  This is where having the VFS limit the
> range of supported timestamps is important: the limit is the
> min(kernel range, filesystem range). This allows the filesystems
> to be indepenent of the kernel time representation, and the kernel
> to be independent of the physical filesystem time encoding....

I agree it makes sense to let the kernel know about the limits
of the file system it accesses, but for the reverse, we're probably
better off just making the kernel representation large enough (i.e.
96 bits) so it can work with any known file system. We need another
check at the user space boundary to turn that into a value that the
user can understand, but that's another problem.

	Arnd
