From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] sunrpc: on successful gss error pipe write, don't
 return error
Date: Fri, 18 Dec 2009 09:47:52 -0500
Message-ID: <1261147672.3229.14.camel@localhost>
References: <1261144574-1642-1-git-send-email-jlayton@redhat.com>
	 <1261145468.3229.7.camel@localhost>
	 <20091218093912.1c426ad6@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49151 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887AbZLROsf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Dec 2009 09:48:35 -0500
In-Reply-To: <20091218093912.1c426ad6-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-12-18 at 09:39 -0500, Jeff Layton wrote: 
> Yeah, we could do that with the existing code. I sort of don't like
> that because it's hard to know if other functions could eventually
> return an EACCES for another reason and then that error would bubble up
> to this function. If you think it's the right thing to do though, I'm
> OK with it.

The error EACCES means 'you are not authorised'. I don't see how it can
be ambiguous here.

> FWIW: The reason I'm poking around in here is because I'm taking a stab
> at fixing the problem where syscalls start returning errors when a krb5
> ticket expires.
> 
> As part of that, I want to have gssd send a more granular error code
> and have the kernel adjust what it does accordingly. I'd like to have
> it retry the upcall indefinitely when there's an expired credcache, and
> return an error when there's no credcache at all).

That makes sense.

> Without a separate downcall error field, we'll need to special case at
> least 2 different errors -- one for a "real" EACCES and one that
> indicates that the ticket expired and the upcall should be retried
> instead.

We can find another error for the 'ticket expired' case. EKEYEXPIRED
springs to mind...

> > BTW: while looking at this, I spotted a nasty bug in
> > gss_import_sec_context_kerberos(). If the kzalloc() call fails, we will
> > return a random error code since 'p' still points to a valid memory
> > location...
> 
> Good catch. Do you want fix that one, or should I?
> 

I can do it, if you like.

Trond
