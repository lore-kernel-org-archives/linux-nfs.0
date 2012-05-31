Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059Ab2EaHvq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 03:51:46 -0400
Subject: Re: [PATCH 1/6] gfs2: Get rid of I_MUTEX_QUOTA usage
From: Steven Whitehouse <swhiteho@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>
In-Reply-To: <1338429016-20119-2-git-send-email-bfields@redhat.com>
References: <1338429016-20119-1-git-send-email-bfields@redhat.com>
	 <1338429016-20119-2-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 31 May 2012 08:50:38 +0100
Message-ID: <1338450638.2714.0.camel@menhir>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Acked-by: Steven Whitehouse <swhiteho@redhat.com>

Eventually we should be able to drop i_mutex from here entirely, but
that proved more problematic that I'd expected, so this is a good
interim fix,

Steve.

On Wed, 2012-05-30 at 21:50 -0400, J. Bruce Fields wrote:
> From: Jan Kara <jack@suse.cz>
> 
> GFS2 uses i_mutex on its system quota inode to synchronize writes to
> quota file. Since this is an internal inode to GFS2 (not part of directory
> hiearchy or visible by user) we are safe to define locking rules for it. So
> let's just get it its own locking class to make it clear.
> 
> CC: Steven Whitehouse <swhiteho@redhat.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/gfs2/ops_fstype.c |    8 ++++++++
>  fs/gfs2/quota.c      |    2 +-
>  2 files changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/gfs2/ops_fstype.c b/fs/gfs2/ops_fstype.c
> index b8c250f..c714ef7 100644
> --- a/fs/gfs2/ops_fstype.c
> +++ b/fs/gfs2/ops_fstype.c
> @@ -19,6 +19,7 @@
>  #include <linux/mount.h>
>  #include <linux/gfs2_ondisk.h>
>  #include <linux/quotaops.h>
> +#include <linux/lockdep.h>
>  
>  #include "gfs2.h"
>  #include "incore.h"
> @@ -766,6 +767,7 @@ fail:
>  	return error;
>  }
>  
> +static struct lock_class_key gfs2_quota_imutex_key;
>  
>  static int init_inodes(struct gfs2_sbd *sdp, int undo)
>  {
> @@ -803,6 +805,12 @@ static int init_inodes(struct gfs2_sbd *sdp, int undo)
>  		fs_err(sdp, "can't get quota file inode: %d\n", error);
>  		goto fail_rindex;
>  	}
> +	/*
> +	 * i_mutex on quota files is special. Since this inode is hidden system
> +	 * file, we are safe to define locking ourselves.
> +	 */
> +	lockdep_set_class(&sdp->sd_quota_inode->i_mutex,
> +			  &gfs2_quota_imutex_key);
>  
>  	error = gfs2_rindex_update(sdp);
>  	if (error)
> diff --git a/fs/gfs2/quota.c b/fs/gfs2/quota.c
> index b97178e..8ed70e7 100644
> --- a/fs/gfs2/quota.c
> +++ b/fs/gfs2/quota.c
> @@ -772,7 +772,7 @@ static int do_sync(unsigned int num_qd, struct gfs2_quota_data **qda)
>  		return -ENOMEM;
>  
>  	sort(qda, num_qd, sizeof(struct gfs2_quota_data *), sort_qd, NULL);
> -	mutex_lock_nested(&ip->i_inode.i_mutex, I_MUTEX_QUOTA);
> +	mutex_lock(&ip->i_inode.i_mutex);
>  	for (qx = 0; qx < num_qd; qx++) {
>  		error = gfs2_glock_nq_init(qda[qx]->qd_gl, LM_ST_EXCLUSIVE,
>  					   GL_NOCACHE, &ghs[qx]);


