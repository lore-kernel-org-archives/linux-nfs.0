Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57748 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755813AbcGFUbH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jul 2016 16:31:07 -0400
Date: Wed, 6 Jul 2016 16:30:55 -0400
From: Fields Bruce <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 09/10] SUNRPC: Change TCP socket space reservation
Message-ID: <20160706203055.GH18856@fieldses.org>
References: <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-5-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-6-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-7-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-8-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-9-git-send-email-trond.myklebust@primarydata.com>
 <20160706195308.GF18856@fieldses.org>
 <3774A9EF-883F-45E2-B93E-26B178FF499D@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <3774A9EF-883F-45E2-B93E-26B178FF499D@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 06, 2016 at 08:11:53PM +0000, Trond Myklebust wrote:
> 
> > On Jul 6, 2016, at 15:53, J. Bruce Fields <bfields@fieldses.org>
> > wrote:
> > 
> > On Fri, Jun 24, 2016 at 10:55:51AM -0400, Trond Myklebust wrote:
> >> Instead of trying (and failing) to predict how much writeable
> >> socket space will be available to the RPC call, just fall back to
> >> the simple model of deferring processing until the socket is
> >> uncongested.
> >> 
> >> If a limit is neeeded, then set the hard per-connection limit.
> > 
> > I was hoping this would be an opportunity to get rid of even more
> > code, but there's still the udp case.  Do we actually need that?
> > 
> 
> I wasn’t really too concerned about UDP; I consider it to be legacy
> code.

Sure, but by the same token maybe it's not worth carrying the extra code
for a udp-only optimization; quick untested diff looks like:

 fs/nfsd/nfs3proc.c              |  1 -
 fs/nfsd/nfs4state.c             |  1 -
 fs/nfsd/nfs4xdr.c               |  1 -
 fs/nfsd/nfsproc.c               |  1 -
 include/linux/sunrpc/svc.h      | 16 ----------------
 include/linux/sunrpc/svc_xprt.h |  1 -
 net/sunrpc/svc.c                |  6 ------
 net/sunrpc/svc_xprt.c           | 37 -------------------------------------
 net/sunrpc/svcsock.c            | 13 +------------
 9 files changed, 1 insertion(+), 76 deletions(-)

> That said, I’d argue the existing system make a little more sense in
> the case of UDP as you don’t have any equivalent of the TCP window
> size. That means the socket buffer sizes are predictable, and so are
> more easily modelled as a pipeline.

OK, could be.

--b.
