Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:40770 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755471Ab0KUTzc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 14:55:32 -0500
Subject: Re: NFS client/sunrpc getting stuck on 2.6.36
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20101121064301.GB3285@hostway.ca>
References: <20101111023520.GH16939@hostway.ca>
	 <1289452967.4062.10.camel@heimdal.trondhjem.org>
	 <20101119202004.GA3270@hostway.ca>
	 <1290201888.3135.61.camel@heimdal.trondhjem.org>
	 <20101119220356.GB3270@hostway.ca>
	 <1290205039.3135.74.camel@heimdal.trondhjem.org>
	 <20101119225803.GC3270@hostway.ca>
	 <1290208645.3135.88.camel@heimdal.trondhjem.org>
	 <20101121064301.GB3285@hostway.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 21 Nov 2010 14:55:24 -0500
Message-ID: <1290369324.5481.19.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2010-11-20 at 22:43 -0800, Simon Kirby wrote:
> That tcpdump I sent included the ACKs, which all looked normal.
> Unfortunately, we haven't seen the problem again yet.  Is your "Fix an
> infinite loop in call_refresh/call_refreshresult" patch possibly related?

It might help if the cause is an RPCSEC_GSS ticket expiration.

Cheers
  Trond

