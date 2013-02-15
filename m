Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:45534 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006Ab3BOR3U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2013 12:29:20 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH v2 3/3] nfsd: add new reply_cache_stats file in nfsdfs
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1360948990-2265-4-git-send-email-jlayton@redhat.com>
Date: Fri, 15 Feb 2013 12:29:08 -0500
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Message-Id: <D3E38097-34BE-4A2D-91F6-200176FEA3F0@oracle.com>
References: <1360948990-2265-1-git-send-email-jlayton@redhat.com> <1360948990-2265-4-git-send-email-jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 15, 2013, at 12:23 PM, Jeff Layton <jlayton@redhat.com> wrote:

> For presenting statistics relating to duplicate reply cache.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfsd/cache.h    |  1 +
> fs/nfsd/nfscache.c | 37 +++++++++++++++++++++++++++++++++----
> fs/nfsd/nfsctl.c   |  9 +++++++++
> 3 files changed, 43 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
> index 87fd141..d5c5b3e 100644
> --- a/fs/nfsd/cache.h
> +++ b/fs/nfsd/cache.h
> @@ -82,6 +82,7 @@ int	nfsd_reply_cache_init(void);
> void	nfsd_reply_cache_shutdown(void);
> int	nfsd_cache_lookup(struct svc_rqst *);
> void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
> +int	nfsd_reply_cache_stats_open(struct inode *, struct file *);
> 
> #ifdef CONFIG_NFSD_V4
> void	nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp);
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index ad1d069..b155afa 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -23,12 +23,17 @@
> static struct hlist_head *	cache_hash;
> static struct list_head 	lru_head;
> static struct kmem_cache	*drc_slab;
> -static unsigned int		num_drc_entries;
> -static unsigned int		max_drc_entries;
> -static unsigned int		drc_mem_usage;
> -static unsigned int		csum_misses;
> 
> /*
> + * Stats on the duplicate reply cache code. All of these and the "rc" fields
> + * in nfsdstats are protected by the cache_lock
> + */
> +static unsigned int		num_drc_entries; /* number of entries */
> +static unsigned int		max_drc_entries; /* max number of entries */
> +static unsigned int		drc_mem_usage;   /* memory used by cache */
> +static unsigned int		csum_misses;     /* cache misses due only to
> +						    csum comparison failures */
> +/*
>  * Calculate the hash index from an XID.
>  */
> static inline u32 request_hash(u32 xid)
> @@ -545,3 +550,27 @@ nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *data)
> 	vec->iov_len += data->iov_len;
> 	return 1;
> }
> +
> +/*
> + * Note that fields may be added, removed or reordered in the future. Programs
> + * scraping this file for info should test the labels to ensure they're
> + * getting the correct field.
> + */
> +static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
> +{
> +	spin_lock(&cache_lock);
> +	seq_printf(m, "max entries:     %u\n", max_drc_entries);
> +	seq_printf(m, "num entries:     %u\n", num_drc_entries);
> +	seq_printf(m, "mem usage:       %u\n", drc_mem_usage);
> +	seq_printf(m, "cache hits:      %u\n", nfsdstats.rchits);
> +	seq_printf(m, "cache misses:    %u\n", nfsdstats.rcmisses);
> +	seq_printf(m, "not cached:      %u\n", nfsdstats.rcnocache);
> +	seq_printf(m, "checksum misses: %u\n", csum_misses);
> +	spin_unlock(&cache_lock);
> +	return 0;
> +}

Would it be hard to add a statistic that quantified the distribution of entries in the cache hash table?  Something like "maximum length of cache hash chain" ?


> +
> +int nfsd_reply_cache_stats_open(struct inode *inode, struct file *file)
> +{
> +	return single_open(file, nfsd_reply_cache_stats_show, NULL);
> +}
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 29c3f0d..5dea5af 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -35,6 +35,7 @@ enum {
> 	NFSD_Threads,
> 	NFSD_Pool_Threads,
> 	NFSD_Pool_Stats,
> +	NFSD_Reply_Cache_Stats,
> 	NFSD_Versions,
> 	NFSD_Ports,
> 	NFSD_MaxBlkSize,
> @@ -194,6 +195,13 @@ static const struct file_operations pool_stats_operations = {
> 	.owner		= THIS_MODULE,
> };
> 
> +static struct file_operations reply_cache_stats_operations = {
> +	.open		= nfsd_reply_cache_stats_open,
> +	.read		= seq_read,
> +	.llseek		= seq_lseek,
> +	.release	= single_release,
> +};
> +
> /*----------------------------------------------------------------------------*/
> /*
>  * payload - write methods
> @@ -1024,6 +1032,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
> 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
> 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
> 		[NFSD_Pool_Stats] = {"pool_stats", &pool_stats_operations, S_IRUGO},
> +		[NFSD_Reply_Cache_Stats] = {"reply_cache_stats", &reply_cache_stats_operations, S_IRUGO},
> 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
> 		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
> 		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




