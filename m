Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51282 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761598Ab3JPSYr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 14:24:47 -0400
Date: Wed, 16 Oct 2013 11:24:47 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: simplify reconnecting dentries looked up by filehandle
Message-ID: <20131016182447.GA3088@infradead.org>
References: <1381869574-10662-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381869574-10662-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 15, 2013 at 04:39:28PM -0400, J. Bruce Fields wrote:
> I tested performance with a script that creates an N-deep directory
> tree, gets a filehandle for the bottom directory, writes 2 to
> /proc/sys/vm/drop_caches, then times an open_by_handle_at() of the
> filehandle.  Code at
> 
> 	git://linux-nfs.org/~bfields/fhtests.git
> 
> For directories of various depths, some example observed times (median
> results of 3 similar runs, in seconds), were:
> 
> 		depth:	8000	2000	200
> 	no patches:	11	0.7	0.02
> 	first patch:	 6	0.4	0.01
> 	all patches:	 0.1	0.03	0.01
> 
> For depths < 2000 I used an ugly hack to shrink_slab_node() to force
> drop_caches to free more dentries.  Difference look lost in the noise
> for much smaller depths.

Btw, it would be good to get this wired up in xfstests - add xfs_io
commands for the by handle ops and then just wire up the script driving
them.

I'd also really like to see a stress test for cold handle conversion vs
various VFS ops based on that sort of infrastructure.

