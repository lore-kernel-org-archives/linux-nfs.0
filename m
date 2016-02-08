Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40291 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbcBHT6G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2016 14:58:06 -0500
Date: Mon, 8 Feb 2016 11:58:06 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: silent truncation for large file offsets
Message-ID: <20160208195806.GA16422@infradead.org>
References: <20160208183328.GA29982@infradead.org>
 <20160208193012.GG17411@fieldses.org>
 <CAHQdGtRN16=oYbsgtf_XEpxyWpz-H8+u6j2ekckqumiHh5Yv7g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRN16=oYbsgtf_XEpxyWpz-H8+u6j2ekckqumiHh5Yv7g@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 08, 2016 at 02:45:54PM -0500, Trond Myklebust wrote:
> I'll bet it's this:
> 
> static inline loff_t nfs_size_to_loff_t(__u64 size)
> {
>         if (size > (__u64) OFFSET_MAX - 1)
>                 return OFFSET_MAX - 1;
>         return (loff_t) size;
> }
> 
> Should be "return OFFSET_MAX", no?

Yes.  That (or rather a slighty nicer version using min_t) fixes the
test case for me.
