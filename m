Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:45004 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756757AbaF3SB3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 14:01:29 -0400
Date: Mon, 30 Jun 2014 11:01:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH v3 008/114] nfsd: clean up nfsd4_close_open_stateid
Message-ID: <20140630180127.GA20028@infradead.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-9-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404143423-24381-9-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2014 at 11:48:37AM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Minor cleanup that should introduce no behavioral changes.
> 
> Currently this function just unhashes the stateid and leaves the caller
> to do the work of the CLOSE processing.
> 
> Change nfsd4_close_open_stateid so that it handles doing all of the work
> of closing a stateid. Move the handling of the unhashed stateid into it
> instead of doing that work in nfsd4_close. This will help isolate some
> coming changes to stateid handling from nfsd4_close.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
