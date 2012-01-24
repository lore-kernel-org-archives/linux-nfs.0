Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18337 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755505Ab2AXQcr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jan 2012 11:32:47 -0500
Date: Tue, 24 Jan 2012 11:32:34 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
        Stephen Boyd <sboyd@codeaurora.org>, <linux-kernel@vger.kernel.org>,
        <bfields@redhat.com>, <linux-nfs@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>
Subject: Re: WARNING: at lib/debugobjects.c:262
 debug_print_object+0x8c/0xb0()
Message-ID: <20120124113234.26c47969@tlielax.poochiereds.net>
In-Reply-To: <4F1EC7C9.2020001@panasas.com>
References: <20120120135646.2fc4fa61@tlielax.poochiereds.net>
	<4F1BCCD6.4020603@codeaurora.org>
	<20120123102311.4378b8c1@tlielax.poochiereds.net>
	<20120124074516.GC2420@redhat.com>
	<4F1E7F3F.3060703@panasas.com>
	<20120124073626.552bc31c@tlielax.poochiereds.net>
	<4F1EC7C9.2020001@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Jan 2012 17:01:29 +0200
Boaz Harrosh <bharrosh@panasas.com> wrote:

> On 01/24/2012 02:36 PM, Jeff Layton wrote:
> > 
> > No, I don't think the state would be undefined after
> > cancel_delayed_work_sync. In principle you could requeue that work
> > again if you like without needing to reinitialize it.
> > 
> > I think this is a problem in the debugobjects code. It doesn't have
> > any way to know that when the object is recycled out of the slab that
> > the work is already initialized.
> > 
> 
> The only difference between your above example of requeue after
> cancel_delayed_work_sync, and this here is the visit back to the
> slab. Does the slab (Maybe in debug mode) stumps over some of the
> record memory?
> 
> If the memory is constant what is then the difference between the two
> cases?
> 
> > Certainly it's simple enough to reinitialize the work every time we
> > allocate an inode here, but I don't think this is really a rpc_pipefs
> > bug per-se. 
> 
> That depends on the API intention. If an init is intended after
> SLAB free then yes if not then not. We should ask for the intention
> of this API.
> 
> > I can send a patch that works around this problem, but
> > if there are plans to fix this in the debugobjects code, I won't
> > bother...
> > 
> 
> You mean other fix then calling INIT_DELAYED_WORK? is that so
> bad that we need more code to avoid it?
> 

I'm not opposed to a patch that sidesteps this problem, but I want to
make sure we understand it so that we don't get bitten by it in other
places. That's a good point. I hadn't considered whether memory
poisoning is a factor. In the kernel I was testing:

CONFIG_SLUB=y
CONFIG_SLUB_DEBUG_ON=y

...just to be sure:

# cat /sys/kernel/slab/rpc_inode_cache/poison 
1

Looking at the code...

It looks like SLAB will call the ctor on every object when it's
allocated, even if it was recycled from an existing slab. SLUB doesn't
do that however -- as best I can tell it avoids poisoning objects when
there is a ctor function, so they don't get reinitialized like they
would with SLAB.

Probably the best solution here is to eliminate the ctor function and
just initialize the objects whenever they're allocated. Since these
objects aren't frequently recycled then there's little benefit to
keeping that around, IMO. I'll spin up a patch for that soon.

Still, I wonder if there are other problems like this around. The slab
allocators seem to call debug_check_no_obj_freed() on kmem_cache_free,
but parts of the objects themselves (like the timer in the work object
here) get initialized in other places and aren't necessarily
reinitialized when they're recycled out of the slab...

-- 
Jeff Layton <jlayton@redhat.com>
