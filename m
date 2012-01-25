Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26568 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030Ab2AYOqd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 09:46:33 -0500
Date: Wed, 25 Jan 2012 09:46:16 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Boaz Harrosh <bharrosh@panasas.com>,
        Stanislaw Gruszka <sgruszka@redhat.com>,
        Stephen Boyd <sboyd@codeaurora.org>, linux-kernel@vger.kernel.org,
        bfields@redhat.com, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>
Subject: Re: WARNING: at lib/debugobjects.c:262
 debug_print_object+0x8c/0xb0()
Message-ID: <20120125094616.6e90d113@tlielax.poochiereds.net>
In-Reply-To: <alpine.LFD.2.02.1201251502210.2716@ionos>
References: <20120120135646.2fc4fa61@tlielax.poochiereds.net>
	<4F1BCCD6.4020603@codeaurora.org>
	<20120123102311.4378b8c1@tlielax.poochiereds.net>
	<20120124074516.GC2420@redhat.com>
	<4F1E7F3F.3060703@panasas.com>
	<20120124073626.552bc31c@tlielax.poochiereds.net>
	<4F1EC7C9.2020001@panasas.com>
	<20120124113234.26c47969@tlielax.poochiereds.net>
	<20120124124353.7148b827@tlielax.poochiereds.net>
	<alpine.LFD.2.02.1201251502210.2716@ionos>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 25 Jan 2012 15:05:03 +0100 (CET)
Thomas Gleixner <tglx@linutronix.de> wrote:

> On Tue, 24 Jan 2012, Jeff Layton wrote:
> > > Still, I wonder if there are other problems like this around. The slab
> > > allocators seem to call debug_check_no_obj_freed() on kmem_cache_free,
> > > but parts of the objects themselves (like the timer in the work object
> > > here) get initialized in other places and aren't necessarily
> > > reinitialized when they're recycled out of the slab...
> > > 
> > 
> > On second thought...getting rid of the ctor function here might be
> > problematic. We have to call inode_init_once, etc...
> > 
> > Almost all of the inode slabs have one, so I've settled for just moving
> > the INIT_DELAYED_WORK call out of init_once and into rpc_alloc_inode. I
> > sent a patch to Trond and linux-nfs to do that. That will fix this
> > case, but I do wonder if there are other places in the kernel that have
> > similar problems with debugobject initialization.
> 
> The problem is that debugobject requires that a newly allocated object
> is reinitialized and made available to the debugobjects code again
> simply because we remove it from the debugobjects core on
> kmem_cache_free(). 
> 
> The real question is why the heck kmem_cache_alloc() does not call the
> ctor on each allocation and just expects the previously used and freed
> object to be in a consistent initialiazed state.
> 
> Thanks,
> 
> 	tglx


I believe that's by design. The comments at the top of slab.c say:

 * This means, that your constructor is used only for newly allocated
 * slabs and you must pass objects with the same initializations to
 * kmem_cache_free.

I assume that it was done that way for efficiency, but not passing
"clean" objects to kmem_cache_free has been the source of bugs in the
past.

Rerunning the ctor should be safe. SLAB already does that when memory
poisoning is enabled. Perhaps we could make sure all the allocators do
that when debug objects are enabled?

OTOH, doing that might paper over bugs in some cases...

-- 
Jeff Layton <jlayton@redhat.com>
