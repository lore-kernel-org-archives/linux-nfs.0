Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51124 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726080AbeHWFOh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Aug 2018 01:14:37 -0400
Date: Wed, 22 Aug 2018 21:47:22 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Olga Kornievskaia <kolga@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v10 0/9] NFSD support for async COPY
Message-ID: <20180823014722.GA24441@fieldses.org>
References: <20180720221925.50744-1-kolga@netapp.com>
 <20180809203450.GE14104@parsley.fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180809203450.GE14104@parsley.fieldses.org>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 09, 2018 at 04:34:50PM -0400, J. Bruce Fields wrote:
> Thanks, I've added these to my -next branch, and I want to read through
> them tomorrow.

Gah, I screwed up and took to long to get around to this and have a few
things I'd like to change, so I'm going to queue these up again for
4.20.

The way the patches are broken up doesn't really work; for example
init_cp_state is used in one but patch not defined till a later patch,
and waiting till the last patch to cleanup on client expiry leaves us
with a bug until that patch is applied.  I'm not seeing a better way to
split things up so I think best is just to glom them all together, which
I've gone ahead and done.  (The XDR patches are still separate, I'm not
sure how much that helps but I think it's harmless.)

I'm not sure about the signalling--I don't see anything else outside
core code setting TIF_SIGPENDING directly, is that really all we need to
do?  I know it was me that asked for signalling there, but for now let's
just rely on kthread_stop.  If somebody can explain to me how we're
supposed to do the signalling, we can do that, but then we should rely
on it alone and not do both that and kthread_stop.

That's a minor change so I did that as well, hope that's OK.  Results
are in my linux-next branch.  I'm also happy to look at the
server-to-server patches on top of that if they're ready.

--b.
