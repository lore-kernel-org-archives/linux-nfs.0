Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41711 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932343AbbDMRam (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2015 13:30:42 -0400
Date: Mon, 13 Apr 2015 10:30:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: David Howells <dhowells@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, NeilBrown <neilb@suse.de>,
        linux-btrfs@vger.kernel.org, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC] fscache/cachefiles versus btrfs
Message-ID: <20150413173040.GA30623@infradead.org>
References: <20150409235234.GJ13731@dastard>
 <20150409174916.5a2efef5@notabene.brown>
 <29536.1428571388@warthog.procyon.org.uk>
 <9282.1428672496@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9282.1428672496@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 10, 2015 at 02:28:16PM +0100, David Howells wrote:
> Dave Chinner <david@fromorbit.com> wrote:
> 
> > SEEK_HOLE/SEEK_DATA is what you want, as they are page cache
> > coherent, not extent based operations. And, really if you need it to
> > really be able to find real holes, then a superblock flag might be a
> > better way of marking filesystems with the required capability.
> 
> Actually, I wonder if what I want is a kernel_read() that returns ENODATA upon
> encountering a hole at the beginning of the area to be read.

NFS READ_PLUS could also make use of this, but someone needs to actually
implement it.

Until we have that lseek SEEK_HOLE/DATA is the way to go, and the
horrible ->bmap hack needs to die ASAP, I can't believe you managed to
sneak that in in the not too distant past.
