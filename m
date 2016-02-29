Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54783 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbcB2J6D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Feb 2016 04:58:03 -0500
Date: Mon, 29 Feb 2016 10:57:56 +0100
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs/blocklayout: make sure making a aligned read request
Message-ID: <20160229095756.GA19397@infradead.org>
References: <56BF34E3.1020003@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <56BF34E3.1020003@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 13, 2016 at 09:51:31PM +0800, Kinglong Mee wrote:
> Only treat write goes up to the inode size as aligned request,
> because it always write PAGE_CACHE_SIZE, but read a dynamic size.

Can you explain what the point is?  We'll never use data pas the block size
in the page cache, but per the block size requirement in the spec we must
be able to read it.  This patch means we can't direct storage reads where
we previously could, without any obvious upside.
