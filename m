From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
 return error
Date: Fri, 18 Dec 2009 10:12:22 -0500
Message-ID: <1261149142.3229.20.camel@localhost>
References: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
	 <1261145468.3229.7.camel@localhost>
	 <20091218093912.1c426ad6@tlielax.poochiereds.net>
	 <1261147672.3229.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50328 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754244AbZLRPMl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Dec 2009 10:12:41 -0500
In-Reply-To: <1261147672.3229.14.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-18 at 09:47 -0500, Trond Myklebust wrote: 
> On Fri, 2009-12-18 at 09:39 -0500, Jeff Layton wrote: 
> > Without a separate downcall error field, we'll need to special case at
> > least 2 different errors -- one for a "real" EACCES and one that
> > indicates that the ticket expired and the upcall should be retried
> > instead.
> 
> We can find another error for the 'ticket expired' case. EKEYEXPIRED
> springs to mind...

BTW: Here be dragons!

I think we need to handle the 'ticket expired' case as if it were an
NFS4ERR_DELAY/EJUKEBOX, and actually do the retry in the NFS layer after
a suitable exponential back-off period.

Otherwise, we end up holding onto resources (in particular NFSv4.1
slots, but also RPC slots, ...) which will cause congestion, and prevent
other RPC calls from making progress.

Cheers
  Trond
