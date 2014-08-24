Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57626 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbaHXPsR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 11:48:17 -0400
Date: Sun, 24 Aug 2014 08:48:17 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org, hch@infradead.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/10] locks: close potential race in lease_get_mtime
Message-ID: <20140824154817.GA15908@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-2-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408804878-1331-2-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 23, 2014 at 10:41:09AM -0400, Jeff Layton wrote:
> lease_get_mtime is called without the i_lock held, so there's no
> guarantee about the stability of the list. Between the time when we
> assign "flock" and then dereference it to check whether it's a lease
> and for write, the lease could be freed.
> 
> Ensure that that doesn't occur by taking the i_lock before trying
> to check the lease.

Looks good.  Also looks way cleaner than before by being just a tad more
verbose..

Reviewed-by: Christoph Hellwig <hch@lst.de>
