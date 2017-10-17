Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48664 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934833AbdJQVbV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 17:31:21 -0400
Date: Tue, 17 Oct 2017 17:31:20 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Thomas Haynes <loghyr@primarydata.com>,
        "loghyr@excfb.com" <loghyr@excfb.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: pynfs replay cache test SEQ9f
Message-ID: <20171017213120.GD28711@fieldses.org>
References: <E0161195-9F4A-4B36-A71D-6A924498C893@primarydata.com>
 <20171012194946.GC5233@fieldses.org>
 <6F78E570-F9B0-41A9-B224-3F2313AA8D4F@primarydata.com>
 <20171012214454.GA19598@fieldses.org>
 <20171012220051.GB29204@psyklo.internal.excfb.com>
 <20171013015223.GA21284@fieldses.org>
 <1507901666.4550.2.camel@primarydata.com>
 <20171013150021.GG5233@fieldses.org>
 <1507908409.9498.14.camel@primarydata.com>
 <20171013185015.GA15087@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171013185015.GA15087@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 13, 2017 at 02:50:15PM -0400, bfields@fieldses.org wrote:
> On Fri, Oct 13, 2017 at 03:26:51PM +0000, Trond Myklebust wrote:
> > On Fri, 2017-10-13 at 11:00 -0400, bfields@fieldses.org wrote:
> > > OK, OK, I'll look into fixing the server (I'm pretty sure we get this
> > > wrong).
> > > 
> > > You've explained the ctrl-C case before and I don't think I
> > > understood
> > > it.  I guess otherwise the only way for the client to sort out the
> > > situation would be to retry the original request.  And that requires
> > > keeping the arguments and credentials around to handle potential
> > > retries.  And that's impractical if the process is going away?  OK.
> > > 
> > 
> > Right, we're not going to do that just for data that is just going to
> > be tossed away anyway. We already guarantee that non-idempotent
> > operations (the ones that we actually do ask the server to cache) are
> > guaranteed to complete whether or not the user presses ^C, so this is
> > mainly about what happens when somebody interrupts an operation that we
> > did not want the server to cache.
> > 
> > I have a patch out there that just replays a SEQUENCE op if we detect
> > that an RPC call was interrupted. That should be sufficient to deal
> > with servers that cache everything (whether or not the client sets
> > sa_cachethis), but don't want to do NFS4ERR_SEQ_FALSE_RETRY. That
> > particular combination has been seen to be extremely toxic to the
> > current client, because it can get replayed LOOKUP or GETATTR requests
> > after someone presses ^C.
> 
> Those all involve uncached compounds with more than one op.  My reading
> of knfsd code is that it will return RETRY_UNCACHED_REP in this case,
> and I think (I might be misunderstanding) that the client will bump the
> slot seqid and retry in that case.  So I *think* you shouldn't be seeing
> that problem with knfsd?

Argh, no, you're sending a bare SEQUENCE so of course there's just one
op.

And looking at Olga's COPY example and the code....  The server gets
confused in this case and returns a reply to the SEQUENCE, nothing else,
but sets the reply's opcnt to the count taken from the original call,
for some reason.

So, the server's returning a corrupt reply.  It needs to return a reply
that's actually legal xdr and SEQUENCE results that match the call.
Beyond that it probably doesn't matter exactly what it returns--either
it handles it as a replay and doesn't bump the seqid, or a new call and
does, but either way the seqid ends up in the same place, which is the
goal here.  OK.

--b.
