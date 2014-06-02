Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35073 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929AbaFBSU1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 14:20:27 -0400
Date: Mon, 2 Jun 2014 11:20:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: bfields@fieldses.org, trond.myklebust@primarydata.com,
        bhalevy@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 9/9] NFSd: protect delegation setup with the i_lock
Message-ID: <20140602182026.GA27238@infradead.org>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
 <1401455373-18207-10-git-send-email-jlayton@primarydata.com>
 <20140602084616.GA2910@infradead.org>
 <20140602101733.651cd9c8@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140602101733.651cd9c8@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 02, 2014 at 10:17:33AM -0400, Jeff Layton wrote:
> Ok, fair enough. A later patch in the series adds a per nfs4_file lock
> (the fi_lock) that we can use for this purpose in lieu of the i_lock.
> Nesting that within the i_lock shouldn't be too painful.

i_lock is part of some very complex locking hierachies in the inode
and dentry caches.  Long term I'd prefer to get the file locking code
detangled from that, but let's keep it simple for now and nest
the nfs4_file lock inside for now.

> We could do that within the rpc_call_prepare operation, but the main
> problem there is that the delegation could leak if the rpc task
> allocation fails. Would you be amenable to adding a "cb_prepare"
> operation or something that we could use to run things from the
> workqueue before the actual callback runs?

I guess we'll have to do it then.  I'll see if it can be done nicely.

I suspect the root problem of all this is that the file locking code
calls the lock manager ops with i_lock held, which isn't very nice.

