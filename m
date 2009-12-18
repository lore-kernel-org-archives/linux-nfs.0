From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
 return error
Date: Fri, 18 Dec 2009 10:25:50 -0500
Message-ID: <20091218102550.6a48c900@tlielax.poochiereds.net>
References: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
	<1261145468.3229.7.camel@localhost>
	<20091218093912.1c426ad6@tlielax.poochiereds.net>
	<1261147672.3229.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50879 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754341AbZLRPZz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Dec 2009 10:25:55 -0500
In-Reply-To: <1261147672.3229.14.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 18 Dec 2009 09:47:52 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2009-12-18 at 09:39 -0500, Jeff Layton wrote: 
> > Yeah, we could do that with the existing code. I sort of don't like
> > that because it's hard to know if other functions could eventually
> > return an EACCES for another reason and then that error would bubble up
> > to this function. If you think it's the right thing to do though, I'm
> > OK with it.
> 
> The error EACCES means 'you are not authorised'. I don't see how it can
> be ambiguous here.
> 

I guess I was thinking that the pipe writer might not be authorized to
import the sec context for some reason, which would be a different
situation. If that'll never be the case, then a single error code is
probably fine. I'll respin it to just special case EACCES for now and
will plan to have it special case the other error when that work is
more fleshed out.

> > FWIW: The reason I'm poking around in here is because I'm taking a stab
> > at fixing the problem where syscalls start returning errors when a krb5
> > ticket expires.
> > 
> > As part of that, I want to have gssd send a more granular error code
> > and have the kernel adjust what it does accordingly. I'd like to have
> > it retry the upcall indefinitely when there's an expired credcache, and
> > return an error when there's no credcache at all).
> 
> That makes sense.
> 
> > Without a separate downcall error field, we'll need to special case at
> > least 2 different errors -- one for a "real" EACCES and one that
> > indicates that the ticket expired and the upcall should be retried
> > instead.
> 
> We can find another error for the 'ticket expired' case. EKEYEXPIRED
> springs to mind...
> 

That's exactly the error I was going to use.

> > > BTW: while looking at this, I spotted a nasty bug in
> > > gss_import_sec_context_kerberos(). If the kzalloc() call fails, we will
> > > return a random error code since 'p' still points to a valid memory
> > > location...
> > 
> > Good catch. Do you want fix that one, or should I?
> > 
> 
> I can do it, if you like.
> 

Sure. I see another problem in this area too. gss_import_sec_context
can return GSS_S_FAILURE which is unsigned and positive when cast to a
signed value. gss_import_sec_context checks for a negative return from
that function though. Should it be checking for non-zero instead?

-- 
Jeff Layton <jlayton@redhat.com>
