Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44970 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751134AbbJIVSU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Oct 2015 17:18:20 -0400
Date: Fri, 9 Oct 2015 17:18:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
Cc: Neil Brown <nfbrown@novell.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] sunrpc: fix waitqueue_active without memory barrier
 in sunrpc
Message-ID: <20151009211819.GE8188@fieldses.org>
References: <87h9m04mbt.fsf@notabene.neil.brown.name>
 <17EC94B0A072C34B8DCF0D30AD16044A02874B59@BPXM09GP.gisp.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <17EC94B0A072C34B8DCF0D30AD16044A02874B59@BPXM09GP.gisp.nec.co.jp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 09, 2015 at 06:29:44AM +0000, Kosuke Tatsukawa wrote:
> Neil Brown wrote:
> > Kosuke Tatsukawa <tatsu@ab.jp.nec.com> writes:
> > 
> >> There are several places in net/sunrpc/svcsock.c which calls
> >> waitqueue_active() without calling a memory barrier.  Add a memory
> >> barrier just as in wq_has_sleeper().
> >>
> >> I found this issue when I was looking through the linux source code
> >> for places calling waitqueue_active() before wake_up*(), but without
> >> preceding memory barriers, after sending a patch to fix a similar
> >> issue in drivers/tty/n_tty.c  (Details about the original issue can be
> >> found here: https://lkml.org/lkml/2015/9/28/849).
> > 
> > hi,
> > this feels like the wrong approach to the problem.  It requires extra
> > 'smb_mb's to be spread around which are hard to understand as easy to
> > forget.
> > 
> > A quick look seems to suggest that (nearly) every waitqueue_active()
> > will need an smb_mb.  Could we just put the smb_mb() inside
> > waitqueue_active()??
> <snip>
> 
> There are around 200 occurrences of waitqueue_active() in the kernel
> source, and most of the places which use it before wake_up are either
> protected by some spin lock, or already has a memory barrier or some
> kind of atomic operation before it.
> 
> Simply adding smp_mb() to waitqueue_active() would incur extra cost in
> many cases and won't be a good idea.
> 
> Another way to solve this problem is to remove the waitqueue_active(),
> making the code look like this;
> 	if (wq)
> 		wake_up_interruptible(wq);
> This also fixes the problem because the spinlock in the wake_up*() acts
> as a memory barrier and prevents the code from being reordered by the
> CPU (and it also makes the resulting code is much simpler).

I might not care which we did, except I don't have the means to test
this quickly, and I guess this is some of our most frequently called
code.

I suppose your patch is the most conservative approach, as the
alternative is a spinlock/unlock in wake_up_interruptible, which I
assume is necessarily more expensive than an smp_mb().

As far as I can tell it's been this way since forever.  (Well, since a
2002 patch "NFSD: TCP: rationalise locking in RPC server routines" which
removed some spinlocks from the data_ready routines.)

I don't understand what the actual race is yet (which code exactly is
missing the wakeup in this case?  nfsd threads seem to instead get
woken up by the wake_up_process() in svc_xprt_do_enqueue().)

--b.
