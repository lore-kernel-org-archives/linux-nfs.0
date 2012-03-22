Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38017 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752784Ab2CVVJy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Mar 2012 17:09:54 -0400
Date: Thu, 22 Mar 2012 17:09:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Change the default setting of the
 nfs4_disable_idmapping parameter
Message-ID: <20120322210953.GC23737@fieldses.org>
References: <1326138354-8138-1-git-send-email-Trond.Myklebust@netapp.com>
 <20120322204705.GA23737@fieldses.org>
 <1332449607.8976.9.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1332449607.8976.9.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 22, 2012 at 08:53:25PM +0000, Myklebust, Trond wrote:
> On Thu, 2012-03-22 at 16:47 -0400, J. Bruce Fields wrote:
> > By the way, I finally got around to looking at the server side.
> > 
> > We don't have any way to negotiate with the client--we don't get an
> > error back if the name we return in a getattr reply isn't one the client
> > likes--so I don't think I can default the new behavior to "on" without
> > breaking existing setups.
> > 
> > Other than that I think I'll just copy the client, module parameter and
> > all.  That allows us to do the numeric case in-kernel and avoid
> > polluting our mapping cache with lots of "obvious" 123<->"123" mappings.
> > 
> > (OK, maybe I shouldn't copy the same parameter name, though--even if it
> > works it might be confusing.)
> 
> Does the idmapper do the right thing for numeric ids these days? If the
> older clients are running a newer idmapper that can deal with numeric
> ids, then even the legacy clients should be able to work cleanly.

If at all possible I really don't want to break clients, even if they
have an easy fix.  (Or maybe I wasn't understanding what you were
suggesting.)

> Otherwise, there is also the alternative of making the whole thing a
> per-client export option...

Hm, maybe that'd be better.

We're currently mapping names to id's when we decode the xdr--before
we've looked up the export--but that's fixable.

--b.
