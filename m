Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:49128 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282AbbJKNP3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Oct 2015 09:15:29 -0400
Date: Sun, 11 Oct 2015 15:15:27 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, Christoph Hellwig <hch@lst.de>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] nfsd: serialize layout stateid morphing operations
Message-ID: <20151011131527.GA4007@lst.de>
References: <1442491104-30080-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1442491104-30080-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 17, 2015 at 07:58:24AM -0400, Jeff Layton wrote:
> In order to allow the client to make a sane determination of what
> happened with racing LAYOUTGET/LAYOUTRETURN/CB_LAYOUTRECALL calls, we
> must ensure that the seqids return accurately represent the order of
> operations. The simplest way to do that is to ensure that operations on
> a single stateid are serialized.
> 
> This patch adds a mutex to the layout stateid, and locks it when
> checking the layout stateid's seqid. The mutex is held over the entire
> operation and released after the seqid is bumped.
> 
> Note that in the case of CB_LAYOUTRECALL we must move the increment of
> the seqid and setting into a new cb "prepare" operation. The lease
> infrastructure will call the lm_break callback with a spinlock held, so
> and we can't take the mutex in that codepath.

I can't say I like the long running mutex all that much.  What kinds
of reproducers do you have where the current behavior causes problems?
