Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:55082 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932370AbcFOO4j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 10:56:39 -0400
Date: Wed, 15 Jun 2016 07:56:38 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "xfs@oss.sgi.com" <xfs@oss.sgi.com>
Subject: Re: [PATCH 10/12] NFS: Do not serialise O_DIRECT reads and writes
Message-ID: <20160615145638.GC5297@infradead.org>
References: <1465931115-30784-5-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-6-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
 <20160615071343.GC4318@infradead.org>
 <755A2A14-C6A9-4737-8335-0A6785490F6D@primarydata.com>
 <20160615144801.GB18524@infradead.org>
 <C13D01C1-4B83-442A-A0EA-D7624BE8A782@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <C13D01C1-4B83-442A-A0EA-D7624BE8A782@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 15, 2016 at 02:52:24PM +0000, Trond Myklebust wrote:
> >But XFS allows full parallelism for direct reads and writes as long
> >as there is no more pagecache to flush.  But if you have pages in
> >the pagecache you need the exclusive lock to prevent against new
> >pagecache pages being added.
> 
> Exactly. So does this.

So let's avoid bloating the inode with another rw_semaphore, and make
everyones life easier by using the existing lock.

> We don???t use generic_file_* for O_DIRECT; we only use it for buffered I/O.

I know - this was just an answer to your reference to the generic_file_*
code.
