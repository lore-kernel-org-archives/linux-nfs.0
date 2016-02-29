Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46926 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbcB2Jt6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Feb 2016 04:49:58 -0500
Date: Mon, 29 Feb 2016 01:49:54 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, Kinglong Mee <kinglongmee@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: nfsd: supports read buffer from multiples pages
Message-ID: <20160229094954.GA23406@infradead.org>
References: <56AE0302.6050101@gmail.com>
 <20160201183805.GB5499@fieldses.org>
 <20160202092054.GA26701@lst.de>
 <20160202142948.GA14068@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160202142948.GA14068@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 02, 2016 at 09:29:48AM -0500, J. Bruce Fields wrote:
> OK.  And what's the failure mode if the layoutcommit fails?  I guess the
> client returns the layout and redoes IO through the MDS.  For a rare
> failure maybe that's not so terrible.
> 
> So I guess the right thing to do is take Kinglong's patch for now.

Yes, it would be great to take it.

> After that, it wouldn't be that hard for nfsd4_block_proc_layoutcommit
> to decode from an array of pages.  But does the iomaps array end up
> being just as big?

The block layout extents are rather bloated, so it will be significantly
smaller.
