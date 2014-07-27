Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58464 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbaG0N2B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 09:28:01 -0400
Date: Sun, 27 Jul 2014 06:28:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 05/40] nfsd: Ensure atomicity of stateid destruction and
 idr tree removal
Message-ID: <20140727132800.GG32153@infradead.org>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
 <1405954972-28904-6-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405954972-28904-6-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 21, 2014 at 11:02:17AM -0400, Jeff Layton wrote:
> Preparation for removal of the client_mutex. Ensure that they are done
> while holding the clp->cl_lock.
> 
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

Looks good, although the orderig vs the earlier patches looks odd
to me.  I'd introduce the nfs4_put_stid before the locking for the
stateid idr, which would then naturally fall into place with the
right atomicity.

Independent of that: is there any point in keeping the separate
remove_stid_locked helper instead of inlining it into the caller?

Reviewed-by: Christoph Hellwig <hch@lst.de>
