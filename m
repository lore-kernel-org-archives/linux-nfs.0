Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:51963 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369AbcFWKT5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2016 06:19:57 -0400
Date: Thu, 23 Jun 2016 03:19:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 11/12] NFS: Remove inode->i_dio_count from the NFS
 O_DIRECT code
Message-ID: <20160623101956.GA2744@infradead.org>
References: <1466544893-12058-4-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-5-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-6-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-7-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-8-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-9-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-10-git-send-email-trond.myklebust@primarydata.com>
 <1466544893-12058-11-git-send-email-trond.myklebust@primarydata.com>
 <20160622164240.GA9176@infradead.org>
 <07829F3C-FCAA-42C0-8AFA-173370A55BDE@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <07829F3C-FCAA-42C0-8AFA-173370A55BDE@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 22, 2016 at 04:58:05PM +0000, Trond Myklebust wrote:
> > For the AIO case that's not true, we can't hold i_rwsem until
> > aio completes.  So for something that does block allocations we'll
> > need something like i_dio_count still.  This probably includes the
> > block / scsi layout code.
> 
> Why can?t we hold the i_rwsem until aio completes?

Because Linux rw_semaphores require have owner semantics, and require
the owner that acquired them to release them again.  If we have
an AIO request we're not going to complete the request in the calling
context, though.

The same is true for regular mutexes, that's why we drop the inode lock
at the end of nfs_file_direct_read/write even if I/O might still be
pending.
