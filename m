Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41814 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726AbcBASsg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Feb 2016 13:48:36 -0500
Date: Mon, 1 Feb 2016 13:48:35 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: nfsd: supports read buffer from multiples pages
Message-ID: <20160201184835.GC5499@fieldses.org>
References: <56AE0302.6050101@gmail.com>
 <20160201183805.GB5499@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160201183805.GB5499@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 01, 2016 at 01:38:05PM -0500, bfields wrote:
> On Sun, Jan 31, 2016 at 08:50:10PM +0800, Kinglong Mee wrote:
> > ltp fsync02 will cause nfs sending LAYOUTCOMMIT with length
> > larger than two pages. nfsd returns NFSERR_BAD_XDR right now.
> 
> This is with the xfs block layout?
> 
> Christoph, do we know anything about average or worst-case sizes for
> that layout update field?
> 
> > This patch lets nfsd supports read buffer from multiples pages.
> 
> Hm.  We'll end up kmalloc()ing the passed-in field length:
> 
> 		p = argp->tmpp = kmalloc(nbytes, GFP_KERNEL);
> 
> We still do still have that (avail + argp->pagelen) limit, so we're not
> going to pass arbitrarily large nbytes straight from the network to
> kmalloc.  But we do try to avoid depending on higher-order allocations.

(Which it looks like we were allowing before, possibly by accident.  But
I doubt they were actually happening in practice, so that's not evidence
that we don't need to worry about allocations greater than a page.)

--b.
