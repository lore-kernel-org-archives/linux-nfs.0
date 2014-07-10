Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51883 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025AbaGJLXn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 07:23:43 -0400
Date: Thu, 10 Jul 2014 04:23:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 003/100] nfsd: Ensure stateids remain unique until
 they are freed
Message-ID: <20140710112342.GB10893@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-4-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404842668-22521-4-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 08, 2014 at 02:02:51PM -0400, Jeff Layton wrote:
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Add an extra delegation state to allow the stateid to remain in the idr
> tree until the last reference has been released. This will be necessary
> to ensure uniqueness once the client_mutex is removed.
> 
> [jlayton: reset the sc_type under the state_lock in unhash_delegation]

I'd be tempted to instead have a closed flag, there's plenty of space in
the hole after sc_type anyway.

The rationale for that is that a stateid really shouldn't change the
type during it's life time, and callers that specify the type to look
up shouldn't bother with looking up different types due to this either.

NFS4_REVOKED_DELEG_STID would also be replaced by a revoked flag, which
makes much more sene to start with as well.

Btw, do you also plan to keep open stateids as NFS4_CLOSED_STID for
4.1+?  In that case the comment there would need an update.  What about
lock stateids?

