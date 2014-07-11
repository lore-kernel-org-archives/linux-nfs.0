Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50833 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755138AbaGKULd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 16:11:33 -0400
Date: Fri, 11 Jul 2014 16:11:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix bad reserving space for encoding rdattr_error
Message-ID: <20140711201129.GB11931@fieldses.org>
References: <53B8C3D3.7080201@gmail.com>
 <20140707181556.GC8630@fieldses.org>
 <20140710105451.GA23266@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710105451.GA23266@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 03:54:51AM -0700, Christoph Hellwig wrote:
> On Mon, Jul 07, 2014 at 02:15:56PM -0400, J. Bruce Fields wrote:
> > > -	p = xdr_reserve_space(xdr, 6);
> > > +	p = xdr_reserve_space(xdr, 20);
> 
> Can we please convert all these magic numbers to expressions adding up
> sizeofs or where that doesn't fit use #defines?

So, this would be 

	xdr_reserve_space(xdr, 5 * sizeof(be32));

?  I guess that'd be OK.

--b.
