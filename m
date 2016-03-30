Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45526 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753984AbcC3SsQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Mar 2016 14:48:16 -0400
Date: Wed, 30 Mar 2016 14:48:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Olga Kornievskaia <aglo@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: out of order v3 write replies and cache invalidation
Message-ID: <20160330184815.GB12525@fieldses.org>
References: <CAN-5tyE_Y8gw9MrCwXpY-zjE2b7sdFGTTWMcO6pOZgo4HAy8AA@mail.gmail.com>
 <20160330174040.GA12525@fieldses.org>
 <CAHQdGtRyYiC7Ji6Au444bjc-ibBfdJEn=WLG=zy_XfHzzB557A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRyYiC7Ji6Au444bjc-ibBfdJEn=WLG=zy_XfHzzB557A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 30, 2016 at 02:20:40PM -0400, Trond Myklebust wrote:
> On Wed, Mar 30, 2016 at 1:40 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > If we assume no other writers until we close, couldn't you on close wait
> > for all writes, send a final getattr for change attribute, and trust
> > that?  If the extra getattr's too much, then you'd need some algorithm
> > like the above to determine which change attribute is the last.  Or
> > implement
> > https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-41#section-12.2.3
> > on client and server and just track the maximum returned value when the
> > server returns something other than NFS4_CHANGE_TYPE_IS_UNDEFINED.
> >
> 
> The correct tool to use for resolving these caching issues is
> ultimately a write delegation.
> 
> You can also eliminate a lot of invalidations if you know that the
> server implements change_attr_type ==
> NFS4_CHANGE_TYPE_IS_VERSION_COUNTER or
> NFS4_CHANGE_TYPE_IS_VERSION_COUNTER_NOPNFS, since that allows you to
> predict what the attribute should be after a change.

Do we know of any implementations?

It looks difficult (and possibly not yet sufficiently well-defined) to
me, but I haven't thought it through.

--b.
