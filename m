Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:39177 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752356AbaKYNGt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2014 08:06:49 -0500
Date: Tue, 25 Nov 2014 14:06:46 +0100
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Weston Andros Adamson <dros@primarydata.com>,
        Peng Tao <bergwolf@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: fix subtle change in COMMIT behavior
Message-ID: <20141125130646.GA30673@lst.de>
References: <1415812080-3033-1-git-send-email-dros@primarydata.com> <CAKVebiX=mRJ7Psc8+FigNLRgGB8vH84vcKdv173HvuT20+eh=w@mail.gmail.com> <20141113110244.GA25709@lst.de> <6E1CB959-CB60-4AE3-9392-65ABDF0DB2F0@primarydata.com> <20141114070401.GA3944@lst.de> <1416866672.3523.1.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1416866672.3523.1.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 24, 2014 at 05:04:32PM -0500, Trond Myklebust wrote:
> On Fri, 2014-11-14 at 08:04 +0100, Christoph Hellwig wrote:
> > The patch below passes block layout testing for me:
> 
> Hmm... Are you sure? It didn't compile for me, due to the misspelled
> 'nrpages'.

Hmm, my locally commited version has nrpages, while the one on the list has
nr_pages.  The one I tested obviously had nrpages.
