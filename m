Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:59776 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbaJWHfA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2014 03:35:00 -0400
Date: Thu, 23 Oct 2014 00:34:57 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfsd4: fix response size estimation for OP_SEQUENCE
Message-ID: <20141023073457.GA18399@infradead.org>
References: <20141017212446.GC3474@fieldses.org>
 <20141021103631.GB21863@infradead.org>
 <20141021131406.GE9863@fieldses.org>
 <20141022192258.GB5552@fieldses.org>
 <20141022194257.GC5552@fieldses.org>
 <57662446-E474-4420-84F5-349B6B85119F@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <57662446-E474-4420-84F5-349B6B85119F@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 22, 2014 at 01:12:12PM -0700, Tom Haynes wrote:
> > That means that if a revision of the 4.2 draft adds a new operation
> > beyond the current end (OP_WRITE_SAME = 70), a client would need to be
> > prepared for old servers returning OP_ILLEGAL to that operation.
> > 
> 
> Or if the new minor versioning rules take effect...

I guess that's a good reason to start future proofing clients to treat
OP_ILLEGAL the same as NFS4ERR_NOTSUP.

