Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41034 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755051AbaJGSCu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Oct 2014 14:02:50 -0400
Date: Tue, 7 Oct 2014 11:02:50 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Thomas Haynes <thomas.haynes@primarydata.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Tom Haynes <loghyr@primarydata.com>
Subject: Re: [PATCH] pnfs: Do not schedule layout segment work if there is no
 work to be done.
Message-ID: <20141007180250.GA623@infradead.org>
References: <1412704787-46388-1-git-send-email-Thomas.Haynes@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1412704787-46388-1-git-send-email-Thomas.Haynes@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 07, 2014 at 10:59:47AM -0700, Thomas Haynes wrote:
> From: Tom Haynes <loghyr@primarydata.com>
> 
> Callers of pnfs_put_lseg_async() might encounter no writes to
> be committed, etc. As such, do not attempt to add work if none
> is needed. Also, don't oops if that is the case.

I think that last issue is the main culprit, isn't it? :)

I still think adding the NULL check to filelayout_clear_request_commit
would be more reasonable, as it's clear that freeme can be NULL there,
but as pnfs_put_lseg accepts a NULL lseg it's probably wise to keep
the two in sync.
