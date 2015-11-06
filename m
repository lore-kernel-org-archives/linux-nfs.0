Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:36478 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161370AbbKFOTw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Nov 2015 09:19:52 -0500
Received: by qgad10 with SMTP id d10so92355483qga.3
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2015 06:19:51 -0800 (PST)
Date: Fri, 6 Nov 2015 09:19:47 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Andrew W Elble <aweits@rit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Bruce James Fields <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: fix nfsd4_delegreturn to return correct error
 codes
Message-ID: <20151106091947.76de6de7@synchrony.poochiereds.net>
In-Reply-To: <CAHQdGtSNC_j7M9y40tNe=WzsqoECa3Y5gMSRsqx3bKsf79TsHA@mail.gmail.com>
References: <1446674837-4980-1-git-send-email-aweits@rit.edu>
	<CAHQdGtShZ=6J9h1hW00zPZ+TWzAYmfSiET-1mEdv1-H=JGEgcA@mail.gmail.com>
	<m2mvurnum3.fsf@discipline.rit.edu>
	<CAHQdGtSbxKDHSD+kxv5Fa6CLoSrB3KjeRjyTsNDhR47VYCUgOg@mail.gmail.com>
	<CAHQdGtSNC_j7M9y40tNe=WzsqoECa3Y5gMSRsqx3bKsf79TsHA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 6 Nov 2015 09:03:50 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Fri, Nov 6, 2015 at 8:48 AM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> > On Fri, Nov 6, 2015 at 8:08 AM, Andrew W Elble <aweits@rit.edu> wrote:
> >>
> >>> Umm... If the client is sending delegreturn, then why not destroy the
> >>> delegation?
> >>
> >> ObDisclaimer: My "internal" version of this patch does just that.
> >>
> >> If the DELEGRETURN is the first time that the client hears of the
> >> revocation, I'm guessing that there isn't anything that can be done to
> >> rewind time and do anything differently. But as Bruce points out, it
> >> seems like there are other places where NFS4ERR_DELEG_REVOKED should be
> >> being returned.
> >>
> >>> What is the point of forcing the client to send
> >>> FREE_STATEID, when it is telling you that it is no longer caching any
> >>> locks or associated state and is no longer interested in keeping the
> >>> delegation?
> >>
> >> But - I keep re-reading RFC5661, and I can't figure out how this is
> >> what was intended.
> >>
> >> It seems like the "correct" thing to do is inform the client (via probably
> >> too many different methods) that the/a delegation is revoked and let it
> >> acknowledge via FREE_STATEID. The allowed error returns in 15.2 seem to
> >> confirm this view.
> >
> > Just because the protocol _allows_ you to do this, it doesn't mean
> > that it is the right thing to do.
> > Section 8.2.4. reads:
> >
> >    Stateids must remain valid until either a client restart or a server
> >    restart or until the client returns all of the locks associated with
> >    the stateid by means of an operation such as CLOSE or DELEGRETURN.
> >    If the locks are lost due to revocation, as long as the client ID is
> >    valid, the stateid remains a valid designation of that revoked state
> >    until the client frees it by using FREE_STATEID.
> >
> > In this case, there are no lost locks due to revocation.
> >
> > The client has presumably not received NFS4ERR_DELEG_REVOKED on any of
> > its previous uses of the delegation stateid and it has presumably not
> > seen any SEQ4_STATUS_* notifications when recovering locks, since both
> > of those situations should cause the client to switch to using
> > TEST_STATEID/FREE_STATEID instead of a DELEGRETURN.
> >
> > So, what exactly is the client supposed to do differently when the
> > server replies NFS4ERR_DELEG_REVOKED to the DELEGRETURN other than
> > send a completely redundant FREE_STATEID? Why couldn't the server just
> > return NFS4ERR_OK?
> 
> BTW: even if you do return NFS4ERR_DELEG_REVOKED, there is precisely
> zero value in keeping the stateid around. It is perfectly legitimate
> to reply NFS4ERR_BAD_STATEID in reply to FREE_STATEID.

Yeah, agreed. Now that I think about it, you should just go ahead and
destroy the delegation as the client is signaling that it's through
with it anyway.

Hmm...so is there any advantage to reporting NFS4ERR_DELEG_REVOKED
there at all? I guess that could be a signal that it may not have held
a delegation that it thought it had, but it's probably too late to do
anything about it if that occurs. Some older clients may also not
handle that error gracefully too, so just returning NFS4_OK might be
best...

-- 
Jeff Layton <jeff.layton@primarydata.com>
