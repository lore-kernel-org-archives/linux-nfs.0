Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55238 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752835AbcKUSh6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 21 Nov 2016 13:37:58 -0500
Date: Mon, 21 Nov 2016 13:37:57 -0500
From: Fields Bruce James <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Kornievskaia Olga <aglo@umich.edu>,
        "tibbs@math.uh.edu" <tibbs@math.uh.edu>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: NFS: nfs4_reclaim_open_state: Lock reclaim failed! log spew
Message-ID: <20161121183757.GA7684@fieldses.org>
References: <20161117204618.GG20937@fieldses.org>
 <CAN-5tyHs1Xq4W2eJOMOW_Tv3=3hQLYhLdVwMDYixhGnaGsEH4Q@mail.gmail.com>
 <20161117212601.GA23130@fieldses.org>
 <1479419127.33885.5.camel@primarydata.com>
 <CAN-5tyFChQ0S4hUwGyWjaJ73hBpTZjJXVK3jm_M_4v1vgzVSjA@mail.gmail.com>
 <1479420942.33885.19.camel@primarydata.com>
 <CAN-5tyFazrkcBVor7YvbOPKGWSCDPH1-NLUjZBKJPoKBrzoy-g@mail.gmail.com>
 <1479422635.33885.30.camel@primarydata.com>
 <20161118205239.GH5424@fieldses.org>
 <08D8E478-40ED-4DA7-B4B3-865BD2E02FB5@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <08D8E478-40ED-4DA7-B4B3-865BD2E02FB5@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 18, 2016 at 10:44:52PM +0000, Trond Myklebust wrote:
> 
> > On Nov 18, 2016, at 15:52, bfields@fieldses.org wrote:
> > 
> > On Thu, Nov 17, 2016 at 10:43:58PM +0000, Trond Myklebust wrote:
> >> On Thu, 2016-11-17 at 17:27 -0500, Olga Kornievskaia wrote:
> >>> On Thu, Nov 17, 2016 at 5:15 PM, Trond Myklebust
> >>> <trondmy@primarydata.com> wrote:
> >>>> What's the alternative? Assume the client pre-emptively bumps the
> >>>> seqid
> >>>> instead of retrying, then the user presses Ctrl-C again. Repeat a
> >>>> few
> >>>> more times. How do I now resync the seqids between the client and
> >>>> server other than by trashing the session?
> >>> 
> >>> I don't see any alternatives than to reset in that case. But I think
> >>> it's better then the possibility of accidentally opening a wrong
> >>> file?
> > 
> > Remind me why you can't continue resending after the Ctrl-C?  (I thought
> > this was already done for some lock and other cases?)
> 
> We’d have to do it for all RPC calls, which means they would all have to be converted to not use the stack. The resulting behaviour would also be confusing, as operations would complete outside of locking rules etc. So, for instance, you would be seeing successfully looked up files mysteriously disappearing as the asynchronous unlink() operation that was interrupted completes, or directories mysteriously getting renamed.

We get that anyway, since the server may already be processing the rpc.

I'll admit it sounds complicated.

> >> They sound equally bad to me which is why I'm not understanding how a
> >> server would fail to implement some minimal form of false retry
> >> checking.
> >> The Linux NFSv3 DRC will, for instance, checksum at least some part of
> >> the RPC arguments for _all_ RPC calls. Most NFSv4.x clients will only
> >> ask that you checksum the non-idempotent RPC calls, which significantly
> >> cuts down on the calculation overhead.
> > 
> > I'll look at adding checksumming, it shouldn't be hard.
> 
> Thanks.

I doubt it's a complete fix, though.  Two calls with the same arguments
aren't necessarily the same call either, and it's the sequence id that's
supposed to distinguish the "same call" and "different call with same
argument" cases.

--b.
