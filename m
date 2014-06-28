Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36276 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751760AbaF1LCQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Jun 2014 07:02:16 -0400
Date: Sat, 28 Jun 2014 04:02:16 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 009/117] nfsd: wait to initialize work struct just
 prior to using it
Message-ID: <20140628110216.GB10848@infradead.org>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
 <1403810017-16062-10-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403810017-16062-10-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 26, 2014 at 03:11:49PM -0400, Jeff Layton wrote:
> There's a fair chance we won't ever need this work struct, so we might
> as well delay initializing it until just before we're going to use it.
> In a later patch, we'll need to intialize the work with a different
> function for delegation callbacks. By delaying this, we avoid having
> to do it twice.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
