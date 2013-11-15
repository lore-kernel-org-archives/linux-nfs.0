Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57282 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab3KOO2u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 09:28:50 -0500
Date: Fri, 15 Nov 2013 06:28:47 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/7] nfs: page cache invalidation for dio
Message-ID: <20131115142847.GA1107@infradead.org>
References: <20131114165027.355613182@bombadil.infradead.org>
 <20131114165042.205194841@bombadil.infradead.org>
 <20131114133551.5d08b5cd@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131114133551.5d08b5cd@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 14, 2013 at 01:35:51PM -0500, Jeff Layton wrote:
> Hrm... I started chasing down a bug reported by our QA group last week
> that's showing up when you mix DIO writes and buffered reads
> (basically, diotest3 in the LTP suite is failing). The bug is marked
> private for dumb reasons but I'll see if I can make it public. I'll
> also plan to give this series a spin to see if it helps fix that bug...
> 
> In any case, the DIO write code calls nfs_zap_mapping after it gets the
> WRITE reply. That sets NFS_INO_INVALID_DATA and should prevent buffered
> read() calls from getting data out of the cache after the write reply
> comes in.
> 
> Why is that not sufficient here?

Sounds like it should actually be fine, although I had similar testcases
fail.  I didn't even notice we were doing the invalidation, but delaying
it.  Can't see how that helps when bringing mmap into the game, although
that was always an best effort and pray that it works scenario.
