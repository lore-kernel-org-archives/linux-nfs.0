Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52829 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932370AbcFOOy4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 10:54:56 -0400
Date: Wed, 15 Jun 2016 07:54:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 06/12] NFS: Don't hold the inode lock across fsync()
Message-ID: <20160615145456.GB5297@infradead.org>
References: <1465931115-30784-1-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-2-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-3-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <20160615070840.GA4318@infradead.org>
 <D6D08D10-6752-4A7A-9CFE-3227D9A58BA2@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D6D08D10-6752-4A7A-9CFE-3227D9A58BA2@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 15, 2016 at 02:47:55PM +0000, Trond Myklebust wrote:
> >But we need something to lock out new callers of inode_dio_end
> >when calling inode_dio_wait.  Then again the current code already
> >fails to to do that..
> 
> We could do that by setting the I/O mode to buffered; that still allows
> parallelism  for the buffered I/O case. I wouldn???t normally expect
> applications that use O_DIRECT on NFS to call fsync(), since we always enforce O_DIRECT|O_SYNC semantics.

Maybe not applications specificly written for NFS.  But if you're using
for example qemu on O_DIRECT without O_SYNC and lots of fdatasync calls
will be the default behavior.

Anyway, as per the other thread we might be able to get rid of the
inode_dio_wait call entirely.
