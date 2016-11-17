Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50382 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752142AbcKQURy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Nov 2016 15:17:54 -0500
Date: Thu, 17 Nov 2016 15:17:53 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        "tibbs@math.uh.edu" <tibbs@math.uh.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
Message-ID: <20161117201753.GF20937@fieldses.org>
References: <ufaegbvdslg.fsf@epithumia.math.uh.edu>
 <20160301004844.GA11952@fieldses.org>
 <ufay4a3c938.fsf@epithumia.math.uh.edu>
 <20160301010120.GB11952@fieldses.org>
 <ufapovfc8m4.fsf@epithumia.math.uh.edu>
 <ufa1syb402e.fsf@epithumia.math.uh.edu>
 <20161117163101.GA19161@fieldses.org>
 <1479404750.33885.1.camel@primarydata.com>
 <20161117193239.GD20937@fieldses.org>
 <CAN-5tyFP8QapcfuG5pO2059ftf3wGhmaO=6RZAA+W_nYbVraPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyFP8QapcfuG5pO2059ftf3wGhmaO=6RZAA+W_nYbVraPQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 17, 2016 at 02:58:12PM -0500, Olga Kornievskaia wrote:
> On Thu, Nov 17, 2016 at 2:32 PM, bfields@fieldses.org
> <bfields@fieldses.org> wrote:
> > On Thu, Nov 17, 2016 at 05:45:52PM +0000, Trond Myklebust wrote:
> >> On Thu, 2016-11-17 at 11:31 -0500, J. Bruce Fields wrote:
> >> > On Wed, Nov 16, 2016 at 02:55:05PM -0600, Jason L Tibbitts III wrote:
> >> > >
> >> > > I'm replying to a rather old message, but the issue has just now
> >> > > popped
> >> > > back up again.
> >> > >
> >> > > To recap, a client stops being able to access _any_ mount on a
> >> > > particular server, and "NFS: nfs4_reclaim_open_state: Lock reclaim
> >> > > failed!" appears several hundred times per second in the kernel
> >> > > log.
> >> > > The load goes up by one for ever process attempting to access any
> >> > > mount
> >> > > from that particular server.  Mounts to other servers are fine, and
> >> > > other clients can mount things from that one server without
> >> > > problems.
> >> > >
> >> > > When I kill every process keeping that particular mount active and
> >> > > then
> >> > > umount it, I see:
> >> > >
> >> > > NFS: nfs4_reclaim_open_state: unhandled error -10068
> >> >
> >> > NFS4ERR_RETRY_UNCACHED_REP.
> >> >
> >> > So, you're using NFSv4.1 or 4.2, and the server thinks that the
> >> > client
> >> > has reused a (slot, sequence number) pair, but the server doesn't
> >> > have a
> >> > cached response to return.
> >> >
> >> > Hard to know how that happened, and it's not shown in the below.
> >> > Sounds like a bug, though.
> >>
> >> ...or a Ctrl-C....
> >
> > How does that happen?
> >
> 
> If I may chime in...
> 
> Bruce, when an application sends a Ctrl-C and clients's session slot
> has sent out an RPC but didn't process the reply, the client doesn't
> know if the server processed that sequence id or not. In that case,
> the client doesn't increment the sequence number. Normally the client
> would handle getting such an error by retrying again (and resetting
> the slots) but I think during recovery operation the client handles
> errors differently (by just erroring). I believe the reasoning that we
> don't want to be stuck trying to recover from the recovery from the
> recovery etc...

So in that case the client can end up sending a different rpc reusing
the old slot and sequence number?

--b.

> 
> Jason,
> 
> The UNCACHED_REP error is really not interesting as it's a consequence
> of you having a client that already failed with an error of "unable to
> reclaim the locks". I'm surprised that the application doesn't error
> at this point with EIO. But that aside, I think I've seen this kind of
> behavior due to client't callback channel going down (and not replying
> to the CB_RECALLs and then server revoking state).
> 
> 
> 
> > --b.
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
