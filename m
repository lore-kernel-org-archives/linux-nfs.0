Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42978 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030388AbbD1SXa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2015 14:23:30 -0400
Date: Tue, 28 Apr 2015 14:23:29 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Saso Slavicic <saso.linux@astim.si>
Cc: linux-nfs@vger.kernel.org
Subject: Re: server_scope v4.1 lock reclaim
Message-ID: <20150428182329.GA16090@fieldses.org>
References: <000601d080b0$687a2860$396e7920$@astim.si>
 <20150427151944.GA2735@fieldses.org>
 <000101d081d2$984f1820$c8ed4860$@astim.si>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <000101d081d2$984f1820$c8ed4860$@astim.si>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2015 at 06:44:27PM +0200, Saso Slavicic wrote:
> > From: J. Bruce Fields
> > Sent: Monday, April 27, 2015 5:20 PM
> 
> > So in theory we could add some sort of way to configure the server scope
> > and then you could set the server scope to the same thing on all your
> > servers.
> >
> > But that's not enough to satisfy
> > https://tools.ietf.org/html/rfc5661#section-2.10.4, which also requires
> > stateid's and the rest to be compatible between the servers.
> 
> OK...I have to admit that with the amount of NFS HA tutorials and the
> improvements that NFS v4(.1) brings in the specs, I assumed that HA failover
> was supported. I apologize if that is not the case.

I'm afraid you're in the vanguard--I doubt many people have tried HA
with 4.1 and knfsd yet. (And I hadn't noticed the server scope problem,
thanks for bringing it up.)

> So, such a config option could be added but it's not planned to be added,
> since it could be wrongly used in some situations (ie. not doing
> active-to-passive failover)?
> Active-active setup is then totally out of the question?

I'm not sure what the right fix is yet.

> > In practice given current Linux servers and clients maybe that could
> > work, because in your situation the only case when they see each other's
> > stateid's is after a restart, in which case the id's will include a boot
> > time that will result in a STALE error as long as the server clocks are
> > roughly synchronized.  But that makes some assumptions about how our
> > servers generate id's and how the clients use them.  And I don't think
> > those assumptions are guaranteed by the spec.  It seems fragile.
> 
> I read (part of) the specs and stateids are supposed to hold over sessions
> but not for different client ids.
> Doing a wireshark dump, the (failover) server sends STALE_CLIENTID after
> reconnect so that should properly invalidate all the ids?

Since this is 4.1, I guess the first rpc the new server sees will have
either a clientid or a sessionid.  So we want to make sure the new
server will handle either of those correctly.

> Would I assume correctly that this is read from the nfsdcltrack? Is there
> even a need for this database to sync between each failover, if the client
> is already known since it's last failover (only the timestamp would be
> older)?

So, you're thinking of a case where there's a failover from server A to
server B, then back to server A again, and a single client is
continuously active throughout both failovers?

Here's the sort of case that's a concern:

	- A->B failover happens
	- client gets a file lock from B
	- client loses contact with B (network problem or something)
	- B->A failover happens.

At this point, should A allow the client to reclaim its lock?  B could
have given up on the client, released its lock, and granted conflicting
lock to other clients.  Or it might not have.  Neither the client nor A
knows, B's the only one that knows what happened, so we need to get that
database from B to find out.

--b.

> > If it's simple active-to-passive failover then I suppose you could
> > arrange for the utsname to be the same too.
> 
> I could, but then I don't know which server is active when I login to ssh :)
> What would happen, if the 'migration' mount option would be modified for
> v4.1 mounts not to check for server scope when doing reclaims (as opposed to
> configuring server scope)? :)
> 
> Thanks,
> Saso Slavicic
