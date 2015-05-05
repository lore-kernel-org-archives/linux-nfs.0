Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:36705 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754183AbbEETKP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 15:10:15 -0400
Date: Tue, 5 May 2015 12:10:12 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
Message-ID: <20150505191012.GA21164@infradead.org>
References: <20150313211124.22471.14517.stgit@manet.1015granger.net>
 <20150505154411.GA16729@infradead.org>
 <5E1B32EA-9803-49AA-856D-BF0E1A5DFFF4@oracle.com>
 <20150505172540.GA19442@infradead.org>
 <55490886.4070502@talpey.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55490886.4070502@talpey.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 05, 2015 at 02:14:30PM -0400, Tom Talpey wrote:
> As you might guess, I can go on at length about this. :-) But, if
> you have a kernel service, the ability to pin memory, and you
> want it to go fast, you want FRWR.

Basically most in-kernel consumers seem to have the same requirements:

 - register a struct page, which can be kernel or user memory (it's
   probably pinned in your Terms, but we don't really use that much in
   kernelspace).
 - In many but not all cases we might need an offset/length for each
   page (think struct bvec, paged sk_buffs, or scatterlists of some
   sort), in other an offset/len for the whole set of pages is fine,
   but that's a superset of the one above.
 - we usually want it to be as fast as possible

While my grep skills aren't the best I can't really find an in-kernel
user that doesn't fit the above, although I might have missed some
long-term registrations where we don't really care about the fast
part.
