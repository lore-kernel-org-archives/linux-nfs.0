Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38358 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3KROQY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Nov 2013 09:16:24 -0500
Date: Mon, 18 Nov 2013 06:16:24 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: split up nfsd_setattr
Message-ID: <20131118141624.GA15744@infradead.org>
References: <20131118130730.GA17184@infradead.org>
 <20131118141031.GA3203@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131118141031.GA3203@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 18, 2013 at 09:10:31AM -0500, J. Bruce Fields wrote:
> On Mon, Nov 18, 2013 at 05:07:30AM -0800, Christoph Hellwig wrote:
> > Split out two helpers to make the code more readable and easier to verify
> > for correctness.
> 
> Thanks, both queued up for 2.14.

The write counter leak on a break_lease failure is quite serious,
given that nfsd_break_lease passes O_NONBLOCK and thus remote users
can arbitrarily trigger it.

