Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:53613 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755078Ab3KNUnY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Nov 2013 15:43:24 -0500
Received: by mail-ie0-f178.google.com with SMTP id aq17so3615691iec.9
        for <linux-nfs@vger.kernel.org>; Thu, 14 Nov 2013 12:43:24 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.0 \(1822\))
Subject: Re: [PATCH 6/7] nfs: take i_mutex during direct I/O reads
From: Trond Myklebust <trondmy@gmail.com>
In-Reply-To: <20131114165042.013211118@bombadil.infradead.org>
Date: Thu, 14 Nov 2013 15:43:21 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <C0D328CF-8E30-49E7-AE2C-A05EC463921B@gmail.com>
References: <20131114165027.355613182@bombadil.infradead.org> <20131114165042.013211118@bombadil.infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 14, 2013, at 11:50, Christoph Hellwig <hch@infradead.org> wrote:

> We'll need the i_mutex to prevent i_dio_count from incrementing while
> truncate is waiting for it to reach zero, and protects against having
> the pagecache repopulated after we flushed it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Hi Christoph,

Why do we need to protect the page cache here? Using O_DIRECT and the page cache without some kind of application-specific synchronization method is technically not supported, since that violates close-to-open cache consistency.
What we _do_ want to support, though, is parallel reads and writes to the server by applications that know what they are doing. If we were to only protect the i_dio_count, then we could fix the truncate race, while continuing to allow parallelism. Is there any reason why we cannot do this?

Cheers
  Trond

PS: I appear to be missing 7/7 in this patch series. Should I have seen it?