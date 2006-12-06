From: David Teigland <teigland@redhat.com>
Subject: Re: [PATCH 10/10] gfs2: nfs lock support for gfs2
Date: Wed, 6 Dec 2006 09:49:51 -0600
Message-ID: <20061206154951.GB16378@redhat.com>
References: <8eb625184e6025f7f3d081dfe0a805abdd62a068.1165380892.git.bfields@citi.umich.edu> <70549752c06e54117024429649fd7aa813f21bec.1165380893.git.bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, me <bfields@umich.edu>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <70549752c06e54117024429649fd7aa813f21bec.1165380893.git.bfields@citi.umich.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Dec 06, 2006 at 12:34:20AM -0500, J. Bruce Fields wrote:
> +int gdlm_plock_callback(struct plock_op *op)
> +{
> +	struct file *file;
> +	struct file_lock *fl;
> +	int rv;
> +
> +	spin_lock(&ops_lock);
> +	if (!list_empty(&op->list)) {
> +		printk(KERN_INFO "plock op on list\n");
> +		list_del(&op->list);
> +	}
> +	spin_unlock(&ops_lock);
> +
> +	rv = op->info.rv;
> +
> +	if (!rv) {
> +		/* check if the following are still valid or make a copy */
> +		file = op->info.file;
> +		fl = op->info.fl;
> +		
> +		if (posix_lock_file_wait(file, fl) < 0)
> +			log_error("gdlm_plock: vfs lock error file %p fl %p",
> +				  file, fl);
> +	}
> +
> +	kfree(op);
> +	return rv;
> +}

..

> +	if (found) {
> +		if (op->info.callback)
> +			gdlm_plock_callback(op);
> +		else
> +			wake_up(&recv_wq);
> +	}

The gfs side looks fine to me.  Did you forget to call fl_notify from
gdlm_plock_callback() or am I missing something?

Dave

