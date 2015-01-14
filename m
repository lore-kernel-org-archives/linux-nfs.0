Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57974 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404AbbANNoy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Jan 2015 08:44:54 -0500
Date: Wed, 14 Jan 2015 14:44:48 +0100
From: Jan Kara <jack@suse.cz>
To: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@fb.com>, David Howells <dhowells@redhat.com>,
        Tejun Heo <tj@kernel.org>, linux-fsdevel@vger.kernel.org,
        linux-mm@kvack.org, linux-mtd@lists.infradead.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org
Subject: Re: [PATCH 09/12] ceph: remove call to bdi_unregister
Message-ID: <20150114134448.GJ10215@quack.suse.cz>
References: <1421228561-16857-1-git-send-email-hch@lst.de>
 <1421228561-16857-10-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1421228561-16857-10-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed 14-01-15 10:42:38, Christoph Hellwig wrote:
> bdi_destroy already does all the work, and if we delay freeing the
> anon bdev we can get away with just that single call.
  Looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/ceph/super.c | 18 ++++++------------
>  1 file changed, 6 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/ceph/super.c b/fs/ceph/super.c
> index 50f06cd..e350cc1 100644
> --- a/fs/ceph/super.c
> +++ b/fs/ceph/super.c
> @@ -40,17 +40,6 @@ static void ceph_put_super(struct super_block *s)
>  
>  	dout("put_super\n");
>  	ceph_mdsc_close_sessions(fsc->mdsc);
> -
> -	/*
> -	 * ensure we release the bdi before put_anon_super releases
> -	 * the device name.
> -	 */
> -	if (s->s_bdi == &fsc->backing_dev_info) {
> -		bdi_unregister(&fsc->backing_dev_info);
> -		s->s_bdi = NULL;
> -	}
> -
> -	return;
>  }
>  
>  static int ceph_statfs(struct dentry *dentry, struct kstatfs *buf)
> @@ -1002,11 +991,16 @@ out_final:
>  static void ceph_kill_sb(struct super_block *s)
>  {
>  	struct ceph_fs_client *fsc = ceph_sb_to_client(s);
> +	dev_t dev = s->s_dev;
> +
>  	dout("kill_sb %p\n", s);
> +
>  	ceph_mdsc_pre_umount(fsc->mdsc);
> -	kill_anon_super(s);    /* will call put_super after sb is r/o */
> +	generic_shutdown_super(s);
>  	ceph_mdsc_destroy(fsc);
> +
>  	destroy_fs_client(fsc);
> +	free_anon_bdev(dev);
>  }
>  
>  static struct file_system_type ceph_fs_type = {
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
