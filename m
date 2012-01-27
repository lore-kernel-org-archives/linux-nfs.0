Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3491 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755872Ab2A0PnG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Jan 2012 10:43:06 -0500
Date: Fri, 27 Jan 2012 10:43:00 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Message-ID: <20120127104300.6159ec82@tlielax.poochiereds.net>
In-Reply-To: <20120125212553.GA22216@fieldses.org>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
 <20120124230855.GE12426@fieldses.org>
 <20120125064158.4551a012@tlielax.poochiereds.net>
 <20120125131116.GA17873@fieldses.org>
 <20120125083820.637c8362@tlielax.poochiereds.net>
 <F6C58345-828B-493E-9D0E-8BBC60E348CF@oracle.com>
 <20120125171401.GI17873@fieldses.org>
 <D13C2C6D-7731-4EE6-BC3D-2A9D1D1F0581@oracle.com>
 <20120125185529.GJ17873@fieldses.org>
 <20120125152356.10bdd772@tlielax.poochiereds.net>
 <20120125212553.GA22216@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 25 Jan 2012 16:25:53 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jan 25, 2012 at 03:23:56PM -0500, Jeff Layton wrote:
> > I suggest that we only allow the reclaim of locks
> > on the original address against which they were established.
> 
> I'm not sure what that means.
> 
> If a server stops responding, the v4.0 client has two choices: it can
> either wait for the server to come back, and reclaim when it does.  Or
> if it supports failover it can go find another server and perform
> reclaims over there.
> 
> I'm a little unclear how it does that, but I suppose it first tests
> somehow to see whether its existing state is supported, and if not, it
> establishes a new clientid with SETCLIENTID/SETCILENTID_CONFIRM using
> its old name, and then attempts to reclaim.
> 
> You're now requiring it *not* to do that if it happens that the servers
> all rebooted in the meantime.  How does it know that that's what
> happened?
> 
> Or maybe that's not what you want to require, I'm not sure.
> 

Sorry I didn't respond sooner. I spent some time yesterday poring
over Dave's whitepaper and the RFCs to see if I could figure out a
better way to do this. Short answer: I don't think we can...

By the above, I meant that we can't reasonably allow a client to
acquire a lock on address A and then reclaim that lock on address B
after a reboot. But now I'm not even certain that's sufficient to
prevent all possible problems after a cold-start of the cluster.

In particular, I'm concerned about this one (from my earlier email):

> Don't worry, it gets worse...suppose we end up with the mounting
> subdirectories of the same mount from different hosts (say,
> node1:/exp2/dir1 node2:/exp2/dir2 -- it's pathological, but there's no
> reason you couldn't do that). Now, it's not even sufficient to track
> this info on a per-node + per-fs basis...

We have no way to prevent someone from doing the above, or even to
reliably detect whether this has been done. The only way that I can see
that we could handle the above situation would be to track each
individual lock on stable storage along with enough information to know
which client owns it at a particular time. That's something I really
don't want to implement at this point in time...

I'm going to continue researching this and seeing if I can come up with
a way to handle the clustered configuration sanely. What I'll probably
plan to do in the interim is to fix the patchsets that I have so far to
at least work properly in the single-node case. I'll also try to
"future-proof" the upcall format such that a clustered configuration
hopefully won't require much in the way of changes.

-- 
Jeff Layton <jlayton@redhat.com>
