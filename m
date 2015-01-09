Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f41.google.com ([209.85.192.41]:59317 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757688AbbAIOr7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2015 09:47:59 -0500
Received: by mail-qg0-f41.google.com with SMTP id e89so8937124qgf.0
        for <linux-nfs@vger.kernel.org>; Fri, 09 Jan 2015 06:47:58 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 9 Jan 2015 06:47:55 -0800
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org
Subject: Re: [PATCH v2 04/10] locks: move flock locks to file_lock_context
Message-ID: <20150109064755.1c88bd4d@synchrony.poochiereds.net>
In-Reply-To: <20150109143155.GB30294@infradead.org>
References: <1420742065-28423-1-git-send-email-jlayton@primarydata.com>
	<1420742065-28423-5-git-send-email-jlayton@primarydata.com>
	<20150109143155.GB30294@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 9 Jan 2015 06:31:55 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> >  void ceph_count_locks(struct inode *inode, int *fcntl_count, int *flock_count)
> >  {
> >  	struct file_lock *lock;
> > +	struct file_lock_context *ctx;
> >  
> >  	*fcntl_count = 0;
> >  	*flock_count = 0;
> >  
> > +	spin_lock(&inode->i_lock);
> 
> Seems like moving the locking around is unrelated to this patch.
> 

Yeah that could be split out into a separate cleanup patch first. I'll
do that on the next iteration.

> > +	list_for_each_entry(fl, &flctx->flc_flock, fl_list) {
> > +		if (nfs_file_open_context(fl->fl_file)->state != state)
> > +			continue;
> > +		spin_unlock(&inode->i_lock);
> > +		status = ops->recover_lock(state, fl);
> > +		switch (status) {
> > +			case 0:
> > +				break;
> > +			case -ESTALE:
> > +			case -NFS4ERR_ADMIN_REVOKED:
> > +			case -NFS4ERR_STALE_STATEID:
> > +			case -NFS4ERR_BAD_STATEID:
> > +			case -NFS4ERR_EXPIRED:
> > +			case -NFS4ERR_NO_GRACE:
> > +			case -NFS4ERR_STALE_CLIENTID:
> > +			case -NFS4ERR_BADSESSION:
> > +			case -NFS4ERR_BADSLOT:
> > +			case -NFS4ERR_BAD_HIGH_SLOT:
> > +			case -NFS4ERR_CONN_NOT_BOUND_TO_SESSION:
> > +				goto out;
> > +			default:
> > +				printk(KERN_ERR "NFS: %s: unhandled error %d\n",
> > +					 __func__, status);
> > +			case -ENOMEM:
> > +			case -NFS4ERR_DENIED:
> > +			case -NFS4ERR_RECLAIM_BAD:
> > +			case -NFS4ERR_RECLAIM_CONFLICT:
> > +				/* kill_proc(fl->fl_pid, SIGLOST, 1); */
> > +				status = 0;
> > +		}
> 
> Instead of duplicating this huge body of code it seems like a good idea
> to add a preparatory patch to factor it out into a helper function.
> 

Sigh, I tried to do that first but the result was just too ugly. The
above logic is too deeply entwined into this function for that to work
well. I'm not usually a fan of cut and paste, but in this case I think
it's the best way to do this. The good news is that the duplication
goes away with the next patch in the series.

> > +static bool
> > +is_whole_file_wrlock(struct file_lock *fl)
> > +{
> > +	return fl->fl_start == 0 && fl->fl_end == OFFSET_MAX && fl->fl_type == F_WRLCK;
> > +}
> 
> Please break this into multiple lines to stay under 80 characters.

Will do. I've probably violated that rule several times in this series
-- mea culpa. I'll clean that up for the next iteration.

-- 
Jeff Layton <jlayton@primarydata.com>
