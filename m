Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35493 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbaCTKEV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Mar 2014 06:04:21 -0400
Date: Thu, 20 Mar 2014 03:04:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2 v2] nfs: remove ->write_pageio_init from rpc ops
Message-ID: <20140320100414.GA28919@infradead.org>
References: <20140319164003.GA26364@infradead.org>
 <5329D82A.6040102@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5329D82A.6040102@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 19, 2014 at 01:47:22PM -0400, Anna Schumaker wrote:
> >  }
> > -EXPORT_SYMBOL_GPL(nfs_pageio_init_write);
> 
> I think we still need the EXPORT_SYMBOL_GPL() here.  Compiling gives me:
> 
> ERROR: "nfs_pageio_init_read" [fs/nfs/nfsv4.ko] undefined!
> ERROR: "nfs_pageio_init_write" [fs/nfs/nfsv4.ko] undefined!

Oh right - I only tested built-in nfs.   I have to say the amount of
fairly low-level interfaces exported from the various nfs modules make a
bit of a mess..

