Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58676 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752961AbaHXQGf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 12:06:35 -0400
Date: Sun, 24 Aug 2014 09:06:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org, hch@infradead.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/10] locks: move i_lock acquisition into
 generic_*_lease handlers
Message-ID: <20140824160634.GG15908@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-9-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408804878-1331-9-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

Some comments on further work I'd like to see in this area, though:

> +	spin_lock(&inode->i_lock);
> +	time_out_leases(inode);
>  	for (before = &inode->i_flock;
>  			((fl = *before) != NULL) && IS_LEASE(fl);
>  			before = &fl->fl_next) {
>  		if (fl->fl_file != filp)
>  			continue;
> -		return fl->fl_lmops->lm_change(before, F_UNLCK);
> +		error = fl->fl_lmops->lm_change(before, F_UNLCK);
>  	}

We really should split a lm_release from lm_change, the way it is
used is highly confusing.  In addition I think a lot of code
currently in lease_modify should move here instead, e.g. something like:


	if (fl->fl_file != filp)
		continue;

	fl = *before;
	fl->fl_type = F_UNLCK;
	lease_clear_pending(fl, F_UNLCK);
	locks_wake_up_blocks(fl);
	if (fl->fl_lmops->lm_delete)
		fl->fl_lmops->lm_delete(fl);
	locks_delete_lock(before, NULL);

with lm_delete for user space leases as:

static void lease_delete(struct file_lock *fl)
{
	struct file *filp = fl->fl_file;

	f_delown(filp);
	filp->f_owner.signum = 0;
	fasync_helper(0, fl->fl_file, 0, &fl->fl_fasync);
	if (fl->fl_fasync != NULL) {
		printk(KERN_ERR "locks_delete_lock: fasync == %p\n",
				fl->fl_fasync);
		fl->fl_fasync = NULL;
	}
}

and a NULL implementation for delegations.
