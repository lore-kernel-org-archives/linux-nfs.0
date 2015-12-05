Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42862 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753116AbbLEMCZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Dec 2015 07:02:25 -0500
Date: Sat, 5 Dec 2015 13:02:22 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151205120222.GA27009@lst.de>
References: <20151129084614.42fb1272@tlielax.poochiereds.net> <565BBB03.7020206@gmail.com> <20151130213420.GA31564@fieldses.org> <20151130193313.5bb10791@synchrony.poochiereds.net> <20151201115600.GA1557@lst.de> <20151201174800.407e2c40@synchrony.poochiereds.net> <20151202072504.GA15839@lst.de> <20151203220850.GC19518@fieldses.org> <20151204083803.GA2440@lst.de> <20151204155110.64a352dd@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151204155110.64a352dd@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 04, 2015 at 03:51:10PM -0500, Jeff Layton wrote:
> > There is no reason not to do it, except for the significant effort
> > to implement it a well as a synthetic test case to actually reproduce
> > the behavior we want to handle.
> 
> Could you end up livelocking here? Suppose you issue the callback and
> the client returns success. He then returns the layout and gets a new
> one just before the delay timer pops. We then end up recalling _that_
> layout...rinse, repeat...

If we start allowing layoutgets before the whole range has been
returned there is a great chance for livelocks, yes.  But I don't think
we should allow layoutgets to proceed before that.
