Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:43270 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932532AbaKMLCq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Nov 2014 06:02:46 -0500
Date: Thu, 13 Nov 2014 12:02:44 +0100
From: Christoph Hellwig <hch@lst.de>
To: Peng Tao <bergwolf@primarydata.com>
Cc: Weston Andros Adamson <dros@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] NFS: fix subtle change in COMMIT behavior
Message-ID: <20141113110244.GA25709@lst.de>
References: <1415812080-3033-1-git-send-email-dros@primarydata.com> <CAKVebiX=mRJ7Psc8+FigNLRgGB8vH84vcKdv173HvuT20+eh=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKVebiX=mRJ7Psc8+FigNLRgGB8vH84vcKdv173HvuT20+eh=w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 13, 2014 at 09:03:53AM +0800, Peng Tao wrote:
> > but should be contiguous (as enforced by nfs_flush_incompatible).
> >
> The idea is to get an estimation on the length of layout that client
> wants to use. So even if a single byte is used by client, client would
> want to ask for a layout that covers the whole page.

That code is very non-obvious and could use a few more comments.

I think the NFS_I(inode)->npages should be replaced with
inode->i_mapping->nrpages which counts the number of page cache pages.
