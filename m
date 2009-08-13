From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS and NFSv4 lists?
Date: Thu, 13 Aug 2009 14:45:04 -0400
Message-ID: <1250189104.16167.66.camel@heimdal.trondhjem.org>
References: <20090813174923.GA15213@infradead.org>
	 <1250186824.16167.31.camel@heimdal.trondhjem.org>
	 <20090813181449.GA11931@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39213 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752646AbZHMSpH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Aug 2009 14:45:07 -0400
In-Reply-To: <20090813181449.GA11931@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-08-13 at 14:14 -0400, Christoph Hellwig wrote:
> On Thu, Aug 13, 2009 at 02:07:04PM -0400, Trond Myklebust wrote:
> > On Thu, 2009-08-13 at 13:49 -0400, Christoph Hellwig wrote:
> > > Is there really a reason to keep a separate NFSv4 mailing list?  v4
> > > support is part of the same nfs/nfsd modules and quite deeply
> > > interwinded with the v2/v3 code.  It seems most posts to the NFSv4 list
> > > get cross-posted to the regular nfs list anyway.
> > 
> > I certainly agree that we can start deprecating the nfsv4@linux-nfs.org
> > list, but I'm reluctant to shut it down completely as long as we're
> > seeing some non-cross posted traffic there.
> > 
> > How about if we keep it open for another 6 months, and use that time to
> > educate those people who post only on nfsv4@linux-nfs.org to move on to
> > linux-nfs?
> 
> How about just turning the nfsv4 list into an auto-responder telling
> people to use the linux-nfs@vger.kernel.org?
> 

I tend to be wary of auto-responders: more often than not, they turn out
to be great vehicles for relaying spam.
However if someone with more mail administrator experience than myself
would volunteer to help set one up, then I'd be willing to give it a
try.

Cheers
  Trond

