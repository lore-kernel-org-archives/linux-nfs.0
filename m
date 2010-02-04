Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:41181 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932457Ab0BDPaH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2010 10:30:07 -0500
Date: Thu, 4 Feb 2010 10:30:06 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Ben Myers <bpm@sgi.com>
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [RFC PATCH 0/4] wsync export option
Message-ID: <20100204153006.GC22014@infradead.org>
References: <20100203233755.17677.96582.stgit@case>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100203233755.17677.96582.stgit@case>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 03, 2010 at 05:44:24PM -0600, Ben Myers wrote:
> The following series is adds a 'wsync' export option to nfsd.  It is intended
> to be used on XFS with the wsync mount option.  When you already have a
> synchronous log there is no need to sync metadata separately.

You don't need the xfs wsync option, as the existing write_inode
calls or your new fsync calls are doing the same as the wsync mount
option, just from a higher layer.  The wsync option causes the log
to be synchronously forced up to the log sequence number of the commit
for the metadata operation, that is make all the operations affected
by it synchronous.  That's exactly what we'll do using fsync (actually
right now we force the whole log, but I have a patch to optimize it
to only force nuntil the last commit lsn), and approqimately the
same as we do using write_inode, just a lot less efficiently.

> This is barely tested, YMMV, I could have this all wrong, etc, etc.  Here are
> some very unscientific measurements taken over gigabit ethernet.
> 
> # time tar -xvf /mnt2/quilt-0.47.tar > /dev/null
> 
> No XFS wsync, no NFS wsync:
> 0m13.177s	0m13.301s	0m13.528s
> 
> XFS wsync set, no NFS wsync:
> 0m13.019s	0m13.232s	0m13.094s
> 
> XFS wsync set, NFS wsync set:
> 0m8.361s	0m8.400s	0m8.301s
> 
> Curious to hear if this is a reasonable thing to do.  Suggestions welcome.

I think it's reasonable.  What might be even better it to have an
export operation call out into the filesystem so that we can force wsync
and not let nfsd deal with it at all.  There is a fair chance that the
filesystem can do the sync more efficiently.

And btw, not directly related to your patch, but getting rid of this
write_inode call defintively makes the usage of ->write_inode more
regular.  From generic code we mostly use it for full inode writeback
in writeback_single_inode, and one other special case in
generic_detach_inode if a filesystem is unmounting.  Only having
writeback_single_inode and fs code use it will make this call much
more predictable for the filesystem.


