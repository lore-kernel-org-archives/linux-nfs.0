From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [NFS] nfs or autofs related hangs
Date: Tue, 17 Feb 2004 18:37:49 +1100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040217183749.490777c5.rusty@rustcorp.com.au>
References: <20040215222107.7E4382C2D8@lists.samba.org>
	<Pine.LNX.4.58.0402160910300.28358@wombat.indigo.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: ia6432@inbox.ru, linux-kernel@vger.kernel.org,
	autofs@linux.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Ian Kent <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.58.0402160910300.28358@wombat.indigo.net.au>
List-ID: <nfs.lists.sourceforge.net>

On Mon, 16 Feb 2004 09:13:55 +0800 (WST)
Ian Kent <raven@themaw.net> wrote:

> On Sun, 15 Feb 2004, Rusty Russell wrote:
> > Is this __cacheline_aligned_in_smp really required?
> 
> I must admit I put this together without much thought with a "cut and 
> paste".
> 
> But, please tell me. I'm not entirely clear on what conditions I 
> should be concerned about blowing the cache.

You should usually try to declare the spinlock near the things it protects, in
the hope that they'll be in the same cacheline.  If we blow 128 bytes for
every spinlock, things will get slower, not faster.

ie. like any optimization, the default should be not to do it unless there's
a reason[1]

Cheers,
Rusty.
[1] An optimization being defined here as something with tradeoffs.
    Doing the obviously superior thing is not an optimization, it's simply
    being a decent coder.
-- 
   there are those who do and those who hang on and you don't see too
   many doers quoting their contemporaries.  -- Larry McVoy
