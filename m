From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/3] NLM: Convert lockd to use kthreads
Date: Mon, 11 Feb 2008 10:29:38 -0500
Message-ID: <20080211152938.GF25742@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53629 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754013AbYBKP3k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2008 10:29:40 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oops, did I forget to send this?  I don't' see it in the archives.
Apologies:

On Mon, Feb 11, 2008 at 12:22:08AM +0000, bfields wrote:
> On Thu, Feb 07, 2008 at 04:34:55PM -0500, Jeff Layton wrote:
> ...
> > diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> > index 0822646..378b393 100644
> > --- a/fs/lockd/svc.c
> > +++ b/fs/lockd/svc.c
> ...
> > @@ -174,6 +167,10 @@ lockd(struct svc_rqst *rqstp)
> >  		} else if (time_before(grace_period_expire, jiffies))
> >  			clear_grace_period();
> >  
> > +		/* nlmsvc_retry_blocked can block, so check for kthread_stop */
> > +		if (kthread_should_stop())
> > +			break;
> 
> The following svc_recv call will check kthread_should_stop() pretty
> early on, so I don't believe this is necessary?
> 
> Assuming that's correct, I've deleted these lines and applied the rest.
> 
> --b.
