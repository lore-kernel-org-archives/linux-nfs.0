Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50987 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754274AbaGNJ7s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jul 2014 05:59:48 -0400
Date: Mon, 14 Jul 2014 02:59:44 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix bad reserving space for encoding rdattr_error
Message-ID: <20140714095944.GA25481@infradead.org>
References: <53B8C3D3.7080201@gmail.com>
 <20140707181556.GC8630@fieldses.org>
 <20140710105451.GA23266@infradead.org>
 <20140711201129.GB11931@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140711201129.GB11931@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 11, 2014 at 04:11:29PM -0400, J. Bruce Fields wrote:
> > On Mon, Jul 07, 2014 at 02:15:56PM -0400, J. Bruce Fields wrote:
> > > > -	p = xdr_reserve_space(xdr, 6);
> > > > +	p = xdr_reserve_space(xdr, 20);
> > 
> > Can we please convert all these magic numbers to expressions adding up
> > sizeofs or where that doesn't fit use #defines?
> 
> So, this would be 
> 
> 	xdr_reserve_space(xdr, 5 * sizeof(be32));
> 
> ?  I guess that'd be OK.

Yes, that makes a lot more sense.  I'm still hoping to make progress
on my krpcgen one day..
