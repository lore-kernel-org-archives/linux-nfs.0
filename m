Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:36789 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726046AbeIETBj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Sep 2018 15:01:39 -0400
Received: by mail-vk0-f48.google.com with SMTP id i2-v6so2758399vkg.3
        for <linux-nfs@vger.kernel.org>; Wed, 05 Sep 2018 07:31:12 -0700 (PDT)
MIME-Version: 1.0
References: <20180720221925.50744-1-kolga@netapp.com> <20180809203450.GE14104@parsley.fieldses.org>
 <20180823014722.GA24441@fieldses.org>
In-Reply-To: <20180823014722.GA24441@fieldses.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 5 Sep 2018 10:30:59 -0400
Message-ID: <CAN-5tyEsME8YdBvzUczE6N_L3ptV8DTA0a4sZCgmDUfGX99CDA@mail.gmail.com>
Subject: Re: [PATCH v10 0/9] NFSD support for async COPY
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

finally getting back to this...

On Wed, Aug 22, 2018 at 9:47 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Thu, Aug 09, 2018 at 04:34:50PM -0400, J. Bruce Fields wrote:
> > Thanks, I've added these to my -next branch, and I want to read through
> > them tomorrow.
>
> Gah, I screwed up and took to long to get around to this and have a few
> things I'd like to change, so I'm going to queue these up again for
> 4.20.
>
> The way the patches are broken up doesn't really work; for example
> init_cp_state is used in one but patch not defined till a later patch,

I don't see what you are seeing.. init_cp_state is defined and used in
0006-NFSD-create-new-stateid-for-async-copy.patch

> and waiting till the last patch to cleanup on client expiry leaves us

That's correct the whole 'stopping threads' it sorta tied in with the
signaling that OFFLOAD_CANCEL also uses.

> with a bug until that patch is applied.  I'm not seeing a better way to
> split things up so I think best is just to glom them all together, which
> I've gone ahead and done.  (The XDR patches are still separate, I'm not
> sure how much that helps but I think it's harmless.)

If you are ok with a single patch for the whole async feature, that's
fine with me.

> I'm not sure about the signalling--I don't see anything else outside
> core code setting TIF_SIGPENDING directly, is that really all we need to
> do?
>  I know it was me that asked for signalling there, but for now let's
> just rely on kthread_stop.  If somebody can explain to me how we're
> supposed to do the signalling, we can do that, but then we should rely
> on it alone and not do both that and kthread_stop.

The modified code seems to work. I think I had signal_pending() in
case something else in the kernel was doing something and sending us
the TIF_SIGPENDING signal. As for setting it, that was an overkill
since I was already doing kthread_stop().

> That's a minor change so I did that as well, hope that's OK.  Results
> are in my linux-next branch.  I'm also happy to look at the
> server-to-server patches on top of that if they're ready.
>
> --b.
