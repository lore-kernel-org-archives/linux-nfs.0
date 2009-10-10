From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
Date: Sat, 10 Oct 2009 09:00:39 -0400
Message-ID: <20091010090039.4dfd1dfb@tlielax.poochiereds.net>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
	<20091009121602.5ec86dfb@tlielax.poochiereds.net>
	<1c358fde92c49215d84129a1bfe2c6ec.squirrel@webmail.rainiday.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758870AbZJJNBJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Oct 2009 09:01:09 -0400
In-Reply-To: <1c358fde92c49215d84129a1bfe2c6ec.squirrel-2RFepEojUI30fF+2cCIZ11aTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 9 Oct 2009 09:53:51 -0700
raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org wrote:

> > No, gssd (the client side daemon) will search /tmp for anything that
> > looks like a credcache for the right user, verify that it is a
> > credcache and then pick the one with the latest TGT expiration.
> 
> > You're correct that NFS ignores $KRB5CCNAME. It uses the above (less
> > than optimal) heuristic instead.
> 
> Thanks for explaining this Jeff - this does accord with what I see - which
> of course leaves my batch job system unpredictable.
> 
> > Probably doable, but not trivial. IIRC, the kernel tracks credentials
> > by uid. You'd need to determine some way to split that up so that each
> > "session" has separate credentials. Once you do that, you'll have to
> > have the kernel pass enough info to the upcall for it to determine what
> > credcache it should use and modify gssd to use the new info accordingly.
> 
> Just to be clear - you mean doable to a coder who might like to improve on
> gssd/kernel credential separation, rather than a non-coding sysadmin who
> needs with work within the current NFS/gssd framework?
> 

Correct, that's what I mean. It'll mean modifying kernel and rpc.gssd
code.

-- 
Jeff Layton <jlayton@redhat.com>
