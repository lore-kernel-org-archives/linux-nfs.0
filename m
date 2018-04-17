Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42418 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753324AbeDQNmZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 09:42:25 -0400
Date: Tue, 17 Apr 2018 09:42:24 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Olga Kornievskaia <kolga@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180417134224.GC10291@parsley.fieldses.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
 <20180416214522.GC2634@parsley.fieldses.org>
 <20180417065203.GA15145@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180417065203.GA15145@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 16, 2018 at 11:52:03PM -0700, Christoph Hellwig wrote:
> On Mon, Apr 16, 2018 at 05:45:22PM -0400, J. Bruce Fields wrote:
> > On Sat, Apr 14, 2018 at 12:22:02AM -0700, Christoph Hellwig wrote:
> > > What is the use case for adding all these crazy complications?
> > 
> > Is there anything specific that you think is too complicated?
> 
> It is a lot of complexity for little gain.
> 
> > I know you don't think server-to-server copy offload is worth the
> > trouble, but I haven't seen you actually explain why (beyond just that
> > it's more complicated).
> 
> I'd like to see numbers for actual, real use cases.  Note that this
> series doesn't seem to include inter-server support, so this is locally
> only, and I'd like to see why we want to support this over the simpler
> and better performing CLONE op.

Note that we already support COPY (using a read-write loop if
necessary).

--b.
