From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: Re: [patch 3/3] knfsd: add file to export stats about nfsd pools
Date: Thu, 12 Feb 2009 17:53:20 -0800
Message-ID: <4994D290.3020906@disney.com>
References: <20090113102633.719563000@sgi.com> <20090113102653.884405000@sgi.com> <20090212171106.GB21445@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Greg Banks <gnb@sgi.com>, Linux NFS ML <linux-nfs@vger.kernel.org>,
	Harshula Jayasuriya <harshula@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate2.disneyanimation.com ([12.188.26.102]:62611 "EHLO
	mailgate2.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758206AbZBMCCv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2009 21:02:51 -0500
In-Reply-To: <20090212171106.GB21445@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/12/09 09:11, J. Bruce Fields wrote:
> On Tue, Jan 13, 2009 at 09:26:36PM +1100, Greg Banks wrote:
>> Add /proc/fs/nfsd/pool_stats to export to userspace various
>> statistics about the operation of rpc server thread pools.
> 
> Could you explainw hy these specific statistics (total packets,
> sockets_queued, threads_woken, overloads_avoided, threads_timedout) are
> the important ones to capture?  Could you give examples of what sort of
> problems could be solved using them?
> 
> As you said, an important question for the sysadmin is "should I
> configure more nfsds?"  How do they answer that?
> 

I typically use the "th" line to determine whether to add more threads 
or not by looking at the distribution of values across the histogram. 
If things are weighted more towards the 90-100% group, I'll add more 
threads and watch the traffic patterns.

Usually, the question of how many to add is answered by trial and error.

echo 32 > /proc/fs/nfsd/threads
Did that improve my throughput? yes?
echo 128 > /proc/fs/nfsd/threads
Did that improve my throughput? no it actually decreased.
rinse... repeat...

> --b.
> 
>> This patch is based on a forward-ported version of
>> knfsd-add-pool-thread-stats which has been shipping in the SGI
>> "Enhanced NFS" product since 2006 and which was previously
>> posted:
> 
>> http://article.gmane.org/gmane.linux.nfs/10375
>>
>> It has also been updated thus:
>>
>>  * moved EXPORT_SYMBOL() to near the function it exports
>>  * made the new struct struct seq_operations const
>>  * used SEQ_START_TOKEN instead of ((void *)1)
>>  * merged fix from SGI PV 990526 "sunrpc: use dprintk instead of
>>    printk in svc_pool_stats_*()" by Harshula Jayasuriya.
>>  * merged fix from SGI PV 964001 "Crash reading pool_stats before
>>    nfsds are started".
>>
>> Signed-off-by: Greg Banks <gnb@sgi.com>
>> Signed-off-by: Harshula Jayasuriya <harshula@sgi.com>
>> ---
>>
>>  fs/nfsd/nfsctl.c           |   12 ++++
>>  fs/nfsd/nfssvc.c           |    7 ++
>>  include/linux/sunrpc/svc.h |   11 +++
>>  net/sunrpc/svc_xprt.c      |  100 +++++++++++++++++++++++++++++++++-
>>  4 files changed, 129 insertions(+), 1 deletion(-)
>>
>> Index: bfields/fs/nfsd/nfsctl.c
>> ===================================================================
>> --- bfields.orig/fs/nfsd/nfsctl.c
>> +++ bfields/fs/nfsd/nfsctl.c
>> @@ -60,6 +60,7 @@ enum {
>>  	NFSD_FO_UnlockFS,
>>  	NFSD_Threads,
>>  	NFSD_Pool_Threads,
>> +	NFSD_Pool_Stats,
>>  	NFSD_Versions,
>>  	NFSD_Ports,
>>  	NFSD_MaxBlkSize,
>> @@ -172,6 +173,16 @@ static const struct file_operations expo
>>  	.owner		= THIS_MODULE,
>>  };
>>  
>> +extern int nfsd_pool_stats_open(struct inode *inode, struct file *file);
>> +
>> +static struct file_operations pool_stats_operations = {
>> +	.open		= nfsd_pool_stats_open,
>> +	.read		= seq_read,
>> +	.llseek		= seq_lseek,
>> +	.release	= seq_release,
>> +	.owner		= THIS_MODULE,
>> +};
>> +
>>  /*----------------------------------------------------------------------------*/
>>  /*
>>   * payload - write methods
>> @@ -1246,6 +1257,7 @@ static int nfsd_fill_super(struct super_
>>  		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
>>  		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
>>  		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
>> +		[NFSD_Pool_Stats] = {"pool_stats", &pool_stats_operations, S_IRUGO},
>>  		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
>>  		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
>>  		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
>> Index: bfields/fs/nfsd/nfssvc.c
>> ===================================================================
>> --- bfields.orig/fs/nfsd/nfssvc.c
>> +++ bfields/fs/nfsd/nfssvc.c
>> @@ -546,3 +546,10 @@ nfsd_dispatch(struct svc_rqst *rqstp, __
>>  	nfsd_cache_update(rqstp, proc->pc_cachetype, statp + 1);
>>  	return 1;
>>  }
>> +
>> +int nfsd_pool_stats_open(struct inode *inode, struct file *file)
>> +{
>> +	if (nfsd_serv == NULL)
>> +		return -ENODEV;
>> +	return svc_pool_stats_open(nfsd_serv, file);
>> +}
>> Index: bfields/include/linux/sunrpc/svc.h
>> ===================================================================
>> --- bfields.orig/include/linux/sunrpc/svc.h
>> +++ bfields/include/linux/sunrpc/svc.h
>> @@ -24,6 +24,15 @@
>>   */
>>  typedef int		(*svc_thread_fn)(void *);
>>  
>> +/* statistics for svc_pool structures */
>> +struct svc_pool_stats {
>> +	unsigned long	packets;
>> +	unsigned long	sockets_queued;
>> +	unsigned long	threads_woken;
>> +	unsigned long	overloads_avoided;
>> +	unsigned long	threads_timedout;
>> +};
>> +
>>  /*
>>   *
>>   * RPC service thread pool.
>> @@ -42,6 +51,7 @@ struct svc_pool {
>>  	unsigned int		sp_nrthreads;	/* # of threads in pool */
>>  	struct list_head	sp_all_threads;	/* all server threads */
>>  	int			sp_nwaking;	/* number of threads woken but not yet active */
>> +	struct svc_pool_stats	sp_stats;	/* statistics on pool operation */
>>  } ____cacheline_aligned_in_smp;
>>  
>>  /*
>> @@ -396,6 +406,7 @@ struct svc_serv *  svc_create_pooled(str
>>  			sa_family_t, void (*shutdown)(struct svc_serv *),
>>  			svc_thread_fn, struct module *);
>>  int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *, int);
>> +int		   svc_pool_stats_open(struct svc_serv *serv, struct file *file);
>>  void		   svc_destroy(struct svc_serv *);
>>  int		   svc_process(struct svc_rqst *);
>>  int		   svc_register(const struct svc_serv *, const unsigned short,
>> Index: bfields/net/sunrpc/svc_xprt.c
>> ===================================================================
>> --- bfields.orig/net/sunrpc/svc_xprt.c
>> +++ bfields/net/sunrpc/svc_xprt.c
>> @@ -318,6 +318,8 @@ void svc_xprt_enqueue(struct svc_xprt *x
>>  		goto out_unlock;
>>  	}
>>  
>> +	pool->sp_stats.packets++;
>> +
>>  	/* Mark transport as busy. It will remain in this state until
>>  	 * the provider calls svc_xprt_received. We update XPT_BUSY
>>  	 * atomically because it also guards against trying to enqueue
>> @@ -355,6 +357,7 @@ void svc_xprt_enqueue(struct svc_xprt *x
>>  	if (pool->sp_nwaking >= SVC_MAX_WAKING) {
>>  		/* too many threads are runnable and trying to wake up */
>>  		thread_avail = 0;
>> +		pool->sp_stats.overloads_avoided++;
>>  	}
>>  
>>  	if (thread_avail) {
>> @@ -374,11 +377,13 @@ void svc_xprt_enqueue(struct svc_xprt *x
>>  		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
>>  		rqstp->rq_waking = 1;
>>  		pool->sp_nwaking++;
>> +		pool->sp_stats.threads_woken++;
>>  		BUG_ON(xprt->xpt_pool != pool);
>>  		wake_up(&rqstp->rq_wait);
>>  	} else {
>>  		dprintk("svc: transport %p put into queue\n", xprt);
>>  		list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
>> +		pool->sp_stats.sockets_queued++;
>>  		BUG_ON(xprt->xpt_pool != pool);
>>  	}
>>  
>> @@ -591,6 +596,7 @@ int svc_recv(struct svc_rqst *rqstp, lon
>>  	int			pages;
>>  	struct xdr_buf		*arg;
>>  	DECLARE_WAITQUEUE(wait, current);
>> +	long			time_left;
>>  
>>  	dprintk("svc: server %p waiting for data (to = %ld)\n",
>>  		rqstp, timeout);
>> @@ -676,12 +682,14 @@ int svc_recv(struct svc_rqst *rqstp, lon
>>  		add_wait_queue(&rqstp->rq_wait, &wait);
>>  		spin_unlock_bh(&pool->sp_lock);
>>  
>> -		schedule_timeout(timeout);
>> + 		time_left = schedule_timeout(timeout);
>>  
>>  		try_to_freeze();
>>  
>>  		spin_lock_bh(&pool->sp_lock);
>>  		remove_wait_queue(&rqstp->rq_wait, &wait);
>> +		if (!time_left)
>> +			pool->sp_stats.threads_timedout++;
>>  
>>  		xprt = rqstp->rq_xprt;
>>  		if (!xprt) {
>> @@ -1103,3 +1111,93 @@ int svc_xprt_names(struct svc_serv *serv
>>  	return totlen;
>>  }
>>  EXPORT_SYMBOL_GPL(svc_xprt_names);
>> +
>> +
>> +/*----------------------------------------------------------------------------*/
>> +
>> +static void *svc_pool_stats_start(struct seq_file *m, loff_t *pos)
>> +{
>> +	unsigned int pidx = (unsigned int)*pos;
>> +	struct svc_serv *serv = m->private;
>> +
>> +	dprintk("svc_pool_stats_start, *pidx=%u\n", pidx);
>> +
>> +	lock_kernel();
>> +	/* bump up the pseudo refcount while traversing */
>> +	svc_get(serv);
>> +	unlock_kernel();
>> +
>> +	if (!pidx)
>> +		return SEQ_START_TOKEN;
>> +	return (pidx > serv->sv_nrpools ? NULL : &serv->sv_pools[pidx-1]);
>> +}
>> +
>> +static void *svc_pool_stats_next(struct seq_file *m, void *p, loff_t *pos)
>> +{
>> +	struct svc_pool *pool = p;
>> +	struct svc_serv *serv = m->private;
>> +
>> +	dprintk("svc_pool_stats_next, *pos=%llu\n", *pos);
>> +
>> +	if (p == SEQ_START_TOKEN) {
>> +		pool = &serv->sv_pools[0];
>> +	} else {
>> +		unsigned int pidx = (pool - &serv->sv_pools[0]);
>> +		if (pidx < serv->sv_nrpools-1)
>> +			pool = &serv->sv_pools[pidx+1];
>> +		else
>> +			pool = NULL;
>> +	}
>> +	++*pos;
>> +	return pool;
>> +}
>> +
>> +static void svc_pool_stats_stop(struct seq_file *m, void *p)
>> +{
>> +	struct svc_serv *serv = m->private;
>> +
>> +	lock_kernel();
>> +	/* this function really, really should have been called svc_put() */
>> +	svc_destroy(serv);
>> +	unlock_kernel();
>> +}
>> +
>> +static int svc_pool_stats_show(struct seq_file *m, void *p)
>> +{
>> +	struct svc_pool *pool = p;
>> +
>> +	if (p == SEQ_START_TOKEN) {
>> +		seq_puts(m, "# pool packets-arrived sockets-enqueued threads-woken overloads-avoided threads-timedout\n");
>> +		return 0;
>> +	}
>> +
>> +	seq_printf(m, "%u %lu %lu %lu %lu %lu\n",
>> +		pool->sp_id,
>> +		pool->sp_stats.packets,
>> +		pool->sp_stats.sockets_queued,
>> +		pool->sp_stats.threads_woken,
>> +		pool->sp_stats.overloads_avoided,
>> +		pool->sp_stats.threads_timedout);
>> +
>> +	return 0;
>> +}
>> +
>> +static const struct seq_operations svc_pool_stats_seq_ops = {
>> +	.start	= svc_pool_stats_start,
>> +	.next	= svc_pool_stats_next,
>> +	.stop	= svc_pool_stats_stop,
>> +	.show	= svc_pool_stats_show,
>> +};
>> +
>> +int svc_pool_stats_open(struct svc_serv *serv, struct file *file)
>> +{
>> +	int err;
>> +
>> +	err = seq_open(file, &svc_pool_stats_seq_ops);
>> +	if (!err)
>> +		((struct seq_file *) file->private_data)->private = serv;
>> +	return err;
>> +}
>> +EXPORT_SYMBOL(svc_pool_stats_open);
>> +
>> +/*----------------------------------------------------------------------------*/
>>
>> --
>> -- 
>> Greg Banks, P.Engineer, SGI Australian Software Group.
>> the brightly coloured sporks of revolution.
>> I don't speak for SGI.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
