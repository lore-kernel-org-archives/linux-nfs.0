Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37317 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030Ab3KROjU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Nov 2013 09:39:20 -0500
Date: Mon, 18 Nov 2013 09:39:18 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd: split up nfsd_setattr
Message-ID: <20131118143918.GB3203@fieldses.org>
References: <20131118130730.GA17184@infradead.org>
 <20131118141031.GA3203@fieldses.org>
 <20131118141624.GA15744@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131118141624.GA15744@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 18, 2013 at 06:16:24AM -0800, Christoph Hellwig wrote:
> On Mon, Nov 18, 2013 at 09:10:31AM -0500, J. Bruce Fields wrote:
> > On Mon, Nov 18, 2013 at 05:07:30AM -0800, Christoph Hellwig wrote:
> > > Split out two helpers to make the code more readable and easier to verify
> > > for correctness.
> > 
> > Thanks, both queued up for 2.14.
> 
> The write counter leak on a break_lease failure is quite serious,
> given that nfsd_break_lease passes O_NONBLOCK and thus remote users
> can arbitrarily trigger it.

Oops, I read too quickly and thought it was just cleanup.

Looks like I introduced that bug into 2.6.38 with
6a76bebefe15d9a08864f824d7f8d5beaf37c997 "nfsd4: break lease on nfsd
setattr"

OK, added a sentence saying that to the second path and I'll pass it
along with stable cc:'s after some testing.

--b.
