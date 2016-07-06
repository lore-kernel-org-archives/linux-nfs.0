Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57736 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666AbcGFURt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jul 2016 16:17:49 -0400
Date: Wed, 6 Jul 2016 16:17:48 -0400
From: Fields Bruce <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 09/10] SUNRPC: Change TCP socket space reservation
Message-ID: <20160706201748.GG18856@fieldses.org>
References: <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-5-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-6-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-7-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-8-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-9-git-send-email-trond.myklebust@primarydata.com>
 <20160624211808.GL3287@fieldses.org>
 <A6F54110-7D15-4545-B15B-D058EAB358F0@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <A6F54110-7D15-4545-B15B-D058EAB358F0@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 24, 2016 at 09:31:07PM +0000, Trond Myklebust wrote:
> 
> > On Jun 24, 2016, at 17:18, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Fri, Jun 24, 2016 at 10:55:51AM -0400, Trond Myklebust wrote:
> >> Instead of trying (and failing) to predict how much writeable socket space
> >> will be available to the RPC call, just fall back to the simple model of
> >> deferring processing until the socket is uncongested.
> > 
> > OK, it would be a relief to get rid of that, I guess that explains the
> > previous patch.
> > 
> > But was there some specific reason you were running into this?
> 
> I’ve been testing using a 40GigE network, which easily hits this bottleneck. The result is that each connection saturates long before we’re even near the saturation of the network or even the disk. So we find ourselves with a server that can continue to scale up to several 100 clients, but with each client seeing the same low performance irrespective of the total number of clients.

OK, I'm stealing some of your responses for a slightly more verbose
changelog (see below), but otherwise committing the patches unchanged
for 4.8.  Thanks!

--b.

    SUNRPC: Change TCP socket space reservation
    
    The current server rpc tcp code attempts to predict how much writeable
    socket space will be available to a given RPC call before accepting it
    for processing.  On a 40GigE network, we've found this throttles
    individual clients long before the network or disk is saturated.  The
    server may handle more clients easily, but the bandwidth of individual
    clients is still artificially limited.
    
    Instead of trying (and failing) to predict how much writeable socket space
    will be available to the RPC call, just fall back to the simple model of
    deferring processing until the socket is uncongested.
    
    This may increase the risk of fast clients starving slower clients; in
    such cases, the previous patch allows setting a hard per-connection
    limit.
