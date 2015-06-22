Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f48.google.com ([209.85.216.48]:35048 "EHLO
	mail-vn0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbbFVVeO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jun 2015 17:34:14 -0400
Received: by vnbg129 with SMTP id g129so7845452vnb.2
        for <linux-nfs@vger.kernel.org>; Mon, 22 Jun 2015 14:34:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150623070414.2bbafec7@noble>
References: <20150622175318.6e840b23@noble>
	<CAHQdGtS2P7gU+9NWjEX5ejrtntMFv+8v6WCPRf3b7XCLuVXxLQ@mail.gmail.com>
	<20150623070414.2bbafec7@noble>
Date: Mon, 22 Jun 2015 17:34:12 -0400
Message-ID: <CAHQdGtS7pw3wicgAw9hdJrAQjtUKU==UhnaMGhNxcCnZ8WnnoQ@mail.gmail.com>
Subject: Re: [PATCH/RFC] NFSv4 - do not accept an incompatible delegation.
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.com>
Cc: NeilBrown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 22, 2015 at 5:04 PM, NeilBrown <neilb@suse.com> wrote:
>
> On Mon, 22 Jun 2015 07:41:11 -0400
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
> > Hi Neil,
> >
> > On Mon, Jun 22, 2015 at 3:53 AM, NeilBrown <neilb@suse.de> wrote:
> > >
> > > Hi,
> > >  this is my proposed solution to the problem I outlined in
> > >    NFSv4 state management issue - Linux disagrees with Netapp.
> > >  I haven't tested it yet (no direct access to the Netapp), but
> > >  I'll try to get some testing done.  RFC for now.
> > >
> > > NeilBrown
> > >
> > >
> > > When opening a file, nfs _nfs4_do_open() will return any
> > > incompatible delegation, meaning if the delegation held for
> > > that file does not give all the permissions required, it is
> > > returned.
> > > This is because various places assume that the current delegation
> > > provides all necessary access.
> > >
> > > However when a delegation is received, it is not validated in the
> > > same way so it is possible to, for example, hold a read-only
> > > delegation while the file is open write-only.
> > > When that delegation is recalled, the NFS client will try to
> > > reclaim the write-only open, and that will fail.
> > >
> >
> > I'd argue that the bug here is the attempt to reclaim the write-only
> > open; your previous email appeared to show that the client already
> > held a corresponding open stateid.
>
> I did consider that approach, but I managed to talk myself out of it...
> Let's see if I can talk you out of it too.
>
> There are potentially two state ids available for each open_owner+inode
> - an open_stateid and a delegation stateid.
>
> Linux does track which of read/write the delegation stateid permits,
> but does *not* track which the open_stateid permits.
> So when returning a delegation it does not know which of "read" and
> "write" need to be reclaimed (because open_stateid doesn't provide
> them) but it does know which cannot be reclaimed (because delegation
> stateid didn't provide them) - so it could just reclaim whatever it
> needs that the delegation *could* have provided.
> So this particular bug could be fixed that way.
>
> However, consider the scenario I described up to just before the 'link'
> system call.
> The client holds a write-only open_stateid and a read-only delegation
> stateid.
> If the client (same lockowner) opens the file read-only again the open
> will succeed without talking to the server on the strength of the
> delegation.
> update_open_stateid will then copy the delegation stateid into the state
> and all IO will use that stateid.  If a write is attempted with the
> still-open write-only fd, it will use the read-only delegation stateid
> and presumably get an error.

This is incorrect. As far as I know, a 4.1 client will do the following:

The NFSv4 open() code will catch the delegation as being insufficient
using can_open_delegated(), and will ensure that the client calls OPEN
in this case. The resulting open stateid is then saved in the
state->open_stateid.

If an I/O attempt is then made for an I/O type for which the
delegation cannot be used, then nfs4_select_rw_stateid() will return
either the lock stateid or the open stateid; whichever is appropriate.


> Unless I've missed something there is no code in Linux/NFS to
> selectively use one stateid for reads and another for writes - both
> coming from the same lockowner to the same inode.

See above.

> Presumably this is the reason that we have
> nf4_return_incompatible_delegation(): because Linux/NFS assumes that if
> it holds a delegation, that delegation covers all active open modes.
> For exactly the same reason, we need to reject a delegation if it
> doesn't cover all the open modes that are already active.
>
> Certainly we *could* track exactly which accesses the open_stateid
> allows, and could have (potentially) separate "read" and "write"
> stateids, but that paths wasn't the easiest so I didn't follow it.
>

I'm rather thinking that the simplest fix is simply to have
nfs4_open_delegation_recall() skip those file modes for which the
current delegation stateid is not appropriate. From a client
perspective, that should always make sense.

Cheers
  Trond
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
