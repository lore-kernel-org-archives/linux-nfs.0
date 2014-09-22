Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54280 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354AbaIVUGm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2014 16:06:42 -0400
Date: Mon, 22 Sep 2014 13:06:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH, RFC] nfsd: fix nfsd4_cb_recall_done error handling
Message-ID: <20140922200642.GA24361@infradead.org>
References: <20140922182923.GA18904@infradead.org>
 <CAHQdGtSGh0vTgXw_eib3EWwGY71bSmDZDEU3Z9FW_bV_FSG7zQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtSGh0vTgXw_eib3EWwGY71bSmDZDEU3Z9FW_bV_FSG7zQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 22, 2014 at 04:03:37PM -0400, Trond Myklebust wrote:
> We're also missing a handler for NFS4ERR_DELAY, which is listed as a
> legal response to CB_RECALL in both RFC5661 and RFC3530bis. As far as
> I can tell from the above, knfsd will currently take that to be a sign
> it should mark the callback path as being down...

Yes.  I've got a fix of that further down in my queue with the pnfs
patches, just wanted to set this bit out first.

I plan to handle NFS4ERR_DELAY in the generic callback layer instead of
burderning it onto the individual callback implementations.
