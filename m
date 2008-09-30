From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/3] lockd: reject reclaims outside the grace period
Date: Tue, 30 Sep 2008 11:59:35 -0400
Message-ID: <20080930155935.GA10405@fieldses.org>
References: <1222742643-31541-1-git-send-email-bfields@citi.umich.edu> <1222742643-31541-2-git-send-email-bfields@citi.umich.edu> <1222742643-31541-3-git-send-email-bfields@citi.umich.edu> <1222742643-31541-4-git-send-email-bfields@citi.umich.edu> <OF00072D17.F38B2A1C-ON882574D4.0019CC91-882574D4.001A6F58@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:46912 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752857AbYI3P7i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2008 11:59:38 -0400
In-Reply-To: <OF00072D17.F38B2A1C-ON882574D4.0019CC91-882574D4.001A6F58@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 29, 2008 at 09:48:48PM -0700, Marc Eshel wrote:
> Unfortunately the application don't get notified when the reclaim failed. 

That depends on the client.  My understanding is that you're correct for
the Linux client, but that Solaris sends a signal?  Anyone know more, or
have suggestions about what we should do to fix the client?  I believe
that's a bug.

> Now you are making sure that application will fail because if they missed 
> the reclaim window they will not get the lock back and the application 
> will continue to run without a lock. Not sure this is better behavior.

Agreed that it's an unfortunate situation, but I think we have to do it.
The protocol requires it, and we owe this to clients who do make use of
the reclaim result somehow.

--b.

> Marc.
> 
> 
> linux-nfs-owner@vger.kernel.org wrote on 09/29/2008 07:44:03 PM:
> 
> > 
> > [PATCH 3/3] lockd: reject reclaims outside the grace period
> > 
> > The current lockd does not reject reclaims that arrive outside of the
> > grace period.
> > 
> > Accepting a reclaim means promising to the client that no conflicting
> > locks were granted since last it held the lock.  We can meet that
> > promise if we assume the only lockers are nfs clients, and that they are
> > sufficiently well-behaved to reclaim only locks that they held before,
> > and that only reclaim locks have been permitted so far.  Once we leave
> > the grace period (and start permitting non-reclaims), we can no longer
> > keep that promise.  So we must start rejecting reclaims at that point.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> > ---
> >  fs/lockd/svclock.c |    4 ++++
> >  1 files changed, 4 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> > index 808d246..6063a8e 100644
> > --- a/fs/lockd/svclock.c
> > +++ b/fs/lockd/svclock.c
> > @@ -410,6 +410,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct 
> > nlm_file *file,
> >        ret = nlm_lck_denied_grace_period;
> >        goto out;
> >     }
> > +   if (reclaim && !locks_in_grace()) {
> > +      ret = nlm_lck_denied_grace_period;
> > +      goto out;
> > +   }
> > 
> >     if (!wait)
> >        lock->fl.fl_flags &= ~FL_SLEEP;
> > -- 
> > 1.5.5.rc1
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
