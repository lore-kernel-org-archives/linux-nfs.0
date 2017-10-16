Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:45016 "EHLO
        elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755016AbdJPQP6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Oct 2017 12:15:58 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Trond Myklebust'" <trondmy@primarydata.com>,
        <bfields@fieldses.org>
Cc: <loghyr@excfb.com>, <linux-nfs@vger.kernel.org>, <nfsv4@ietf.org>,
        "'Thomas Haynes'" <loghyr@primarydata.com>
References: <1507740502-5151-1-git-send-email-Thomas.Haynes@primarydata.com> <E0161195-9F4A-4B36-A71D-6A924498C893@primarydata.com> <20171012194946.GC5233@fieldses.org> <6F78E570-F9B0-41A9-B224-3F2313AA8D4F@primarydata.com> <20171012214454.GA19598@fieldses.org> <20171012220051.GB29204@psyklo.internal.excfb.com> <20171013015223.GA21284@fieldses.org> <1507901666.4550.2.camel@primarydata.com> <20171013150021.GG5233@fieldses.org> <1507908409.9498.14.camel@primarydata.com>
In-Reply-To: <1507908409.9498.14.camel@primarydata.com>
Subject: RE: [nfsv4] pynfs replay cache test SEQ9f
Date: Mon, 16 Oct 2017 09:15:45 -0700
Message-ID: <000b01d3469a$0606e760$1214b620$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Fri, 2017-10-13 at 11:00 -0400, bfields@fieldses.org wrote:
> > On Fri, Oct 13, 2017 at 01:34:28PM +0000, Trond Myklebust wrote:
> > > On Thu, 2017-10-12 at 21:52 -0400, J. Bruce Fields wrote:
> > > > On Thu, Oct 12, 2017 at 03:00:51PM -0700, Tom Haynes wrote:
> > > > > On Thu, Oct 12, 2017 at 05:44:54PM -0400, J. Bruce Fields
> > > > > wrote:
> > > > > > Your mailer's not quoting right, it's a little hard for me to
> > > > > > find your replies.  Wading in:
> > > > > >
> > > > > > On Thu, Oct 12, 2017 at 09:39:04PM +0000, Thomas Haynes
> > > > > > wrote:
> > > > > > > On Oct 12, 2017, at 12:49 PM, J. Bruce Fields <bfields@fiel
> > > > > > > dses .org<mailto:bfields@fieldses.org>> wrote:
> > > > > > > > So I *think* the only correct options OK or FALSE_RETRY?
> > > > > > >
> > > > > > > It can=E2=80=99t be OK if the parameters to SEQUENCE differ.
> > > > > >
> > > > > > I'm getting that from: "When the replier detects a false
> > > > > > retry, it is permitted (but not always obligated) to return
> > > > > > NFS4ERR_FALSE_RETRY in response to the Sequence operation
> when
> > > > > > it detects a false retry."
> > > > >
> > > > > I think you are agreeing with me that OK is not appropriate
> > > > > here?
> > > >
> > > > No, I think OK is OK:
> > > >
> > > > > > If i understand the following language, we're required to
> > > > > > return FALSE_RETRY in the case the rpc credentials of the
> > > > > > caller map to different principals, but not otherwise.
> > > > >
> > > > > This one drove me crazy:
> > > > >
> > > > >    If a requester sent a Sequence operation with a slot ID and
> > > > > sequence
> > > > >    ID that are in the reply cache but the replier detected that
> > > > > the
> > > > >    retried request is not the same as the original request,
> > > > > including a
> > > > >    retry that has different operations or different arguments in
> > > > > the
> > > > >    operations from the original
> > > > >
> > > > > SEQUENCE is not special - both the compounds in this example
> > > > > only have the SEQUENCE op and they differ only in that in the
> > > > > first sa_cachethis is False and in the second it is True.
> > > > >
> > > > > So we have to return FALSE_SEQ_RETRY here...
> > > >
> > > > It says "if the replier detected" a difference, not "if there is"
> > > > a
> > > > difference.  So the replier is not required to do such detection.
> > > > This agrees with the "not always obligated" above.
> > > >
> > > > So I think it's allowed for the server to just return an old
> > > > cached response here (with the cached OK).  And I can't see any
> > > > practical problem that would create--a client shouldn't be sending
> > > > a different request with the same (slot, sequence) anyway.  The
> > > > only potential risk is the malicious client trying to snoop
> > > > somebody else's reply cache, hence the requirement in the case
> > > > principals differ.
> > >
> > > Clients may indeed send a different request with the same slot and
> > > sequence if they don't know that the server received the last
> > > request.
> > > This is tbe "user pressed ^C" scenario...
> > >
> > > Servers MAY ignore that fact, but they'd be really stupid to do
> > > so...
> >
> > OK, OK, I'll look into fixing the server (I'm pretty sure we get this
> > wrong).
> >
> > You've explained the ctrl-C case before and I don't think I understood
> > it.  I guess otherwise the only way for the client to sort out the
> > situation would be to retry the original request.  And that requires
> > keeping the arguments and credentials around to handle potential
> > retries.  And that's impractical if the process is going away?  OK.
> >
> 
> Right, we're not going to do that just for data that is just going to be =
tossed
> away anyway. We already guarantee that non-idempotent operations (the
> ones that we actually do ask the server to cache) are guaranteed to compl=
ete
> whether or not the user presses ^C, so this is mainly about what happens
> when somebody interrupts an operation that we did not want the server to
> cache.
> 
> I have a patch out there that just replays a SEQUENCE op if we detect tha=
t an
> RPC call was interrupted. That should be sufficient to deal with servers =
that
> cache everything (whether or not the client sets sa_cachethis), but don't=

> want to do NFS4ERR_SEQ_FALSE_RETRY. That particular combination has
> been seen to be extremely toxic to the current client, because it can get=

> replayed LOOKUP or GETATTR requests after someone presses ^C.

I'm wondering if Ganesha does this right...

Bruce, if there's something not covered by the pynfs tests, can we make sur=
e to add one?

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

