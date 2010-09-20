Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:41510 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754489Ab0ITNzg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 09:55:36 -0400
Subject: Re: Locking question around "...PagePrivate()"
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4C97584F.4020104@bull.net>
References: <4C7E4469.70807@duchatelet.net>  <4C97584F.4020104@bull.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Sep 2010 09:55:30 -0400
Message-ID: <1284990930.2851.3.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-09-20 at 14:49 +0200, Menyhart Zoltan wrote:
> Hi,
> 
> nfs_inode_add_request() runs under the protection of the Page Lock
> while setting up SetPagePrivate(), set_page_private().
> 
> The consumers of PagePrivate() run also under the protection of the Page Lock.
> 
> On the other hand, nfs_inode_remove_request() invoked by
> nfs_writeback_release_full() and nfs_commit_release() apparently does
> not take the Page Lock.
> 
> nfs_inode_remove_request() includes the sequence of
> 
>          set_page_private(req->wb_page, 0);
>          ClearPagePrivate(req->wb_page);
> 
> When the base kernel calls e.g.
> 
> 	mapping->a_ops->releasepage(page, gfp_mask)
> 
> then nfs_release_page() may see an incoherent "private" state.
> 
> Should not all the "private" operations be protected by the Page Lock?

No.

Cheers
  Trond

