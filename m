Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49900 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685Ab1HURHS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Aug 2011 13:07:18 -0400
Date: Sun, 21 Aug 2011 13:07:14 -0400
To: Jamie Lokier <jamie@shareable.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Sylvain Rochet <gradator@gradator.net>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Message-ID: <20110821170714.GB9296@fieldses.org>
References: <20101018223540.GA20730@gradator.net>
 <20110819230344.GA24784@gradator.net>
 <20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
 <20110820012943.GD2203@ZenIV.linux.org.uk>
 <20110820030335.GA14899@jl-vm1.vm.bytemark.co.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110820030335.GA14899@jl-vm1.vm.bytemark.co.uk>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Aug 20, 2011 at 04:03:35AM +0100, Jamie Lokier wrote:
> Well you still have your sense of humour...
> 
> I've never understood why you think it's about the file manager /
> desktop, or why you so strongly dislike the feature.  It originated
> there historically, but that is not it's primary use.
> 
> The implementation, sure, but you seem to dislike the very *principle*
> of subscribing to changes.
> 
> Every interesting use of inotify that I've seen is for some kind of
> cache support, to eliminate the majority of stat() calls, to remove
> disk I/O (no stat means no inode), to ensure correctness (st_mtime is
> coarse and unreliable),

It seems rather fragile as an mtime replacement unless it's also got
some sort of logging built in at a pretty low level so that you don't
lose events while you're not listening.

And of course events have to be defined very carefully to avoid problems
such as this one.

> and to avoid having to modify every
> application which might affect any file from which cached items are
> derived to explicitly notify all the applications which might use any
> of those files.
> 
> You like high performance, reliable and correct behaviour, and high
> scalability.  So I have never understood why you dislike the
> change-subscription principle so strongly, because it is a natural
> ally to those properties.

I don't think we've seen a design that does all of that yet.

--b.
