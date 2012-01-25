Return-Path: linux-nfs-owner@vger.kernel.org
Received: from www.linutronix.de ([62.245.132.108]:59975 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445Ab2AYOFK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 09:05:10 -0500
Date: Wed, 25 Jan 2012 15:05:03 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
To: Jeff Layton <jlayton@redhat.com>
cc: Boaz Harrosh <bharrosh@panasas.com>,
        Stanislaw Gruszka <sgruszka@redhat.com>,
        Stephen Boyd <sboyd@codeaurora.org>, linux-kernel@vger.kernel.org,
        bfields@redhat.com, linux-nfs@vger.kernel.org,
        Tejun Heo <tj@kernel.org>
Subject: Re: WARNING: at lib/debugobjects.c:262
 debug_print_object+0x8c/0xb0()
In-Reply-To: <20120124124353.7148b827@tlielax.poochiereds.net>
Message-ID: <alpine.LFD.2.02.1201251502210.2716@ionos>
References: <20120120135646.2fc4fa61@tlielax.poochiereds.net> <4F1BCCD6.4020603@codeaurora.org> <20120123102311.4378b8c1@tlielax.poochiereds.net> <20120124074516.GC2420@redhat.com> <4F1E7F3F.3060703@panasas.com> <20120124073626.552bc31c@tlielax.poochiereds.net>
 <4F1EC7C9.2020001@panasas.com> <20120124113234.26c47969@tlielax.poochiereds.net> <20120124124353.7148b827@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Jan 2012, Jeff Layton wrote:
> > Still, I wonder if there are other problems like this around. The slab
> > allocators seem to call debug_check_no_obj_freed() on kmem_cache_free,
> > but parts of the objects themselves (like the timer in the work object
> > here) get initialized in other places and aren't necessarily
> > reinitialized when they're recycled out of the slab...
> > 
> 
> On second thought...getting rid of the ctor function here might be
> problematic. We have to call inode_init_once, etc...
> 
> Almost all of the inode slabs have one, so I've settled for just moving
> the INIT_DELAYED_WORK call out of init_once and into rpc_alloc_inode. I
> sent a patch to Trond and linux-nfs to do that. That will fix this
> case, but I do wonder if there are other places in the kernel that have
> similar problems with debugobject initialization.

The problem is that debugobject requires that a newly allocated object
is reinitialized and made available to the debugobjects code again
simply because we remove it from the debugobjects core on
kmem_cache_free(). 

The real question is why the heck kmem_cache_alloc() does not call the
ctor on each allocation and just expects the previously used and freed
object to be in a consistent initialiazed state.

Thanks,

	tglx
