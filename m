From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Should truncated READDIR replies return -EIO?
Date: Fri, 8 Feb 2008 11:51:32 -0500
Message-ID: <20080208115132.3631c6b4@tleilax.poochiereds.net>
References: <1202483082-5334-1-git-send-email-jlayton@redhat.com>
	<1202483596.8914.13.camel@heimdal.trondhjem.org>
	<20080208105659.3bfb8a6b@tleilax.poochiereds.net>
	<1202487187.10337.25.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762666AbYBHQvr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 11:51:47 -0500
In-Reply-To: <1202487187.10337.25.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 08 Feb 2008 11:13:07 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Fri, 2008-02-08 at 10:56 -0500, Jeff Layton wrote:
> 
> > If it looks like the above, but EOF is 0, then we *do* "goto
> > short_pkt", and that case would be affected by this. But in that case
> > we currently reset EOF to 1. The client won't retry the request. I'm
> > not sure that's what we want to do either...
> 
> That is to deal with the afore-mentioned broken server. I'm not
> unwilling to change this (I _hate_ client side fixes for server bugs),
> but it's important to note that there may be consequences if we do.
> 

Hmm, tough call...

I don't know that the current behavior is actually causing any
problems, per se. If changing it is likely to do so, then maybe leaving
this as it is the best thing, at least for lower NFS versions.

Maybe we should consider changing this behavior for NFSv4? It might be
good not to carry these sort of kludges forward into later revs. Was
this buggy nfs server a v4 server as well?

-- 
Jeff Layton <jlayton@redhat.com>
