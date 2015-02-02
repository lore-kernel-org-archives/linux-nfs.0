Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:43199 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753018AbbBBIGi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Feb 2015 03:06:38 -0500
Date: Mon, 2 Feb 2015 09:06:35 +0100
From: Christoph Hellwig <hch@lst.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@lst.de>,
        David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-mtd@lists.infradead.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: Re: backing_dev_info cleanups & lifetime rule fixes V2
Message-ID: <20150202080635.GB9851@lst.de>
References: <1421228561-16857-1-git-send-email-hch@lst.de> <54BEC3C2.7080906@fb.com> <20150201063116.GP29656@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150201063116.GP29656@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 01, 2015 at 06:31:16AM +0000, Al Viro wrote:
> And at that point we finally can make sb_lock and super_blocks static in
> fs/super.c.  Do you want that in your tree, or would you rather have it
> done via vfs.git during the merge window after your tree goes in?  It's
> as trivial as this:
> 
> Make super_blocks and sb_lock static
> 
> The only user outside of fs/super.c is gone now
> 
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

I'd say merge it through the block tree..

Acked-by: Christoph Hellwig <hch@lst.de>
