From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/7] nfsd: formally deprecate legacy nfsd syscall
 interface
Date: Tue, 21 Sep 2010 23:10:33 -0400
Message-ID: <20100922031033.GD22021@fieldses.org>
References: <20100922025009.31745.98237.stgit@localhost.localdomain>
 <20100922025507.31745.57024.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44173 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830Ab0IVDMB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Sep 2010 23:12:01 -0400
In-Reply-To: <20100922025507.31745.57024.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 22, 2010 at 12:55:07PM +1000, NeilBrown wrote:
> The syscall interface is has been replaced by a more flexible
> interface since 2.6.0.  It is time to work towards discarding
> the old interface.
> 
> So add a entry in feature-removal-schedule.txt and print a warning
> when the interface is used.

Thanks, yes, agreed that it's about time to do this.

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  Documentation/feature-removal-schedule.txt |   10 ++++++++++
>  fs/nfsd/nfsctl.c                           |   10 ++++++++++
>  2 files changed, 20 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
> index 842aa9d..076a2c0 100644
> --- a/Documentation/feature-removal-schedule.txt
> +++ b/Documentation/feature-removal-schedule.txt
> @@ -564,3 +564,13 @@ Who:	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
>  
>  ----------------------------
>  
> +What:   access to nfsd auth cache through sys_nfsservctl or '.' files
> +        in the 'nfsd' filesystem.
> +When:   2.6.40
> +Why:    This is a legacy interface which have been replaced by a more
> +        dynamic cache.  Continuing to maintain this interface is an
> +        unnecessary burden.
> +Who:    NeilBrown <neilb@suse.de>
> +
> +----------------------------
> +	
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index b53b1d0..7f0fc88 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -121,6 +121,16 @@ static ssize_t nfsctl_transaction_write(struct file *file, const char __user *bu
>  
>  static ssize_t nfsctl_transaction_read(struct file *file, char __user *buf, size_t size, loff_t *pos)
>  {
> +	static int warned;
> +	if (file->f_dentry->d_name.name[0] == '.' && !warned) {
> +		char name[sizeof(current->comm)];
> +		printk(KERN_INFO
> +		       "Warning: \"%s\" uses deprecated NFSD interface: %s."
> +		       "  This will be removed in 2.6.40\n",
> +		       get_task_comm(name, current),
> +		       file->f_dentry->d_name.name);
> +		warned = 1;
> +	}
>  	if (! file->private_data) {
>  		/* An attempt to read a transaction file without writing
>  		 * causes a 0-byte write so that the file can return
> 
> 
