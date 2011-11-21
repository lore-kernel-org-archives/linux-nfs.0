Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24436 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752007Ab1KUU6d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Nov 2011 15:58:33 -0500
Date: Mon, 21 Nov 2011 15:57:46 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Tejun Heo <tj@kernel.org>
Cc: rjw@sisk.pl, linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org,
        john@calva.com, trond.myklebust@netapp.com
Subject: Re: [PATCH 1/2] sunrpc: make rpc_wait_bit_killable handle freeze
 events
Message-ID: <20111121155746.4b216239@corrin.poochiereds.net>
In-Reply-To: <20111121204620.GF25776@google.com>
References: <1321897221-2278-1-git-send-email-jlayton@redhat.com>
	<1321897221-2278-2-git-send-email-jlayton@redhat.com>
	<20111121204620.GF25776@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 21 Nov 2011 12:46:20 -0800
Tejun Heo <tj@kernel.org> wrote:

> On Mon, Nov 21, 2011 at 12:40:20PM -0500, Jeff Layton wrote:
> >  /*
> > + * Freezer-friendly macro around schedule() in the kernel.
> > + */
> > +#define freezable_schedule()						\
> > +({									\
> > +	freezer_do_not_count();						\
> > +	schedule();							\
> > +	freezer_count();						\
> > +})
> 
> So, yes, this seems correct to me but I'm not really sure about the
> naming.  Given what freezable means for other interfaces, this is a
> bit confusing to me but that could be because I know how each is
> implemented.  Anyone with a better name?
> 
> Also, this definitely can use a lot more detailed comment.  What it's
> supposed to do, how it's supposed to be used and so on.
> 
> Thank you.
> 

That makes sense. I'll plan to flesh out the comments in a respin.

Yeah, naming these things is rather difficult -- too many "*able"
adjectives. I'm quite open to better suggestions for the name (and for
wait_event_freezekillable too).

-- 
Jeff Layton <jlayton@redhat.com>
