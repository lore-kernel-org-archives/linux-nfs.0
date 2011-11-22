Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36464 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756172Ab1KVVFS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Nov 2011 16:05:18 -0500
Date: Tue, 22 Nov 2011 16:05:18 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC] NFS: Cache state owners after files are closed
Message-ID: <20111122210517.GH21451@fieldses.org>
References: <20111122174225.1866.25410.stgit@degas.1015granger.net>
 <20111122193638.GB21451@fieldses.org>
 <5CE4FEAE-3432-4F87-ABC8-DBFE4FAF91C7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5CE4FEAE-3432-4F87-ABC8-DBFE4FAF91C7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 22, 2011 at 03:14:03PM -0500, Chuck Lever wrote:
> 
> On Nov 22, 2011, at 2:36 PM, J. Bruce Fields wrote:
> 
> > On Tue, Nov 22, 2011 at 12:52:53PM -0500, Chuck Lever wrote:
> >> Servers have a finite amount of memory to store NFSv4 open and lock
> >> owners.  Moreover, servers may have a difficult time determining when
> >> they can reap their state owner table, thanks to gray areas in the
> >> NFSv4 protocol specification.
> > 
> > What's the gray area?
> > 
> > Reminding myself: OK, I guess it's the NFSv4.0 close-replay problem.
> > You have to keep around enough information about a closed stateid to
> > handle a replay.  If a client reuses the stateowner than you can purge
> > that as soon as you bump the sequence number, otherwise you have to keep
> > it around a while (how long is unclear).
> 
>                     ^^^^^^^^^^^^^^^^^^^^
> That's the problem.
> 
> When the server can't store any more state owners, it has to use heuristics to reap unused state owners, or it can have the client perform state recovery to determine which state owners the client wants to keep around.  Or, it can return NFS4ERR_RESOURCE and hope for the best.

Yeah.  All the Linux server currently does is keep them around for a
lease period, then purge them.

That strikes me as too short a time to catch a lot of replays, but
possibly too long in the face of a client creating a lot of new
openowners.

Anyway, making the client less agressive seems like the most important
thing, thanks.

--b.
