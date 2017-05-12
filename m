Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36854 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754683AbdELWEf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 May 2017 18:04:35 -0400
Date: Fri, 12 May 2017 18:04:34 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: hch <hch@lst.de>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: remove function pointer casts and constify function tables
Message-ID: <20170512220434.GB9317@fieldses.org>
References: <20170512161701.22468-1-hch@lst.de>
 <1494620040.19467.1.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1494620040.19467.1.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 12, 2017 at 08:14:03PM +0000, Trond Myklebust wrote:
> On Fri, 2017-05-12 at 18:16 +0200, Christoph Hellwig wrote:
> > This series was inspired by two recent events:  talking to a academic
> > researcher about the harm of function pointer casts for static
> > analysis
> > at a conference, and reading up the whole Grsecurity drama, including
> > finding that their patchset does a lot of work to remove these casts
> > in sunrpc and nfs (and in fact those seem the biggest culprit in the
> > kernel), and constifying the operation vectors like so many others in
> > the kernel, although done in a rather hacky and/or mechnical way.
> > 
> > Note that the first part of the series is about the RPC forechannel,
> > and the latter about the backchannel, but due to bidirection
> > operation
> > in NFSv4 there is no really clean split between the client and server
> > parts.
> > 
> > Changes from RFC:
> >  - move procedure call counters into separate arrays
> > 
> 
> How should we proceed to merge this series? Given that it is changing a
> lot of function headers, but not actually changing functionality, might
> it be possible to merge it out-of-band with the merge window (e.g. next
> week) in order to minimise the amount of work needed to fix up future
> patches?

That'd be OK.  Or we could commit to a common tree and build on that.

Also, whatever we do with the rest, the following appear to be
completely independent and touch nothing outside fs/nfsd, I could take
them:

	[PATCH 26/33] nfsd4: properly type op_set_currentstateid callbacks
	[PATCH 27/33] nfsd4: properly type op_get_currentstateid callbacks
	[PATCH 28/33] nfsd4: remove nfsd4op_rsize
	[PATCH 29/33] nfsd4: properly type op_func callbacks
	[PATCH 33/33] nfsd4: const-ify nfsd4_ops

--b.


