Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga11.intel.com ([192.55.52.93]:36470 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254Ab2FYCmS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Jun 2012 22:42:18 -0400
Date: Mon, 25 Jun 2012 10:42:11 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andi Kleen <ak@linux.intel.com>
Cc: Linux-NFS <linux-nfs@vger.kernel.org>
Subject: Re: rpcauth_lookup_credcache() lock contentions
Message-ID: <20120625024211.GA11057@localhost>
References: <20120623122604.GA10887@localhost>
 <20120624213417.GI4152@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120624213417.GI4152@tassilo.jf.intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 24, 2012 at 02:34:17PM -0700, Andi Kleen wrote:
> On Sat, Jun 23, 2012 at 08:26:04PM +0800, Fengguang Wu wrote:
> > Hi,
> > 
> > When doing parallel kernel builds on an NFSROOT system with 32 logical
> > CPUs, I see half CPU time spent in kernel:
> > 
> > top - 20:08:28 up  5:01,  8 users,  load average: 62.97, 55.82, 54.56
> > Tasks: 751 total,  80 running, 671 sleeping,   0 stopped,   0 zombie
> > Cpu(s):  0.1%us, 53.5%sy, 46.4%ni,  0.0%id,  0.0%wa,  0.0%hi,  0.1%si,  0.0%st
> > Mem:  65401132k total, 36455604k used, 28945528k free,        0k buffers
> > Swap:        0k total,        0k used,        0k free, 31858244k cached
> > 
> > The attached lock_stat shows that rpcauth_lookup_credcache() has the
> > outstanding contentions.
> 
> Hmm, the cache is already using RCU for the read case, just takes
> a lock for writing. Or when checking an entry.
> 
> So you either have a lot of lookups on the same entry, or you thrash
> the cache.
> 
> When you look up the look address, is it the one in the first loop?
> If yes then it's the first.
> 
> I'm not fully sure why it takes the lock in the read case anyways. Neither
> test_bit nor atomic_inc under RCU should need a lock, so I suppose
> it can be just removed.
> 
> 367                 spin_lock(&cache->lock);
> 368                 if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) == 0) {
> 369                         spin_unlock(&cache->lock);
> 370                         continue;
> 371                 }
> 372                 cred = get_rpccred(entry);
> 373                 spin_unlock(&cache->lock);
> 
> and get_rpccred is just
> 
> 154 static inline
> 155 struct rpc_cred *       get_rpccred(struct rpc_cred *cred)
> 156 {
> 157         atomic_inc(&cred->cr_count);
> 158         return cred;
> 159 }
> 
> Can you try this patch?

Thank you! This patch brings %sys down to 24%, a pretty large improvement!

root@snb /home/wfg# vmstat 3
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
78  0      0 21294520      0 8822056    0    0     0     0   46   56  7  3 90  0
71  0      0 21312104      0 8832776    0    0     0     0 32831 14960 76 24  0  0
76  0      0 21203800      0 8844552    0    0     0     0 32892 15100 75 25  0  0
73  0      0 21019004      0 8856028    0    0     0     0 32837 14770 75 25  0  0
72  0      0 21021084      0 8865996    0    0     0     0 32841 14901 76 24  0  0
76  0      0 20907260      0 8876084    0    0     0     0 32678 14643 76 24  0  0
68  0      0 20936304      0 8886732    0    0     0     0 32724 14858 78 22  0  0
72  0      0 20889164      0 8897520    0    0     0     0 32732 14813 76 24  0  0
81  0      0 20742408      0 8907368    0    0     0     0 32745 14669 77 23  0  0
70  0      0 20662060      0 8917840    0    0     0     0 32748 14751 76 24  0  0
74  0      0 21035616      0 8927836    0    0     0     0 32781 14856 77 23  0  0
^C

