Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38259 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbcFOOlv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 10:41:51 -0400
Date: Wed, 15 Jun 2016 07:41:50 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 11/12] NFS: Don't count O_DIRECT reads in the
 inode->i_dio_count
Message-ID: <20160615144150.GA18524@infradead.org>
References: <1465931115-30784-4-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-11-git-send-email-trond.myklebust@primarydata.com>
 <20160615071605.GD4318@infradead.org>
 <C9DCA08F-F8FE-41FD-978B-8B1CAF3DEB17@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <C9DCA08F-F8FE-41FD-978B-8B1CAF3DEB17@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 15, 2016 at 02:36:04PM +0000, Trond Myklebust wrote:
> On 6/15/16, 03:16, "Christoph Hellwig" <hch@infradead.org> wrote:
> 
> >Explanation of why reads are more special than writes here or in
> >general why they are safe?
> >
> 
> With the new locking, we already have exclusion between buffered I/O and direct I/O, and so the only remaining use case for inode_dio_wait() is to wait for writes to complete in operations like fsync().

There is no need to wait for pending dio in fsync - fsync is only
guarantee to flush out I/O that's alreayd been completed.

inode_dio_wait and friends were introduces to protect aio that doesn't
hold i_mutex against truncate.
