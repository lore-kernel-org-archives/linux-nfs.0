Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.133]:54126 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752762AbeDRHHK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Apr 2018 03:07:10 -0400
Date: Wed, 18 Apr 2018 00:07:09 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Olga Kornievskaia <kolga@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180418070709.GB8764@infradead.org>
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
> 
> I know you don't think server-to-server copy offload is worth the
> trouble, but I haven't seen you actually explain why (beyond just that
> it's more complicated).

For one all code is buggy and introduces issues, and code implementing
asynchronous, distributed state machines is even more so.  So a large
chunk of code is a big warning sign.  Especially if it isn't actually
useful to normal users.
