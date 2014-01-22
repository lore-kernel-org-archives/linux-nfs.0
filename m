Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47134 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbaAVIYS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jan 2014 03:24:18 -0500
Date: Wed, 22 Jan 2014 00:24:14 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/7] nfs: page cache invalidation for dio
Message-ID: <20140122082414.GA12530@infradead.org>
References: <20131114165027.355613182@bombadil.infradead.org>
 <20131114165042.205194841@bombadil.infradead.org>
 <20131114133551.5d08b5cd@tlielax.poochiereds.net>
 <20131115142847.GA1107@infradead.org>
 <20131115095241.2c5e1cfb@tlielax.poochiereds.net>
 <20131115150204.GA8105@infradead.org>
 <20131115103324.6a3cf978@tlielax.poochiereds.net>
 <20140121142159.210ca0b8@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140121142159.210ca0b8@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 21, 2014 at 02:21:59PM -0500, Jeff Layton wrote:
> In any case, this helps but it's a little odd. With this patch, you add
> an invalidate_inode_pages2 call prior to doing the DIO. But, you've
> also left in the call to nfs_zap_mapping in the completion codepath.
> 
> So now, we shoot down the mapping prior to doing a DIO write, and then
> mark the mapping for invalidation again when the write completes. Was
> that intentional?
> 
> It seems a little excessive and might hurt performance in some cases.
> OTOH, if you mix buffered and DIO you're asking for trouble anyway and
> this approach seems to give better cache coherency.

Thile follows the model implemented and documented in
generic_file_direct_write().

