Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48059 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730AbbJONuj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Oct 2015 09:50:39 -0400
Date: Thu, 15 Oct 2015 09:50:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.com>
Cc: Olaf Kirch <okir@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC] sunrpc/cache: make cache flushing more reliable.
Message-ID: <20151015135039.GB18976@fieldses.org>
References: <87fv1cwsln.fsf@notabene.neil.brown.name>
 <87a8rkws7g.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87a8rkws7g.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 15, 2015 at 05:39:47PM +1100, Neil Brown wrote:
> 
> Sorry.. I didn't refresh before posting....
> 
> > @@ -487,10 +496,13 @@ EXPORT_SYMBOL_GPL(cache_flush);
> >  
> >  void cache_purge(struct cache_detail *detail)
> >  {
> > -	detail->flush_time = LONG_MAX;
> > +	time_t now = seconds_since_boot();
> > +	if (detail->flush_time >= now)
> > +		now = detail->flush_time + 1;
> > +	/* 'now' is the maximum value any 'last_refresh' can have */
> > +	detail->flush_time = now + 1;
> 
> This should not have the '+ 1'.
> 
> >  	detail->nextcheck = seconds_since_boot();
> >  	cache_flush();
> > -	detail->flush_time = 1;
> >  }
> >  EXPORT_SYMBOL_GPL(cache_purge);
> >  
> > @@ -1447,8 +1460,22 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
> >  		return -EINVAL;
> >  
> >  	bp = tbuf;
> > -	cd->flush_time = get_expiry(&bp);
> > -	cd->nextcheck = seconds_since_boot();
> > +	then = get_expiry(&bp);
> > +	now = seconds_since_boot();
> > +	cd->nextcheck = now;
> > +	/* Can only set flush_time to 1 second beyond "now", or
> > +	 * possibly 1 second beyond flushtime.  This is because
> > +	 * flush_time never goes backwards so it mustn't get too far
> > +	 * ahead of time.
> > +	 */
> > +	if (then >= now) {
> > +		/* Want to flush everything, so behave like cache_purge() */
> > +		if (cd->flush_time >= now)
> > +			now = cd->flush_time + 1;
> > +		then = now + 1;
> 
> Nor should.
> 
> I'll resend it people are otherwise happy.

I'm otherwise happy!  Looks like a reasonable approach.

(The one thing I wonder is whether it would be clearer to outright fail
writes that attempt to create already-expired cache entries.

But I think that's an unimportant corner case really.  And if there are
existing cases where that's happening then perhaps it's less disruptive
just to let them expire a second later rathern than to introduce a new
error.)

--b.
