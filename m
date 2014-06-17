Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33292 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbaFQK22 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 06:28:28 -0400
Date: Tue, 17 Jun 2014 03:28:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: fix return of nfs4_acl_write_who
Message-ID: <20140617102826.GB32216@infradead.org>
References: <1403000048-31245-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403000048-31245-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 17, 2014 at 06:14:08AM -0400, Jeff Layton wrote:
> AFAICT, the only way to hit this error is to pass this function a bogus
> "who" value. In that case, we probably don't want to return -1 as that
> could get sent back to the client. Turn this into nfserr_serverfault,
> which is a more appropriate error for a server bug like this.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
