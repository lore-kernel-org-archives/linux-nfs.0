Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2348 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755028Ab1KQBhV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Nov 2011 20:37:21 -0500
Date: Wed, 16 Nov 2011 20:38:10 -0500
From: Jeff Layton <jlayton@redhat.com>
Cc: Jim Rees <rees@umich.edu>, John Hughes <john@calvaedi.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
Message-ID: <20111116203810.4e1b9d28@corrin.poochiereds.net>
In-Reply-To: <20111116203119.1d9c0dd6@corrin.poochiereds.net>
References: <4EC3FD8B.6000705@calvaedi.com>
	<20111116144718.78b2e288@corrin.poochiereds.net>
	<20111116234434.GA12882@umich.edu>
	<20111116203119.1d9c0dd6@corrin.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Nov 2011 20:31:19 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 16 Nov 2011 18:44:34 -0500
> Jim Rees <rees@umich.edu> wrote:
> 
> > Jeff Layton wrote:
> > 
> >   Uhhh, no...EKEYEXPIRED was never passed to userland. The patchset that
> >   added EKEYEXPIRED returns in this codepath also added the code to make
> >   it hang. 
> >   
> >   This not a bug, or at least it's intentional behavior. When a krb5
> >   ticket expires, we *want* the process to hang. Otherwise, people with
> >   long running jobs will often find that their jobs error out
> >   inexplicably when their ticket expires.
> > 
> > Who decided that?  This seems completely wrong to me.  If my credentials
> > expire, I want to get permission denied, not a client hang.  In 20 years of
> > using authenticated file systems I never once wished my process had hung
> > when my ticket expired.
> > 
> 
> I proposed it, we discussed it on the list, and Trond and Steve
> committed the patches necessary to make it happen. This was back in
> late 2009/early 2010 though, so my memory is a bit fuzzy...
> 
> > Why should this be any different from any other failure condition?  If you
> > try to open a file that doesn't exist, do you want your process to hang
> > instead of getting ENOENT, just in case the file magically appears at some
> > point in the future?
> >
> 
> That's different. Not renewing your credentials is often a temporary
> situation. Kerberos is different than other authentication methods in
> that you get a ticket only for a period of time, so expired credentials
> are not a situation that's common with other authentication methods.
> 
> > This seems a recipe for disaster.  Suppose I have a cron job that fires once
> > a minute, and all those jobs hang waiting for a ticket.  I come to work in
> > the morning and discover I've got 10,000 hung processes.  Or not, because my
> > computer has crashed from resource exhaustion.
> 
> The previous situation was also a recipe for disaster, and was often
> cited as a primary reason why people didn't want to deploy kerberized
> NFS. Having everything fall down and go boom when your ticket expires
> is not desirable either.
> 
> I suppose we'll have to agree to disagree on this point. That said, I'm
> open to sane suggestions however that don't regress the behavior for
> those users who need to be able to cope with expired tickets.
> 

Note too that the gssd code distinguishes between an expired TGT and a
non-existent credcache. The latter will give you the error you desire
here. So one possibility is just to remove the credcache from /tmp in
this situation.

Another possibility might be a new option to rpc.gssd that allows the
user to select the error that it passes back to the kernel on an
expired ticket.

-- 
Jeff Layton <jlayton@redhat.com>
