Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f171.google.com ([209.85.192.171]:39684 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbaLVHMU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Dec 2014 02:12:20 -0500
Received: by mail-pd0-f171.google.com with SMTP id y13so5326448pdi.30
        for <linux-nfs@vger.kernel.org>; Sun, 21 Dec 2014 23:12:20 -0800 (PST)
Date: Sun, 21 Dec 2014 23:12:16 -0800
From: Omar Sandoval <osandov@osandov.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH v2 2/5] direct-io: don't dirty ITER_BVEC pages on read
Message-ID: <20141222071216.GA24722@mew>
References: <cover.1419044605.git.osandov@osandov.com>
 <f9b69250ba0598807d96857e9b736d57e6841ba3.1419044605.git.osandov@osandov.com>
 <20141220060130.GA22149@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141220060130.GA22149@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 20, 2014 at 06:01:30AM +0000, Al Viro wrote:
> On Fri, Dec 19, 2014 at 07:18:26PM -0800, Omar Sandoval wrote:
> > Reads through the iov_iter infrastructure for kernel pages shouldn't be
> > dirtied by the direct I/O code.
> > 
> > This is based on Dave Kleikamp's and Ming Lei's previously posted
> > patches.
> 
> Umm...  
> 
> > +	dio->should_dirty = !iov_iter_is_bvec(iter);
> 
> 	dio->should_dirty = iter_is_iovec(iter);
> 
> perhaps?

Mm, yeah, I'll do that. That helper snuck in without me noticing it... I
see that we can't do iov_iter_get_pages on an ITER_KVEC, so a kvec
doesn't work for blockdev_direct_IO anyways, right?

-- 
Omar
