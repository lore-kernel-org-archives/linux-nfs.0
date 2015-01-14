Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58454 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752406AbbANN7U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2015 08:59:20 -0500
Date: Wed, 14 Jan 2015 14:59:14 +0100
From: Jan Kara <jack@suse.cz>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>,
        Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org
Subject: Re: [PATCH 11/12] fs: don't reassign dirty inodes to
 default_backing_dev_info
Message-ID: <20150114135914.GL10215@quack.suse.cz>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-12-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421228561-16857-12-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 14-01-15 10:42:40, Christoph Hellwig wrote:
> If we have dirty inodes we need to call the filesystem for it, even if the
> device has been removed and the filesystem will error out early.  The
> current code does that by reassining all dirty inodes to the default
> backing_dev_info when a bdi is unlinked, but that's pretty pointless given
> that the bdi must always outlive the super block.
> 
> Instead of stopping writeback at unregister time and moving inodes to the
> default bdi just keep the current bdi alive until it is destroyed.  The
> containing objects of the bdi ensure this doesn't happen until all
> writeback has finished by erroring out.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Tejun Heo <tj@kernel.org>
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

One nit below:


> ---
>  mm/backing-dev.c | 91 +++++++++++++++-----------------------------------------
>  1 file changed, 24 insertions(+), 67 deletions(-)
> 
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 52e0c76..3ebba25 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
...
> @@ -471,37 +445,20 @@ void bdi_destroy(struct backing_dev_info *bdi)
>  {
>  	int i;
>  
> -	/*
> -	 * Splice our entries to the default_backing_dev_info.  This
> -	 * condition shouldn't happen.  @wb must be empty at this point and
> -	 * dirty inodes on it might cause other issues.  This workaround is
> -	 * added by ce5f8e779519 ("writeback: splice dirty inode entries to
> -	 * default bdi on bdi_destroy()") without root-causing the issue.
> -	 *
> -	 * http://lkml.kernel.org/g/1253038617-30204-11-git-send-email-jens.axboe@oracle.com
> -	 * http://thread.gmane.org/gmane.linux.file-systems/35341/focus=35350
> -	 *
> -	 * We should probably add WARN_ON() to find out whether it still
> -	 * happens and track it down if so.
> -	 */
> -	if (bdi_has_dirty_io(bdi)) {
> -		struct bdi_writeback *dst = &default_backing_dev_info.wb;
> -
> -		bdi_lock_two(&bdi->wb, dst);
> -		list_splice(&bdi->wb.b_dirty, &dst->b_dirty);
> -		list_splice(&bdi->wb.b_io, &dst->b_io);
> -		list_splice(&bdi->wb.b_more_io, &dst->b_more_io);
> -		spin_unlock(&bdi->wb.list_lock);
> -		spin_unlock(&dst->list_lock);
> -	}
> -
> -	bdi_unregister(bdi);
> +	bdi_wb_shutdown(bdi);
>  
> +	WARN_ON(!list_empty(&bdi->work_list));
> +	WARN_ON(delayed_work_pending(&bdi->wb.dwork));
>  	WARN_ON(delayed_work_pending(&bdi->wb.dwork));
  You have the warning twice here...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
