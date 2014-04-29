Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:57835 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbaD2KcV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 06:32:21 -0400
Date: Tue, 29 Apr 2014 12:32:17 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: NeilBrown <neilb@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] SCHED: allow wait_on_bit functions to support a
 timeout.
Message-ID: <20140429103217.GQ27561@twins.programming.kicks-ass.net>
References: <20140429194406.06c580b8@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140429194406.06c580b8@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 29, 2014 at 07:44:06PM +1000, NeilBrown wrote:
> 
> 
> It is currently not possible for various wait_on_bit functions to
> implement a timeout.
> While the "action" function that is called to do the waiting could
> certainly use schedule_timeout(), there is no way to carry forward the
> remaining timeout after a false wake-up.
> As false-wakeups a clearly possible at least due to possible
> hash collisions in bit_waitqueue(), this is a real problem.
> 
> The 'action' function is currently passed a pointer to the word
> containing the bit being waited on.  Of the 27 currently defined
> action functions, zero of them use this pointer.
> So changing it to something else will be a little noisy but will have
> no immediate effect.
> 
> This patch changes the 'action' function to take a pointer to the
> "struct wait_bit_key", which contains a pointer to the word
> containing the bit so nothing is really lost.
> 
> It also adds a 'private' field to "struct wait_bit_key", which is
> initialized to zero.
> 
> An action function can now implement a timeout with something like
> 
> static int timed_out_waiter(struct wait_bit_key *key)
> {
> 	unsigned long waited;
> 	if (key->private == 0) {
> 		key->private = jiffies;
> 		if (key->private == 0)
> 			key->private -= 1;
> 	}
> 	waited = jiffies - key->private;
> 	if (waited > 10 * HZ)
> 		return -EAGAIN;
> 	schedule_timeout(waited - 10 * HZ);
> 	return 0;
> }
> 
> If any other need for context in a waiter were found it would be easy
> to use ->private for some other purpose, or even extend "struct
> wait_bit_key".
> 
> My particular need is to support timeouts in nfs_release_page() to
> avoid deadlocks with loopback mounted NFS.

So I'm sure I'm not getting it; but why is all the wait_bit crap so
entirely different from the normal wait stuff?

Surely something like:

	wait_event_timeout(&wq, test_bit(bit, word), timeout);

Is pretty much the same, no? The only thing that's different is the wake
function, but surely we can thread that into there somehow without all
this silly repetition.

Furthermore, I count about 23 action functions, of which there appear to
be only like 4 actual variants. Surely such repetition sucks arse and
should be avoided?


