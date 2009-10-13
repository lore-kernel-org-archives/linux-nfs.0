Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:36959 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753599AbZJMQ5M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Oct 2009 12:57:12 -0400
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Kevin Coffman <kwc@citi.umich.edu>
Cc: Jeff Layton <jlayton@redhat.com>, raini@rainiday.com,
        linux-nfs@vger.kernel.org
In-Reply-To: <4d569c330910130851o155050djdfed6a52e1f3177a@mail.gmail.com>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
	 <20091009121602.5ec86dfb@tlielax.poochiereds.net>
	 <1c358fde92c49215d84129a1bfe2c6ec.squirrel@webmail.rainiday.com>
	 <20091010090039.4dfd1dfb@tlielax.poochiereds.net>
	 <ee56329e7d86a3e4b15001a39bb7e14a.squirrel@webmail.rainiday.com>
	 <20091013114441.2882c8b9@tlielax.poochiereds.net>
	 <4d569c330910130851o155050djdfed6a52e1f3177a@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 13 Oct 2009 12:56:20 -0400
Message-Id: <1255452985.3711.85.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2009-10-13 at 11:51 -0400, Kevin Coffman wrote:
> On Tue, Oct 13, 2009 at 11:44 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > On Tue, 13 Oct 2009 08:28:52 -0700
> > raini@rainiday.com wrote:
> >
> >> Jeff Layton <jlayton@redhat.com> said:
> >> >> Just to be clear - you mean doable to a coder who might like to improve
> >> >> on
> >> >> gssd/kernel credential separation, rather than a non-coding sysadmin who
> >> >> needs with work within the current NFS/gssd framework?
> >> >>
> >> >
> >> > Correct, that's what I mean. It'll mean modifying kernel and rpc.gssd
> >> > code.
> >>
> >> Thanks for confirming.  Skipping back a little:
> >>
> >> >> > No, gssd (the client side daemon) will search /tmp for anything that
> >> >> > looks like a credcache for the right user, verify that it is a
> >> >> > credcache and then pick the one with the latest TGT expiration.
> >>
> >> Kevin Coffman on the NFS4 list actually implied this used simple mtime
> >> rather than actually scanning /tmp/krb5cc_uid* for ccache files with the
> >> latest TGT expiration, which is how I originally read your statement.
> >> This seemingly would make a difference in an environment with a batch job
> >> with a long lifetime ticket and subsequent interactive login generating a
> >> separate ccache file with a shorter lifetime but newer mtime.
> >>
> >> I'm not a coder but I scanned krb5_util.c in the gssd code, and it *seems*
> >> to me it only looks at mtime, although what you suggest would be more
> >> optimal.  Could you confirm whether it's scanning ccache files for longest
> >> TGT, or just using mtime?
> >>
> >
> > You and Kevin are correct. rpc.gssd only looks at the mtime. When I did
> > the work to allow the CIFS SPNGEO upcall to find alternate credcaches,
> > I implemented the behavior I described (prefer the latest TGT
> > expiration) -- sorry for the confusion...
> >
> > It probably wouldn't be too hard to change rpc.gssd to prefer
> > credcaches with the latest TGT expiration if it was considered a
> > desirable change.
> >
> > Kevin, any thoughts?
> 
> I agree it shouldn't be too hard to change if that behavior is desirable/useful.

Shouldn't rpc.gssd in any case be looking for all _valid_ credcaches,
rather than just any old credcache-like file?

If you stick to that principle, then if there is one file that contains
a still-unexpired TGT, and one with a TGT that has expired, then the
first file should always be preferred, irrespective of the value of the
mtimes...

Cheers
  Trond