It completely removes the function from lock_stat. Now the new
contented functions are

                              class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

               &(&dentry->d_lock)->rlock:     197445146      201224451           0.10        2777.33   461033150.94     1345525784     6033591257           0.08         321.13  1158851748.52
               -------------------------
               &(&dentry->d_lock)->rlock      111609824          [<ffffffff811609f1>] dput+0x33/0x169
               &(&dentry->d_lock)->rlock       18819236          [<ffffffff81156b86>] path_get+0x2c/0x3c
               &(&dentry->d_lock)->rlock       17621335          [<ffffffff81156c20>] unlazy_walk+0x8a/0x1ac
               &(&dentry->d_lock)->rlock       34148964          [<ffffffff81160233>] dget_parent+0x4b/0xaf
               -------------------------
               &(&dentry->d_lock)->rlock       14495017          [<ffffffff81156b86>] path_get+0x2c/0x3c
               &(&dentry->d_lock)->rlock       89313409          [<ffffffff811609f1>] dput+0x33/0x169
               &(&dentry->d_lock)->rlock       19487816          [<ffffffff81156c20>] unlazy_walk+0x8a/0x1ac
               &(&dentry->d_lock)->rlock       59151508          [<ffffffff81160233>] dget_parent+0x4b/0xaf

...............................................................................................................................................................................................

               &sb->s_type->i_lock_key#1:      24313829       24330907           0.09         185.01    22864745.70      572924538     1422754983           0.08         244.15   852837006.69
               -------------------------
               &sb->s_type->i_lock_key#1       24263909          [<ffffffff81244ad9>] nfs_do_access+0x2b/0x350
               &sb->s_type->i_lock_key#1           1438          [<ffffffff8125069d>] nfs_unblock_sillyrename+0x9b/0xce
               &sb->s_type->i_lock_key#1          24986          [<ffffffff81247049>] nfs_file_set_open_context+0x3a/0x62
               &sb->s_type->i_lock_key#1          18689          [<ffffffff813f8285>] _atomic_dec_and_lock+0x39/0x50
               -------------------------
               &sb->s_type->i_lock_key#1       24280596          [<ffffffff81244ad9>] nfs_do_access+0x2b/0x350
               &sb->s_type->i_lock_key#1            578          [<ffffffff8125069d>] nfs_unblock_sillyrename+0x9b/0xce
               &sb->s_type->i_lock_key#1           8602          [<ffffffff813f8285>] _atomic_dec_and_lock+0x39/0x50
               &sb->s_type->i_lock_key#1          15649          [<ffffffff81247186>] nfs_release+0x47/0x93

Thanks,
Fengguang

> commit fa1eef2ec22f2fc31e0381b864044fbb753dd572
> Author: Andi Kleen <ak@linux.intel.com>
> Date:   Sun Jun 24 14:31:06 2012 -0700
> 
>     sunrpc: remove useless spinlocks in credential lookup path
>     
>     Fengguang noticed that rpcauth_lookup_credcache has high lock contention
>     on the nfs server when doing kernel builds on nfsroot.
>     
>     There is no reason to take the spinlock in the read loop: the RCU
>     makes sure the object does not go away, and either test_bit
>     nor atomic_inc in get_rpccred() needs a lock.
>     
>     So just remove the spinlock in the read lookup path.
>     
>     Reported-by: Fengguang Wu
>     Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index 727e506..13c2b58 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -364,13 +364,10 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
>  	hlist_for_each_entry_rcu(entry, pos, &cache->hashtable[nr], cr_hash) {
>  		if (!entry->cr_ops->crmatch(acred, entry, flags))
>  			continue;
> -		spin_lock(&cache->lock);
>  		if (test_bit(RPCAUTH_CRED_HASHED, &entry->cr_flags) == 0) {
> -			spin_unlock(&cache->lock);
>  			continue;
>  		}
>  		cred = get_rpccred(entry);
> -		spin_unlock(&cache->lock);
>  		break;
>  	}
>  	rcu_read_unlock();
