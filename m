From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] NLM add resume procfs file
Date: Mon, 28 Jan 2008 21:19:10 -0500
Message-ID: <20080129021910.GF16785@fieldses.org>
References: <47997059.704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41083 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752038AbYA2CTR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 21:19:17 -0500
In-Reply-To: <47997059.704@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 25, 2008 at 12:15:05AM -0500, Wendy Cheng wrote:
> Add a new nfsd procfs file "resume_ip" to enable per-ip base lockd grace  
> period:
>
> Example Usage:
> root-shell> echo 10.1.1.64 > /proc/fs/nfsd/resume_ip
>
> Only support IPV4 address for this patch submission.
>
> -- Wendy
>

> Add a new nfsd procfs file "resume_ip" to enable per-ip base lockd grace 
> period:
> 
> Example Usage:
> root-shell> echo 10.1.1.64 > /proc/fs/nfsd/resume_ip
> 
> Only support IPV4 address for this patch submission.
> 
> Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
> Signed-off-by: Lon Hohberger  <lhh@redhat.com>
> 
>  fs/lockd/svcsubs.c          |    9 +++++++++
>  fs/nfsd/nfsctl.c            |   43 ++++++++++++++++++++++++++++++++++++++-----
>  include/linux/lockd/lockd.h |    1 +
>  3 files changed, 48 insertions(+), 5 deletions(-)
> 
> --- linux-1/fs/nfsd/nfsctl.c	2008-01-22 10:36:24.000000000 -0500
> +++ linux-2/fs/nfsd/nfsctl.c	2008-01-24 17:03:12.000000000 -0500
> @@ -56,6 +56,7 @@ enum {
>  	NFSD_Fh,
>  	NFSD_FO_UnlockIP,
>  	NFSD_FO_UnlockFS,
> +	NFSD_FO_ResumeIP,
>  	NFSD_Threads,
>  	NFSD_Pool_Threads,
>  	NFSD_Versions,
> @@ -94,6 +95,7 @@ static ssize_t write_recoverydir(struct 
>  
>  static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size);
>  static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size);
> +static ssize_t failover_resume_ip(struct file *file, char *buf, size_t size);
>  
>  static ssize_t (*write_op[])(struct file *, char *, size_t) = {
>  	[NFSD_Svc] = write_svc,
> @@ -106,6 +108,7 @@ static ssize_t (*write_op[])(struct file
>  	[NFSD_Fh] = write_filehandle,
>  	[NFSD_FO_UnlockIP] = failover_unlock_ip,
>  	[NFSD_FO_UnlockFS] = failover_unlock_fs,
> +	[NFSD_FO_ResumeIP] = failover_resume_ip,
>  	[NFSD_Threads] = write_threads,
>  	[NFSD_Pool_Threads] = write_pool_threads,
>  	[NFSD_Versions] = write_versions,
> @@ -297,11 +300,13 @@ static ssize_t write_getfd(struct file *
>  	return err;
>  }
>  
> -static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
> +static int failover_parse_ip(struct file *file,
> +			     char *buf,
> +			     size_t size,
> +			     __be32 *server_ip)
>  {
> -	__be32 server_ip;
>  	char *fo_path, c;
> -	int b1, b2, b3, b4;
> +	int b1, b2, b3, b4, len;
>  
>  	/* sanity check */
>  	if (size == 0)
> @@ -315,13 +320,39 @@ static ssize_t failover_unlock_ip(struct
>  		return -EINVAL;
>  
>  	/* get ipv4 address */
> -	if (sscanf(fo_path, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
> +	len = sscanf(fo_path, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c);
> +	if (len != 4)
>  		return -EINVAL;
> -	server_ip = htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
> +
> +	*server_ip = htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
> +
> +	return len;
> +}
> +
> +static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
> +{
> +	__be32 server_ip;
> +	int rc;
> +
> +	rc = failover_parse_ip(file, buf, size, &server_ip);
> +	if (rc < 0)
> +		return rc;
>  
>  	return nlmsvc_failover_ip(server_ip);
>  }

Looks great, but it would fit more logically with the previous patch.
(If you know you're going to end up using this code in two places, may
as well write it that way from the start.)

>  
> +static ssize_t failover_resume_ip(struct file *file, char *buf, size_t size)
> +{
> +	__be32 server_ip;
> +	int len;
> +
> +	len = failover_parse_ip(file, buf, size, &server_ip);
> +	if (len < 0)
> +		return len;
> +
> +	return nlmsvc_failover_setgrace(&server_ip, len);

Does this really need to take a void *?  And the &server_ip makes it
look like server_ip may be modified, which is slightly confusing.

Maybe the next patches will remind me why it's being done this way....

> +}
> +
>  static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size)
>  {
>  	struct nameidata nd;
> @@ -711,6 +742,8 @@ static int nfsd_fill_super(struct super_
>  					&transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_FO_UnlockFS] = {"unlock_filesystem",
>  					&transaction_ops, S_IWUSR|S_IRUSR},
> +		[NFSD_FO_ResumeIP] = {"resume_ip",
> +					&transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
>  		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
> --- linux-1/fs/lockd/svcsubs.c	2008-01-22 10:36:24.000000000 -0500
> +++ linux-2/fs/lockd/svcsubs.c	2008-01-22 11:45:44.000000000 -0500
> @@ -422,3 +422,12 @@ nlmsvc_failover_ip(__be32 server_addr)
>  			nlmsvc_failover_file_ok_ip);
>  }
>  EXPORT_SYMBOL_GPL(nlmsvc_failover_ip);
> +
> +int
> +nlmsvc_failover_setgrace(void *server_ip, int ip_size)
> +{
> +	/* implemented by resume_002.patch */
> +	return ENOSYS;

OK, terrifically trivial nit, but: that should be -ENOSYS?

--b.

> +}
> +EXPORT_SYMBOL_GPL(nlmsvc_failover_setgrace);
> +
> --- linux-1/include/linux/lockd/lockd.h	2008-01-22 10:36:24.000000000 -0500
> +++ linux-2/include/linux/lockd/lockd.h	2008-01-22 11:45:44.000000000 -0500
> @@ -220,6 +220,7 @@ void		  nlmsvc_invalidate_all(void);
>   */
>  int           nlmsvc_failover_path(struct nameidata *nd);
>  int           nlmsvc_failover_ip(__be32 server_addr);
> +int           nlmsvc_failover_setgrace(void *server_ip, int ip_size);
>  
>  static __inline__ struct inode *
>  nlmsvc_file_inode(struct nlm_file *file)

