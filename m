Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56049 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758408Ab3BNWJn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Feb 2013 17:09:43 -0500
Date: Thu, 14 Feb 2013 17:09:42 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd: add new reply_cache_stats file in nfsdfs
Message-ID: <20130214220942.GH8343@fieldses.org>
References: <1360878315-21578-1-git-send-email-jlayton@redhat.com>
 <1360878315-21578-4-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1360878315-21578-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 14, 2013 at 04:45:15PM -0500, Jeff Layton wrote:
> For presenting statistics relating to duplicate reply cache.

Looks to me like a reasonable way to do it.  Holding off on applying for
now.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfsd/cache.h    |  1 +
>  fs/nfsd/nfscache.c | 18 ++++++++++++++++++
>  fs/nfsd/nfsctl.c   |  9 +++++++++
>  3 files changed, 28 insertions(+)
> 
> diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
> index 87fd141..d5c5b3e 100644
> --- a/fs/nfsd/cache.h
> +++ b/fs/nfsd/cache.h
> @@ -82,6 +82,7 @@ int	nfsd_reply_cache_init(void);
>  void	nfsd_reply_cache_shutdown(void);
>  int	nfsd_cache_lookup(struct svc_rqst *);
>  void	nfsd_cache_update(struct svc_rqst *, int, __be32 *);
> +int	nfsd_reply_cache_stats_open(struct inode *, struct file *);
>  
>  #ifdef CONFIG_NFSD_V4
>  void	nfsd4_set_statp(struct svc_rqst *rqstp, __be32 *statp);
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index bccf74f..517b92d 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -540,3 +540,21 @@ nfsd_cache_append(struct svc_rqst *rqstp, struct kvec *data)
>  	vec->iov_len += data->iov_len;
>  	return 1;
>  }
> +
> +static int nfsd_reply_cache_stats_show(struct seq_file *m, void *v)
> +{
> +	spin_lock(&cache_lock);
> +	seq_printf(m, "max entries:     %u\n", max_drc_entries);
> +	seq_printf(m, "num entries:     %u\n", num_drc_entries);
> +	seq_printf(m, "cache hits:      %u\n", nfsdstats.rchits);
> +	seq_printf(m, "cache misses:    %u\n", nfsdstats.rcmisses);
> +	seq_printf(m, "not cached:      %u\n", nfsdstats.rcnocache);
> +	seq_printf(m, "checksum misses: %u\n", csum_misses);
> +	spin_unlock(&cache_lock);
> +	return 0;
> +}
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
>  	NFSD_Threads,
>  	NFSD_Pool_Threads,
>  	NFSD_Pool_Stats,
> +	NFSD_Reply_Cache_Stats,
>  	NFSD_Versions,
>  	NFSD_Ports,
>  	NFSD_MaxBlkSize,
> @@ -194,6 +195,13 @@ static const struct file_operations pool_stats_operations = {
>  	.owner		= THIS_MODULE,
>  };
>  
> +static struct file_operations reply_cache_stats_operations = {
> +	.open		= nfsd_reply_cache_stats_open,
> +	.read		= seq_read,
> +	.llseek		= seq_lseek,
> +	.release	= single_release,
> +};
> +
>  /*----------------------------------------------------------------------------*/
>  /*
>   * payload - write methods
> @@ -1024,6 +1032,7 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
>  		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_Pool_Stats] = {"pool_stats", &pool_stats_operations, S_IRUGO},
> +		[NFSD_Reply_Cache_Stats] = {"reply_cache_stats", &reply_cache_stats_operations, S_IRUGO},
>  		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
>  		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
> -- 
> 1.7.11.7
> 
