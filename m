Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44265 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752019Ab2AYUxm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 15:53:42 -0500
Date: Wed, 25 Jan 2012 15:53:40 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Message-ID: <20120125205340.GA21335@fieldses.org>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
 <20120124230855.GE12426@fieldses.org>
 <20120125064158.4551a012@tlielax.poochiereds.net>
 <20120125131116.GA17873@fieldses.org>
 <20120125083820.637c8362@tlielax.poochiereds.net>
 <F6C58345-828B-493E-9D0E-8BBC60E348CF@oracle.com>
 <20120125171401.GI17873@fieldses.org>
 <D13C2C6D-7731-4EE6-BC3D-2A9D1D1F0581@oracle.com>
 <20120125185529.GJ17873@fieldses.org>
 <7D6EA28C-26F1-46A3-B1C5-6BC6F6AE713D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7D6EA28C-26F1-46A3-B1C5-6BC6F6AE713D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2012 at 03:29:34PM -0500, Chuck Lever wrote:
> 
> On Jan 25, 2012, at 1:55 PM, J. Bruce Fields wrote:
> 
> > On Wed, Jan 25, 2012 at 12:41:27PM -0500, Chuck Lever wrote:
> >> If SETCLIENTID returns a unique clientid4 that a client hasn't seen from other servers, the client knows that's a unique server instance which must be recovered separately after a reboot.
> > 
> > Hm, but does it have to do the recovery with that server?
> 
> If a client has a lease and open state on that server, it should do recovery if the server reboots.

Yes, but does it have to do it against *that* server, or could it
recover against another?

Again, as long as failover is allowed, I think the latter is too.

> > And if so, then how does that fit with failover?
> 
> We were supposed to discuss that with Bill and Piyush.  Maybe we can bring it up again at Connectathon.  But my assumption is that fail over is supposed to look like a server reboot.

That's what I assume too: but that means, if I'm a client, and I fail
over from server A to server B, and server B gives me a STALE error: I
don't know if that's just because I failed over, or if in fact A and/or
B did just reboot.

And from the point of view of the servers: they don't know if the state
I'm trying to reclaim is state I previously held from server A, or if
it's some other state that I previously held on server C (but then lost,
unbeknownst to me, due to a network partition that lost my RENEWs to C).

So I guess the servers would be stuck trying to track all that state
across reboots?

> The question is what clients does the server allow to recover, and which does it force to start fresh?  Shouldn't it be enough for a server to remember nfs_client_id4 strings?
> 
> > I mean, suppose the whole cluster is rebooted.  From the client's point
> > of view, its server becomes unresponsive.  So it should probably start
> > pinging the replicas to see if another one's up.  The first server it
> > gets a response from won't necessarily be the one it was using before.
> > What happens next?
> 
> Again, it depends on whether your clustering implementation shares state among all servers in the cluster.

Assume for now it doesn't.

--b.
