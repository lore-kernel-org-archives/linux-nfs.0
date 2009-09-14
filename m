From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH v2 05/12] nfsd41: Backchannel: callback infrastructure
Date: Mon, 14 Sep 2009 16:04:23 -0400
Message-ID: <20090914200423.GE1658@fieldses.org>
References: <4AA8C597.8080809@panasas.com> <1252574759-30176-1-git-send-email-bhalevy@panasas.com> <20090914163535.GE30806@fieldses.org> <20090914164951.GA32757@fieldses.org> <4AAE7C19.7070600@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Andy Adamson <andros@netapp.com>,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36989 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752882AbZINUEW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Sep 2009 16:04:22 -0400
In-Reply-To: <4AAE7C19.7070600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 14, 2009 at 08:23:37PM +0300, Benny Halevy wrote:
> Where exactly is the NULL deref?
> 
> > 
> > Note--that's fixed 7 patches later in fsd41: Refactor create_client(),
> > but I don't actually understand how yet.
> 
> unconf's cl_flavor initialization was moved in the latter patch
> from nfsd4_setclientid to create_client so maybe this could
> be the culprit (though, assuming it is initialized to 0
> it will choosing implicitly authnull_ops in rpcauth_create()
> which _should_ work...)

Oog, yes, turns out auth_null doesn't initialize the cred hashtable.  So
also reproduceable by mounting with "mount -tnfs4 -osec=null", then
touching a file.  So either we should be using some other interface, or
rpcauth_lookupcred should be checking au_credcache, or something.

--b.
