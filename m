Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45315 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753466Ab3GPB6F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jul 2013 21:58:05 -0400
Date: Mon, 15 Jul 2013 21:58:03 -0400
From: "J.Bruce Fields" <bfields@citi.umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130716015803.GA5271@fieldses.org>
References: <20130710092255.0240a36d@notabene.brown>
 <20130710022735.GI8281@fieldses.org>
 <20130710143233.77e35721@notabene.brown>
 <20130710190727.GA22305@fieldses.org>
 <20130715143203.51bc583b@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130715143203.51bc583b@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 15, 2013 at 02:32:03PM +1000, NeilBrown wrote:
> On Wed, 10 Jul 2013 15:07:28 -0400 "J.Bruce Fields" <bfields@citi.umich.edu>
> wrote:
> 
> > On Wed, Jul 10, 2013 at 02:32:33PM +1000, NeilBrown wrote:
> > > On Tue, 9 Jul 2013 22:27:35 -0400 "J.Bruce Fields" <bfields@citi.umich.edu>
> > > wrote:
> > > 
> > > > On Wed, Jul 10, 2013 at 09:22:55AM +1000, NeilBrown wrote:
> > > > > 
> > > > > Hi,
> > > > >  I just noticed this commit:
> > > > > 
> > > > > commit 9660439861aa8dbd5e2b8087f33e20760c2c9afc
> > > > > Author: Olga Kornievskaia <aglo@citi.umich.edu>
> > > > > Date:   Tue Oct 21 14:13:47 2008 -0400
> > > > > 
> > > > >     svcrpc: take advantage of tcp autotuning
> > > > > 
> > > > > 
> > > > > which I must confess surprised me.  I wonder if the full implications of
> > > > > removing that functionality were understood.
> > > > > 
> > > > > Previously nfsd would set the transmit buffer space for a connection to
> > > > > ensure there is plenty to hold all replies.  Now it doesn't.
> > > > > 
> > > > > nfsd refuses to accept a request if there isn't enough space in the transmit
> > > > > buffer to send a reply.  This is important to ensure that each reply gets
> > > > > sent atomically without blocking and there is no risk of replies getting
> > > > > interleaved.
> > 
> > By the way, it's xpt_mutex that really guarantees non-interleaving,
> > isn't it?
> 
> Yes.  I had the two different things confused.  The issue is only about
> blocking on writes and consequently tying up nfsd threads.
> 
> > 
> > I think of the svc_tcp_has_wspace checks as solving a problem of
> > fairness between clients.  If we only had one client, everything would
> > work without them.  But when we have multiple clients we don't want a
> > single slow client to be able to tie block every thread waiting for that
> > client to receive read data.  Is that accurate?
> 
> It agrees with my understanding - yes.
> 
> 
> > 
> > > > > The server starts out with a large estimate of the reply space (1M) and for
> > > > > NFSv3 and v2 it quickly adjusts this down to something realistic.  For NFSv4
> > > > > it is much harder to estimate the space needed so it just assumes every
> > > > > reply will require 1M of space.
> > > > > 
> > > > > This means that with NFSv4, as soon as you have enough concurrent requests
> > > > > such that 1M each reserves all of whatever window size was auto-tuned, new
> > > > > requests on that connection will be ignored.
> > > > >
> > > > > This could significantly limit the amount of parallelism that can be achieved
> > > > > for a single TCP connection (and given that the Linux client strongly prefers
> > > > > a single connection now, this could become more of an issue).
> > > > 
> > > > Worse, I believe it can deadlock completely if the transmit buffer
> > > > shrinks too far, and people really have run into this:
> > > > 
> > > > 	http://mid.gmane.org/<20130125185748.GC29596@fieldses.org>
> > > > 
> > > > Trond's suggestion looked at the time like it might work and be doable:
> > > > 
> > > > 	http://mid.gmane.org/<4FA345DA4F4AE44899BD2B03EEEC2FA91833C1D8@sacexcmbx05-prd.hq.netapp.com>
> > > > 
> > > > but I dropped it.
> > > 
> > > I would probably generalise Trond's suggestion and allow "N" extra requests
> > > through that exceed the reservation, when N is related to the number of idle
> > > threads.  squareroot might be nice, but half is probably easiest.
> > > 
> > > If any send takes more than 30 seconds the sk_sndtimeo will kick in and close
> > > the connection so a really bad connection won't block threads indefinitely.
> > > 
> > > 
> > > And yes - a nice test case would be good.
> > > 
> > > What do you think of the following (totally untested - just for comment)?
> > 
> > In cases where the disk is the bottleneck, there aren't actually going
> > to be idle threads, are there?  In which case I don't think this helps
> > save a stuck client.
> 
> Do we care about the disk being a bottleneck?  We don't currently try to
> handle that situation at all - if the disk is slow, everything slows down.

Right, that's fine, it's just that:

Suppose you have a fast network, several fast clients all continuously
reading, and one slow disk.

Then in the steady state all the threads will be waiting on the disk,
and the receive buffers will all be full of read requests from the
various clients.  When a thread completes a read it will immediately
send the response, pick up the next request, and go back to waiting on
the disk.

Suppose the send buffer of one of the clients drops below the minimum
necessary.

Then aftert that point, I don't think that one client will ever have
another rpc processed, even after your proposed change.

Am I missing anything?

--b.
