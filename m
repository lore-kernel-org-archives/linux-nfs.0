Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:51215 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaFBSsa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 14:48:30 -0400
Received: by mail-qa0-f50.google.com with SMTP id j15so3357896qaq.9
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jun 2014 11:48:30 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 2 Jun 2014 14:48:26 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 9/9] NFSd: protect delegation setup with the i_lock
Message-ID: <20140602144826.627a06f4@tlielax.poochiereds.net>
In-Reply-To: <20140602182026.GA27238@infradead.org>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
	<1401455373-18207-10-git-send-email-jlayton@primarydata.com>
	<20140602084616.GA2910@infradead.org>
	<20140602101733.651cd9c8@tlielax.poochiereds.net>
	<20140602182026.GA27238@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2 Jun 2014 11:20:26 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Jun 02, 2014 at 10:17:33AM -0400, Jeff Layton wrote:
> > Ok, fair enough. A later patch in the series adds a per nfs4_file lock
> > (the fi_lock) that we can use for this purpose in lieu of the i_lock.
> > Nesting that within the i_lock shouldn't be too painful.
> 
> i_lock is part of some very complex locking hierachies in the inode
> and dentry caches.  Long term I'd prefer to get the file locking code
> detangled from that, but let's keep it simple for now and nest
> the nfs4_file lock inside for now.
> 
> > We could do that within the rpc_call_prepare operation, but the main
> > problem there is that the delegation could leak if the rpc task
> > allocation fails. Would you be amenable to adding a "cb_prepare"
> > operation or something that we could use to run things from the
> > workqueue before the actual callback runs?
> 
> I guess we'll have to do it then.  I'll see if it can be done nicely.
> 

There is another option, but it's sort of ugly...

We could try to queue the thing in the rpc_call_prepare op, but if that
fails to occur then we could do it in the rpc_release callback. The
tricky part is figuring out whether we'll need to queue it in
rpc_release.

Perhaps we can try to use the dl_time field to indicate that as well so
we won't need to add a separate flag for it.

> I suspect the root problem of all this is that the file locking code
> calls the lock manager ops with i_lock held, which isn't very nice.
> 

Yeah, it would be nice if it didn't, but it's better than it was. It
used to use a global spinlock for that instead of the i_lock, but that
was also a clear scalability problem...

-- 
Jeff Layton <jlayton@primarydata.com>
