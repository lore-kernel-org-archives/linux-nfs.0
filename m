Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48245 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894Ab1GaT6r convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 31 Jul 2011 15:58:47 -0400
Subject: Re: Please pull NFS client changes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jens Axboe <jaxboe@fusionio.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Sun, 31 Jul 2011 15:58:45 -0400
In-Reply-To: <4E35B126.8050009@fusionio.com>
References: <1312082377.10882.1.camel@lade.trondhjem.org>
	  <20110731182406.GA16470@infradead.org> <4E35A9B1.9090309@fusionio.com>
	 <1312141193.7127.1.camel@lade.trondhjem.org>
	 <4E35B126.8050009@fusionio.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1312142325.7127.3.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2011-07-31 at 21:46 +0200, Jens Axboe wrote: 
> On 2011-07-31 21:39, Trond Myklebust wrote:
> > On Sun, 2011-07-31 at 21:14 +0200, Jens Axboe wrote: 
> >> On 2011-07-31 20:24, Christoph Hellwig wrote:
> >>> How does this manage to include the pnfs block code, which only was posted
> >>> on the list a few hours before the pull request, and which doesn't
> >>> appear to past testing very well (although the major issue seems to be
> >>> core nfs code)?
> >>
> >> And it doesn't even compile:
> >>
> >> In file included from fs/nfs/client.c:51:0:
> >> fs/nfs/pnfs.h:384:1: error: expected identifier or ‘(’ before ‘{’ token
> >> fs/nfs/client.c: In function ‘nfs_server_set_fsinfo’:
> >> fs/nfs/client.c:939:8: error: ‘struct nfs_server’ has no member named
> >> ‘pnfs_blksize’
> >> fs/nfs/client.c: At top level:
> >> fs/nfs/pnfs.h:382:20: warning: ‘set_pnfs_layoutdriver’ used but never
> >> defined [enabled by default]
> >> make[2]: *** [fs/nfs/client.o] Error 1
> > 
> > Sigh. This should fix it...
> 
> Only the first one, there are two independent places it broke. You
> missed this bit:
> 
> fs/nfs/client.c:939:8: error: ‘struct nfs_server’ has no member named

How's this?

8<-------------------------------------------------------------------------------------- 
