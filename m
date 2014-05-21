Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:45322 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458AbaEUOXV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2014 10:23:21 -0400
Date: Wed, 21 May 2014 07:23:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        dros@primarydata.com, hch@infradead.org
Subject: Re: [RFC 00/12] PNFS Read and Write Cleanups
Message-ID: <20140521142320.GA12674@infradead.org>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 20, 2014 at 02:08:07PM -0400, Anna Schumaker wrote:
> There is a lot of duplicate code in pnfs.c that can be cleaned up to
> share more code.  This patch set goes through each function one at a
> time and merges read and write code together wherever possible.  In the
> end I'm passing around a few function pointers.  Would it be better to
> use a function pointer struct instead?

No chance to share this with the r/w ops for the classic code?

Aso I think it would be even better if a lot of this code could be
mergedinto the classic code path, it seems like we'd mostly need
pnfs_get/put_lseg in common code for this.  pnfs_get_lseg is so trivial
that it's not a problem, and the put could be done by simply giving each
lseg a free function pointer.

