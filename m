From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/11] nfsd: ADD data structure infrastructure
Date: Tue, 21 Apr 2009 18:48:38 -0400
Message-ID: <20090421224838.GH27411@fieldses.org>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090325133628.16437.11092.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar <krkumar2@in.ibm.com>, jlayton@redhat.com,
	linux-nfs@vger.kernel.org
To: Krishna Kumar <krikku@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:50792 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbZDUWst (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 18:48:49 -0400
In-Reply-To: <20090325133628.16437.11092.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2009 at 07:06:28PM +0530, Krishna Kumar wrote:
> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> ADD infrastructure in terms of new structures.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
> 
>  fs/nfsd/vfs.c |   35 +++++++++++++++++++++++++++++++++++
>  1 file changed, 35 insertions(+)
> 
> diff -ruNp org/fs/nfsd/vfs.c new1/fs/nfsd/vfs.c
> --- org/fs/nfsd/vfs.c	2009-03-25 17:31:39.000000000 +0530
> +++ new1/fs/nfsd/vfs.c	2009-03-25 17:39:43.000000000 +0530
> @@ -88,6 +88,41 @@ struct raparm_hbucket {
>  #define RAPARM_HASH_MASK	(RAPARM_HASH_SIZE-1)
>  static struct raparm_hbucket	raparm_hash[RAPARM_HASH_SIZE];
>  
> +/*
> + * This is a cache of file handles to quicken file lookup. This also
> + * helps prevent multiple open/close of a file when a client reads it.
> + *
> + * If you increase the number of cached files very much, you'll need to
> + * add a hash table here.

I'm a little confused here--what do you mean by "add a hash table here"?

--b.

> + */
> +struct fhcache {
> +	struct fhcache		*p_next;
> +
> +	/* Hashed on this parameter */
> +	__u32			p_auth;
> +
> +	/* Cached information */
> +	struct file		*p_filp;
> +	struct svc_export	*p_exp;
> +
> +	/* Refcount for overwrite */
> +	atomic_t		p_count;
> +
> +	/* When this entry expires */
> +	unsigned long		p_expires;
> +
> +	unsigned int		p_hindex;
> +};
> +
> +struct fhcache_hbucket {
> +	struct fhcache		*pb_head;
> +	spinlock_t		pb_lock;
> +} ____cacheline_aligned_in_smp;
> +
> +#define FHPARM_HASH_BITS	8
> +#define FHPARM_HASH_SIZE	(1<<FHPARM_HASH_BITS)
> +#define FHPARM_HASH_MASK	(FHPARM_HASH_SIZE-1)
> +
>  /* 
>   * Called from nfsd_lookup and encode_dirent. Check if we have crossed 
>   * a mount point.
