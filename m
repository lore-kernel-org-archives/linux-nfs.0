From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] xprtrdma: fix XDR tail buf marshalling for all ops
Date: Thu, 06 Dec 2007 02:23:36 -0500
Message-ID: <1196925817.7663.1.camel@heimdal.trondhjem.org>
References: <Pine.LNX.4.64.0711291521010.7142@jlentini-linux.nane.netapp.com>
	 <1196902607.17724.2.camel@heimdal.trondhjem.org>
	 <1196916625.25528.43.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain
Cc: James Lentini <jlentini@netapp.com>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:41901 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752329AbXLFHZl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2007 02:25:41 -0500
In-Reply-To: <1196916625.25528.43.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2007-12-05 at 22:50 -0600, Tom Tucker wrote:
> xdr->len is 0

Mind explaining where we're missing a call to xdr_adjust_iovec?

> > Alternatively, just a single line fix should fix the bug AFAICS:
> > -		pos += len;
> > +		pos += xdrbuf->page_len
> 
> xdr->len notwithstanding, for the purpose of this code, the pos
> manipulation isn't necessary because the condition being checked (no
> tail) can be trivially determined just by looking at tail[0].iov_len.

I know that, but we're in an -rc4 release.

Trond

