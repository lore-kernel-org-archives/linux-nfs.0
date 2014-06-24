Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:63730 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574AbaFXMAd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2014 08:00:33 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so149671qcv.10
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jun 2014 05:00:32 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 24 Jun 2014 08:00:31 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 012/104] NFSd: Clean up helper __release_lock_stateid
Message-ID: <20140624080031.2c3de85d@tlielax.poochiereds.net>
In-Reply-To: <20140624115336.GB31935@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<1403189450-18729-13-git-send-email-jlayton@primarydata.com>
	<20140624115336.GB31935@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Jun 2014 04:53:36 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jun 19, 2014 at 10:49:18AM -0400, Jeff Layton wrote:
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > Use filp_close() instead of open coding
> 
> filp_close does more than what's currently opencoded here:
> 
>  - file_count debug check which seems pointless but harmless
>  - calling ->flush. This doesn't do much on nfs exportable filesystem
>    except for exofs, which does dumb shit in it that should be removed,
>    but the maintainer refuse.
>  - call into dnotify, which we probably should be doing here.
> 

Yeah. It is a small change in behavior but seems like the right thing
to do. I'll flesh out the commit message to spell that out though.

> > -static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
> > +static void __release_lock_stateid(struct nfs4_lockowner *lo,
> > +		struct nfs4_ol_stateid *stp)
> 
> But what's the point of explicitly passing the lock owner instead of
> deriving it?
> 

I thought that was a little silly too, but didn't care enough to change
it. I can only assume that Trond figured that the callers all needed to
know what the lockowner was so you wouldn't need to do two lockowner()
calls. Still, those are just container_of(), so I don't see the point
in avoiding them either. I'll change it not to pass the owner.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
