Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:42135 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbaFGOeL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:34:11 -0400
Received: by mail-qa0-f41.google.com with SMTP id dc16so5974993qab.0
        for <linux-nfs@vger.kernel.org>; Sat, 07 Jun 2014 07:34:10 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sat, 7 Jun 2014 10:34:08 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com
Subject: Re: [PATCH v2 2/2] nfsd: avoid taking the state_lock while holding
 the i_lock
Message-ID: <20140607103408.6e6629c9@tlielax.poochiereds.net>
In-Reply-To: <20140607143133.GA5072@infradead.org>
References: <1402060026-26511-1-git-send-email-jlayton@primarydata.com>
	<1402060026-26511-3-git-send-email-jlayton@primarydata.com>
	<20140607140904.GB18140@infradead.org>
	<20140607102826.59a4af24@tlielax.poochiereds.net>
	<20140607143133.GA5072@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 7 Jun 2014 07:31:33 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Sat, Jun 07, 2014 at 10:28:26AM -0400, Jeff Layton wrote:
> > Well, I think using the fp->fi_lock instead of the i_lock here is
> > reasonable. We at least avoid taking the state_lock (which is likely to
> > be much more contended) within the i_lock.
> 
> Yes, avoiding i_lock usage inside nfsd is something I'd prefer.  But
> with the current lock manager ops that are called with i_lock held
> we'll have some leakage into the nfsd lock hierachy anyway
> unfortunately.
> 

Yeah. Switching the file locking infrastructure over to the i_lock
seemed like such a good idea at the time...

> > The thing that makes this
> > patch nasty is all of the shenanigans to queue the delegation to the
> > global list from within rpc_prepare or rpc_release.
> > 
> > Personally, I think it'd be cleaner to add some sort of cb_prepare
> > operation to the generic callback framework you're building to
> > handle that, but let me know what you thing.
> 
> I guess I'll have to do it that way then.  It's not like so far
> unreleased code should be a hard blocker for a bug fix anyway.
> 
> Care to prefer a version that uses fi_lock, but otherwise works like
> the first version?
> 

Nope, that'd be fine. It might take a few days to respin as I'll be at
the bakeathon next week.

-- 
Jeff Layton <jlayton@primarydata.com>
