Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52140 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751882AbeDPVpY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Apr 2018 17:45:24 -0400
Date: Mon, 16 Apr 2018 17:45:22 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Olga Kornievskaia <kolga@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v8 0/9] NFSD support for async COPY
Message-ID: <20180416214522.GC2634@parsley.fieldses.org>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180414072202.GA6514@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180414072202.GA6514@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 14, 2018 at 12:22:02AM -0700, Christoph Hellwig wrote:
> What is the use case for adding all these crazy complications?

Is there anything specific that you think is too complicated?

I know you don't think server-to-server copy offload is worth the
trouble, but I haven't seen you actually explain why (beyond just that
it's more complicated).

Is there some reason you think it won't actually be useful?

--b.
