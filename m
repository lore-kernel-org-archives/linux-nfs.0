Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:34972 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320AbbKFRAz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Nov 2015 12:00:55 -0500
Received: by qkao63 with SMTP id o63so5379677qka.2
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2015 09:00:54 -0800 (PST)
Date: Fri, 6 Nov 2015 12:00:51 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: Bruce James Fields <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Andrew W Elble <aweits@rit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: fix nfsd4_delegreturn to return correct error
 codes
Message-ID: <20151106120051.6f380290@synchrony.poochiereds.net>
In-Reply-To: <20151106152914.GA16006@fieldses.org>
References: <1446674837-4980-1-git-send-email-aweits@rit.edu>
	<CAHQdGtShZ=6J9h1hW00zPZ+TWzAYmfSiET-1mEdv1-H=JGEgcA@mail.gmail.com>
	<m2mvurnum3.fsf@discipline.rit.edu>
	<CAHQdGtSbxKDHSD+kxv5Fa6CLoSrB3KjeRjyTsNDhR47VYCUgOg@mail.gmail.com>
	<CAHQdGtSNC_j7M9y40tNe=WzsqoECa3Y5gMSRsqx3bKsf79TsHA@mail.gmail.com>
	<20151106091947.76de6de7@synchrony.poochiereds.net>
	<20151106152914.GA16006@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 6 Nov 2015 10:29:14 -0500
Bruce James Fields <bfields@fieldses.org> wrote:

> On Fri, Nov 06, 2015 at 09:19:47AM -0500, Jeff Layton wrote:
> > On Fri, 6 Nov 2015 09:03:50 -0500
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > 
> > > On Fri, Nov 6, 2015 at 8:48 AM, Trond Myklebust
> > > <trond.myklebust@primarydata.com> wrote:
> > > > On Fri, Nov 6, 2015 at 8:08 AM, Andrew W Elble <aweits@rit.edu> wrote:
> > > >>
> > > >>> Umm... If the client is sending delegreturn, then why not destroy the
> > > >>> delegation?
> 
> Yeah, good question, I didn't think about that.
> 
> The one thing that bothers me:
> 
> > Hmm...so is there any advantage to reporting NFS4ERR_DELEG_REVOKED
> > there at all? I guess that could be a signal that it may not have held
> > a delegation that it thought it had,
> 
> Yes, I'd like to think a little about this.  It does worry me that the
> loss of a delegation could be completely silent.
> 
> Even in the absence of locks, userspace may now have gotten incorrect
> lookup or stat results.  (Unless the client is careful not to depend on
> delegations for any guarantees that go beyond close-to-open?)
> 
> So,
> 
> 	client1		client2
> 	-------		-------
> 
> 			make prog
> 					(client2 gets delegation on prog.c)
> 
> 	vi prog.c
> 					(client2's deleg recalled, then
> 					revoked)
> 
> 			wait for ac timeout
> 			make prog
> 			make: 'prog' is up to date
> 
> Hm, I think the client has to see a STATUS_RECALLABLE_STATE_REVOKED at
> some point here, though.
> 
> In fact, is there any situation this could happen without the client
> having seeing that flag on the SEQUENCE preceding this op?  I guess
> there could be an extremely narrow window for a race between the two
> ops.  Is that race is the only justification for having this error in
> the protocol at all?  In the typical case it's going to see the sequence
> flag at the same time as the error and have to do some kind of recovery
> anyway.
> 

Yes, I think a revoke would have to race in between the SEQUENCE and
DELEGRETURN for it to happen.

> > but it's probably too late to do anything about it if that occurs.
> 
> Yeah, I can't think what the client could do beyond log something
> scary.
> 
> > Some older clients may also not handle that error gracefully too,
> 
> Is it likely?  (How's the current client?)  Not sure what ungraceful
> handling would be, though, it would be an odd client that would do
> anything other than either FREE_STATEID or just give up.
> 

I think the current client will handle it sanely. I believe we detach
the delegation from the inode before issuing a delegreturn, so we
shouldn't end up triggering a new one from nfs4_handle_exception (which
was my main concern).

> I don't see any reason this case needs to be optimized, so if clients
> handle the REVOKED error then maybe it's OK.
> 
> > so just returning NFS4_OK might be best...
> 
> Anyway, after all that, yes, maybe so, if only out of conservatism
> about change.
> 

Yeah, that might be best, at least until we can come up with a reason
to change it.

-- 
Jeff Layton <jeff.layton@primarydata.com>
