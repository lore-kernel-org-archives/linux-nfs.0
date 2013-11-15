Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57439 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407Ab3KOPCF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 10:02:05 -0500
Date: Fri, 15 Nov 2013 07:02:04 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/7] nfs: page cache invalidation for dio
Message-ID: <20131115150204.GA8105@infradead.org>
References: <20131114165027.355613182@bombadil.infradead.org>
 <20131114165042.205194841@bombadil.infradead.org>
 <20131114133551.5d08b5cd@tlielax.poochiereds.net>
 <20131115142847.GA1107@infradead.org>
 <20131115095241.2c5e1cfb@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131115095241.2c5e1cfb@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 15, 2013 at 09:52:41AM -0500, Jeff Layton wrote:
> Do you have these patches in a git tree someplace? If so, I wouldn't
> mind running this reproducer against it to see if it helps. It's a bit
> of a longshot, but what the heck...

While I do have a local git tree I don't really have anywhere to push
it to.  But applying these patches shouldn't be all that hard.

