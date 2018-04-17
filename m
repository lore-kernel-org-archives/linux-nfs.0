Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:55140 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752204AbeDQGwE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2018 02:52:04 -0400
Date: Mon, 16 Apr 2018 23:52:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Olga Kornievskaia <kolga@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180417065203.GA15145@infradead.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180416214522.GC2634@parsley.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 16, 2018 at 05:45:22PM -0400, J. Bruce Fields wrote:
> On Sat, Apr 14, 2018 at 12:22:02AM -0700, Christoph Hellwig wrote:
> > What is the use case for adding all these crazy complications?
> 
> Is there anything specific that you think is too complicated?

It is a lot of complexity for little gain.

> I know you don't think server-to-server copy offload is worth the
> trouble, but I haven't seen you actually explain why (beyond just that
> it's more complicated).

I'd like to see numbers for actual, real use cases.  Note that this
series doesn't seem to include inter-server support, so this is locally
only, and I'd like to see why we want to support this over the simpler
and better performing CLONE op.

Also even if we have a good reason to add it I absolutely want a config
option for the feature - it is a lot code adding potential attack
vectors, so we should not just enabled it by default.

> Is there some reason you think it won't actually be useful?

Lets start with explaining why it would actually be useful and benefit
Linux users.
