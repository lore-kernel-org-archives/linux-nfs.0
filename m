Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44933 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754188AbbFRQQ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jun 2015 12:16:58 -0400
Date: Thu, 18 Jun 2015 12:16:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Martin <martin@uni-mainz.de>
Cc: Andy Adamson <andros@netapp.com>, Markus Tacke <tacke@uni-mainz.de>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] make nfsd_drc_max_mem configurable
Message-ID: <20150618161657.GC10305@fieldses.org>
References: <55816C84.1080608@uni-mainz.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55816C84.1080608@uni-mainz.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 17, 2015 at 02:48:04PM +0200, Christoph Martin wrote:
> Dear Andy, dear Bruce,
> 
> (sorry for the recent to you, I now cc'd linux-nfs)
> 
> I have attached a patch to nfssvc.diff to make the size of the drc nfsd
> cache configurable.
> 
> In the last month we were stumbling twice over the problem that the
> NFS4.1 session cache was to small.

Thanks for the careful investigation!

> The first time we wanted to setup a NFS Server for our HPC cluster. We
> were wondering why we were only able to mount the filesystem on 380 of
> our ~700 nodes. It took us a long time to find out that it was the limit
> of the NFS4.1 session cache. Since this machine had 12G Ram, the kernel
> reserved 12M for the cache, which results in 384 slots a 32k:
> 
> echo $(((12582912>>10)/32))
> 384

So each client is using 32k?

Might be interesting to take a look at the CREATE_SESSION call and reply
in wireshark (especially the values of maxresponsesize_cached and
maxrequests)--there might also be defaults there that need tweaking.

> We patched the kernel redhat 7 kernel to change NFSD_DRC_SIZE_SHIFT to
> from 10 to 7 to fix this problem.
> 
> The second time we installed a small Debian VM with 1G ram to act as a
> NFS4 referral server for the home and group directories on our campus.
> Since the server does only NFS referrals it does not really need more
> memory than the 1G. But it could only server about 30 clients with this
> limitation of the session cache.
> 
> I think it would be a good idea to have the amount of memory
> configurable in nfsd. So I wrote this small patch to make drc_size
> configurable while loading the kernel nfsd module.
> 
> The patch uses the old value computed from NFSD_DRC_SIZE_SHIFT as the
> lower limit. If drc_size as a parameter for then nfsd is higher than a
> 1/1000 of the RAM, this value will be used.
> 
> One might consider to make NFSD_DRC_SIZE_SHIFT even higher to use less
> memory for situations where it is not needed. I did not implement an
> upper limit, but it might be important.
> 
> Please consider to include this patch into the nfsd code.

Looks good, my one concern is that this covers only the size of the 4.1
session cache.  We may need to add some more limits in the future and
might not want to require separate configuration of each limit.

Maybe one or two more generic size parameters would be more useful?
Like:

	- Maximum memory to devote to knfsd
	- Maximum memory to devote to a single client

--b.



> 
> Yours
> Christoph Martin
> 
> --- linux-source-3.16/fs/nfsd/nfssvc.c	2015-03-30 12:09:09.000000000 +0200
> +++ linux-source-3.16.nfsd/fs/nfsd/nfssvc.c	2015-06-17
> 09:28:37.880443867 +0200
> @@ -359,11 +359,19 @@ void nfsd_reset_versions(void)
>   * For now this is a #defined shift which could be under admin control
>   * in the future.
>   */
> +
> +static ulong drc_size = 0;
> +module_param(drc_size, ulong, 0444);
> +MODULE_PARM_DESC(drc_size,
> +		 "size of NFSv4.1 DRC cache memory (default and minimum:
> free_buffer_size >> 10)");
> +
>  static void set_max_drc(void)
>  {
>  	#define NFSD_DRC_SIZE_SHIFT	10
> -	nfsd_drc_max_mem = (nr_free_buffer_pages()
> -					>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE;
> +	nfsd_drc_max_mem = max(drc_size,
> +			       (nr_free_buffer_pages()
> +				>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE);
> +	drc_size = nfsd_drc_max_mem;
>  	nfsd_drc_mem_used = 0;
>  	spin_lock_init(&nfsd_drc_lock);
>  	dprintk("%s nfsd_drc_max_mem %lu \n", __func__, nfsd_drc_max_mem);
> 
> 


