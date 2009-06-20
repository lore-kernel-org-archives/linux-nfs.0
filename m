From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/3] SUNRPC: Fix the TCP write space reservations for
 deferred requests
Date: Sat, 20 Jun 2009 17:44:08 -0400
Message-ID: <1245534248.5182.45.camel@heimdal.trondhjem.org>
References: <20090518214756.786.28129.stgit@heimdal.trondhjem.org>
	 <20090518214756.786.33956.stgit@heimdal.trondhjem.org>
	 <20090619222344.GB32083@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Moyer <jmoyer@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44934 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753449AbZFTVoH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Jun 2009 17:44:07 -0400
In-Reply-To: <20090619222344.GB32083@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-06-19 at 18:23 -0400, J. Bruce Fields wrote:
> On Mon, May 18, 2009 at 05:47:56PM -0400, Trond Myklebust wrote:
> > Ensure that deferred requests are accounted for correctly by the write
> > space reservation mechanism. In order to avoid double counting, remove the
> > reservation when we defer the request, and save any calculated value, so
> > that we can restore it when the request is requeued.
> 
> I like that it does the addition to xpt_reserved in just one place
> instead of two, and carrying over the reserved_space is nice, but I
> don't understand the "double accounting" comment--where exactly is
> something counted twice?

Correct me if I'm wrong, but as far as I can see, the current code bumps
xpt_reserved every time you call svc_xprt_enqueue() irrespective of
whether or not you are going to process a new RPC call, or whether you
are processing a deferred call.

In the latter case, there doesn't appear to be any code that subtracts
from xpt_reserved prior to the re-enqueue process, hence my belief that
we are double counting those events...

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
