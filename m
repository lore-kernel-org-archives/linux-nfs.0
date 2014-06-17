Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39453 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133AbaFQNxn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 09:53:43 -0400
Date: Tue, 17 Jun 2014 06:53:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v2 3/4] nfsd: nfsd_splice_read and nfsd_readv should
 return __be32
Message-ID: <20140617135342.GC13980@infradead.org>
References: <1403005454-7319-1-git-send-email-jlayton@primarydata.com>
 <1403005454-7319-4-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403005454-7319-4-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 17, 2014 at 07:44:13AM -0400, Jeff Layton wrote:
> The callers expect a __be32 return and the functions they call return
> __be32, so having these return int is just wrong. Also, nfsd_finish_read
> can be made static.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
