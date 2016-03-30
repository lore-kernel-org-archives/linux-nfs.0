Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45534 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754100AbcC3Su1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Mar 2016 14:50:27 -0400
Date: Wed, 30 Mar 2016 14:50:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Olga Kornievskaia <aglo@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: out of order v3 write replies and cache invalidation
Message-ID: <20160330185026.GC12525@fieldses.org>
References: <CAN-5tyE_Y8gw9MrCwXpY-zjE2b7sdFGTTWMcO6pOZgo4HAy8AA@mail.gmail.com>
 <20160330174040.GA12525@fieldses.org>
 <CAHQdGtRyYiC7Ji6Au444bjc-ibBfdJEn=WLG=zy_XfHzzB557A@mail.gmail.com>
 <CAN-5tyFpb4vht+QyL3vVsRqv6n0TZ6x_PK4oQintch00040wBw@mail.gmail.com>
 <CAHQdGtTfzfSCan_h4Cue5NrABG=A4=uaBORBfx6wp9gU+7bQmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTfzfSCan_h4Cue5NrABG=A4=uaBORBfx6wp9gU+7bQmQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 30, 2016 at 02:43:38PM -0400, Trond Myklebust wrote:
> On Wed, Mar 30, 2016 at 2:39 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> > On Wed, Mar 30, 2016 at 2:20 PM, Trond Myklebust
> > <trond.myklebust@primarydata.com> wrote:
> >> On Wed, Mar 30, 2016 at 1:40 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >>> If we assume no other writers until we close, couldn't you on close wait
> >>> for all writes, send a final getattr for change attribute, and trust
> >>> that?  If the extra getattr's too much, then you'd need some algorithm
> >>> like the above to determine which change attribute is the last.  Or
> >>> implement
> >>> https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-41#section-12.2.3
> >>> on client and server and just track the maximum returned value when the
> >>> server returns something other than NFS4_CHANGE_TYPE_IS_UNDEFINED.
> >>>
> >>
> >> The correct tool to use for resolving these caching issues is
> >> ultimately a write delegation.
> >>
> >> You can also eliminate a lot of invalidations if you know that the
> >> server implements change_attr_type ==
> >> NFS4_CHANGE_TYPE_IS_VERSION_COUNTER or
> >> NFS4_CHANGE_TYPE_IS_VERSION_COUNTER_NOPNFS, since that allows you to
> >> predict what the attribute should be after a change.
> >
> > Thanks for all the info. But let me highlight that I was asking about
> > v3. I don't see that the code has issues with cache invalidation for
> > nfsv4 when receiving out-of-order RPCs.
> >
> > I am not sure if it's worth implementing something that Bruce
> > suggests. I just wanted to make sure that what i'm seeing is
> > "expected" behavior (caz it's v3) and not a bug.
> 
> Yes. The design does expect the occasional false positive cache
> invalidation due to RPC request reordering.

In the v3 and close-to-open case, since the ctime's monotonically
increasing, why couldn't we just keep track of the maximum ctime seen
before close?

--b.
