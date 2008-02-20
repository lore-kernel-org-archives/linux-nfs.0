From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] NFS: flush signals before taking down callback thread
Date: Wed, 20 Feb 2008 09:01:10 -0500
Message-ID: <20080220090110.5658c78e@barsoom.rdu.redhat.com>
References: <1203443495-7854-1-git-send-email-jlayton@redhat.com>
	<20080219222226.GA10656@infradead.org>
	<1203461010.13265.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50213 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757665AbYBTOBY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2008 09:01:24 -0500
In-Reply-To: <1203461010.13265.12.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 19 Feb 2008 17:43:30 -0500
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Tue, 2008-02-19 at 17:22 -0500, Christoph Hellwig wrote:
> > Wouldn't it be better to not allow for signals to this thread at
> > all? The code really begs for a similar kthread conversion as the
> > lockd one.
> 
> I'd tend to prefer that solution too.
> 

I did a bit of smoke testing on that patch this morning and just sent
it out to the list. The only problem is that that patch depends on a
couple of other patches currently in Bruce's tree and that are slated
for 2.6.26. It might be reasonable in the interim to go ahead and take
the patch to flush_signals() in the existing code.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
