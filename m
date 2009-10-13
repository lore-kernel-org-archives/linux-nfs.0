From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
Date: Tue, 13 Oct 2009 11:44:41 -0400
Message-ID: <20091013114441.2882c8b9@tlielax.poochiereds.net>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
	<20091009121602.5ec86dfb@tlielax.poochiereds.net>
	<1c358fde92c49215d84129a1bfe2c6ec.squirrel@webmail.rainiday.com>
	<20091010090039.4dfd1dfb@tlielax.poochiereds.net>
	<ee56329e7d86a3e4b15001a39bb7e14a.squirrel@webmail.rainiday.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, Kevin Coffman <kwc@citi.umich.edu>
To: raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46673 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760069AbZJMPpM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2009 11:45:12 -0400
In-Reply-To: <ee56329e7d86a3e4b15001a39bb7e14a.squirrel-2RFepEojUI30fF+2cCIZ11aTQe2KTcn/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 13 Oct 2009 08:28:52 -0700
raini-9HxftnAiGddWk0Htik3J/w@public.gmane.org wrote:

> Jeff Layton <jlayton@redhat.com> said:
> >> Just to be clear - you mean doable to a coder who might like to improve
> >> on
> >> gssd/kernel credential separation, rather than a non-coding sysadmin who
> >> needs with work within the current NFS/gssd framework?
> >>
> >
> > Correct, that's what I mean. It'll mean modifying kernel and rpc.gssd
> > code.
> 
> Thanks for confirming.  Skipping back a little:
> 
> >> > No, gssd (the client side daemon) will search /tmp for anything that
> >> > looks like a credcache for the right user, verify that it is a
> >> > credcache and then pick the one with the latest TGT expiration.
> 
> Kevin Coffman on the NFS4 list actually implied this used simple mtime
> rather than actually scanning /tmp/krb5cc_uid* for ccache files with the
> latest TGT expiration, which is how I originally read your statement. 
> This seemingly would make a difference in an environment with a batch job
> with a long lifetime ticket and subsequent interactive login generating a
> separate ccache file with a shorter lifetime but newer mtime.
> 
> I'm not a coder but I scanned krb5_util.c in the gssd code, and it *seems*
> to me it only looks at mtime, although what you suggest would be more
> optimal.  Could you confirm whether it's scanning ccache files for longest
> TGT, or just using mtime?
> 

You and Kevin are correct. rpc.gssd only looks at the mtime. When I did
the work to allow the CIFS SPNGEO upcall to find alternate credcaches,
I implemented the behavior I described (prefer the latest TGT
expiration) -- sorry for the confusion...

It probably wouldn't be too hard to change rpc.gssd to prefer
credcaches with the latest TGT expiration if it was considered a
desirable change.

Kevin, any thoughts?

-- 
Jeff Layton <jlayton@redhat.com>
