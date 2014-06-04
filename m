Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:57027 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbaFDRag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 13:30:36 -0400
Received: by mail-qa0-f42.google.com with SMTP id j5so7644467qaq.1
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 10:30:35 -0700 (PDT)
Date: Wed, 4 Jun 2014 13:30:32 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
To: Arnd Bergmann <arnd@arndb.de>
cc: Dave Chinner <david@fromorbit.com>, hch@infradead.org,
        linux-mtd@lists.infradead.org, "H. Peter Anvin" <hpa@zytor.com>,
        logfs@logfs.org, linux-afs@lists.infradead.org,
        "Joseph S. Myers" <joseph@codesourcery.com>,
        linux-arch@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-scsi@vger.kernel.org, ceph-devel@vger.kernel.org,
        cluster-devel@redhat.com, coda@cs.cmu.edu, geert@linux-m68k.org,
        linux-ext4@vger.kernel.org, codalist@telemann.coda.cs.cmu.edu,
        fuse-devel@lists.sourceforge.net, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, john.stultz@linaro.org, tglx@linutronix.de,
        linux-nfs@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, lftan@altera.com,
        linux-btrfs@vger.kernel.org
Subject: Re: [RFC 00/32] making inode time stamps y2038 ready
In-Reply-To: <201406041703.47592.arnd@arndb.de>
Message-ID: <alpine.LFD.2.11.1406041308300.17310@knanqh.ubzr>
References: <1401480116-1973111-1-git-send-email-arnd@arndb.de> <5011138.W0gbOc20Qp@wuerfel> <20140603213802.GH14410@dastard> <201406041703.47592.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 4 Jun 2014, Arnd Bergmann wrote:

> On Tuesday 03 June 2014, Dave Chinner wrote:
> > Just ot be pedantic, inodes don't need 96 bit timestamps - some
> > filesystems can *support up to* 96 bit timestamps. If the kernel
> > only supports 64 bit timestamps and that's all the kernel can
> > represent, then the upper bits of the 96 bit on-disk inode
> > timestamps simply remain zero.
> 
> I meant the reverse: since we have file systems that can store
> 96-bit timestamps when using 64-bit kernels, we need to extend
> 32-bit kernels to have the same internal representation so we
> can actually read those file systems correctly.
> 
> > If you move the filesystem between kernels with different time
> > ranges, then the filesystem needs to be able to tell the kernel what
> > it's supported range is.  This is where having the VFS limit the
> > range of supported timestamps is important: the limit is the
> > min(kernel range, filesystem range). This allows the filesystems
> > to be indepenent of the kernel time representation, and the kernel
> > to be independent of the physical filesystem time encoding....
> 
> I agree it makes sense to let the kernel know about the limits
> of the file system it accesses, but for the reverse, we're probably
> better off just making the kernel representation large enough (i.e.
> 96 bits) so it can work with any known file system.

Depends...  96 bit handling may get prohibitive on 32-bit archs.

The important point here is for the kernel to be able to represent the 
time _range_ used by any known filesystem, not necessarily the time 
_precision_.

For example, a 64 bit representation can be made of 40 bits for seconds 
spanning 34865 years, and 24 bits for fractional seconds providing 
precision down to 60 nanosecs.  That ought to be plenty good on 32 bit 
systems while still being cheap to handle.


Nicolas
