Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44710 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755038Ab0IKAII (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Sep 2010 20:08:08 -0400
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Christoph Hellwig <hch@infradead.org>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20100910235858.GB11231@infradead.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	 <1283450419-5648-8-git-send-email-iisaman@netapp.com>
	 <20100910235858.GB11231@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Sep 2010 20:07:59 -0400
Message-ID: <1284163679.14078.106.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-09-10 at 19:58 -0400, Christoph Hellwig wrote:
> > +EXPORT_SYMBOL(pnfs_register_layoutdriver);
> 
> Al exports from nfs.ko needs to be _GPL - this is in no way a public
> API, just an internal subdivision of the nfs client.

ACK. We're not committing to supporting a stable ABI here in any way,
shape or form...

Cheers
  Trond

