Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:39821 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932334AbaFBORh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 10:17:37 -0400
Received: by mail-qa0-f48.google.com with SMTP id i13so2740824qae.21
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jun 2014 07:17:36 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 2 Jun 2014 10:17:33 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, trond.myklebust@primarydata.com,
        bhalevy@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 9/9] NFSd: protect delegation setup with the i_lock
Message-ID: <20140602101733.651cd9c8@tlielax.poochiereds.net>
In-Reply-To: <20140602084616.GA2910@infradead.org>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
	<1401455373-18207-10-git-send-email-jlayton@primarydata.com>
	<20140602084616.GA2910@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2 Jun 2014 01:46:16 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Fri, May 30, 2014 at 09:09:33AM -0400, Jeff Layton wrote:
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > state_lock is a heavily contended global lock. We don't want to grab
> > that while simultaneously holding the inode->i_lock. Avoid doing that in
> > the delegation break callback by ensuring that we add/remove the
> > dl_perfile under the inode->i_lock.
> 
> The current code never takes the state lock (or recall lock) under
> i_lock.  Non-trivial use of i_lock in nfsd is only added in this patch.
> 
> > 
> > This however, can cause an ABBA deadlock between the state_lock and the
> > i_lock. Work around that by doing the list manipulation in the delegation
> > recall from the workqueue context prior to starting the rpc call.
> 
> I very much dislike the patch for multiple reasons.  For one thing
> nfsd currently stays away from i_lock which is a VFS (and sometimes
> abused by the fs) lock except for a single case in the file locking code
> which really should be factored into common code.  I'd rather have
> locks in nfsd than starting to use i_lock in nfsd and making auditing
> it's use and it's lock hierchies more complex by introducing usage
> outside of the VFS.
> 

Ok, fair enough. A later patch in the series adds a per nfs4_file lock
(the fi_lock) that we can use for this purpose in lieu of the i_lock.
Nesting that within the i_lock shouldn't be too painful.

> Second I really don't like pushing the delegation setup into the
> callback workqueue.  I have a patchset refactoring the callback code
> to allow adding more callbacks without lots of copy & paste, and except
> for this new addition the code in the workqueue already is almost
> perfectly generic for arbitrary callbacks.
> 
> Please add a lock in struct nfs4_file to protects it's own members
> instead.
> 

This is a problem however. The del_recall_lru list is a per-namespace
list, so we need a lock that is either global or per-namespace to add
things onto it. The point of this patch is to get that extra locking
out of the codepath where the i_lock is already held.

We could do that within the rpc_call_prepare operation, but the main
problem there is that the delegation could leak if the rpc task
allocation fails. Would you be amenable to adding a "cb_prepare"
operation or something that we could use to run things from the
workqueue before the actual callback runs?

-- 
Jeff Layton <jlayton@primarydata.com>
