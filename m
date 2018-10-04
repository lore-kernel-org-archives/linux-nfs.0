Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua1-f65.google.com ([209.85.222.65]:45296 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727615AbeJEBqC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Oct 2018 21:46:02 -0400
Received: by mail-ua1-f65.google.com with SMTP id c10so2262785uao.12
        for <linux-nfs@vger.kernel.org>; Thu, 04 Oct 2018 11:51:28 -0700 (PDT)
MIME-Version: 1.0
References: <20180905192400.107485-1-trond.myklebust@hammerspace.com>
 <20180905192400.107485-2-trond.myklebust@hammerspace.com> <20180905192400.107485-3-trond.myklebust@hammerspace.com>
 <20180905192400.107485-4-trond.myklebust@hammerspace.com> <20180905192400.107485-5-trond.myklebust@hammerspace.com>
 <20180905192400.107485-6-trond.myklebust@hammerspace.com> <CAN-5tyG_qr7P8-2_yXAqDvQps0C06AQUuNuBBbYpUcWUsXEVYg@mail.gmail.com>
 <CAN-5tyGoywV9_cqv9jwHS7s58sX49baG4HXLn85ka-jHySxT0g@mail.gmail.com>
 <9dbc1442dd1e7bba1903a5ecf2855054ffcd0ee4.camel@gmail.com>
 <CAN-5tyH=YKiTb4ZWUeJgZg+TDJP9W2yP8acapKSs=km5RTU_6Q@mail.gmail.com>
 <cf7ee206ca825e243f671ccc3a0f3c332e144174.camel@hammerspace.com>
 <CAN-5tyGBufKA6Bn1AsB7yLviVGr5SHGyRc4z4hrKF-hScTrQXg@mail.gmail.com>
 <CAN-5tyGrjjGKG5KoDAgzLrnnzjGUqmf1iUD_AM=wbX8bD5Jk-g@mail.gmail.com>
 <983c9970070f98ac54526742e6c4de4b0ff7ad63.camel@hammerspace.com>
 <CAN-5tyGt+J=irZQgByH_nXOtXkztsyjjzLwEfrXHs2UzOZXEHA@mail.gmail.com>
 <6caf095d3bf43494d25dfe854f2cd87f8eab5adf.camel@hammerspace.com>
 <CAN-5tyFG41UaAkFyLxFVx308r7r1DsCG2_QqDtw5gvUr0ryfLg@mail.gmail.com>
 <012393cb0b1bcb0a2a95650f2929f8d439c8913c.camel@hammerspace.com>
 <CAN-5tyF0XefktaY0moUvVagbs6DOLD8b0t0S34BH6FXKkFbJxQ@mail.gmail.com>
 <81e98d8bd299449b600ebbedcf53fdffa59d3cca.camel@hammerspace.com>
 <CAN-5tyFW9+04uqtSAqq=J+uD3d5TdGNZs_1RL-_W7+iNLEE99A@mail.gmail.com> <f085fa2a4f26c1b0a73a33ee55900e7dc7220859.camel@hammerspace.com>
In-Reply-To: <f085fa2a4f26c1b0a73a33ee55900e7dc7220859.camel@hammerspace.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 4 Oct 2018 14:51:16 -0400
Message-ID: <CAN-5tyFh6U_=VhBwRTsD261WbJmsJesYrXr9fPMNvt1MQ7ZwZg@mail.gmail.com>
Subject: Re: [PATCH 5/7] NFS: Convert lookups of the open context to RCU
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 4, 2018 at 12:42 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> On Thu, 2018-10-04 at 12:31 -0400, Olga Kornievskaia wrote:
> > On Thu, Oct 4, 2018 at 12:13 PM Trond Myklebust <
> > trondmy@hammerspace.com> wrote:
> > >
> > > On Thu, 2018-10-04 at 11:49 -0400, Olga Kornievskaia wrote:
> > > > On Thu, Oct 4, 2018 at 11:22 AM Trond Myklebust <
> > > > trondmy@hammerspace.com> wrote:
> > > > >
> > > > > Hi Olga,
> > > > >
> > > > > On Wed, 2018-10-03 at 14:38 -0400, Olga Kornievskaia wrote:
> > > > > > Hi Trond,
> > > > > >
> > > > > > Here's why the ordering of the "open_files" list matters and
> > > > > > changes/fixes the existing problem.
> > > > > >
> > > > > > When we first open the file for writing and get a delegation,
> > > > > > it's
> > > > > > the
> > > > > > first one on the list. When we opened the file again for the
> > > > > > same
> > > > > > mode
> > > > > > type, then before the patch, the new entry is inserted before
> > > > > > what's
> > > > > > already on the list. Both of these files share the same
> > > > > > nfs4_state
> > > > > > that's marked delegated.
> > > > > >
> > > > > > Once we receive a delegation recall, in
> > > > > > delegation_claim_opens()
> > > > > > we
> > > > > > walk the list. First one will be the 2nd open. It's marked
> > > > > > delegated
> > > > > > but after calling nfs4_open_delegation_recall() the
> > > > > > delegation
> > > > > > flag
> > > > > > is
> > > > > > cleared. The 2nd open doesn't have the lock associated with
> > > > > > it.
> > > > > > So no
> > > > > > lock is reclaimed. We now go to the 2nd entry in the
> > > > > > open_file
> > > > > > list
> > > > > > which is the 1st open but now the delegation flag is cleared
> > > > > > so
> > > > > > we
> > > > > > never recover the lock.
> > > > > >
> > > > > > Any of the opens on the open_list can be the lock holder and
> > > > > > we
> > > > > > can't
> > > > > > clear the delegation flag on the first treatment of the
> > > > > > delegated
> > > > > > open
> > > > > > because it might not be the owner of the lock.
> > > > > >
> > > > > > I'm trying to figure out how I would fix it but I thought I'd
> > > > > > send
> > > > > > this for your comments.
> > > > >
> > > > > The expectation here is that once we find an open context with
> > > > > a
> > > > > stateid that needs to be reclaimed or recovered, we recover
> > > > > _all_
> > > > > the
> > > > > state associated with that stateid.
> > > > > IOW: the expectation is that we first look at the open state,
> > > > > and
> > > > > (depending on whether this is a write delegation or a read
> > > > > delegation)
> > > > > run through a set of calls to nfs4_open_recover_helper() that
> > > > > will
> > > > > recover all outstanding open state for this file.
> > > >
> > > > That's true. I see that it will recover all the outstanding opens
> > > > for
> > > > this file.
> > > >
> > > > > We then iterate through all the lock stateids for the file and
> > > > > recover
> > > > > those.
> > > >
> > > > However this is not true. Because we pass in a specific
> > > > nfs_open_context into the nfs_delegation_claim_locks() and while
> > > > looping thru the list of locks for the file we compare if the
> > > > open
> > > > context associated with the file lock is same as the passed in
> > > > context. The passed in context is that of the first
> > > > nfs_open_context
> > > > that was marked delegated and not necessarily the context that
> > > > hold
> > > > the locks. That's the problem.
> > > >
> > > > While we are looping thru the locks for the file, we need to be
> > > > checking against any and all the nfs_open_context that are
> > > > associated
> > > > with the file and recovering those locks. I'm still not sure how
> > > > to
> > > > do
> > > > it.
> > > >
> > >
> > > Interesting. Why are we checking that open context? I can't see any
> > > reason why we would want to do that.
> >
> > I'm thinking it's probably because we might have open context
> > (non-delegated) on this file that holds a lock (say we opened with
> > O_DIRECT and got a lock; that lock was sent to the server so doesn't
> > need to recovered). Then we opened a file again and got a delegation
> > and got a different lock. When we are looping thru the locks for the
> > file, we only need to recover the 2nd one.
> >
> > I'm thinking can't we check that the passed in state is the same that
> > is what we get nfs_file_open_context(fl->fl_file)->state ? I'm
> > testing
> > it now...
>
> There is nothing in the protocol that stops you from recovering a lock
> twice (unless the server does Microsoft stacked locks, which our client
> doesn't support). I'd prefer to just go for simplicity here, and
> recover everything.
>
> ...and yes, I agree that we should select the locks to recover based on
> the state. As I said, that was the expectation in the first place.

Ok. I sent out a patch but not sure if you want something that just
removes the check all together.





>
> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
>
