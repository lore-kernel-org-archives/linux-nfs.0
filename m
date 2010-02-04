Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56160 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932346Ab0BDPVt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Feb 2010 10:21:49 -0500
Date: Thu, 4 Feb 2010 10:21:47 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Ben Myers <bpm@sgi.com>, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 0/4] wsync export option
Message-ID: <20100204152147.GB22014@infradead.org>
References: <20100203233755.17677.96582.stgit@case> <1265241511.2632.12.camel@localhost>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1265241511.2632.12.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Feb 03, 2010 at 06:58:31PM -0500, Trond Myklebust wrote:
> Why should the administrator have to both change /etc/fstab
> and /etc/exports? That will be an immediate source of trouble if someone
> changes one without changing the other.

I agree, this should be left to the filesystems.

> Why not rather add an optional operation to the export_ops to let the
> filesystem specify exactly what kind of synchronisation policy is
> optimal for it?

Maybe.  But I suspect fsync is actually the right thing to do for
all the filesystems.  The only reason why we'd still might want to make
it an export operation is that I'd really prefer not to grow more
instances of fsync without the file pointer.  Then again they're
already all in nfs and it doesn't matter too much to audit a few
more places later.

