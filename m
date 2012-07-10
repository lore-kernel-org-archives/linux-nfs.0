Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48214 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754554Ab2GJWiV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 18:38:21 -0400
Date: Tue, 10 Jul 2012 18:38:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Simo Sorce <simo@redhat.com>, "bfields@redhat.com" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] Add support for new RPCSEC_GSS upcall mechanism
 for nfsd
Message-ID: <20120710223818.GA6720@fieldses.org>
References: <1337983796-26476-1-git-send-email-simo@redhat.com>
 <20120710204913.GA6038@fieldses.org>
 <1341957169.17428.4.camel@lade.trondhjem.org>
 <20120710215618.GC6038@fieldses.org>
 <1341958332.17428.12.camel@lade.trondhjem.org>
 <1341959112.17428.19.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1341959112.17428.19.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 10, 2012 at 10:25:13PM +0000, Myklebust, Trond wrote:
> On Tue, 2012-07-10 at 18:12 -0400, Trond Myklebust wrote:
> > Then why is it being labelled as a knfsd-only change?

It should be labeled an rpc server change.

> > How will it behave if I don't run gss proxy?

It will work, but if the server's running on the same machine it will
also use svcgssd, and hence won't (for example) be able to handle the
larger init_sec_context packets.

> ...and how will it behave in a net namespace?

It will need the same fixes as we need for rpcbind.

I'm sure we could allow the callback server and the nfs server to use
different authentication upcalls.  But that makes this not worth it.

We should be able to share the same use the same mechanism on all rpc
servers, so if a mechanism based on gssproxy calls isn't acceptable for
the nfs callback server then I'll drop it.

--b.
