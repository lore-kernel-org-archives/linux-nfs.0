From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 3/5] NLM: Have lockd call try_to_freeze
Date: Mon, 14 Jan 2008 09:24:51 +1100
Message-ID: <18314.36787.541818.450563@notabene.brown>
References: <1199988096-19700-1-git-send-email-jlayton@redhat.com>
	<1199988096-19700-2-git-send-email-jlayton@redhat.com>
	<1199988096-19700-3-git-send-email-jlayton@redhat.com>
	<1199988096-19700-4-git-send-email-jlayton@redhat.com>
	<20080113065453.4774f8dd@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:52589 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754332AbYAMWZA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jan 2008 17:25:00 -0500
In-Reply-To: message from Jeff Layton on Sunday January 13
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sunday January 13, jlayton@redhat.com wrote:
> On Thu, 10 Jan 2008 13:01:34 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > lockd makes itself freezable, but never calls try_to_freeze(). Have it
> > call try_to_freeze() within the main loop.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/lockd/svc.c |    3 +++
> >  1 files changed, 3 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> > index 82e2192..6ee8bed 100644
> > --- a/fs/lockd/svc.c
> > +++ b/fs/lockd/svc.c
> > @@ -155,6 +155,9 @@ lockd(struct svc_rqst *rqstp)
> >  		long timeout = MAX_SCHEDULE_TIMEOUT;
> >  		char buf[RPC_MAX_ADDRBUFLEN];
> >  
> > +		if (try_to_freeze())
> > +			continue;
> > +
> >  		if (signalled()) {
> >  			flush_signals(current);
> >  			if (nlmsvc_ops) {
> 
> 
> I was looking over svc_recv today and noticed that it calls
> try_to_freeze a couple of times. Given that, the above patch may be
> unnecessary. I don't think it hurts anything though. Should we keep
> this patch or drop it?

I would suggest dropping it.
Having unnecessary code is likely to be confusing.

NeilBrown
