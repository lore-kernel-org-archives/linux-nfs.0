Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35383 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751989AbbFVVEW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Jun 2015 17:04:22 -0400
Date: Tue, 23 Jun 2015 07:04:14 +1000
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: NeilBrown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] NFSv4 - do not accept an incompatible delegation.
Message-ID: <20150623070414.2bbafec7@noble>
In-Reply-To: <CAHQdGtS2P7gU+9NWjEX5ejrtntMFv+8v6WCPRf3b7XCLuVXxLQ@mail.gmail.com>
References: <20150622175318.6e840b23@noble>
	<CAHQdGtS2P7gU+9NWjEX5ejrtntMFv+8v6WCPRf3b7XCLuVXxLQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 22 Jun 2015 07:41:11 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Hi Neil,
> 
> On Mon, Jun 22, 2015 at 3:53 AM, NeilBrown <neilb@suse.de> wrote:
> >
> > Hi,
> >  this is my proposed solution to the problem I outlined in
> >    NFSv4 state management issue - Linux disagrees with Netapp.
> >  I haven't tested it yet (no direct access to the Netapp), but
> >  I'll try to get some testing done.  RFC for now.
> >
> > NeilBrown
> >
> >
> > When opening a file, nfs _nfs4_do_open() will return any
> > incompatible delegation, meaning if the delegation held for
> > that file does not give all the permissions required, it is
> > returned.
> > This is because various places assume that the current delegation
> > provides all necessary access.
> >
> > However when a delegation is received, it is not validated in the
> > same way so it is possible to, for example, hold a read-only
> > delegation while the file is open write-only.
> > When that delegation is recalled, the NFS client will try to
> > reclaim the write-only open, and that will fail.
> >
> 
> I'd argue that the bug here is the attempt to reclaim the write-only
> open; your previous email appeared to show that the client already
> held a corresponding open stateid.

I did consider that approach, but I managed to talk myself out of it...
Let's see if I can talk you out of it too.

There are potentially two state ids available for each open_owner+inode
- an open_stateid and a delegation stateid.

Linux does track which of read/write the delegation stateid permits,
but does *not* track which the open_stateid permits.
So when returning a delegation it does not know which of "read" and
"write" need to be reclaimed (because open_stateid doesn't provide
them) but it does know which cannot be reclaimed (because delegation
stateid didn't provide them) - so it could just reclaim whatever it
needs that the delegation *could* have provided.
So this particular bug could be fixed that way.

However, consider the scenario I described up to just before the 'link'
system call.
The client holds a write-only open_stateid and a read-only delegation
stateid.
If the client (same lockowner) opens the file read-only again the open
will succeed without talking to the server on the strength of the
delegation.
update_open_stateid will then copy the delegation stateid into the state
and all IO will use that stateid.  If a write is attempted with the
still-open write-only fd, it will use the read-only delegation stateid
and presumably get an error.

Unless I've missed something there is no code in Linux/NFS to
selectively use one stateid for reads and another for writes - both
coming from the same lockowner to the same inode.

Presumably this is the reason that we have
nf4_return_incompatible_delegation(): because Linux/NFS assumes that if
it holds a delegation, that delegation covers all active open modes.
For exactly the same reason, we need to reject a delegation if it
doesn't cover all the open modes that are already active.

Certainly we *could* track exactly which accesses the open_stateid
allows, and could have (potentially) separate "read" and "write"
stateids, but that paths wasn't the easiest so I didn't follow it.

Convinced?

NeilBrown
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
