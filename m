Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51778 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752668AbcKRUwj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Nov 2016 15:52:39 -0500
Date: Fri, 18 Nov 2016 15:52:39 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "aglo@umich.edu" <aglo@umich.edu>,
        "tibbs@math.uh.edu" <tibbs@math.uh.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
Message-ID: <20161118205239.GH5424@fieldses.org>
References: <20161117201753.GF20937@fieldses.org>
 <CAN-5tyHcaJCCdBaNbU4Mc=JuJXi9cDppuTVKKixrgVZMZS-DMg@mail.gmail.com>
 <20161117204618.GG20937@fieldses.org>
 <CAN-5tyHs1Xq4W2eJOMOW_Tv3=3hQLYhLdVwMDYixhGnaGsEH4Q@mail.gmail.com>
 <20161117212601.GA23130@fieldses.org>
 <1479419127.33885.5.camel@primarydata.com>
 <CAN-5tyFChQ0S4hUwGyWjaJ73hBpTZjJXVK3jm_M_4v1vgzVSjA@mail.gmail.com>
 <1479420942.33885.19.camel@primarydata.com>
 <CAN-5tyFazrkcBVor7YvbOPKGWSCDPH1-NLUjZBKJPoKBrzoy-g@mail.gmail.com>
 <1479422635.33885.30.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1479422635.33885.30.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 17, 2016 at 10:43:58PM +0000, Trond Myklebust wrote:
> On Thu, 2016-11-17 at 17:27 -0500, Olga Kornievskaia wrote:
> > On Thu, Nov 17, 2016 at 5:15 PM, Trond Myklebust
> > <trondmy@primarydata.com> wrote:
> > > What's the alternative? Assume the client pre-emptively bumps the
> > > seqid
> > > instead of retrying, then the user presses Ctrl-C again. Repeat a
> > > few
> > > more times. How do I now resync the seqids between the client and
> > > server other than by trashing the session?
> > 
> > I don't see any alternatives than to reset in that case. But I think
> > it's better then the possibility of accidentally opening a wrong
> > file?

Remind me why you can't continue resending after the Ctrl-C?  (I thought
this was already done for some lock and other cases?)

> They sound equally bad to me which is why I'm not understanding how a
> server would fail to implement some minimal form of false retry
> checking.
> The Linux NFSv3 DRC will, for instance, checksum at least some part of
> the RPC arguments for _all_ RPC calls. Most NFSv4.x clients will only
> ask that you checksum the non-idempotent RPC calls, which significantly
> cuts down on the calculation overhead.

I'll look at adding checksumming, it shouldn't be hard.

--b.
