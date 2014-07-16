Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53070 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531AbaGPSK5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 14:10:57 -0400
Date: Wed, 16 Jul 2014 11:10:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 08/10] nfsd: Simplify stateid management
Message-ID: <20140716181056.GB6920@infradead.org>
References: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
 <1405521125-2303-9-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405521125-2303-9-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 16, 2014 at 10:32:03AM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Don't allow stateids to clear the open file pointer until they are
> being destroyed. Also, move to kzalloc and get rid of explicit
> zeroing of fields.

This doesn't explain what's actually simplified as the subject line
claims, nor does it explain why this move is safe.  It generally
looks good to me, but a little more explanation wouldn't hurt.

