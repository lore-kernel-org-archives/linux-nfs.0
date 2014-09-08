Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46748 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753794AbaIHOmY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 10:42:24 -0400
Date: Mon, 8 Sep 2014 07:42:23 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfs: revert "nfs4: queue free_lock_state job submission
 to nfsiod"
Message-ID: <20140908144223.GA19811@infradead.org>
References: <20140907153534.GA7026@infradead.org>
 <1410179161-18418-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1410179161-18418-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 08, 2014 at 08:26:01AM -0400, Jeff Layton wrote:
> The original reason for this patch was because the fl_release_private
> operation couldn't sleep. With commit ed9814d85810 (locks: defer freeing
> locks in locks_delete_lock until after i_lock has been dropped), this is
> no longer a problem so we can revert this patch.
> 
> Reported-by: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks good, I tested an equivalent revert for about half a dozen runs
of xfstests yesterday and couldn't reproduce this bug with it.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Tested-by: Christoph Hellwig <hch@lst.de>
