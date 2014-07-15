Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44734 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752919AbaGOQp3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 12:45:29 -0400
Date: Tue, 15 Jul 2014 09:45:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: silence sparse warning about accessing credentials
Message-ID: <20140715164527.GA9127@infradead.org>
References: <1405420134-3736-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405420134-3736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2014 at 06:28:54AM -0400, Jeff Layton wrote:
> sparse says:
> 
>     fs/nfsd/auth.c:31:38: warning: incorrect type in argument 1 (different address spaces)
>     fs/nfsd/auth.c:31:38:    expected struct cred const *cred
>     fs/nfsd/auth.c:31:38:    got struct cred const [noderef] <asn:4>*real_cred
> 
> Add a new accessor for the ->real_cred and use that to fetch the
> pointer. Accessing current->real_cred directly is actually quite safe
> since we know that they can't go away so this is mostly a cosmetic fixup
> to silence sparse.

This looks reasonable, but I'd suggest Ccing linux-kernel for changes to
global headers.

Reviewed-by: Christoph Hellwig <hch@lst.de>
