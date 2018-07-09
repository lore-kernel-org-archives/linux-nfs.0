Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35197 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933025AbeGIV5d (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Jul 2018 17:57:33 -0400
Received: by mail-it0-f67.google.com with SMTP id l16-v6so28575501ita.0
        for <linux-nfs@vger.kernel.org>; Mon, 09 Jul 2018 14:57:33 -0700 (PDT)
MIME-Version: 1.0
References: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
 <1529598933-16506-2-git-send-email-manjunath.b.patil@oracle.com>
 <20180622175416.GA7119@fieldses.org> <20180709142512.GA17769@fieldses.org>
In-Reply-To: <20180709142512.GA17769@fieldses.org>
From: Trond Myklebust <trondmy@gmail.com>
Date: Mon, 9 Jul 2018 17:57:21 -0400
Message-ID: <CAABAsM6vDOaudUZYWH23oGiWGqX5Bd1YbCDnL6L=pxzMXgZzaw@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfsd: return ENOSPC if unable to allocate a session slot
To: Dr James Bruce Fields <bfields@fieldses.org>
Cc: manjunath.b.patil@oracle.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 9 Jul 2018 at 10:27, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Jun 22, 2018 at 01:54:16PM -0400, bfields wrote:
> > On Thu, Jun 21, 2018 at 04:35:33PM +0000, Manjunath Patil wrote:
> > > Presently nfserr_jukebox is being returned by nfsd for create_session
> > > request if server is unable to allocate a session slot. This may be
> > > treated as NFS4ERR_DELAY by the clients and which may continue to re-try
> > > create_session in loop leading NFSv4.1+ mounts in hung state. nfsd
> > > should return nfserr_nospc in this case as per rfc5661(section-18.36.4
> > > subpoint 4. Session creation).
> >
> > I don't think the spec actually gives us an error that we can use to say
> > a CREATE_SESSION failed permanently for lack of resources.
> >
> > Better would be to avoid the need to fail at all.  Possibilities:
> >
> >       - revive Trond's patches some time back to do dynamic slot size
>
> By the way, I finally got around to reviewing those patches (5 years
> late!).  One issue is that they seem to take the slot count requested by
> the client at CREATE_SESSION as a lower bound.  And the current client
> requests a lot of slots (1024, I think?--this is just from looking at
> the code, I should watch a mount).  Anyway, I assume that's not a hard
> requirement and that we can fix it.
>
> Also the slot number is driven entirely by the server's guess at what
> the client needs--we might also want to take into account whether we're
> running out of server resources.
>
> So that still leaves the question of how to cap the total slot memory.
>
> I'm beginning to wonder whether that's a good idea at all.  Perhaps it'd
> be better for now just to keep going till kmalloc fails.  There's no
> shortage of other ways that a malicious client could DOS the server
> anyway.
>
> I'll probably forward-port and repost Trond's patches some time in the
> next month.

To be fair, if I were redoing the patches today, I'd probably change
them to ensure that we only grow the session slot table size using the
sequence target_slot, but shrink it using the CB_RECALL_SLOT
mechanism. That makes for a much cleaner implementation with less
heuristics needed on the part of both the client and server.

Cheers
  Trond
