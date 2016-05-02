Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.horizon.com ([71.41.210.147]:61174 "HELO ns.horizon.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754977AbcEBTI4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2016 15:08:56 -0400
Date: 2 May 2016 15:08:54 -0400
Message-ID: <20160502190854.21326.qmail@ns.horizon.com>
From: "George Spelvin" <linux@horizon.com>
To: linux@horizon.com, peterz@infradead.org
Subject: Re: [PATCH 1/2] <linux/hash.h>: Make hash_64(), hash_ptr() return 32 bits
Cc: bfields@fieldses.org, eric.dumazet@gmail.com, jlayton@poochiereds.net,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        riel@redhat.com, tglx@linutronix.de, torvalds@linux-foundation.org
In-Reply-To: <20160502132804.GF12845@twins.programming.kicks-ass.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Peter Zijlstra wrote:
> Is the subject stale or the above a mistake? Because hash_64() still
> very much seems to return u64.

Damn it no, it's a brown-paper-bag typo caused by a recent rebase.
It's meant to be u32, it was developed with u32, but the typo snuck
in during late testing and I didn't catch it.

I know Linus hates recent rebases, but I actually had a good
reason if you want to hear the saga...

I developed the patch while running v4.4.x.  I'd been doing other hacking
on top of v4.5 that resulted in an unstable system, so I kept going back
to the "last known good" v4.4.x kernel to get work done.

Developing this patch, I backed out that buggy work and based it on my
4.5 tree, since Linus hates basing work on random kernels.

Most of it was compile testing, but just before submitting, I of course
had to boot it and test.

When I booted it, I discovered I couldn't load microcode.  How the hell
did I cause that?  Oh, I have CONFIG_MICROCODE turned off... huh?  Oh,
v4.5 has bug where CONFIG_MICROCODE depende on CONFIG_BLK_DEV_INITRD
which I don't use, and the fix went in to v4.6-rc1.

Okay, fine, in the interest of getting a clean boot for testing, I'll
rebase to v4.6-rc6.  See, I told you I had a reason!

Now, I actually have a fair pile of local patches for hacking projects in
progress (I'm running 4.6.0-rc6-0130), so rebasing my whole stack takes
me about an hour and a half, with several merge conflict resolutions.

Finally, I get my clean boot, and everything seems to be working
fine, and I'm ready to post.

But by this time it's late, I'm tired, and I didn't notice that I somehow
managed to screw that up!  In hindsight, I think I remember the sequence
of edits that caused it (I deleted something by accident and cut & pasted
it back), but that's an even more obscure saga.

I will now go and fix it and boot test again, just to be sure.

Grump.
