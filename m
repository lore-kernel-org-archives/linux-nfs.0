Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55064 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466Ab3HUL1D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 07:27:03 -0400
Date: Wed, 21 Aug 2013 07:27:00 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Martin Hicks <mort@bork.org>, linux-nfs@vger.kernel.org
Subject: Re: server mountpoint busy after unexporting nfs4 share
Message-ID: <20130821112700.GD25198@fieldses.org>
References: <CAJUS3XmebzQHnQNwEYECUjYyK+nj2cVpKz_-4gmPacEWzmxEZQ@mail.gmail.com>
 <20130816211217.GB21539@fieldses.org>
 <20130821124343.4f5462cc@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130821124343.4f5462cc@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 21, 2013 at 12:43:43PM +1000, NeilBrown wrote:
> On Fri, 16 Aug 2013 17:12:18 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Thu, Aug 15, 2013 at 12:04:33PM -0400, Martin Hicks wrote:
> > > I'm wondering if I'm missing something or if this is a bug.
> > > 
> > > A NFS4 export has active clients.  The mount is removed from
> > > /etc/exports and 'exportfs -r' is run.  Clients immediately start
> > > getting 'Stale file handle' errors, but the mountpoint is still busy
> > > and cannot be unmounted.  Killing off nfsd solves the problem, but is
> > > undesirable for obvious reasons.
> > > 
> > > On debian linux, kernel version 3.10-2-amd64,  with nfs-utils 1.2.8.
> > 
> > Yeah, the clients may hold opens or locks on the filesystem and those
> > don't get removed on exports -r.
> > 
> > For now shutting down the server is the only solution.
> 
> How far does:
>   echo /path/to/export > /proc/fs/nfsd/unlock_filesystem
> get you? Or does that just drop 'lockd' locks and not NFSv4 locks?

Right, it just does lockd locks.  It should also do NFSv4 locks, opens,
and delegations.  Happy if somebody wants to finish that job off--it
probably wouldn't be too hard?  Although there may be a bit of work to
get the error returns right in the v4 case--I think we'd want to keep
the relevant stateid's around and return NFS4ERR_ADMIN_REVOKED when a
client continues to use them.

--b.
