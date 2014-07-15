Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:34863 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193AbaGOQYy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 12:24:54 -0400
Date: Tue, 15 Jul 2014 09:24:53 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 1/7] nfsd: nfs4_alloc_init_lease should take a nfs4_file
 arg
Message-ID: <20140715162453.GB8928@infradead.org>
References: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
 <1405420669-4030-2-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405420669-4030-2-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2014 at 06:37:43AM -0400, Jeff Layton wrote:
> No need to pass the delegation pointer in here as it's only used to get
> the nfs4_file pointer.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
