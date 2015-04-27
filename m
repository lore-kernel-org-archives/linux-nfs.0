Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42057 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751336AbbD0PTp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Apr 2015 11:19:45 -0400
Date: Mon, 27 Apr 2015 11:19:44 -0400
To: Saso Slavicic <saso.linux@astim.si>
Cc: linux-nfs@vger.kernel.org
Subject: Re: server_scope v4.1 lock reclaim
Message-ID: <20150427151944.GA2735@fieldses.org>
References: <000601d080b0$687a2860$396e7920$@astim.si>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <000601d080b0$687a2860$396e7920$@astim.si>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 27, 2015 at 08:07:12AM +0200, Saso Slavicic wrote:
> I'm doing a NFS HA setup for KVM and need lock reclaim to work. I've been
> doing a lot of testing and reading in the past week and finally figured out
> that for reclaims to work on a 4.1 mount (4.1 is preferable due to
> RECLAIM_COMPLETE and thus faster failover), the server hostnames need to be
> the same. RFC specifies that reclaim can succeed if server scope is the same
> and in fact, the client will not even attempt a reclaim if the server scope
> does not match.
> 
> But...there doesn't seem to be any way of setting server scope other than
> changing server hostname? RFC states: "The purpose of the server scope is to
> allow a group of servers to indicate to clients that a set of servers
> sharing the same server scope value has arranged to use compatible values of
> otherwise opaque identifiers." The nfsdcltrack directory is properly handed
> over during failover so I'd need some way of configuring server scope on
> this "set of servers"? From the code, the server scope is simply set to
> utsname()->nodename in nfs4xdr.c.
> 
> What am I missing here, how can this work when Heartbeat needs different
> names for nodes?

So in theory we could add some sort of way to configure the server scope
and then you could set the server scope to the same thing on all your
servers.

But that's not enough to satisfy
https://tools.ietf.org/html/rfc5661#section-2.10.4, which also requires
stateid's and the rest to be compatible between the servers.

In practice given current Linux servers and clients maybe that could
work, because in your situation the only case when they see each other's
stateid's is after a restart, in which case the id's will include a boot
time that will result in a STALE error as long as the server clocks are
roughly synchronized.  But that makes some assumptions about how our
servers generate id's and how the clients use them.  And I don't think
those assumptions are guaranteed by the spec.  It seems fragile.

If it's simple active-to-passive failover then I suppose you could
arrange for the utsname to be the same too.

--b.
