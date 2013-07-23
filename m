Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932595Ab3GWQ0e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jul 2013 12:26:34 -0400
Date: Tue, 23 Jul 2013 12:26:29 -0400
From: Jeff Layton <jlayton@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: torvalds@linux-foundation.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        Milosz Tanski <milosz@adfin.com>,
        Yacine Belkadi <yacine.belkadi.1@gmail.com>
Subject: Re: [PATCH] Fix __wait_on_atomic_t() to call the action func if the
 counter != 0
Message-ID: <20130723122629.6b5ae46e@tlielax.poochiereds.net>
In-Reply-To: <24785.1374596102@warthog.procyon.org.uk>
References: <20130723120258.01024e81@tlielax.poochiereds.net>
	<20130723154924.24306.42326.stgit@warthog.procyon.org.uk>
	<24785.1374596102@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 23 Jul 2013 17:15:02 +0100
David Howells <dhowells@redhat.com> wrote:

> Jeff Layton <jlayton@redhat.com> wrote:
> 
> > > @@ -333,7 +333,8 @@ int __wait_on_atomic_t(wait_queue_head_t *wq, struct wait_bit_queue *q,
> > >  		prepare_to_wait(wq, &q->wait, mode);
> > >  		val = q->key.flags;
> > >  		if (atomic_read(val) == 0)
> > > -			ret = (*action)(val);
> > > +			break;
> > > +		ret = (*action)(val);
> > >  	} while (!ret && atomic_read(val) != 0);
> > 
> > nit: can you now eliminate the check for "val" in the while condition?
> > It doesn't look like it harms anything, but eliminating it would
> > probably simplify the code slightly...
> 
> Its presence means that we don't have to call prepare_to_wait() again if val
> became 0.
> 
> David

Ok, and prepare_to_wait involves taking spinlocks, etc...

Got it!

Reviewed-by: Jeff Layton <jlayton@redhat.com>
