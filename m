Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:46269 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbaGKSHi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2014 14:07:38 -0400
Received: by mail-qc0-f171.google.com with SMTP id w7so1334918qcr.16
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jul 2014 11:07:37 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 11 Jul 2014 14:07:35 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Frank Filz <ffilzlnx@mindspring.com>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Bruce Fields <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/11] nfsd: make deny mode enforcement more efficient
 and close races in it
Message-ID: <20140711140735.2d94e698@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtTUz7hCsowAEi7gpDk+d2J0NPNHJJVhy5hFmq6pQKg=CQ@mail.gmail.com>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
	<1405015655-12469-11-git-send-email-jlayton@primarydata.com>
	<03f901cf9d2d$f23c21f0$d6b465d0$@mindspring.com>
	<20140711134820.66d53162@tlielax.poochiereds.net>
	<03fc01cf9d31$719fcc50$54df64f0$@mindspring.com>
	<CAHQdGtTUz7hCsowAEi7gpDk+d2J0NPNHJJVhy5hFmq6pQKg=CQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 11 Jul 2014 14:00:43 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Fri, Jul 11, 2014 at 1:56 PM, Frank Filz <ffilzlnx@mindspring.com> wrote:
> >> On Fri, 11 Jul 2014 10:31:26 -0700
> >> "Frank Filz" <ffilzlnx@mindspring.com> wrote:
> >>
> >> > > The current enforcement of deny modes is both inefficient and
> >> > > scattered across several places, which makes it hard to guarantee
> >> > > atomicity. The inefficiency is a problem now, and the lack of
> >> > > atomicity will mean races
> >> > once
> >> > > the client_mutex is removed.
> >> > >
> >> > > First, we address the inefficiency. We have to track deny modes on a
> >> > > per- stateid basis to ensure that open downgrades are sane, but when
> >> > > the server goes to enforce them it has to walk the entire list of
> >> > > stateids and check against each one.
> >> > >
> >> > > Instead of doing that, maintain a per-nfs4_file deny mode. When a
> >> > > file is opened, we simply set any deny bits in that mode that were
> >> > > specified in
> >> > the
> >> > > OPEN call. We can then use that unified deny mode to do a simple
> >> > > check to see whether there are any conflicts without needing to walk
> >> > > the entire stateid list.
> >> > >
> >> > > The only time we'll need to walk the entire list of stateids is when
> >> > > a
> >> > stateid
> >> > > that has a deny mode on it is being released, or one is having its
> >> > > deny
> >> > mode
> >> > > downgraded. In that case, we must walk the entire list and
> >> > > recalculate the fi_share_deny field. Since deny modes are pretty
> >> > > rare today, this should
> >> > be
> >> > > very rare under normal workloads.
> >> >
> >> > What we do in Ganesha to avoid walking the list of stateids on release
> >> > is maintain the effective deny (and access) mode not at bits, but as a
> >> > counter for each bit. Thus, to remove a SHARE_ACCESS_READ |
> >> > SHARE_DENY_WRITE, you decrement the counts for access_read and
> >> deny_write.
> >> >
> >> > Frank
> >> >
> >> >
> >>
> >> Sure, that's another possibility that I considered, but I didn't want to
> > be
> >> bothered with having to add counters for deny modes. In practice there are
> >> *no* clients that use them (aside from pynfs and maybe the semi-mythical
> >> Windows v4.1 client).
> 
> You don't need counters for deny modes. There can only be 1 of each,
> since any deny mode has to be part of an OPEN that has at least one
> non-zero share access mode. So a single bit for each  should be fine.
> 

I'm not sure that's 100% true.

I see no reason that you can't have several clients open the same file
with (e.g.) ACCESS_READ and DENY_WRITE. You wouldn't want to lift the
DENY_WRITE on the file until all of those clients have closed the file
(or downgraded to remove the DENY_WRITE access).

So, I think you do need a little more than just a single set of bits on
the file. You either need to use per-file counters for them there
(which it sounds like ganesha does) or track them on a per-stateid
basis (like knfsd does).

> >>
> >> With this scheme, deny mode enforcement is pretty darned efficient,
> >> particularly in the common case where there are no deny modes to enforce.
> >>
> >> Any penalty for the use of deny modes is generally paid during the CLOSE
> > or
> >> OPEN_DOWNGRADE on behalf of the client that's using them.
> >> Any RPC from a client that's not won't need to do any extra work (aside
> > from
> >> maybe spinning on the fi_lock while another client is having to
> > recalculate the
> >> fi_share_deny).
> >
> > Good point.
> >
> > Whatever happened to Pavel Shilovsky's O_DENY patch set? I was looking
> > forward to that for allowing Ganesha and Samba share reservations to more
> > fully interact with each other...
> >
> > Frank
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 


-- 
Jeff Layton <jlayton@primarydata.com>
