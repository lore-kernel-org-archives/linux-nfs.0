Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60884 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752285AbdEJSiW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 10 May 2017 14:38:22 -0400
Date: Wed, 10 May 2017 14:38:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>,
        "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/32] sunrpc: fix encoder callback prototypes
Message-ID: <20170510183821.GB10450@fieldses.org>
References: <20170509092010.30752-1-hch@lst.de>
 <20170509092010.30752-3-hch@lst.de>
 <779451235.5133504.1494323029528.JavaMail.zimbra@desy.de>
 <20170509131108.GA15042@lst.de>
 <1494336641.2659.5.camel@redhat.com>
 <20170509141708.GA18466@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170509141708.GA18466@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 09, 2017 at 10:17:08AM -0400, J. Bruce Fields wrote:
> On Tue, May 09, 2017 at 09:30:41AM -0400, Jeff Layton wrote:
> > On Tue, 2017-05-09 at 15:11 +0200, Christoph Hellwig wrote:
> > > On Tue, May 09, 2017 at 11:43:49AM +0200, Mkrtchyan, Tigran wrote:
> > > > just out of curiosity: you are talking about increasing type safety, but
> > > > at the same time replaces arguments to 'const void *data', which will accept
> > > > everything. Is there something special which I don't understand?
> > > 
> > > Nothing special - cast are potentially dangerous in general, and
> > > function pointer cases are especially dangerous as there is no
> > > verify the caller and callee signatures match at all.  As generic
> > > method call patterns need to have private data of some points they
> > > need to have a void pointer somewhere - either in the signature or
> > > as a pointer from a passed structure.  For those the compiler at least
> > > can do some basic sanity checking, and good static analysis tools can
> > > even verify we get the proper object using whole program analysis.
> > 
> > Strong ACK on all of this.
> 
> Also very much in favor of these patches.

Passes my usual tests too, by the way.

--b.
