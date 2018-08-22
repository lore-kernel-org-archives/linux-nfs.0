Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50436 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727687AbeHVXMd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Aug 2018 19:12:33 -0400
Date: Wed, 22 Aug 2018 15:46:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Paul B. Henson" <henson@acm.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs4-acl-tools 0.3.5
Message-ID: <20180822194620.GA25562@fieldses.org>
References: <20180807193736.GA18187@fieldses.org>
 <20180821165130.GA14413@fieldses.org>
 <5fa4b700-3d45-cda3-37ed-bdfbd427574d@acm.org>
 <20180822003301.GA17500@fieldses.org>
 <d4649560-ad74-d119-13ba-876af9a4974e@acm.org>
 <20180822151213.GA24172@fieldses.org>
 <c1b05b61-b85e-7dff-8cff-12b85bffb3c6@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <c1b05b61-b85e-7dff-8cff-12b85bffb3c6@acm.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 22, 2018 at 12:28:13PM -0700, Paul B. Henson wrote:
> On 8/22/2018 8:12 AM, J. Bruce Fields wrote:
> >
> >Huh.  Yeah, that does look like a bug.  But I'm surprised the utilities
> >would work at all in that case--I'd expect both the Solaris and Linux
> >knfsd to reject an ACL with those extra bits, and certainly neither
> 
> Hmm, you're right; trying to include any of them when updating an
> ACL on an illumos server from the Linux client results in "Failed
> setxattr operation: Invalid argument".
> 
> It looks like those extra flags aren't even documented. Given a
> server will never actually return them such that a user sees them
> displayed, and they are not documented, it's most likely no one has
> ever actually tried to use them 8-/. From a historical perspective,
> it would be interesting to know why they are there, but that is
> perhaps lost to antiquity ;).

Oh, I see now, I was assuming they were automatically set on owner ACEs
or something, but they're only set if you happen to know this bit of
undocumented UI implemented in get_ace_flags/ace_from_string.  So, yeah,
we should just remove that code.

> >I suspect they're unnecessary, and I'd happily take a patch to remove
> >them once we figure out what's going on.
> 
> I'll strip them out and send you a patch soon; hopefully it won't
> take 10 more years to show up in a release :).

OK, great, thanks.

> A side question while I have your attention; once I get the ZFS
> NFSv4 acl support committed upstream, what is it going to take to
> have the linux NFSv4 server use them and provide them to clients?

I can't take knfsd patches to support something that only an out-of-tree
filesystem cares about.

Looks like ZFS has pretty much no chance of going upstream.

You could try to port them to some other filesystem (xfs, ext4).  But
the attempt to implement rich ACLs (which are pretty similar) seemed to
get vetoed for reasons I don't completely understand, and I don't see
why this would fare any better.

So I think you'd be stuck carrying your own out-of-tree patches for it.

Ganesha probably could (may already) do this, for what it's worth.

--b.
