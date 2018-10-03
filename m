Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vs1-f50.google.com ([209.85.217.50]:35184 "EHLO
        mail-vs1-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726851AbeJDB2p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Oct 2018 21:28:45 -0400
Received: by mail-vs1-f50.google.com with SMTP id c10so3856274vsk.2
        for <linux-nfs@vger.kernel.org>; Wed, 03 Oct 2018 11:39:10 -0700 (PDT)
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
 <CAN-5tyGt+J=irZQgByH_nXOtXkztsyjjzLwEfrXHs2UzOZXEHA@mail.gmail.com> <6caf095d3bf43494d25dfe854f2cd87f8eab5adf.camel@hammerspace.com>
In-Reply-To: <6caf095d3bf43494d25dfe854f2cd87f8eab5adf.camel@hammerspace.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 3 Oct 2018 14:38:58 -0400
Message-ID: <CAN-5tyFG41UaAkFyLxFVx308r7r1DsCG2_QqDtw5gvUr0ryfLg@mail.gmail.com>
Subject: Re: [PATCH 5/7] NFS: Convert lookups of the open context to RCU
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Here's why the ordering of the "open_files" list matters and
changes/fixes the existing problem.

When we first open the file for writing and get a delegation, it's the
first one on the list. When we opened the file again for the same mode
type, then before the patch, the new entry is inserted before what's
already on the list. Both of these files share the same nfs4_state
that's marked delegated.

Once we receive a delegation recall, in delegation_claim_opens() we
walk the list. First one will be the 2nd open. It's marked delegated
but after calling nfs4_open_delegation_recall() the delegation flag is
cleared. The 2nd open doesn't have the lock associated with it. So no
lock is reclaimed. We now go to the 2nd entry in the open_file list
which is the 1st open but now the delegation flag is cleared so we
never recover the lock.

Any of the opens on the open_list can be the lock holder and we can't
clear the delegation flag on the first treatment of the delegated open
because it might not be the owner of the lock.

I'm trying to figure out how I would fix it but I thought I'd send
this for your comments.

On Fri, Sep 28, 2018 at 4:38 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> On Fri, 2018-09-28 at 16:19 -0400, Olga Kornievskaia wrote:
> > On Fri, Sep 28, 2018 at 4:07 PM Trond Myklebust <
> > trondmy@hammerspace.com> wrote:
> > >
> > > On Fri, 2018-09-28 at 15:55 -0400, Olga Kornievskaia wrote:
> > > > On Fri, Sep 28, 2018 at 3:10 PM Olga Kornievskaia <aglo@umich.edu
> > > > >
> > > > wrote:
> > > > >
> > > > Wait, why are we suppose to reclaim the open state when we have a
> > > > valid open stateid? We don't have any cached opens that server
> > > > doesn't
> > > > know about. RFC7530 says "if the file has other open reference",
> > > > I
> > > > think the emphasis is on "other". I don't believe we need to be
> > > > sending anything besides the locks to the server. Then I'm back
> > > > to
> > > > square one.
> > >
> > > Holding a delegation does not imply that we hold an open stateid.
> > > Under
> > > Linux, the open stateid gets closed as soon as the application
> > > closes
> > > the file.
> > >
> > > The delegation, on the other hand, is retained until either it is
> > > recalled, or we see that the file has not been used for 2 lease
> > > periods.
> >
> > Ok I agree with all of it but I'm saying it doesn't need to be
> > reclaimed unconditionally or are you saying that's what the linux
> > client does? In this test case, the file hasn't been closed or
> > expired. I'm stating that the client has a valid open stateid and
> > should only be required to reclaim the locks (which with this patch
> > it
> > does).
>
> As I said earlier, the client is required to recover all _cached_ open
> and lock state. If it already holds an open stateid, then it should not
> need to reclaim the open modes that are covered by that stateid,
> however it may still need to reclaim those open modes that were not
> already subject to an explicit OPEN call.
>
> IOW: If the file was first opened with an open(O_RDRW) call by the
> application, but a second application then opened it using
> open(O_WRONLY), then we may already hold a stateid with a
> "SHARE_ACCESS_BOTH" open mode, however we will still need to send a
> reclaim for the cached SHARE_ACCESS_WRITE mode, so that a later
> OPEN_DOWNGRADE(SHARE_ACCESS_WRITE) can succeed.
>
> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
>
