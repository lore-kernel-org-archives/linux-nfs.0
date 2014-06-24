Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f66.google.com ([209.85.216.66]:61144 "EHLO
	mail-qa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbaFXMXw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2014 08:23:52 -0400
Received: by mail-qa0-f66.google.com with SMTP id m5so55833qaj.9
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jun 2014 05:23:51 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 24 Jun 2014 08:23:51 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 104/104] nfsd: add file documenting new state object
 model
Message-ID: <20140624082351.595aab59@f20.localdomain>
In-Reply-To: <20140624121158.GB11055@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<1403189450-18729-105-git-send-email-jlayton@primarydata.com>
	<20140624121158.GB11055@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Jun 2014 05:11:58 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > +KNFSD4 State Object Model:
> > +==========================
> > +Written 2014 by Jeff Layton <jlayton@primarydata.com>
> > +
> > +Introduction:
> > +-------------
> > +Until recently, knfsd relied heavily on a global mutex to ensure that objects
> > +didn't disappear while they were being operated on. That has proven to be a
> > +scalability bottleneck however, so the code has been overhauled to make heavy
> > +use of reference counting and spinlocks for tracking the different objects.
> 
> It's hard enough to keep documents uptodate with the current version of
> the code, so I don't think this historical blurb buys us anything.
> 

OK

> > +struct nfs4_client:
> > +-------------------
> > +The initial object created by an NFS client using SETCLIENTID (for NFSv4.0) or
> > +EXCHANGE_ID (for NFSv4.1+). These objects are refcounted and timestamped. Each
> > +nfsd_net_ns object contains a set of these and they are tracked via short and
> > +long form clientid. They are hashed and searched for under the per-nfsd-net
> > +client_lock spinlock.
> > +
> > +The lifecycle of these is a little strange. References to it are only held
> > +during the processing of compounds, and in certain other operations. In their
> > +"resting state" they have a refcount of 0. If they are not renewed within a
> > +lease period, they become eligible for destruction by the laundromat.
> 
> That's the normal lifecycle of objects on a lru, so I'd strike the
> "strange" part.
> 

Fair enough.

> > +strict nfs4_stid:
> > +-----------------
> > +A core object that represents a "generic" stateid. These are generally embedded
> > +within the different (more specific) stateid objects and contain fields that
> > +are of general use to any stateid.
> 
> Maybe replace "generic" stateid with common stateid or similar?  The
> generic_stateid term is unfortunately is used in the code in a weird way
> for open/lock stateids.  Or better yet fix up those names in the code..
> 

Yeah, I didn't make that change here as we have enough "churn" going
on, but maybe it's a good idea to just do it. "generic" really ought to
refer to nfs4_stid, and we should rename the nfs4_ol_stateid to
something besides "generic".

> 
> Given how documentation outside the source code gets out of data
> easily maybe you should move these texts to comments above each of the
> structures?

Yeah, probably so. This document started for my own benefit as I was
going through the code and documenting things. We can drop it if it's
not helpful but I figured I'd toss it on top of the pile in case it was.
-- 
Jeff Layton <jlayton@primarydata.com>
