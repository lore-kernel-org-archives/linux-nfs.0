Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57292 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab3KOO3Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 09:29:24 -0500
Date: Fri, 15 Nov 2013 06:29:23 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6/7] nfs: take i_mutex during direct I/O reads
Message-ID: <20131115142923.GB1107@infradead.org>
References: <20131114165027.355613182@bombadil.infradead.org>
 <20131114165042.013211118@bombadil.infradead.org>
 <71EA5383-5AAD-4BDE-B93A-BEE22D691CD8@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <71EA5383-5AAD-4BDE-B93A-BEE22D691CD8@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 14, 2013 at 12:00:06PM -0500, Chuck Lever wrote:
> > We'll need the i_mutex to prevent i_dio_count from incrementing while
> > truncate is waiting for it to reach zero, and protects against having
> > the pagecache repopulated after we flushed it.
> 
> How was the performance impact of this change measured?

I've only done correctness tests.

