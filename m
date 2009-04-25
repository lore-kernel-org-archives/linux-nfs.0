From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 03/29] knfsd: add userspace controls for stats tables
Date: Sat, 25 Apr 2009 17:57:45 -0400
Message-ID: <20090425215745.GA5088@fieldses.org>
References: <20090331202800.739621000@sgi.com> <20090331202938.939647000@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:37059 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbZDYV5p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Apr 2009 17:57:45 -0400
In-Reply-To: <20090331202938.939647000@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 01, 2009 at 07:28:03AM +1100, Greg Banks wrote:
> Add two control files to /proc/fs/nfsd:
> 
> * "stats_enabled" can be used to disable or enable the gathering
>    of per-client and per-export statistics in the server.
> 
> * "stats_prune_period" can be used to set the period at
>    which the pruning timer runs, in seconds.  Unused stats
>    entries will survive at most twice that time.
> 
> Signed-off-by: Greg Banks <gnb@sgi.com>
> ---
> 
>  fs/nfsd/nfsctl.c |   99 ++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 99 insertions(+)
> 
> Index: bfields/fs/nfsd/nfsctl.c
> ===================================================================
> --- bfields.orig/fs/nfsd/nfsctl.c
> +++ bfields/fs/nfsd/nfsctl.c
> @@ -64,6 +64,8 @@ enum {
>  	NFSD_Versions,
>  	NFSD_Ports,
>  	NFSD_MaxBlkSize,
> +	NFSD_Stats_Enabled,
> +	NFSD_Stats_Prune_Period,
>  	/*
>  	 * The below MUST come last.  Otherwise we leave a hole in nfsd_files[]
>  	 * with !CONFIG_NFSD_V4 and simple_fill_super() goes oops
> @@ -92,6 +94,8 @@ static ssize_t write_pool_threads(struct
>  static ssize_t write_versions(struct file *file, char *buf, size_t size);
>  static ssize_t write_ports(struct file *file, char *buf, size_t size);
>  static ssize_t write_maxblksize(struct file *file, char *buf, size_t size);
> +static ssize_t write_stats_enabled(struct file *file, char *buf, size_t size);
> +static ssize_t write_stats_prune_period(struct file *file, char *buf, size_t size);
>  #ifdef CONFIG_NFSD_V4
>  static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
>  static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
> @@ -113,6 +117,8 @@ static ssize_t (*write_op[])(struct file
>  	[NFSD_Versions] = write_versions,
>  	[NFSD_Ports] = write_ports,
>  	[NFSD_MaxBlkSize] = write_maxblksize,
> +	[NFSD_Stats_Enabled] = write_stats_enabled,
> +	[NFSD_Stats_Prune_Period] = write_stats_prune_period,
>  #ifdef CONFIG_NFSD_V4
>  	[NFSD_Leasetime] = write_leasetime,
>  	[NFSD_RecoveryDir] = write_recoverydir,
> @@ -1121,6 +1127,97 @@ static ssize_t write_maxblksize(struct f
>  	return sprintf(buf, "%d\n", nfsd_max_blksize);
>  }
>  
> +extern int nfsd_stats_enabled;
> +
> +/**
> + * write_stats_enabled - Set or report whether per-client/
> + *			 per-export stats are enabled.
> + *
> + * Input:
> + *			buf:		ignored
> + *			size:		zero
> + *
> + * OR
> + *
> + * Input:
> + * 			buf:		C string containing an unsigned
> + * 					integer value representing the new value
> + *			size:		non-zero length of C string in @buf
> + * Output:
> + *	On success:	passed-in buffer filled with '\n'-terminated C string
> + *			containing numeric value of the current setting
> + *			return code is the size in bytes of the string
> + *	On error:	return code is zero or a negative errno value
> + */
> +static ssize_t write_stats_enabled(struct file *file, char *buf, size_t size)
> +{
> +	char *mesg = buf;
> +	if (size > 0) {
> +		int enabled;
> +		int rv = get_int(&mesg, &enabled);
> +		if (rv)
> +			return rv;
> +		/* check `enabled' against allowed range */
> +		if (enabled < 0 || enabled > 1)
> +			return -EINVAL;
> +		/*
> +		 * We can change the enabled flag at any time without
> +		 * locking.  All it controls is whether stats are
> +		 * gathered for new incoming NFS calls.  Old gathered
> +		 * stats still sit around in the hash tables until
> +		 * naturally pruned.
> +		 */
> +		nfsd_stats_enabled = enabled;
> +	}
> +	return sprintf(buf, "%d\n", nfsd_stats_enabled);
> +}
> +
> +extern int nfsd_stats_prune_period;
> +
> +/**
> + * write_stats_prune_period - Set or report the period for pruning
> + *			      old per-client/per-export stats entries,
> + *			      in seconds.
> + *
> + * Input:
> + *			buf:		ignored
> + *			size:		zero
> + *
> + * OR
> + *
> + * Input:
> + * 			buf:		C string containing an unsigned
> + * 					integer value representing the new value
> + *			size:		non-zero length of C string in @buf
> + * Output:
> + *	On success:	passed-in buffer filled with '\n'-terminated C string
> + *			containing numeric value of the current setting
> + *			return code is the size in bytes of the string
> + *	On error:	return code is zero or a negative errno value
> + */

Just an idle remark, don't worry about this for now, but: we might want
to rein in this write_*() comment format a little some day.  A lot of
the content seems duplicated.

--b.

> +static ssize_t write_stats_prune_period(struct file *file, char *buf, size_t size)
> +{
> +	char *mesg = buf;
> +	if (size > 0) {
> +		int period;
> +		int rv = get_int(&mesg, &period);
> +		if (rv)
> +			return rv;
> +		/* check `period' against allowed range */
> +		if (period < 10 || period > 14*86400)
> +			return -EINVAL;
> +		/*
> +		 * We can change the period at any time without
> +		 * locking.  All it controls is the timeout on the
> +		 * next run of the prune timer.  This might cause
> +		 * some unexpected behaviour if the period is
> +		 * changed from really high to really low.
> +		 */
> +		nfsd_stats_prune_period = period;
> +	}
> +	return sprintf(buf, "%d\n", nfsd_stats_prune_period);
> +}
> +
>  #ifdef CONFIG_NFSD_V4
>  extern time_t nfs4_leasetime(void);
>  
> @@ -1263,6 +1360,8 @@ static int nfsd_fill_super(struct super_
>  		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_Ports] = {"portlist", &transaction_ops, S_IWUSR|S_IRUGO},
>  		[NFSD_MaxBlkSize] = {"max_block_size", &transaction_ops, S_IWUSR|S_IRUGO},
> +		[NFSD_Stats_Enabled] = {"stats_enabled", &transaction_ops, S_IWUSR|S_IRUGO},
> +		[NFSD_Stats_Prune_Period] = {"stats_prune_period", &transaction_ops, S_IWUSR|S_IRUGO},
>  #ifdef CONFIG_NFSD_V4
>  		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
> 
> --
> Greg
