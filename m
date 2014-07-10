Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57940 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbaGJKyv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 06:54:51 -0400
Date: Thu, 10 Jul 2014 03:54:51 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: Fix bad reserving space for encoding rdattr_error
Message-ID: <20140710105451.GA23266@infradead.org>
References: <53B8C3D3.7080201@gmail.com>
 <20140707181556.GC8630@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140707181556.GC8630@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 07, 2014 at 02:15:56PM -0400, J. Bruce Fields wrote:
> > -	p = xdr_reserve_space(xdr, 6);
> > +	p = xdr_reserve_space(xdr, 20);

Can we please convert all these magic numbers to expressions adding up
sizeofs or where that doesn't fit use #defines?

