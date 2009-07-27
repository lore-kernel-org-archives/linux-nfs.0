Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:51489 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752728AbZG0RBJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2009 13:01:09 -0400
Date: Mon, 27 Jul 2009 10:01:06 -0700
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Slower performance with lookupcache (2.6.30.2)
Message-ID: <20090727170106.GA9330@hostway.ca>
References: <20090724231300.GA572@hostway.ca> <1248540703.6139.106.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1248540703.6139.106.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jul 25, 2009 at 12:51:43PM -0400, Trond Myklebust wrote:

> On Fri, 2009-07-24 at 16:13 -0700, Simon Kirby wrote:
> > The lookupcache here seems to be increasing initial performance but then
> > seems to slow down cached performance by causing more getattrs than with
> > no lookupcache, perhaps for revalidation tests.
> 
> Yes. This is expected behaviour.
> 
> When you look up a dentry, you are also retrieving its attributes, so
> the stat() call, can be entirely handled by the single LOOKUP rpc call.
> 
> If you are caching the dentries, then your stat() call doesn't need to
> do a lookup, but it still needs to return valid attributes. Since
> acregmin=3 seconds, then your test is likely to have to revalidate a
> couple of times. However as long as there are no changes to the file,
> then the attribute caching algorithm should get progressively more
> aggressive. I'd therefore expect that if you change that to 'repeat 10'
> or so, then the lookupcache=all/positive cases should show an
> improvement.

Ahh, yes, I see, there is.  If I run it longer, I see that it gets even
faster (0.6 seconds) for the forth run and then after a few more, back
up to 4 seconds once.  That makes sense now.

You say that LOOKUP is returning the attributes as well -- is it not
possible to operate the same way doing revalidation?  I was surprised
that there are so many fewer RPC calls during the first run (8622 calls
versus 25076 calls).  But, I suppose it's just readdirplus batching some
information together in a single call (since there are 23,650 files and
directories in the tree), and we probably wouldn't want to readdir all
the time.

Cheers,

Simon-
