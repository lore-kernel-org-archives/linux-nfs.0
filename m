From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH v2 05/12] nfsd41: Backchannel: callback infrastructure
Date: Mon, 14 Sep 2009 16:17:32 -0400
Message-ID: <1252959452.6866.92.camel@heimdal.trondhjem.org>
References: <4AA8C597.8080809@panasas.com>
	 <1252574759-30176-1-git-send-email-bhalevy@panasas.com>
	 <20090914163535.GE30806@fieldses.org> <20090914164951.GA32757@fieldses.org>
	 <4AAE7C19.7070600@panasas.com>  <20090914200423.GE1658@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:54897 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757063AbZINURh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 16:17:37 -0400
In-Reply-To: <20090914200423.GE1658@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-09-14 at 16:04 -0400, J. Bruce Fields wrote:
> On Mon, Sep 14, 2009 at 08:23:37PM +0300, Benny Halevy wrote:
> > Where exactly is the NULL deref?
> > 
> > > 
> > > Note--that's fixed 7 patches later in fsd41: Refactor create_client(),
> > > but I don't actually understand how yet.
> > 
> > unconf's cl_flavor initialization was moved in the latter patch
> > from nfsd4_setclientid to create_client so maybe this could
> > be the culprit (though, assuming it is initialized to 0
> > it will choosing implicitly authnull_ops in rpcauth_create()
> > which _should_ work...)
> 
> Oog, yes, turns out auth_null doesn't initialize the cred hashtable.  So
> also reproduceable by mounting with "mount -tnfs4 -osec=null", then
> touching a file.  So either we should be using some other interface, or
> rpcauth_lookupcred should be checking au_credcache, or something.

There shouldn't be a need for an auth_null hashtable. It isn't a
credential...

Trond

