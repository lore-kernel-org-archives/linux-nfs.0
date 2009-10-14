Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751512AbZJNRVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2009 13:21:35 -0400
Date: Wed, 14 Oct 2009 13:21:03 -0400
From: Jeff Layton <jlayton@redhat.com>
To: raini@rainiday.com
Cc: linux-nfs@vger.kernel.org, "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
Message-ID: <20091014132103.616383ed@tlielax.poochiereds.net>
In-Reply-To: <6c850afdb750affdca863df8bbcafa75.squirrel@webmail.rainiday.com>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
	<20091009121602.5ec86dfb@tlielax.poochiereds.net>
	<1c358fde92c49215d84129a1bfe2c6ec.squirrel@webmail.rainiday.com>
	<20091010090039.4dfd1dfb@tlielax.poochiereds.net>
	<ee56329e7d86a3e4b15001a39bb7e14a.squirrel@webmail.rainiday.com>
	<20091013114441.2882c8b9@tlielax.poochiereds.net>
	<08395e6249442278ab2b59c2ae4cfd14.squirrel@webmail.rainiday.com>
	<20091013133138.77c2cf35@tlielax.poochiereds.net>
	<6c850afdb750affdca863df8bbcafa75.squirrel@webmail.rainiday.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 14 Oct 2009 10:00:59 -0700
raini@rainiday.com wrote:

> > On Tue, 13 Oct 2009 08:59:29 -0700
> > raini@rainiday.com wrote:
> >
> >> > You and Kevin are correct. rpc.gssd only looks at the mtime. When I
> >> did
> >> > the work to allow the CIFS SPNGEO upcall to find alternate credcaches,
> >> > I implemented the behavior I described (prefer the latest TGT
> >> > expiration) -- sorry for the confusion...
> >> >
> >> > It probably wouldn't be too hard to change rpc.gssd to prefer
> >> > credcaches with the latest TGT expiration if it was considered a
> >> > desirable change.
> >> >
> >> > Kevin, any thoughts?
> >>
> >> This would be a big plus from me - I still wouldn't be able to create
> >> per-job ccaches of course, but if a user who knew they needed to run a
> >> job
> >> could create a long lifetime renewable ticket in
> >> /tmp/krb5cc_<uid>_batch,
> >> say, and NFS would use this in preference to a later login ticket, this
> >> would really help.
> >
> > Ok, here's a proposed patch...only compile-tested so far. I don't have
> > time at the moment to test it more extensively so if you could test it
> > out and report back, that would be helpful.
> 
> Thanks Jeff - this looks extremely useful, caveat my other comment (and
> perhaps lack of understanding) on the list today about what's happened in
> recent nfs-utils which I'd like to clarify.
> 
> I may have trouble testing this in the short term as I'm largely bound to
> production environments - but will get to back to you if I can.
> 

Actually...I'm not convinced that it is that useful. As Trond pointed
out, when the credentials expire, the kernel should upcall for new
creds. As long as there is a valid TGT in a credcache for that user
somewhere then it should just pick up that one and keep humming along.
If that's not working for some reason then that's likely a bug.

-- 
Jeff Layton <jlayton@redhat.com>
