From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/3] NLM: Convert lockd to use kthreads
Date: Mon, 11 Feb 2008 10:33:13 -0500
Message-ID: <20080211103313.0e3bb207@tleilax.poochiereds.net>
References: <20080211152938.GF25742@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37641 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753096AbYBKPdQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2008 10:33:16 -0500
In-Reply-To: <20080211152938.GF25742@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 11 Feb 2008 10:29:38 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> Oops, did I forget to send this?  I don't' see it in the archives.
> Apologies:
> 
> On Mon, Feb 11, 2008 at 12:22:08AM +0000, bfields wrote:
> > On Thu, Feb 07, 2008 at 04:34:55PM -0500, Jeff Layton wrote:
> > ...
> > > diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> > > index 0822646..378b393 100644
> > > --- a/fs/lockd/svc.c
> > > +++ b/fs/lockd/svc.c
> > ...
> > > @@ -174,6 +167,10 @@ lockd(struct svc_rqst *rqstp)
> > >  		} else if (time_before(grace_period_expire, jiffies))
> > >  			clear_grace_period();
> > >  
> > > +		/* nlmsvc_retry_blocked can block, so check for kthread_stop */
> > > +		if (kthread_should_stop())
> > > +			break;
> > 
> > The following svc_recv call will check kthread_should_stop() pretty
> > early on, so I don't believe this is necessary?
> > 
> > Assuming that's correct, I've deleted these lines and applied the rest.
> > 

Sounds reasonable...ACK

-- 
Jeff Layton <jlayton@redhat.com>
