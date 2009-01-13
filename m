From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [patch 1/3] knfsd: remove the nfsd thread busy histogram
Date: Tue, 13 Jan 2009 11:41:04 -0500
Message-ID: <BF9EF754-76CE-41B7-B712-2E96E3D9CA9B@oracle.com>
References: <20090113102633.719563000@sgi.com> <20090113102653.445100000@sgi.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:45074 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756006AbZAMQlX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2009 11:41:23 -0500
In-Reply-To: <20090113102653.445100000@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 13, 2009, at Jan 13, 2009, 5:26 AM, Greg Banks wrote:
> Stop gathering the data that feeds the 'th' line in /proc/net/rpc/nfsd
> because the questionable data provided is not worth the scalability
> impact of calculating it.  Instead, always report zeroes.  The current
> approach suffers from three major issues:
>
> 1. update_thread_usage() increments buckets by call service
>   time or call arrival time...in jiffies.  On lightly loaded
>   machines, call service times are usually < 1 jiffy; on
>   heavily loaded machines call arrival times will be << 1 jiffy.
>   So a large portion of the updates to the buckets are rounded
>   down to zero, and the histogram is undercounting.

Use ktime_get_real() instead.  This is what the network layer uses.   
You could even steal the start timestamp from the first skbuff in an  
incoming RPC request.

This problem is made worse on "server" configurations and in virtual  
guests which may still use HZ=100, though with tickless HZ this is a  
less frequently seen configuration.

> 2. As seen previously on the nfs mailing list, the format in which
>   the histogram is presented is cryptic, difficult to explain,
>   and difficult to use.

A user space script similar to mountstats that interprets these  
metrics might help here.

> 3. Updating the histogram requires taking a global spinlock and
>   dirtying the global variables nfsd_last_call, nfsd_busy, and
>   nfsdstats *twice* on every RPC call, which is a significant
>   scaling limitation.

You might fix this by making the global variables into per-CPU  
variables, then totaling the per-CPU variables only at presentation  
time (ie when someone cats /proc/net/rpc/nfsd).  That would make the  
collection logic lockless.

> Testing on a 4 CPU 4 NIC Altix using 4 IRIX clients each doing
> 1K streaming reads at full line rate, shows the stats update code
> (inlined into nfsd()) takes about 1.7% of each CPU.  This patch drops
> the contribution from nfsd() into the profile noise.
>
> This patch is a forward-ported version of knfsd-remove-nfsd- 
> threadstats
> which has been shipping in the SGI "Enhanced NFS" product since 2006.
> In that time, exactly one customer has noticed that the threadstats
> were missing.

Yeah.  The real issue here is deciding whether these stats are useful  
or not; if not, can they be made useable?

>  It has been previously posted:
>
> http://article.gmane.org/gmane.linux.nfs/10376
>
> and more recently requested to be posted again.
>
> Signed-off-by: Greg Banks <gnb@sgi.com>
> ---
>
> fs/nfsd/nfssvc.c |   28 ----------------------------
> 1 file changed, 28 deletions(-)
>
> Index: bfields/fs/nfsd/nfssvc.c
> ===================================================================
> --- bfields.orig/fs/nfsd/nfssvc.c
> +++ bfields/fs/nfsd/nfssvc.c
> @@ -40,9 +40,6 @@
> extern struct svc_program	nfsd_program;
> static int			nfsd(void *vrqstp);
> struct timeval			nfssvc_boot;
> -static atomic_t			nfsd_busy;
> -static unsigned long		nfsd_last_call;
> -static DEFINE_SPINLOCK(nfsd_call_lock);
>
> /*
>  * nfsd_mutex protects nfsd_serv -- both the pointer itself and the  
> members
> @@ -227,7 +224,6 @@ int nfsd_create_serv(void)
> 			nfsd_max_blksize /= 2;
> 	}
>
> -	atomic_set(&nfsd_busy, 0);
> 	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
> 				      AF_INET,
> 				      nfsd_last_thread, nfsd, THIS_MODULE);
> @@ -376,26 +372,6 @@ nfsd_svc(unsigned short port, int nrserv
> 	return error;
> }
>
> -static inline void
> -update_thread_usage(int busy_threads)
> -{
> -	unsigned long prev_call;
> -	unsigned long diff;
> -	int decile;
> -
> -	spin_lock(&nfsd_call_lock);
> -	prev_call = nfsd_last_call;
> -	nfsd_last_call = jiffies;
> -	decile = busy_threads*10/nfsdstats.th_cnt;
> -	if (decile>0 && decile <= 10) {
> -		diff = nfsd_last_call - prev_call;
> -		if ( (nfsdstats.th_usage[decile-1] += diff) >= NFSD_USAGE_WRAP)
> -			nfsdstats.th_usage[decile-1] -= NFSD_USAGE_WRAP;
> -		if (decile == 10)
> -			nfsdstats.th_fullcnt++;
> -	}
> -	spin_unlock(&nfsd_call_lock);
> -}
>
> /*
>  * This is the NFS server kernel thread
> @@ -464,8 +440,6 @@ nfsd(void *vrqstp)
> 			continue;
> 		}
>
> -		update_thread_usage(atomic_read(&nfsd_busy));
> -		atomic_inc(&nfsd_busy);
>
> 		/* Lock the export hash tables for reading. */
> 		exp_readlock();
> @@ -474,8 +448,6 @@ nfsd(void *vrqstp)
>
> 		/* Unlock export hash tables */
> 		exp_readunlock();
> -		update_thread_usage(atomic_read(&nfsd_busy));
> -		atomic_dec(&nfsd_busy);
> 	}
>
> 	/* Clear signals before calling svc_exit_thread() */
>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
