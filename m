Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:37675 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754060AbaFWQAD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:00:03 -0400
Date: Mon, 23 Jun 2014 09:00:01 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 000/104] nfsd: eliminate the client_mutex
Message-ID: <20140623160001.GA24193@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <20140623133926.GA32746@infradead.org>
 <20140623095645.1fc23e9c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140623095645.1fc23e9c@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2014 at 09:56:45AM -0400, Jeff Layton wrote:
> Thanks for taking a look. The big problem with breaking this set up is
> that it will likely result in at least some performance regression in
> the interim. We're adding more granular locking inside of the
> coarse-grained client_mutex, which is likely to mean at least some
> slowdown until the client_mutex is removed. Maybe that's worth it
> though.

That's why I didn't dare to ask for splitting the lock breakup, but
rather the surrounding fixes and logic changes.  But yes, if that's not
doable either we'll have to bite the bullet.

> >  - there is some confusion of NFSd vs nfsd in the subsystem prefixes.
> >    While it seems odd and against the usual naming NFSd seems to be
> >    the common one for nfs patches.
> > 
> 
> I tend to prefer "nfsd", but ok -- "NFSd" it is.

I'd prefer nfsd as well, but in Rome do as the Romans do, so..

