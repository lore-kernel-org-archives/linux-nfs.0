Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34524 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435AbcFOPOX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 11:14:23 -0400
Date: Wed, 15 Jun 2016 08:14:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "xfs@oss.sgi.com" <xfs@oss.sgi.com>
Subject: Re: [PATCH 10/12] NFS: Do not serialise O_DIRECT reads and writes
Message-ID: <20160615151422.GA28557@infradead.org>
References: <1465931115-30784-7-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-8-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-9-git-send-email-trond.myklebust@primarydata.com>
 <1465931115-30784-10-git-send-email-trond.myklebust@primarydata.com>
 <20160615071343.GC4318@infradead.org>
 <755A2A14-C6A9-4737-8335-0A6785490F6D@primarydata.com>
 <20160615144801.GB18524@infradead.org>
 <C13D01C1-4B83-442A-A0EA-D7624BE8A782@primarydata.com>
 <20160615145638.GC5297@infradead.org>
 <02DCF6B5-AFDF-4E33-A8F2-DBFE67A87E91@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <02DCF6B5-AFDF-4E33-A8F2-DBFE67A87E91@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 15, 2016 at 03:09:23PM +0000, Trond Myklebust wrote:
> As I said earlier, the problem with that is you end up artificially serialising buffered reads and buffered writes.

If you actually want to be Posix compiant you need to serialize buffered
reads against buffererd writes - it's just that most Linux file systems
happen to get this wrong.

> ??? The reads only need a shared lock in order to protect the I/O mode from flipping to O_DIRECT (and relying on page locks to protect against buffered writes).

Which strictly speaking is not enough, although as said above most
Linux filesystems get this wrong.  If you indeed want to keep that
(incorrect) behavior you need another lock.  It's defintively not
"simpler", though.
