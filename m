Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35424 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754678AbaH0Rn0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2014 13:43:26 -0400
Date: Wed, 27 Aug 2014 10:43:25 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Add v4.2 SEEK support
Message-ID: <20140827174325.GB13128@infradead.org>
References: <1409152730-8070-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1409152730-8070-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 27, 2014 at 11:18:49AM -0400, Anna Schumaker wrote:
> This patch adds support for the NFS v4.2 operation SEEK.
> 
> I think nfs4proc.c and nfs4xdr.c have grown out of control, and I would like
> to avoid adding new functions to these files unless absolutely necessary.
> Therefore, I created nfs4.2proc.c and nfs4.2xdr.h in an attempt to separate
> out the new code.
> 
> Questions?  Comments?  Thoughts?

I hate the dot in the name :)  why not nfs42proc.c and co?

Also without splitting out the much larger 4.1 ops this seems a bit
pointless, although I generally like the idea.

