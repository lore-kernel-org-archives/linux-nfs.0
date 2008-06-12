From: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Subject: RE: CONFIG_DEBUG_SLAB_LEAK omits size-4096 and larger?
Date: Thu, 12 Jun 2008 14:54:09 -0500
Message-ID: <0122F800A3B64C449565A9E8C297701002D75DAE@hoexmb9.conoco.net>
References: <0122F800A3B64C449565A9E8C2977010155587@hoexmb9.conoco.net> <20080609185355.GF28584@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75D9F@hoexmb9.conoco.net> <20080610171602.GG20184@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DA3@hoexmb9.conoco.net> <20080611184613.GM15380@fieldses.org> <20080611195222.GP15380@fieldses.org> <20080611160947.5f08fb16@tleilax.poochiereds.net> <20080611205749.GA25194@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DAA@hoexmb9.conoco.net> <20080611225431.GD25194@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Jeff Layton" <jlayton@poochiereds.net>,
	<linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailman1.ppco.com ([138.32.41.4]:59537 "EHLO mailman1.ppco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754569AbYFLTyT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jun 2008 15:54:19 -0400
In-Reply-To: <20080611225431.GD25194@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org 
> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Wednesday, June 11, 2008 5:55 PM
> To: Weathers, Norman R.
> Cc: Jeff Layton; linux-kernel@vger.kernel.org; 
> linux-nfs@vger.kernel.org
> Subject: Re: CONFIG_DEBUG_SLAB_LEAK omits size-4096 and larger?
> 
> On Wed, Jun 11, 2008 at 05:46:13PM -0500, Weathers, Norman R. wrote:
> > I will try and get it patched and retested, but it may be a 
> day or two
> > before I can get back the information due to production jobs now
> > running.  Once they finish up, I will get back with the info.
> 
> Understood.
> 


I was able to get my big user to cooperate and let me in to be able to
get the information that you were needing.  The full output from the
/proc/slab_allocator file is at
http://www.shashi-weathers.net/linux/cluster/NFS_DEBUG_2 .  The 16
thread case is very interesting.  Also, there is a small txt file in the
directory that has some rpc errors, but I imagine the way that I am
running the box (oversubscribed threads) has more to do with the rpc
errors than anything else.  For those of you wanting the gist of the
story, the size-4096 slab has the following very large allocation:

size-4096: 2 sys_init_module+0x140b/0x1980
size-4096: 1 __vmalloc_area_node+0x188/0x1b0
size-4096: 1 seq_read+0x1d9/0x2e0
size-4096: 1 slabstats_open+0x2b/0x80
size-4096: 5 vc_allocate+0x167/0x190
size-4096: 3 input_allocate_device+0x12/0x80
size-4096: 1 hid_add_field+0x122/0x290
size-4096: 9 reqsk_queue_alloc+0x5f/0xf0
size-4096: 1846825 __alloc_skb+0x7d/0x170
size-4096: 3 alloc_netdev+0x33/0xa0
size-4096: 10 neigh_sysctl_register+0x52/0x2b0
size-4096: 5 devinet_sysctl_register+0x28/0x110
size-4096: 1 pidmap_init+0x15/0x60
size-4096: 1 netlink_proto_init+0x44/0x190
size-4096: 1 ip_rt_init+0xfd/0x2f0
size-4096: 1 cipso_v4_init+0x13/0x70
size-4096: 3 journal_init_revoke+0xe7/0x270 [jbd]
size-4096: 3 journal_init_revoke+0x18a/0x270 [jbd]
size-4096: 2 journal_init_inode+0x84/0x150 [jbd]
size-4096: 2 bnx2_alloc_mem+0x18/0x1f0 [bnx2]
size-4096: 1 joydev_connect+0x53/0x390 [joydev]
size-4096: 13 kmem_alloc+0xb3/0x100 [xfs]
size-4096: 5 addrconf_sysctl_register+0x31/0x130 [ipv6]
size-4096: 7 rpc_clone_client+0x84/0x140 [sunrpc]
size-4096: 3 rpc_create+0x254/0x4d0 [sunrpc]
size-4096: 16 __svc_create_thread+0x53/0x1f0 [sunrpc]
size-4096: 16 __svc_create_thread+0x72/0x1f0 [sunrpc]
size-4096: 1 nfsd_racache_init+0x2e/0x140 [nfsd]

The big one seems to be the __alloc_skb. (This is with 16 threads, and
it says that we are using up somewhere between 12 and 14 GB of memory,
about 2 to 3 gig of that is disk cache).  If I were to put anymore
threads out there, the server would become almost unresponsive (it was
bad enough as it was).   

At the same time, I also noticed this:

skbuff_fclone_cache: 1842524 __alloc_skb+0x50/0x170

Don't know for sure if that is meaningful or not....



> > Thanks everyone for looking at this, by the way!
> 
> And thanks for your persistence.
> 
> --b.
> 


Anytime.  This is the part of the job that is fun (except for my
users...).  Anyone can watch a system run, it's dealing with the unknown
that makes it interesting.


Norman Weathers


> > 
> > > 
> > > 
> > > diff --git a/mm/slab.c b/mm/slab.c
> > > index 06236e4..b379e31 100644
> > > --- a/mm/slab.c
> > > +++ b/mm/slab.c
> > > @@ -2202,7 +2202,7 @@ kmem_cache_create (const char *name, 
> > > size_t size, size_t align,
> > >  	 * above the next power of two: caches with object 
> > > sizes just above a
> > >  	 * power of two have a significant amount of internal 
> > > fragmentation.
> > >  	 */
> > > -	if (size < 4096 || fls(size - 1) == fls(size-1 + REDZONE_ALIGN +
> > > +	if (size < 8192 || fls(size - 1) == fls(size-1 + REDZONE_ALIGN +
> > >  						2 * 
> > > sizeof(unsigned long long)))
> > >  		flags |= SLAB_RED_ZONE | SLAB_STORE_USER;
> > >  	if (!(flags & SLAB_DESTROY_BY_RCU))
> > > 
> > 
> > 
> > Norman Weathers
> --
> To unsubscribe from this list: send the line "unsubscribe 
> linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
